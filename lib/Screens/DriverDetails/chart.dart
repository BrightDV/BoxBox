import 'package:boxbox/scraping/f1-fansite.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DriverDetailsStatsChart extends StatefulWidget {
  final TeamMateComparison comparison;

  const DriverDetailsStatsChart(this.comparison, {super.key});

  @override
  State<DriverDetailsStatsChart> createState() =>
      _DriverDetailsStatsChartState();
}

class _DriverDetailsStatsChartState extends State<DriverDetailsStatsChart> {
  // final List<ChartData> _chartData = <ChartData>[];
  final List<ComparisonData> _chartData = <ComparisonData>[];

  @override
  void initState() {
    for (ComparisonValues element in widget.comparison.pointsComparision) {
      _chartData.add(ComparisonData(
          element.rowKey, element.driverValue, element.teamMateValue));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Expanded(
        child: SfCartesianChart(
          title: ChartTitle(text: 'Points comparison between Max verstappen and team mates'),
          enableAxisAnimation: true,
          tooltipBehavior: TooltipBehavior(enable: true),
          legend: Legend(isVisible: true),
          primaryXAxis: CategoryAxis(
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            interval: 1,
            labelRotation: -90,
            majorGridLines: const MajorGridLines(width: 0),
            axisLabelFormatter: (AxisLabelRenderDetails details) {
              return ChartAxisLabel(details.text.split(' ')[1], details.textStyle);
            }
          ),
          primaryYAxis: NumericAxis(
            labelFormat: '{value}',
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
          ),
          series: <ChartSeries>[
            LineSeries<ComparisonData, String>(
                dataSource: _chartData,
                xValueMapper: (ComparisonData sales, _) => sales.rowKey,
                yValueMapper: (ComparisonData sales, _) => sales.driverValue,
                name: 'Max Verstappen',
                width: 2,
                markerSettings: const MarkerSettings(isVisible: true)),
            LineSeries<ComparisonData, String>(
                dataSource: _chartData,
                xValueMapper: (ComparisonData sales, _) => sales.rowKey,
                yValueMapper: (ComparisonData sales, _) => sales.teamMateValue,
                name: 'Team mate',
                width: 2,
                markerSettings: const MarkerSettings(isVisible: true)),
          ],
        ),
      );

  // @override
  // Widget build(BuildContext context) => /*const Placeholder();*/
  //     Expanded(
  //         child: SfCartesianChart(
  //       plotAreaBorderWidth: 0,
  //       title: ChartTitle(text: 'most points'),
  //       legend:
  //           Legend(isVisible: false, overflowMode: LegendItemOverflowMode.wrap),
  //       primaryXAxis: CategoryAxis(
  //           edgeLabelPlacement: EdgeLabelPlacement.shift,
  //           interval: 1,
  //           labelRotation: -90,
  //           majorGridLines: const MajorGridLines(width: 0)),
  //       primaryYAxis: NumericAxis(
  //           // labelFormat: '{value}%',
  //           axisLine: const AxisLine(width: 0),
  //           majorTickLines: const MajorTickLines(color: Colors.transparent)),
  //       series: <StackedLineSeries<ChartData, String>>[
  //         StackedLineSeries<ChartData, String>(
  //             animationDuration: 2500,
  //             dataSource: _chartData,
  //             xValueMapper: (ChartData data, _) => data.teamMate,
  //             yValueMapper: (ChartData data, _) => data.driverValue,
  //             width: 2,
  //             name: 'Max Verstappen',
  //             markerSettings: const MarkerSettings(isVisible: true)),
  //         StackedLineSeries<ChartData, String>(
  //             animationDuration: 2500,
  //             dataSource: _chartData,
  //             width: 2,
  //             name: 'Team mate',
  //             xValueMapper: (ChartData data, _) => data.teamMate,
  //             yValueMapper: (ChartData data, _) => data.teamMateValue,
  //             markerSettings: const MarkerSettings(isVisible: true))
  //       ],
  //       tooltipBehavior: TooltipBehavior(enable: true),
  //       trackballBehavior: _trackballBehavior,
  //     ));
  //
  @override
  void dispose() {
    _chartData.clear();
    super.dispose();
  }
}

class ComparisonData {
  final String rowKey;
  final num driverValue;
  final num teamMateValue;

  ComparisonData(this.rowKey, this.driverValue, this.teamMateValue);
}
