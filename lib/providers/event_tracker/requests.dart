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

import 'package:boxbox/api/event_tracker.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EventTrackerRequestsProvider {
  Event? getSavedEventTrackerRequest() {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      Map eventTrackerSavedRequestAsMap =
          Hive.box('requests').get('f1-event-tracker', defaultValue: {}) as Map;
      if (eventTrackerSavedRequestAsMap.isNotEmpty) {
        return EventTracker().plainF1EventParser(
          eventTrackerSavedRequestAsMap,
          eventTrackerSavedRequestAsMap['event'] != null
              ? 'event'
              : 'seasonContext',
          eventTrackerSavedRequestAsMap['event'] != null ? 'event' : 'race',
        );
      }
    } else if (championship == 'Formula E') {
      Map eventTrackerSavedRequestAsMap =
          Hive.box('requests').get('fe-event-tracker', defaultValue: {}) as Map;
      if (eventTrackerSavedRequestAsMap.isNotEmpty) {
        return EventTracker().plainFEEventParser(eventTrackerSavedRequestAsMap);
      }
    }
    return null;
  }

  Future<Event> parseEvent() async {
    String championship = Hive.box('settings')
        .get('championship', defaultValue: 'Formula 1') as String;
    if (championship == 'Formula 1') {
      return await EventTracker().parseF1Event();
    } else {
      return await EventTracker().parseFEEvent();
    }
  }
}
