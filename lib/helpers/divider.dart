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

// originally from flutter

import 'package:flutter/material.dart';

class BoxBoxVerticalDivider extends StatelessWidget {
  final double? width;
  final double? thickness;
  final double? indent;
  final double? endIndent;
  final Color? color;
  final BorderRadiusGeometry? border;

  const BoxBoxVerticalDivider({
    super.key,
    this.width,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DividerThemeData dividerTheme = DividerTheme.of(context);
    final DividerThemeData defaults = theme.useMaterial3
        ? _DividerDefaultsM3(context)
        : _DividerDefaultsM2(context);
    final double width = this.width ?? dividerTheme.space ?? defaults.space!;
    final double thickness =
        this.thickness ?? dividerTheme.thickness ?? defaults.thickness!;
    final double indent =
        this.indent ?? dividerTheme.indent ?? defaults.indent!;
    final double endIndent =
        this.endIndent ?? dividerTheme.endIndent ?? defaults.endIndent!;

    return SizedBox(
      width: width,
      child: Center(
        child: Container(
          width: thickness,
          margin: EdgeInsetsDirectional.only(top: indent, bottom: endIndent),
          decoration: BoxDecoration(
            borderRadius: border,
            border: Border(
              left: Divider.createBorderSide(
                context,
                color: color,
                width: thickness,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DividerDefaultsM2 extends DividerThemeData {
  const _DividerDefaultsM2(this.context)
      : super(
          space: 16,
          thickness: 0,
          indent: 0,
          endIndent: 0,
        );

  final BuildContext context;

  @override
  Color? get color => Theme.of(context).dividerColor;
}

class _DividerDefaultsM3 extends DividerThemeData {
  const _DividerDefaultsM3(this.context)
      : super(
          space: 16,
          thickness: 1.0,
          indent: 0,
          endIndent: 0,
        );

  final BuildContext context;

  @override
  Color? get color => Theme.of(context).colorScheme.outlineVariant;
}
