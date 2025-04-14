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
 * Copyright (c) 2022-2025, BrightDV
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:boxbox/helpers/circuit_points.dart';
import 'package:url_launcher/url_launcher.dart';

class CircuitMapScreen extends StatelessWidget {
  final String circuitId;

  const CircuitMapScreen(this.circuitId, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context)!.grandPrixMap,
      ),
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
  MapController mapController = MapController();

  Future<List<Polyline>> addPoints(String circuitId) async {
    List<List> circuitPointsData =
        await GetTrackGeoJSONPoints().getCircuitPoints(
      circuitId,
    );
    List trackPoints = circuitPointsData[0];
    List<Polyline> parsedPoints = [];

    for (final point in trackPoints) {
      num diffPointIndex = trackPoints.length - trackPoints.indexOf(point);
      if (diffPointIndex.toInt() > 1) {
        List secondPoint = trackPoints[trackPoints.indexOf(point) + 1];
        parsedPoints.add(
          Polyline(
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
            color: Theme.of(context).colorScheme.onPrimary,
            strokeWidth: 2.5,
          ),
        );
      }
    }

    return parsedPoints;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Polyline>>(
      future: addPoints(widget.circuitId),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          mapController.move(snapshot.data![0].points[1], 14.0);
        }
        return FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialZoom: 14.0,
          ),
          children: [
            RichAttributionWidget(
              animationConfig: const ScaleRAWA(),
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => launchUrl(
                      Uri.parse('https://openstreetmap.org/copyright')),
                ),
              ],
            ),
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            ),
            PolylineLayer<Object>(
              polylines: snapshot.hasData ? snapshot.data! : [],
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
