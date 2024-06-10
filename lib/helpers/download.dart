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
 * Copyright (c) 2022-2024, BrightDV
 */

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DownloadUtils {
  Future<String?> videoDownloadQualitySelector(
    String videoId,
    Function(TaskStatusUpdate) updateWithType,
    Function setState,
    BuildContext context,
  ) async {
    String quality = await showDialog(
      context: context,
      builder: (context) {
        String selectedQuality = "360"; // TODO: default from settings
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  20.0,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.all(
              20.0,
            ),
            title: Text(
              'Select which quality to download.', // TODO: localize
              style: TextStyle(
                fontSize: 24.0,
              ), // here
              textAlign: TextAlign.center,
            ),
            content: Row(
              children: [
                Radio(
                  value: "180",
                  groupValue: selectedQuality,
                  onChanged: (String? value) => setState(() {
                    selectedQuality = value!;
                  }),
                ),
                Text(
                  '180p',
                ),
                Radio(
                  value: "360",
                  groupValue: selectedQuality,
                  onChanged: (String? value) => setState(() {
                    selectedQuality = value!;
                  }),
                ),
                Text(
                  '360p',
                ),
                Radio(
                  value: "720",
                  groupValue: selectedQuality,
                  onChanged: (String? value) => setState(() {
                    selectedQuality = value!;
                  }),
                ),
                Text(
                  '720p',
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                ),
              ),
              TextButton(
                child: Text('Download'), // TODO: localize
                onPressed: () async {
                  Navigator.of(context).pop(selectedQuality);
                },
              ),
            ],
          ),
        );
      },
    );
    return quality;
  }
}
