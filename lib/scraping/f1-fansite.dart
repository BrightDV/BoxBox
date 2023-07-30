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
    final url =
        'https://www.f1-fansite.com/f1-drivers/${driverName.replaceAll('_', '-')}-information-statistics/';

    final Future<File> fileStream = instance.getSingleFile(url);
    final response = await fileStream;

    final document = parser.parse(await response.readAsBytes());

    final table = document.querySelector('table.msr_team_mates');
    final rows = table?.querySelectorAll('tbody tr');

    int? previousYear;

    final TeamMateComparison result = TeamMateComparison();

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

        final String rowKey = '$teamMate-$year';

        result.bestPositionComparison.add(ComparisonValues(rowKey, num.parse(cells[3].text.trim()), num.parse(cells[4].text.trim())));
        result.pointsComparison.add(ComparisonValues(rowKey, num.parse(cells[5].text.trim()), num.parse(cells[6].text.trim())));
        result.winsComparison.add(ComparisonValues(rowKey, num.parse(cells[7].text.trim()), num.parse(cells[8].text.trim())));
        result.polesComparison.add(ComparisonValues(rowKey, num.parse(cells[9].text.trim()), num.parse(cells[10].text.trim())));
        result.positionComparison.add(ComparisonValues(rowKey, num.parse(cells[11].text.trim()), num.parse(cells[12].text.trim())));
        result.qualificationComparison.add(ComparisonValues(rowKey, num.parse(cells[13].text.trim()), num.parse(cells[14].text.trim())));

        previousYear = year;
      }
    }

    return result;
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
  final List<ComparisonValues> bestPositionComparison = <ComparisonValues>[];
  final List<ComparisonValues> pointsComparison = <ComparisonValues>[];
  final List<ComparisonValues> winsComparison = <ComparisonValues>[];
  final List<ComparisonValues> polesComparison = <ComparisonValues>[];
  final List<ComparisonValues> positionComparison = <ComparisonValues>[];
  final List<ComparisonValues> qualificationComparison = <ComparisonValues>[];

  TeamMateComparison();
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
