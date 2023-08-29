import 'package:boxbox/Screens/race_details.dart';
import 'package:boxbox/api/driver_components.dart';
import 'package:boxbox/api/ergast.dart';
import 'package:boxbox/helpers/convert_ergast_and_formula_one.dart';
import 'package:boxbox/helpers/driver_result_item.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DriverResults extends StatelessWidget {
  final String driverId;
  const DriverResults(this.driverId, {super.key});

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
    Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return FutureBuilder<List<DriverResult>>(
      future: ErgastApi().getDriverResults(driverId),
      builder: (context, snapshot) => snapshot.hasError
          ? RequestErrorWidget(
        snapshot.error.toString(),
      )
          : snapshot.hasData
          ? ListView.builder(
        itemCount: snapshot.data!.length + 1,
        itemBuilder: (context, index) => index == 0
            ? Container(
          color: const Color(0xff383840),
          height: 45,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    AppLocalizations.of(context)
                        ?.positionAbbreviation ??
                        ' POS',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(''),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    AppLocalizations.of(context)
                        ?.driverAbbreviation ??
                        'DRI',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Text(
                    AppLocalizations.of(context)?.time ??
                        'TIME',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    AppLocalizations.of(context)?.laps ??
                        'Laps',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    AppLocalizations.of(context)
                        ?.pointsAbbreviation ??
                        'PTS',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 5),
              child: GestureDetector(
                onTap: () {
                  String circuitId =
                  Convert().circuitIdFromErgastToFormulaOne(
                    snapshot.data![index - 1].raceId!,
                  );
                  String circuitName = Convert()
                      .circuitNameFromErgastToFormulaOne(
                    snapshot.data![index - 1].raceId!,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: Text(
                            AppLocalizations.of(context)!.race,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        body: RaceResultsProvider(
                          raceUrl:
                          'https://www.formula1.com/en/results.html/2023/races/$circuitId/$circuitName/race-result.html',
                        ),
                      ),
                    ),
                  );
                },
                child: Text(
                  '${snapshot.data![index - 1].raceName!} >',
                  style: TextStyle(
                    color: useDarkMode
                        ? Colors.white
                        : Colors.black,
                    decoration: TextDecoration.underline,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            DriverResultItem(
              snapshot.data![index - 1],
              5,
            ),
          ],
        ),
      )
          : const LoadingIndicatorUtil(),
    );
  }
}