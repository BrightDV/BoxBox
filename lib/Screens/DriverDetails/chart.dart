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
  final List<ChartData> _chartData = <ChartData>[];
  TrackballBehavior? _trackballBehavior;

  @override
  void initState() {
    _trackballBehavior = TrackballBehavior(
        enable: true, activationMode: ActivationMode.singleTap);

    widget.comparison.resultMap.forEach((year, YearData values) {
      values.teamMates.forEach((teamMate, values) {
        _chartData.add(
            ChartData('$teamMate $year', values.points, values.pointsTeamMate));
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) => /*const Placeholder();*/
      Expanded(
          child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        title: ChartTitle(text: 'most points'),
        legend:
            Legend(isVisible: false, overflowMode: LegendItemOverflowMode.wrap),
        primaryXAxis: CategoryAxis(
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            interval: 1,
            labelRotation: -90,
            majorGridLines: const MajorGridLines(width: 0)),
        primaryYAxis: NumericAxis(
            // labelFormat: '{value}%',
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(color: Colors.transparent)),
        series: <StackedLineSeries<ChartData, String>>[
          StackedLineSeries<ChartData, String>(
              animationDuration: 2500,
              dataSource: _chartData,
              xValueMapper: (ChartData data, _) => data.teamMate,
              yValueMapper: (ChartData data, _) => data.driverValue,
              width: 2,
              name: 'Max Verstappen',
              markerSettings: const MarkerSettings(isVisible: true)),
          StackedLineSeries<ChartData, String>(
              animationDuration: 2500,
              dataSource: _chartData,
              width: 2,
              name: 'Team mate',
              xValueMapper: (ChartData data, _) => data.teamMate,
              yValueMapper: (ChartData data, _) => data.teamMateValue,
              markerSettings: const MarkerSettings(isVisible: true))
        ],
        tooltipBehavior: TooltipBehavior(enable: true),
        trackballBehavior: _trackballBehavior,
      ));

  @override
  void dispose() {
    _chartData.clear();
    super.dispose();
  }
}

class ChartData {
  final String teamMate;
  final num driverValue;
  final num teamMateValue;

  ChartData(this.teamMate, this.driverValue, this.teamMateValue);
}
