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
import 'package:go_router/go_router.dart';

/// Class for common button used across the app.
///
/// For a route: `route` must not be null.
/// For a widget: `isDialog=false`, `isRoute=false` and `widget` must not null.
/// For a dialog: `isDialog=true` and `widget` must not null.
/// For a function: `isDialog=false` and `toExecute` must not null.
class BoxBoxButton extends StatelessWidget {
  final String title;
  final Widget icon;
  final bool isDialog;
  final bool isRoute;
  final Function? toExecute;
  final double? verticalPadding;
  final double? horizontalPadding;
  final Widget? widget;
  final String? route;
  final Map<String, String>? pathParameters;
  final Map? extra;

  const BoxBoxButton(
    this.title,
    this.icon, {
    this.isDialog = false,
    this.isRoute = true,
    this.toExecute,
    this.verticalPadding,
    this.horizontalPadding,
    this.widget,
    this.route,
    this.pathParameters,
    this.extra,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding ?? 3,
        horizontal: horizontalPadding ?? 10,
      ),
      child: GestureDetector(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSecondary,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              10,
            ),
            child: Row(
              children: [
                Text(title),
                const Spacer(),
                icon,
              ],
            ),
          ),
        ),
        onTap: () async => isDialog
            ? showDialog(
                context: context,
                builder: (BuildContext context) => widget!,
              )
            : toExecute != null
                ? await toExecute!()
                : isRoute
                    ? context.pushNamed(
                        route!,
                        pathParameters: pathParameters ?? {},
                        extra: extra,
                      )
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => widget!,
                        ),
                      ),
      ),
    );
  }
}
