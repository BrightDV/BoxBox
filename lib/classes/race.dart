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

import 'package:boxbox/classes/article.dart';
import 'package:boxbox/classes/driver.dart';
import 'package:boxbox/classes/event_tracker.dart';

class RaceDetails {
  final String meetingId;
  final String meetingDisplayName;
  final String meetingCompleteName;
  final List<Session> sessions;
  final bool hasFacts;
  final List<News>? articles;
  final String? raceImageUrl;
  final String? flagImageUrl;
  final String? headline;
  final String? highlightsArticleId;
  final List<DriverResult>? results;
  final Map<String, List<Link>>? sessionsLinks;
  final String? circuitOfficialName;
  final String? circuitMapImageUrl;
  final String? circuitDescriptionText;
  final List? circuitMapLinks;

  const RaceDetails(
    this.meetingId,
    this.meetingDisplayName,
    this.meetingCompleteName,
    this.sessions,
    this.hasFacts, {
    this.articles,
    this.raceImageUrl,
    this.flagImageUrl,
    this.headline,
    this.highlightsArticleId,
    this.results,
    this.sessionsLinks,
    this.circuitOfficialName,
    this.circuitMapImageUrl,
    this.circuitDescriptionText,
    this.circuitMapLinks,
  });
}

class Link {
  final String text;
  final String type;
  final String url;

  const Link(this.text, this.type, this.url);
}

class Race {
  final String round;
  final String meetingId;
  final String raceName;
  final String date;
  final String raceHour;
  final String circuitId;
  final String circuitName;
  final String circuitUrl;
  final String country;
  final List<DateTime> sessionDates;
  final bool? isFirst;
  final String? raceCoverUrl;
  final String? detailsPath;
  final List? sessionStates;
  final bool? isPreSeasonTesting;
  final bool? hasRaceHour;

  Race(
    this.round,
    this.meetingId,
    this.raceName,
    this.date,
    this.raceHour,
    this.circuitId,
    this.circuitName,
    this.circuitUrl,
    this.country,
    this.sessionDates, {
    this.isFirst,
    this.raceCoverUrl,
    this.detailsPath,
    this.sessionStates,
    this.isPreSeasonTesting,
    this.hasRaceHour,
  });
}
