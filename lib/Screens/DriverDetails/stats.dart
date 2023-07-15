import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/scraping/f1-fansite.dart';
import 'package:flutter/material.dart';

class DriverStats extends StatelessWidget {
  final String driverId;

  const DriverStats(this.driverId, {super.key});

  @override
  Widget build(BuildContext context) => FutureBuilder<List<TeamMateData>>(
        future: Chicanef1().teammateComparison('Lando Norris'),
        builder: (BuildContext context,
                AsyncSnapshot<List<TeamMateData>> snapshot) =>
            snapshot.hasError
                ? RequestErrorWidget(
                    snapshot.error.toString(),
                  )
                : snapshot.hasData
                    ? _buildContent(snapshot.data!)
                    : const LoadingIndicatorUtil(),
      );

  Widget _buildContent(List<TeamMateData> data) => ListView(
      children: data.map((TeamMateData e) => Text(e.teamMate)).toList());
}
