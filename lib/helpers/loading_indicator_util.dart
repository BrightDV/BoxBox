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

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LoadingIndicatorUtil extends StatelessWidget {
  final double? width;
  final bool replaceImage;
  final bool borderRadius;
  final bool fullBorderRadius;
  const LoadingIndicatorUtil({
    Key? key,
    this.width,
    this.replaceImage = false,
    this.borderRadius = true,
    this.fullBorderRadius = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    return replaceImage
        ? ClipRRect(
            borderRadius: fullBorderRadius
                ? BorderRadius.circular(16)
                : BorderRadius.only(
                    topLeft: Radius.circular(borderRadius ? 16.0 : 0),
                    topRight: Radius.circular(borderRadius ? 16.0 : 0),
                  ),
            child: Image.asset('assets/images/image_loading_bg.png'),
          )
        : Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: SizedBox(
                width: width ?? 110.0,
                height: 55.0,
                child: LoadingIndicator(
                  indicatorType: Indicator.values[15],
                  colors: useDarkMode
                      ? [Theme.of(context).colorScheme.onPrimary]
                      : null,
                  strokeWidth: 2.0,
                ),
              ),
            ),
          );
  }
}
