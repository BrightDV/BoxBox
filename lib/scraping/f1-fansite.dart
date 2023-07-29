import 'package:file/src/interface/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:html/parser.dart' as parser;

class Chicanef1 {
  static const String baseUrl = 'https://www.chicanef1.com';

  static const key = 'customCacheKey';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 20,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  Future<TeamMateComparison> teammateComparison(String driverName) async {
    print('DriverId -> $driverName');
    final url =
        'https://www.f1-fansite.com/f1-drivers/${driverName.replaceAll('_', '-')}-information-statistics/';

    final Future<File> fileStream = instance.getSingleFile(url);
    final response = await fileStream;

    final document = parser.parse(await response.readAsBytes());

    final table = document.querySelector('table.msr_team_mates');
    final rows = table?.querySelectorAll('tbody tr');

    int? previousYear;

    final resultMap = <int, YearData>{};

    final List<ComparisonValues> pointsComparision =
        <ComparisonValues>[];
    final List<MostPolesComparison> mostPolesComparison =
        <MostPolesComparison>[];

    if (rows != null) {
      for (final row in rows) {
        final cells = row.querySelectorAll('td');
        if (cells.isEmpty) {
          continue;
        }

        final int year = cells[0].text.trim().isNotEmpty
            ? int.parse(cells[0].text.trim())
            : previousYear!;
        final teamMate = cells[2].text.trim();

        final String rowKey = '$teamMate $year';

        pointsComparision.add(ComparisonValues(rowKey, num.parse(cells[5].text.trim()), num.parse(cells[6].text.trim())));

        // print('points : $driverName -> ${pointsComparision.driverValue}');
        // print('points : $teamMate -> ${pointsComparision.teamMateValue}');

        // final yearData =
        //     resultMap.putIfAbsent(year, () => YearData(teamMates: {}));
        // final teamMateData = TeamMateData(
        //   bestPos: num.parse(cells[3].text.trim()),
        //   bestPosTeamMate: num.parse(cells[4].text.trim()),
        //   points: num.parse(cells[5].text.trim()),
        //   pointsTeamMate: num.parse(cells[6].text.trim()),
        //   wins: num.parse(cells[7].text.trim()),
        //   winsTeamMate: num.parse(cells[8].text.trim()),
        //   poles: num.parse(cells[9].text.trim()),
        //   polesTeamMate: num.parse(cells[10].text.trim()),
        //   pos: num.parse(cells[11].text.trim()),
        //   posTeamMate: num.parse(cells[12].text.trim()),
        //   quali: num.parse(cells[13].text.trim()),
        //   qualiTeamMate: num.parse(cells[14].text.trim()),
        // );

        // final String rowKey = '$teamMate $year';
        // mostPointsComparison.add(MostPointsComparison(rowKey,
        //     num.parse(cells[5].text.trim()), num.parse(cells[6].text.trim())));
        // mostPolesComparison.add(MostPolesComparison(rowKey,
        //     num.parse(cells[9].text.trim()), num.parse(cells[10].text.trim())));
        //
        // yearData.teamMates[teamMate] = teamMateData;
        previousYear = year;
      }
    }

    return TeamMateComparison(
      pointsComparision: pointsComparision,
      // mostPolesComparison: mostPolesComparison,
    );

    // if (rows != null) {
    //
    //   for (final row in rows) {
    //     final cells = row.querySelectorAll('td');
    //     if (cells.isEmpty) {
    //       continue;
    //     }
    //
    //     final year = cells[0].text.trim().isNotEmpty ? int.parse(cells[0].text.trim()) : previousYear!;
    //     final team = cells[1].text.trim().isNotEmpty ? cells[1].text.trim() : previousTeam!;
    //     final teamMate = cells[2].text.trim();
    //     final bestPos = cells[3].text.trim();
    //     final bestPosTeamMate = cells[4].text.trim();
    //     final points = cells[5].text.trim();
    //     final pointsTeamMate = cells[6].text.trim();
    //     final wins = cells[7].text.trim();
    //     final winsTeamMate = cells[8].text.trim();
    //     final poles = cells[9].text.trim();
    //     final polesTeamMate = cells[10].text.trim();
    //     final pos = cells[11].text.trim();
    //     final posTeamMate = cells[12].text.trim();
    //     final quali = cells[13].text.trim();
    //     final qualiTeamMate = cells[14].text.trim();
    //
    //     final teamMateData = TeamMateComparison(
    //       year: year!,
    //       team: team,
    //       teamMate: teamMate,
    //       bestPos: int.parse(bestPos),
    //       bestPosTeamMate: int.parse(bestPosTeamMate),
    //       points: double.parse(points),
    //       pointsTeamMate: double.parse(pointsTeamMate),
    //       wins: int.parse(wins),
    //       winsTeamMate: int.parse(winsTeamMate),
    //       poles: int.parse(poles),
    //       polesTeamMate: int.parse(polesTeamMate),
    //       pos: int.parse(pos),
    //       posTeamMate: int.parse(posTeamMate),
    //       quali: int.parse(quali),
    //       qualiTeamMate: int.parse(qualiTeamMate),
    //     );
    //
    //     teamMateDataList.add(teamMateData);
    //     previousYear = year;
    //     previousTeam = team;
    //   }
    // }
    //
    // return teamMateDataList;
  }
}

class TeamMateData {
  num bestPos;
  num bestPosTeamMate;
  num points;
  num pointsTeamMate;
  num wins;
  num winsTeamMate;
  num poles;
  num polesTeamMate;
  num pos;
  num posTeamMate;
  num quali;
  num qualiTeamMate;

  TeamMateData({
    required this.bestPos,
    required this.bestPosTeamMate,
    required this.points,
    required this.pointsTeamMate,
    required this.wins,
    required this.winsTeamMate,
    required this.poles,
    required this.polesTeamMate,
    required this.pos,
    required this.posTeamMate,
    required this.quali,
    required this.qualiTeamMate,
  });
}

class YearData {
  Map<String, TeamMateData> teamMates;

  YearData({required this.teamMates});
}

class TeamMateComparison {
  final List<ComparisonValues> pointsComparision;
  // final List<MostPolesComparison> mostPolesComparison;

  // Map<int, YearData> resultMap;
  //
  TeamMateComparison(
      {required this.pointsComparision});
}

class MostPointsComparison {
  final String rowKey;
  final num points;
  final num pointsTeamMate;

  MostPointsComparison(this.rowKey, this.points, this.pointsTeamMate);
}

class MostPolesComparison {
  final String rowKey;
  final num poles;
  final num polesTeamMate;

  MostPolesComparison(this.rowKey, this.poles, this.polesTeamMate);
}
class ComparisonValues {
  final String rowKey;
  final num driverValue;
  final num teamMateValue;

  ComparisonValues(this.rowKey, this.driverValue, this.teamMateValue);

  @override
  String toString() {
    return '$rowKey -> [$driverValue : $teamMateValue]';
  }
}

// class TeamMateComparison {
//   final int year;
//   final String team;
//   final String teamMate;
//   final int bestPos;
//   final int bestPosTeamMate;
//   final double points;
//   final double pointsTeamMate;
//   final int wins;
//   final int winsTeamMate;
//   final int poles;
//   final int polesTeamMate;
//   final int pos;
//   final int posTeamMate;
//   final int quali;
//   final int qualiTeamMate;
//
//   TeamMateComparison({
//     required this.year,
//     required this.team,
//     required this.teamMate,
//     required this.bestPos,
//     required this.bestPosTeamMate,
//     required this.points,
//     required this.pointsTeamMate,
//     required this.wins,
//     required this.winsTeamMate,
//     required this.poles,
//     required this.polesTeamMate,
//     required this.pos,
//     required this.posTeamMate,
//     required this.quali,
//     required this.qualiTeamMate,
//   });
// }
