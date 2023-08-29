import 'package:boxbox/Screens/widgets/driver_image_provider.dart';
import 'package:boxbox/scraping/f1-fansite.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DriverDetailsStatsChart extends StatefulWidget {
  final String driverId;
  final TeamMateComparison comparison;

  const DriverDetailsStatsChart(this.driverId, this.comparison, {super.key});

  @override
  State<DriverDetailsStatsChart> createState() =>
      _DriverDetailsStatsChartState();
}

class _DriverDetailsStatsChartState extends State<DriverDetailsStatsChart> {
  final List<ComparisonData> _chartData = <ComparisonData>[];

  @override
  void initState() {
    for (ComparisonValues element in widget.comparison.pointsComparison) {
      _chartData.add(ComparisonData(
          element.rowKey, element.driverValue, element.teamMateValue));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Expanded(
        child: SfCartesianChart(
          title: ChartTitle(
              text: 'Points comparison between Max verstappen and team mates'),
          enableAxisAnimation: true,
          trackballBehavior: _buildTrackballBehavior(),
          legend: Legend(isVisible: true),
          primaryXAxis: CategoryAxis(
              edgeLabelPlacement: EdgeLabelPlacement.shift,
              interval: 1,
              labelRotation: -90,
              majorGridLines: const MajorGridLines(width: 0),
              axisLabelFormatter: (AxisLabelRenderDetails details) {
                return ChartAxisLabel(
                    details.text.split('-')[0], details.textStyle);
              }),
          primaryYAxis: NumericAxis(
            numberFormat: NumberFormat.decimalPattern(),
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

  TrackballBehavior _buildTrackballBehavior() {
    return TrackballBehavior(
        enable: true,
        markerSettings: const TrackballMarkerSettings(
          height: 10,
          width: 10,
          borderWidth: 1,
        ),
        hideDelay: 2000,
        activationMode: ActivationMode.singleTap,
        // tooltipSettings:
        //     const InteractiveTooltip(format: null, canShowMarker: true),
        // shouldAlwaysShow: true,
        builder: (BuildContext context, TrackballDetails trackballDetails) {
          return Padding(
              padding: EdgeInsets.zero,
              child: Container(
                  height: 50,
                  width: 120,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  ),
                  child: Row(children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: SizedBox(
                          height: 35,
                          width: 35,
                          child: getDriverImage(trackballDetails),
                        )),
                    Center(child: Text(trackballDetails.point!.y.toString()))
                  ])));
        });
  }

  Widget getDriverImage(TrackballDetails trackballDetails) {
    if (trackballDetails.series!.name == 'Team mate') {
      final String teamMate = trackballDetails.point!.x
          .toString()
          .split('-')[0]
          .split(' ')[1]
          .toLowerCase();
      return DriverImageProvider(teamMate);
    }
    return DriverImageProvider(widget.driverId);
  }

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
