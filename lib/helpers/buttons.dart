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

import 'package:flutter/material.dart';

class BoxBoxButton extends StatelessWidget {
  final String title;
  final Icon icon;
  final Widget destination;
  final bool isDialog;
  const BoxBoxButton(
    this.title,
    this.icon,
    this.destination, {
    this.isDialog = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 3,
        horizontal: 10,
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
        onTap: () => isDialog
            ? showDialog(
                context: context,
                builder: (BuildContext context) => destination,
              )
            : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => destination,
                ),
              ),
      ),
    );
  }
}
