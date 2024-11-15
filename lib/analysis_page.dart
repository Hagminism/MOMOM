import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  int tabIndex = 0;

  // 샘플 데이터: 월별, 주별, 일별 데이터
  final List<double> monthlyData = [15, 35, 30, 28, 11, 29, 28]; // 월별 데이터
  final List<double> weeklyData = [10, 20, 15, 25, 12]; // 주별 데이터
  final List<double> dailyData = [5, 10, 15, 20, 15, 10, 5]; // 일별 데이터

  // X축 레이블
  final List<String> monthlyLabels = ['4월', '5월', '6월', '7월', '8월', '9월', '10월'];
  final List<String> weeklyLabels = ['1주차', '2주차', '3주차', '4주차', '5주차'];
  final List<String> dailyLabels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    // 화면 크기 가져오기
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400; // 작은 화면 기준

    // 현재 데이터 및 레이블 선택
    List<double> currentData;
    List<String> currentLabels;
    if (tabIndex == 0) {
      currentData = monthlyData;
      currentLabels = monthlyLabels;
    } else if (tabIndex == 1) {
      currentData = weeklyData;
      currentLabels = weeklyLabels;
    } else {
      currentData = dailyData;
      currentLabels = dailyLabels;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '10월 소비·수입',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 24 : 30, // 화면 크기에 따라 조정
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 텍스트
            Text(
              tabIndex == 0
                  ? '지난달보다 자산이 5만원 줄었어요ㅠㅠ'
                  : tabIndex == 1
                  ? '주별 소비 분석입니다.'
                  : '일별 소비 분석입니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            // 라인 차트
            Expanded(
              flex: 2,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(showTitles: false),
                    rightTitles: SideTitles(showTitles: false),
                    topTitles: SideTitles(showTitles: false),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitles: (double value) {
                        int index = value.toInt();
                        if (index >= 0 && index < currentLabels.length) {
                          return currentLabels[index];
                        }
                        return '';
                      },
                      reservedSize: isSmallScreen ? 22 : 28,
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        currentData.length,
                            (index) => FlSpot(index.toDouble(), currentData[index]),
                      ),
                      isCurved: true,
                      colors: [Colors.red],
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            // 막대 차트
            Expanded(
              flex: 3,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(showTitles: false),
                    rightTitles: SideTitles(showTitles: false),
                    topTitles: SideTitles(showTitles: false),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitles: (double value) {
                        int index = value.toInt();
                        if (index >= 0 && index < currentLabels.length) {
                          return currentLabels[index];
                        }
                        return '';
                      },
                      reservedSize: isSmallScreen ? 22 : 28,
                    ),
                  ),
                  barGroups: List.generate(
                    currentData.length,
                        (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          y: currentData[index],
                          colors: [Colors.lightBlue],
                          width: 18,
                          borderRadius: BorderRadius.zero,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => setState(() => tabIndex = 0),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              child: Text(
                '월별',
                style: TextStyle(
                  color: tabIndex == 0 ? Colors.white : Colors.white54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => setState(() => tabIndex = 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              child: Text(
                '주별',
                style: TextStyle(
                  color: tabIndex == 1 ? Colors.white : Colors.white54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => setState(() => tabIndex = 2),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              child: Text(
                '일별',
                style: TextStyle(
                  color: tabIndex == 2 ? Colors.white : Colors.white54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
