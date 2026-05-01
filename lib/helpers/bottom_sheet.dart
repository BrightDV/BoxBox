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

Future<String?> showCustomBottomSheet(
    BuildContext context, Widget builder) async {
  return await showModalBottomSheet(
    context: context,
    builder: (context) => CustomBottomSheet(builder),
    isScrollControlled: true,
    useSafeArea: true,
  );
}

class CustomBottomSheet extends StatelessWidget {
  final Widget builder;
  const CustomBottomSheet(this.builder, {super.key});

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      onClosing: () {},
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: builder,
      ),
    );
  }
}
