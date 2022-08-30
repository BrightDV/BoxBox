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

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:boxbox/helpers/driver_image.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';

class DriverDetailsScreen extends StatelessWidget {
  final String driverId;
  final String givenName;
  final String familyName;

  const DriverDetailsScreen(
    this.driverId,
    this.givenName,
    this.familyName,
  );
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: false) as bool;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$givenName ${familyName.toUpperCase()}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      body: Padding(
        padding: EdgeInsets.all(5),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DriverImageProvider(this.driverId, 'driver'),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  '$givenName $familyName',
                  style: TextStyle(
                    color: useDarkMode
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                    fontSize: 20,
                  ),
                ),
              ),
              DriverImageProvider(this.driverId, 'helmet'),
            ],
          ),
        ),
      ),
    );
  }
}

class DriverImageProvider extends StatelessWidget {
  Future<String> getImageURL(String driverId, String idOfImage) async {
    if (idOfImage == 'driver') {
      return await DriverStatsImage().getDriverImage(driverId);
    } else if (idOfImage == 'helmet') {
      return await DriverHelmetImage().getDriverHelmetImage(driverId);
    } else if (idOfImage == 'flag') {
      return await DriverFlagImage().getDriverFlagImage(driverId);
    }
  }

  final String driverId;
  final String idOfImage;
  DriverImageProvider(this.driverId, this.idOfImage);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getImageURL(this.driverId, this.idOfImage),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return RequestErrorWidget(snapshot.error.toString());
        }
        return snapshot.hasData
            ? Image.network(
                snapshot.data,
                width: idOfImage == 'driver' ? 400 : 200,
                //fit: BoxFit.scaleDown,
              )
            : LoadingIndicatorUtil();
      },
    );
  }
}
