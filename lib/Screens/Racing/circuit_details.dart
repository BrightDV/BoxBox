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

import 'package:boxbox/Screens/circuit_map_screen.dart';
import 'package:boxbox/helpers/buttons.dart';
import 'package:boxbox/helpers/convert_ergast_and_formula_one.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class CircuitDetailsScreen extends StatelessWidget {
  final String trackCountry;
  final String trackName;
  final String trackImageUrl;
  final String trackDetailsText;
  final List circuitMap;
  const CircuitDetailsScreen(
    this.trackCountry,
    this.trackName,
    this.trackImageUrl,
    this.trackDetailsText,
    this.circuitMap, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trackName),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width / (16 / 9),
              child: TrackLayoutImage(trackImageUrl),
            ),
            BoxBoxButton(
              AppLocalizations.of(context)!.grandPrixMap,
              Icon(
                Icons.map_outlined,
              ),
              widget: CircuitMapScreen(
                Convert().circuitNameFromFormulaOneToErgastForCircuitPoints(
                  trackCountry,
                ),
              ),
              isDialog: true,
            ),
            for (var link in circuitMap)
              if (!(link['text'].contains('Buy') ||
                  link['text'].contains('Guide') ||
                  link['text'].contains('Results')))
                BoxBoxButton(
                  link['text'],
                  Icon(
                    Icons.article_outlined,
                  ),
                  route: 'article',
                  pathParameters: {
                    'id': link['url'].split('.').last,
                  },
                  extra: {'isFromLink': true},
                ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 10,
                right: 10,
              ),
              child: MarkdownBody(
                data: trackDetailsText,
                selectable: true,
                fitContent: false,
                styleSheet: MarkdownStyleSheet(
                  strong: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  p: TextStyle(
                    fontSize: 14,
                  ),
                  pPadding: EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                  ),
                  a: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: WrapAlignment.spaceBetween,
                  h2: TextStyle(
                    fontFamily: 'Northwell',
                    fontSize: 70,
                  ),
                  h2Padding: EdgeInsets.only(left: 10, bottom: 3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrackLayoutImage extends StatelessWidget {
  final String url;
  const TrackLayoutImage(
    this.url, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: const EdgeInsets.only(
                top: 52,
                bottom: 50,
              ),
              insetPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.black,
              surfaceTintColor: Colors.transparent,
              content: Builder(
                builder: (context) {
                  return SizedBox(
                    width: double.infinity - 10,
                    child: InteractiveViewer(
                      minScale: 0.1,
                      maxScale: 8,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                          ),
                          Card(
                            color: Colors.black,
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image(
                              image: NetworkImage(url),
                              loadingBuilder: (context, child,
                                      loadingProgress) =>
                                  loadingProgress == null
                                      ? child
                                      : SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              (16 / 9),
                                          child: const LoadingIndicatorUtil(),
                                        ),
                              errorBuilder: (context, url, error) => Icon(
                                Icons.error_outlined,
                                size: 30,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Image.network(
              url,
              loadingBuilder: (context, child, loadingProgress) =>
                  loadingProgress == null
                      ? child
                      : SizedBox(
                          height: MediaQuery.of(context).size.width / (16 / 9),
                          child: const LoadingIndicatorUtil(),
                        ),
              errorBuilder: (context, url, error) => Icon(
                Icons.error_outlined,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
