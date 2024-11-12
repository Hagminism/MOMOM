import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  int selectedIndex = 0;
  int tabIndex = 0;

  final List<double> barValues = [15, 35, 30, 28, 11, 29, 28]; // 막대 차트 데이터 값

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '10월 소비·수입',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30, // 폰트 크기를 조절할 수 있습니다
            ),
          ),
        ),
        centerTitle: false,
      ),

      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '지난달보다 자산이 5만원 줄었어요ㅠㅠ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500), // 폰트 크기를 키우고 약간의 굵기를 추가
            ),

            SizedBox(height: 20),
            // 라인 차트
            Container(
              height: 200,
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
                        switch (value.toInt()) {
                          case 4:
                            return '4월';
                          case 5:
                            return '5월';
                          case 6:
                            return '6월';
                          case 7:
                            return '7월';
                          case 8:
                            return '8월';
                          case 9:
                            return '9월';
                          case 10:
                            return '10월';
                          default:
                            return '';
                        }
                      },
                      reservedSize: 28,
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(4, 15),
                        FlSpot(5, 35),
                        FlSpot(6, 30),
                        FlSpot(7, 28),
                        FlSpot(8, 11),
                        FlSpot(9, 29),
                        FlSpot(10, 28),
                      ],
                      isCurved: true,
                      colors: [Colors.red],
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40), // 두 그래프 사이에 여백 추가
            // 막대 차트
            Spacer(),
            Container(
              height: 300, // 막대 차트의 높이를 더 크게 설정
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
                        switch (value.toInt()) {
                          case 4:
                            return '4월';
                          case 5:
                            return '5월';
                          case 6:
                            return '6월';
                          case 7:
                            return '7월';
                          case 8:
                            return '8월';
                          case 9:
                            return '9월';
                          case 10:
                            return '10월';
                          default:
                            return '';
                        }
                      },
                      reservedSize: 28,
                    ),
                  ),
                  barGroups: barValues
                      .asMap()
                      .entries
                      .map((entry) => BarChartGroupData(
                    x: entry.key + 4,
                    barRods: [
                      BarChartRodData(
                        y: entry.value,
                        colors: [Colors.lightBlue],
                        width: 20,
                        borderRadius: BorderRadius.zero, // 막대를 네모난 형태로 설정
                      ),
                    ],
                  ))
                      .toList(),
                ),
              ),
            ),
            Spacer(flex: 2), // 막대 차트 아래에 더 많은 여백 추가
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
        ],
      ),
    );
  }
}
