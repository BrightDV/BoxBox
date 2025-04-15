/*
 *  This file is part of BoxBox (https://github.com/BrightDV/BoxBox).
 * 
 * BoxBox is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BoxBox is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BoxBox.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Copyright (c) 2022-2025, BrightDV
 */

import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

class Constants {
  final String F1_WEBSITE_URL = utf8.decode(
    base64Decode("aHR0cHM6Ly93d3cuZm9ybXVsYTEuY29t"),
  );
  final String F1_API_URL = utf8.decode(
    base64Decode("aHR0cHM6Ly9hcGkuZm9ybXVsYTEuY29t"),
  );
  final String FE_API_URL = utf8.decode(
    base64Decode("aHR0cHM6Ly9hcGkuZm9ybXVsYS1lLnB1bHNlbGl2ZS5jb20="),
  );
  final String ERGAST_API_URL = "https://ergast.com/api";
  final String OFFICIAL_BBS_SERVER_URL =
      "https://boxbox-server.netlify.app/api";
  final String F1_API_KEY = utf8.decode(
    base64Decode("eFo3QU9PRFNqaVFhZExzSVlXZWZRcnBDU1FWRGJIR0M="),
  );
  final String F1_BRIGHTCOVE_PLAYER_ID = utf8.decode(
    base64Decode("NjA1Nzk0OTQzMjAwMQ=="),
  );
  final String FE_BRIGHTCOVE_PLAYER_ID = utf8.decode(
    base64Decode("NjI3NTM2MTM0NDAwMQ=="),
  );
  final String F1_BRIGHTCOVE_PLAYER_KEY = utf8.decode(
    base64Decode(
      "IGFwcGxpY2F0aW9uL2pzb247cGs9QkNwa0FEYXdxTTFoUVZCdVhrU2xzbDZoVXNCWlFNbXJMYklmT2pKUTNfbjh6bVBPaGxOU3daaFFCRjZkNXhnZ3htMHQwNTJsUWpZeWhxWlIzRlcyZVAwM1lHT0VSOWloSmtVbkloUlpHQnh1TGhuTC1RaUZwdmNEV0loX0x2d041ajh6a2pUdEdLYXJoc2RW",
    ),
  );
  final String FE_BRIGHTCOVE_PLAYER_KEY = utf8.decode(
    base64Decode(
      "IGFwcGxpY2F0aW9uL2pzb247cGs9QkNwa0FEYXdxTTBDWkVsa1Z3ZnM2MnEtSlRPYzRDZVpTTkpSZnhUOTIzcXpiTVNxcDZxbjVWRWdXVjFpYW8xY0VmMnNYWDljZThhY2hUdU9mWUtVdmZjaFNpc19yQjVTeHpfaWg3MEdZTFlkZjhiWmdIaTNZcTFWS182djNtajI5cnh4Y0pqRjNPWDZSaTMy",
    ),
  );

  String getOfficialApiKey() {
    String apiKey = Hive.box('settings')
        .get('officialApiKey', defaultValue: F1_API_KEY) as String;
    return apiKey;
  }
}
