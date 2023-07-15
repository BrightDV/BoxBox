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

  Future<List<TeamMateData>> teammateComparison(String driverName) async {

    print('DriverId -> $driverName');
    final url =
        'https://www.f1-fansite.com/f1-drivers/${driverName.replaceAll('_', '-')}-information-statistics/';

    final Future<File> fileStream = instance.getSingleFile(url);
    final response = await fileStream;

    final teamMateDataList = <TeamMateData>[];

    final document = parser.parse(await response.readAsBytes());

    final table = document.querySelector('table.msr_team_mates');
    final rows = table?.querySelectorAll('tbody tr');

    String? previousYear;

    if (rows != null) {

      for (final row in rows) {
        final cells = row.querySelectorAll('td');
        if (cells.isEmpty) {
          continue;
        }

        final year = cells[0].text.trim().isNotEmpty ? cells[0].text.trim() : previousYear;        final team = cells[1].text.trim();
        final teamMate = cells[2].text.trim();
        final bestPos = cells[3].text.trim();
        final bestPosTeamMate = cells[4].text.trim();
        final points = cells[5].text.trim();
        final pointsTeamMate = cells[6].text.trim();
        final wins = cells[7].text.trim();
        final winsTeamMate = cells[8].text.trim();
        final poles = cells[9].text.trim();
        final polesTeamMate = cells[10].text.trim();
        final pos = cells[11].text.trim();
        final posTeamMate = cells[12].text.trim();
        final quali = cells[13].text.trim();
        final qualiTeamMate = cells[14].text.trim();

        final teamMateData = TeamMateData(
          year: year!,
          team: team,
          teamMate: teamMate,
          bestPos: bestPos,
          bestPosTeamMate: bestPosTeamMate,
          points: points,
          pointsTeamMate: pointsTeamMate,
          wins: wins,
          winsTeamMate: winsTeamMate,
          poles: poles,
          polesTeamMate: polesTeamMate,
          pos: pos,
          posTeamMate: posTeamMate,
          quali: quali,
          qualiTeamMate: qualiTeamMate,
        );

        teamMateDataList.add(teamMateData);
        previousYear = year;
      }
    }

    return teamMateDataList;
  }
}

class TeamMateData {
  final String year;
  final String team;
  final String teamMate;
  final String bestPos;
  final String bestPosTeamMate;
  final String points;
  final String pointsTeamMate;
  final String wins;
  final String winsTeamMate;
  final String poles;
  final String polesTeamMate;
  final String pos;
  final String posTeamMate;
  final String quali;
  final String qualiTeamMate;

  TeamMateData({
    required this.year,
    required this.team,
    required this.teamMate,
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
