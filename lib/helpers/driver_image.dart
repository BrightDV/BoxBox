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
 * Copyright (c) 2022, BrightDV
 */

import 'package:boxbox/helpers/convert_ergast_and_formula_one.dart';

class DriverResultsImage {
  Map<String, String> driverDecoder = {
    "leclerc":
        "https://www.formula1.com/content/dam/fom-website/drivers/C/CHALEC01_Charles_Leclerc/chalec01.png",
    "sainz":
        "https://www.formula1.com/content/dam/fom-website/drivers/C/CARSAI01_Carlos_Sainz/carsai01.png",
    "max_verstappen":
        "https://www.formula1.com/content/dam/fom-website/drivers/M/MAXVER01_Max_Verstappen/maxver01.png",
    "russell":
        "https://www.formula1.com/content/dam/fom-website/drivers/G/GEORUS01_George_Russell/georus01.png",
    "hamilton":
        "https://www.formula1.com/content/dam/fom-website/drivers/L/LEWHAM01_Lewis_Hamilton/lewham01.png",
    "ocon":
        "https://www.formula1.com/content/dam/fom-website/drivers/E/ESTOCO01_Esteban_Ocon/estoco01.png",
    "perez":
        "https://www.formula1.com/content/dam/fom-website/drivers/S/SERPER01_Sergio_Perez/serper01.png",
    "kevin_magnussen":
        "https://www.formula1.com/content/dam/fom-website/drivers/K/KEVMAG01_Kevin_Magnussen/kevmag01.png",
    "bottas":
        "https://www.formula1.com/content/dam/fom-website/drivers/V/VALBOT01_Valtteri_Bottas/valbot01.png",
    "norris":
        "https://www.formula1.com/content/dam/fom-website/drivers/L/LANNOR01_Lando_Norris/lannor01.png",
    "tsunoda":
        "https://www.formula1.com/content/dam/fom-website/drivers/Y/YUKTSU01_Yuki_Tsunoda/yuktsu01.png",
    "gasly":
        "https://www.formula1.com/content/dam/fom-website/drivers/P/PIEGAS01_Pierre_Gasly/piegas01.png",
    "alonso":
        "https://www.formula1.com/content/dam/fom-website/drivers/F/FERALO01_Fernando_Alonso/feralo01.png",
    "zhou":
        "https://www.formula1.com/content/dam/fom-website/drivers/G/GUAZHO01_Guanyu_Zhou/guazho01.png",
    "mick_schumacher":
        "https://www.formula1.com/content/dam/fom-website/drivers/M/MICSCH02_Mick_Schumacher/micsch02.png",
    "stroll":
        "https://www.formula1.com/content/dam/fom-website/drivers/L/LANSTR01_Lance_Stroll/lanstr01.png",
    "hulkenberg":
        "https://www.formula1.com/content/dam/fom-website/drivers/N/NICHUL01_Nico_Hulkenberg/nichul01.png",
    "albon":
        "https://www.formula1.com/content/dam/fom-website/drivers/A/ALEALB01_Alexander_Albon/alealb01.png",
    "ricciardo":
        "https://www.formula1.com/content/dam/fom-website/drivers/D/DANRIC01_Daniel_Ricciardo/danric01.png",
    "latifi":
        "https://www.formula1.com/content/dam/fom-website/drivers/N/NICLAF01_Nicholas_Latifi/niclaf01.png",
    "vettel":
        "https://www.formula1.com/content/dam/fom-website/drivers/S/SEBVET01_Sebastian_Vettel/sebvet01.png",
    "de_vries":
        "https://www.formula1.com/content/dam/fom-website/drivers/N/NYCDEV01_Nyck_De%20Vries/nycdev01.png.transform/2col/image.png",
  };
  Future<String> getDriverImageURL(String driverId) async {
    return driverDecoder[driverId]!;
  }
}

class DriverStatsImage {
  Future<String> getDriverImage(String driverId) async {
    String driverPath = Convert().driverIdFromErgast(driverId);
    String driverImageUrl =
        "https://www.formula1.com/content/fom-website/en/drivers/$driverPath/_jcr_content/image.img.1920.medium.jpg/1646818893219.jpg";
    return driverImageUrl;
  }
}

class DriverHelmetImage {
  Future<String> getDriverHelmetImage(String driverId) async {
    String driverPath = Convert().driverIdFromErgast(driverId);
    String driverImageUrl =
        "https://www.formula1.com/content/fom-website/en/drivers/$driverPath/_jcr_content/helmet.img.png";
    return driverImageUrl;
  }
}

class DriverFlagImage {
  Future<String> getDriverFlagImage(String driverId) async {
    String driverPath = Convert().driverIdFromErgast(driverId);
    String driverImageUrl =
        "https://www.formula1.com/content/fom-website/en/drivers/$driverPath/_jcr_content/countryFlag.img.jpg";
    return driverImageUrl;
  }
}
