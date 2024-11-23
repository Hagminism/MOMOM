import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnalysisPage extends StatefulWidget {
  final String userId;

  const AnalysisPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  late final DataService _dataService;
  late ChartDataModel _chartData;
  int _tabIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dataService = DataService(userId: widget.userId);
    _chartData = ChartDataModel();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      await _dataService.fetchFirestoreData();
      setState(() {
        _chartData = _dataService.chartData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터를 불러오는데 실패했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('소비 분석',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: Column(
          children: [
            Expanded(
              child: ChartWidget(
                chartData: _chartData,
                tabIndex: _tabIndex,
                chartType: ChartType.line,
              ),
            ),
            Expanded(
              child: ChartWidget(
                chartData: _chartData,
                tabIndex: _tabIndex,
                chartType: ChartType.bar,
              ),
            ),
            _buildTabButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['월별', '주별', '일별'].asMap().entries.map((entry) {
          final isSelected = _tabIndex == entry.key;
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: isSelected ? Colors.white : Colors.black87, backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => setState(() => _tabIndex = entry.key),
            child: Text(entry.value),
          );
        }).toList(),
      ),
    );
  }
}

class DataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late ChartDataModel chartData;
  final String userId;

  DataService({required this.userId}) {
    chartData = ChartDataModel();
    print('DataService initialized for user: $userId');
  }

  Future<void> fetchFirestoreData() async {
    try {
      // 기본 쿼리
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();

      print('Retrieved ${snapshot.docs.length} transactions');

      if (snapshot.docs.isEmpty) {
        print('No transactions found for user: $userId');
        return;
      }

      // 데이터 처리를 위한 맵 초기화
      final Map<int, double> monthlyTotals = {};
      final Map<int, double> weeklyTotals = {};
      final Map<int, double> dailyTotals = {};

      final now = DateTime.now();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final price = (data['price'] as num).toDouble(); // price 필드 가져오기

        // 월별 데이터 처리
        final monthDiff = (now.year - date.year) * 12 + (now.month - date.month);
        if (monthDiff <= 6) {
          final monthIndex = 6 - monthDiff;
          monthlyTotals[monthIndex] = (monthlyTotals[monthIndex] ?? 0) + price;
        }

        // 이번 달 데이터만 주별/일별로 처리
        if (date.month == now.month && date.year == now.year) {
          // 주별 데이터
          final weekOfMonth = ((date.day - 1) ~/ 7);
          weeklyTotals[weekOfMonth] = (weeklyTotals[weekOfMonth] ?? 0) + price;

          // 일별 데이터
          final dayIndex = date.weekday - 1; // 월요일이 0
          dailyTotals[dayIndex] = (dailyTotals[dayIndex] ?? 0) + price;
        }
      }

      print('Data processed - Monthly totals: $monthlyTotals');
      print('Weekly totals: $weeklyTotals');
      print('Daily totals: $dailyTotals');

      chartData.updateData(monthlyTotals, weeklyTotals, dailyTotals);

    } catch (e) {
      print('Error fetching transaction data: $e');
      rethrow;
    }
  }
}

class ChartDataModel {
  List<List<double>> data = [];
  List<List<String>> labels = [];

  static const int MONTH_COUNT = 7; // 현재 달 포함 7개월
  static const int WEEK_COUNT = 5; // 한 달의 주 수
  static const int DAY_COUNT = 7; // 일주일

  ChartDataModel() {
    initializeLabels();
    _initializeData();
  }

  void _initializeData() {
    // 각 기간별 데이터 배열 초기화
    data = [
      List.filled(MONTH_COUNT, 0), // 월별
      List.filled(WEEK_COUNT, 0),  // 주별
      List.filled(DAY_COUNT, 0),   // 일별
    ];
  }

  void initializeLabels() {
    final now = DateTime.now();

    // 월 라벨 생성 (최근 6개월 + 현재 월)
    final monthLabels = List.generate(MONTH_COUNT, (i) {
      final month = (now.month - (6 - i) + 11) % 12 + 1;
      return '$month월';
    });

    labels = [
      monthLabels,
      List.generate(WEEK_COUNT, (i) => '${i + 1}주차'),
      const ['월', '화', '수', '목', '금', '토', '일'],
    ];
  }

  void updateData(Map<int, double> monthlyTotals, Map<int, double> weeklyTotals, Map<int, double> dailyTotals) {
    // 데이터 업데이트
    data[0] = List.generate(MONTH_COUNT, (i) => monthlyTotals[i] ?? 0);
    data[1] = List.generate(WEEK_COUNT, (i) => weeklyTotals[i] ?? 0);
    data[2] = List.generate(DAY_COUNT, (i) => dailyTotals[i] ?? 0);
  }
}

enum ChartType { line, bar }

class ChartWidget extends StatelessWidget {
  final ChartDataModel chartData;
  final int tabIndex;
  final ChartType chartType;

  const ChartWidget({
    Key? key,
    required this.chartData,
    required this.tabIndex,
    required this.chartType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxY = _calculateMaxY();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: chartType == ChartType.line
          ? _buildLineChart(maxY)
          : _buildBarChart(maxY),
    );
  }

  double _calculateMaxY() {
    final currentData = chartData.data[tabIndex];
    if (currentData.isEmpty) return 100000;

    double max = currentData.reduce((a, b) => a > b ? a : b);
    return max > 0 ? ((max / 100000).ceil() * 100000).toDouble() : 100000;
  }

  Widget _buildLineChart(double maxY) {
    final currentData = chartData.data[tabIndex];
    final spots = <FlSpot>[];

    final dataLength = tabIndex == 1 ? ChartDataModel.WEEK_COUNT : currentData.length;

    for (int i = 0; i < dataLength; i++) {
      spots.add(FlSpot(i.toDouble(), currentData[i]));
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.2,
            colors: const [Colors.blue],
            barWidth: 4,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              colors: [Colors.blue.withOpacity(0.3)],
            ),
          ),
        ],
        titlesData: _buildTitlesData(maxY),
        gridData: _buildGridData(maxY),
        borderData: FlBorderData(show: true),
      ),
    );
  }

  Widget _buildBarChart(double maxY) {
    final currentData = chartData.data[tabIndex];
    final barGroups = <BarChartGroupData>[];

    final dataLength = tabIndex == 1 ? ChartDataModel.WEEK_COUNT : currentData.length;

    for (int i = 0; i < dataLength; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              y: currentData[i],
              width: 12,
              colors: const [Colors.blue],
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY,
        barGroups: barGroups,
        titlesData: _buildTitlesData(maxY),
        gridData: _buildGridData(maxY),
        borderData: FlBorderData(show: true),
      ),
    );
  }

  FlTitlesData _buildTitlesData(double maxY) {
    return FlTitlesData(
      bottomTitles: SideTitles(
        showTitles: true,
        getTitles: (value) {
          final index = value.toInt();
          final labels = chartData.labels[tabIndex];
          return index < labels.length ? labels[index] : '';
        },
        margin: 10,
        reservedSize: tabIndex == 1 ? 30 : 22,
      ),
      leftTitles: SideTitles(
        showTitles: true,
        margin: 10,
        reservedSize: 60,
        interval: maxY > 0 ? maxY / 5 : 20000,
        getTitles: (value) => '${(value / 10000).toStringAsFixed(0)}만원',
      ),
    );
  }

  FlGridData _buildGridData(double maxY) {
    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      horizontalInterval: maxY > 0 ? maxY / 5 : 20000,
      getDrawingHorizontalLine: (value) => FlLine(
        color: Colors.grey.withOpacity(0.3),
        strokeWidth: 1,
      ),
    );
  }
}
