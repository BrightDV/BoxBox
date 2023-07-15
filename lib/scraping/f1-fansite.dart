import 'package:html/parser.dart' as htmlParser;
import 'package:http/http.dart' as http;

class Chicanef1 {
  static const String baseUrl = 'https://www.chicanef1.com';

  Future<List<TeamMateData>> teammateComparison(String driverName) async {
    final response = await http.get(Uri.parse(
        'https://www.f1-fansite.com/f1-drivers/max-verstappen-information-statistics/'));
    final driverInfo = <String, String>{};

    final teamMateDataList = <TeamMateData>[];

    if (response.statusCode == 200) {
      final document = htmlParser.parse(response.body);

      final table = document.querySelector('table.msr_team_mates');
      final rows = table?.querySelectorAll('tbody tr');

      if (rows != null) {

        print('Rows length: ${rows.length}');

        for (final row in rows) {
          print (row.text);
          final cells = row.querySelectorAll('td');
          if (cells.isEmpty) {
            continue;
          }

          print('cells length: ${cells.length}');

          final year = cells[0].text.trim();
          final team = cells[1].text.trim();
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
            year: year,
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
        }
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