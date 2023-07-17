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
  final List<CategoricalMultiLevelLabel> _xAxisCategories =
      <CategoricalMultiLevelLabel>[];

  @override
  void initState() {
    String? lastEndValue;

    widget.comparison.resultMap.forEach((year, YearData values) {
      values.teamMates.forEach((teamMate, values) {
        _chartData.add(
            ChartData('$year-$teamMate', values.points, values.pointsTeamMate));
      });

      String start = '$year-${values.teamMates.keys.first}';
      String end = '$year-${values.teamMates.keys.last}';

      if (start == end && lastEndValue != null) {
        start = lastEndValue!;
      }

      _xAxisCategories.add(CategoricalMultiLevelLabel(
          start: start,
          end: end,
          text: year.toString()));

      lastEndValue = end;
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
        // primaryXAxis: CategoryAxis(
        //     interval: 1,
        //     labelRotation: -90,
        //     edgeLabelPlacement: EdgeLabelPlacement.shift,
        //     majorGridLines: const MajorGridLines(width: 0)),
        primaryXAxis: CategoryAxis(
            interval: 1,
            labelRotation: -90,
            majorGridLines: const MajorGridLines(width: 0),
            majorTickLines: const MajorTickLines(size: 5),
            borderWidth: 0,
            axisLine: const AxisLine(width: 0),
            multiLevelLabelStyle: const MultiLevelLabelStyle(borderWidth: 1),
            multiLevelLabels: _xAxisCategories),
        primaryYAxis: NumericAxis(
            // labelFormat: '{value}%',
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(color: Colors.transparent)),
        series: <LineSeries<ChartData, String>>[
          LineSeries<ChartData, String>(
              animationDuration: 2500,
              dataSource: _chartData,
              xValueMapper: (ChartData data, _) => data.teamMate,
              yValueMapper: (ChartData data, _) => data.driverValue,
              width: 1,
              name: 'Max Verstappen',
              markerSettings: const MarkerSettings(isVisible: true)),
          LineSeries<ChartData, String>(
              animationDuration: 2500,
              dataSource: _chartData,
              width: 1,
              name: 'Team mate',
              xValueMapper: (ChartData data, _) => data.teamMate,
              yValueMapper: (ChartData data, _) => data.teamMateValue,
              markerSettings: const MarkerSettings(isVisible: true))
        ],
        tooltipBehavior: TooltipBehavior(enable: true),
      ));

  @override
  void dispose() {
    _chartData.clear();
    _xAxisCategories.clear();
    super.dispose();
  }
}

class ChartData {
  final String teamMate;
  final num driverValue;
  final num teamMateValue;

  ChartData(this.teamMate, this.driverValue, this.teamMateValue);
}
