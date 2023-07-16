import 'package:boxbox/Screens/DriverDetails/chart.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/scraping/f1-fansite.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DriverStats extends StatelessWidget {
  final String driverId;

  const DriverStats(this.driverId, {super.key});

  @override
  Widget build(BuildContext context) => FutureBuilder<TeamMateComparison>(
        future: Chicanef1().teammateComparison(driverId),
        builder: (BuildContext context,
                AsyncSnapshot<TeamMateComparison> snapshot) =>
            snapshot.hasError
                ? RequestErrorWidget(
                    snapshot.error.toString(),
                  )
                : snapshot.hasData
                    ? Padding(
                        padding: const EdgeInsets.all(5),
                        child: _buildContent(snapshot.data!))
                    : const LoadingIndicatorUtil(),
      );

  Widget _buildContent(final TeamMateComparison data) => Column(
      // children: [_buildTeamMateTitle(data.first)]);
      children: [DriverDetailsStatsChart(data)]);

  // children: data
  //     .map((TeamMateData teamMateData) => _buildTeamMateTitle(teamMateData))
  //     .toList());

  // Widget _buildTeamMateTitle(final TeamMateData teamMateData) => Column(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: <Widget>[
  //           Row(children: <Widget>[
  //             Expanded(
  //                 child: Text(teamMateData.teamMate!,
  //                     style: const TextStyle(fontSize: 16.0))),
  //             Text(teamMateData.year!, style: const TextStyle(fontSize: 16.0)),
  //           ]),
  //           Text(teamMateData.poles!)
  //         ]);

  // Widget _buildTeamMateGraph(final List<TeamMateComparison> data) => Expanded(
  //         child: SfCartesianChart(
  //       plotAreaBorderWidth: 0,
  //       title: ChartTitle(text: 'Best position'),
  //       legend: Legend(
  //           isVisible: false,
  //           overflowMode: LegendItemOverflowMode.wrap),
  //       primaryXAxis: CategoryAxis(
  //           edgeLabelPlacement: EdgeLabelPlacement.shift,
  //           majorGridLines: const MajorGridLines(width: 0)),
  //       primaryYAxis: NumericAxis(
  //           // labelFormat: '{value}%',
  //           axisLine: const AxisLine(width: 0),
  //           majorTickLines: const MajorTickLines(color: Colors.transparent)),
  //       series: <LineSeries<TeamMateComparison, String>>[
  //         LineSeries<TeamMateComparison, String>(
  //             animationDuration: 2500,
  //             dataSource: data!,
  //             xValueMapper: (TeamMateComparison sales, _) => '${sales.year}-${sales.teamMate}',
  //             yValueMapper: (TeamMateComparison sales, _) => sales.bestPos,
  //             width: 1,
  //             name: 'Max Verstappen',
  //             markerSettings: const MarkerSettings(isVisible: true)),
  //         LineSeries<TeamMateComparison, String>(
  //             animationDuration: 2500,
  //             dataSource: data!,
  //             width: 1,
  //             name: 'Team mate',
  //             xValueMapper: (TeamMateComparison sales, _) => '${sales.year}-${sales.teamMate}',
  //             yValueMapper: (TeamMateComparison sales, _) => sales.bestPosTeamMate,
  //             markerSettings: const MarkerSettings(isVisible: true))
  //       ],
  //       tooltipBehavior: TooltipBehavior(enable: true),
  //     ));
}
