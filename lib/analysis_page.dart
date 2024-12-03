import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '소비 분석',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            FutureBuilder<List<double>>(
              future: Future.wait([
                _dataService.getMonthlyBudget(), // 예산 가져오기
                _dataService.getTotalSpentThisMonth(), // 이번 달 사용 금액 가져오기
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // 로딩 표시
                }
                if (snapshot.hasError) {
                  return const Text('데이터 없음'); // 에러 처리
                }

                final budget = snapshot.data?[0] ?? 1; // 예산 (0 방지)
                final spent = snapshot.data?[1] ?? 0; // 사용 금액
                final percentage = (spent / budget * 100).clamp(0, 100); // 퍼센트 계산

                return Text(
                  '이번달엔 설정한 예산의 ${percentage.toStringAsFixed(1)}%를 사용하셨어요!',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ],
        ),
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
              foregroundColor: isSelected ? Colors.white : Colors.black87,
              backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
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
  }

  Future<double> getMonthlyBudget() async {
    try {
      // 'users' 컬렉션에서 email 필드로 문서 가져오기
      final snapshot = await _firestore.collection('users').where('email', isEqualTo: userId).get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final budget = (data['monthly_budget'] as num?)?.toDouble() ?? 0.0;
        debugPrint('Monthly budget: $budget');
        return budget;
      } else {
        return 0.0;
      }
    } catch (e) {
      debugPrint('Error fetching monthly budget: $e');
      return 0.0;
    }
  }

  Future<void> fetchFirestoreData() async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('isDeposit', isEqualTo: false)
          .get();

      final Map<int, double> monthlyTotals = {};
      final Map<int, double> weeklyTotals = {};
      final Map<int, double> dailyTotals = {};

      final now = DateTime.now();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final price = (data['price'] as num).toDouble();

        final monthDiff = (now.year - date.year) * 12 + (now.month - date.month);
        if (monthDiff <= 6) {
          final monthIndex = 6 - monthDiff;
          monthlyTotals[monthIndex] = (monthlyTotals[monthIndex] ?? 0) + price;
        }

        if (date.month == now.month && date.year == now.year) {
          final weekOfMonth = ((date.day - 1) ~/ 7);
          weeklyTotals[weekOfMonth] = (weeklyTotals[weekOfMonth] ?? 0) + price;

          final dayIndex = date.weekday - 1;
          dailyTotals[dayIndex] = (dailyTotals[dayIndex] ?? 0) + price;
        }
      }

      chartData.updateData(monthlyTotals, weeklyTotals, dailyTotals);
    } catch (e) {
      rethrow;
    }
  }

  Future<double> getTotalSpentThisMonth() async {
    final now = DateTime.now();
    double totalSpent = 0.0;

    try {
      // 'transactions' 컬렉션에서 userId 기준으로 데이터 가져오기
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('isDeposit', isEqualTo: false) // 지출 항목만 가져오기
          .get();

      // 현재 연도와 월에 해당하는 지출 금액 합산
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final price = (data['price'] as num).toDouble();

        if (date.year == now.year && date.month == now.month) {
          totalSpent += price;
        }
      }
      debugPrint('Total spent this month: $totalSpent');
      return totalSpent;
    } catch (e) {
      debugPrint('Error fetching total spent this month: $e');
      return 0.0;
    }
  }
}

class ChartDataModel {
  List<List<double>> data = [];
  List<List<String>> labels = [];

  static const int MONTH_COUNT = 7;
  static const int WEEK_COUNT = 5;
  static const int DAY_COUNT = 7;

  ChartDataModel() {
    initializeLabels();
    _initializeData();
  }

  void _initializeData() {
    data = [
      List.filled(MONTH_COUNT, 0),
      List.filled(WEEK_COUNT, 0),
      List.filled(DAY_COUNT, 0),
    ];
  }

  void initializeLabels() {
    final now = DateTime.now();

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
      padding: const EdgeInsets.only(left: 0.0, right: 19.0, top: 8.0, bottom: 8.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        width: MediaQuery.of(context).size.width * 0.9,
        child: chartType == ChartType.line
            ? _buildLineChart(maxY)
            : _buildBarChart(maxY),
      ),
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
            isCurved: false,
            colors: const [Colors.red],
            barWidth: 4,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              colors: [Colors.red.withOpacity(0.3)],
            ),
          ),
        ],
        titlesData: _buildTitlesData(maxY),
        gridData: _buildGridData(maxY),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            top: BorderSide(color: Colors.black),
            bottom: BorderSide(color: Colors.black),
            left: BorderSide(color: Colors.black),
            right: BorderSide(color: Colors.black),
          ),
        ),
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
        borderData: FlBorderData(
          show: true,
          border: const Border(
            top: BorderSide(color: Colors.black),
            bottom: BorderSide(color: Colors.black),
            left: BorderSide(color: Colors.black),
            right: BorderSide(color: Colors.black),
          ),
        ),
      ),
    );
  }

  FlTitlesData _buildTitlesData(double maxY) {
    final labels = chartData.labels[tabIndex];

    return FlTitlesData(
      leftTitles: SideTitles(
        showTitles: true,
        getTitles: (value) => '${value ~/ 10000}만원',
        reservedSize: 48,
        interval: 50000,
      ),
      bottomTitles: SideTitles(
        showTitles: true,
        getTitles: (value) => labels[value.toInt()],
        reservedSize: 32,
      ),
    );
  }

  FlGridData _buildGridData(double maxY) {
    return FlGridData(
      show: true,
      horizontalInterval: 50000,
    );
  }
}
