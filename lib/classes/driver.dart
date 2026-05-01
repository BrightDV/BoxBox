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

import 'dart:ui';

class Driver {
  final String driverId;
  final String position;
  final String permanentNumber;
  final String givenName;
  final String familyName;
  final String code;
  final String team;
  final String points;
  final String? driverImage;
  final String? detailsPath;
  final Color? teamColor;

  Driver(
    this.driverId,
    this.position,
    this.permanentNumber,
    this.givenName,
    this.familyName,
    this.code,
    this.team,
    this.points, {
    this.driverImage,
    this.detailsPath,
    this.teamColor,
  });
}

class DriverResult {
  final String driverId;
  final String position;
  final String permanentNumber;
  final String givenName;
  final String familyName;
  final String code;
  final String team;
  final String sessionTime;
  final String gap;
  final bool isFastest;
  final String fastestLapTime;
  final String fastestLap;
  final String? lapsDone;
  final String? points;
  final String? raceId;
  final String? raceName;
  final String? status;
  final String? teamColor;

  DriverResult(
    this.driverId,
    this.position,
    this.permanentNumber,
    this.givenName,
    this.familyName,
    this.code,
    this.team,
    this.sessionTime,
    this.gap,
    this.isFastest,
    this.fastestLapTime,
    this.fastestLap, {
    this.lapsDone,
    this.points,
    this.raceId,
    this.raceName,
    this.status,
    this.teamColor,
  });
}

class DriverQualificationResult {
  final String driverId;
  final String position;
  final String permanentNumber;
  final String givenName;
  final String familyName;
  final String code;
  final String team;
  final String timeq1;
  final String timeq2;
  final String timeq3;
  final String? teamColor;

  DriverQualificationResult(
    this.driverId,
    this.position,
    this.permanentNumber,
    this.givenName,
    this.familyName,
    this.code,
    this.team,
    this.timeq1,
    this.timeq2,
    this.timeq3, {
    this.teamColor,
  });
}

class StartingGridPosition {
  final String position;
  final String number;
  final String driver;
  final String team;
  final String teamFullName;
  final String time;
  final String? teamColor;

  StartingGridPosition(
    this.position,
    this.number,
    this.driver,
    this.team,
    this.teamFullName,
    this.time, {
    this.teamColor,
  });
}
