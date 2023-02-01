// ignore_for_file: use_build_context_synchronously

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
 * Copyright (c) 2022-2023, BrightDV
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_controller/map_controller.dart';
import 'package:boxbox/helpers/circuit_points.dart';

class CircuitMapScreen extends StatelessWidget {
  final String circuitId;

  const CircuitMapScreen(this.circuitId, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context)!.grandPrixMap,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      content: Builder(
        builder: (context) {
          var height = MediaQuery.of(context).size.height;
          var width = MediaQuery.of(context).size.width;

          return SizedBox(
            height: height * 0.6,
            width: width * 0.8,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: MarkersPage(
                circuitId,
              ),
            ),
          );
        },
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          child: Text(
            AppLocalizations.of(context)!.close,
          ),
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
    );
  }
}

class MarkersPage extends StatefulWidget {
  final String circuitId;

  const MarkersPage(this.circuitId, {Key? key}) : super(key: key);
  @override
  State<MarkersPage> createState() => _MarkersPageState();
}

class _MarkersPageState extends State<MarkersPage> {
  late MapController mapController;
  late StatefulMapController statefulMapController;
  late StreamSubscription<StatefulMapControllerStateChange> sub;

  Future<void> addPoints(String circuitId) async {
    List<List> circuitPointsData =
        await GetTrackGeoJSONPoints().getCircuitPoints(
      circuitId,
    );
    List trackPoints = circuitPointsData[0];
    List mapCenter = circuitPointsData[1];

    statefulMapController.centerOnPoint(
      LatLng(mapCenter[0], mapCenter[1]),
    );

    for (final point in trackPoints) {
      num diffPointIndex = trackPoints.length - trackPoints.indexOf(point);
      if (diffPointIndex.toInt() > 1) {
        List secondPoint = trackPoints[trackPoints.indexOf(point) + 1];
        statefulMapController.addLine(
          name: point.toString(),
          points: [
            LatLng(
              point[1],
              point[0],
            ),
            LatLng(
              secondPoint[1],
              secondPoint[0],
            ),
          ],
          color: Theme.of(context).primaryColor,
        );
      }
    }
    return;
  }

  @override
  void initState() {
    mapController = MapController();
    statefulMapController = StatefulMapController(mapController: mapController);
    sub = statefulMapController.changeFeed.listen((change) => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      addPoints(widget.circuitId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        zoom: 14.0,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        PolylineLayerOptions(
          polylines: statefulMapController.lines,
        ),
      ],
    );
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }
}
