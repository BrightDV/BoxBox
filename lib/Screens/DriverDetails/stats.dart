import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/scraping/f1-fansite.dart';
import 'package:flutter/material.dart';

class DriverStats extends StatelessWidget {
  final String driverId;

  const DriverStats(this.driverId, {super.key});

  @override
  Widget build(BuildContext context) => FutureBuilder<List<TeamMateData>>(
        future: Chicanef1().teammateComparison(driverId),
        builder: (BuildContext context,
                AsyncSnapshot<List<TeamMateData>> snapshot) =>
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

  Widget _buildContent(final List<TeamMateData> data) => Column(
    // children: [_buildTeamMateTitle(data.first)]);
      children: data
          .map((TeamMateData teamMateData) => _buildTeamMateTitle(teamMateData))
          .toList());

  Widget _buildTeamMateTitle(final TeamMateData teamMateData) => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(children: <Widget>[
              Expanded(
                  child: Text(teamMateData.teamMate!,
                      style: const TextStyle(fontSize: 16.0))),
              Text(teamMateData.year!, style: const TextStyle(fontSize: 16.0)),
            ]),
            Text(teamMateData.poles!)
          ]);

  Widget _buildTeamMateGraph() => Container();
}
