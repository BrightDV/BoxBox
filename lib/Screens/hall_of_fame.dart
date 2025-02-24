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

import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/scraping/formula_one.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HallOfFameScreen extends StatelessWidget {
  const HallOfFameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.hallOfFame),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: FutureBuilder<List<HallOfFameDriver>>(
        future: FormulaOneScraper().scrapeHallOfFame(),
        builder: (context, snapshot) => snapshot.hasError
            ? RequestErrorWidget(
                snapshot.error.toString(),
              )
            : snapshot.hasData
                ? ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HallOfFameDriverDetailsScreen(
                            snapshot.data![index].detailsPageUrl,
                            snapshot.data![index].driverName,
                          ),
                        ),
                      ),
                      child: Card(
                        elevation: 10.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15.0),
                                topRight: Radius.circular(15.0),
                              ),
                              child: Image(
                                image: NetworkImage(
                                  snapshot.data![index].imageUrl,
                                ),
                              ),
                            ),
                            ListTile(
                              title: Text(
                                snapshot.data![index].driverName,
                              ),
                              subtitle: Text(
                                snapshot.data![index].years,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const LoadingIndicatorUtil(),
      ),
    );
  }
}

class HallOfFameDriverDetailsScreen extends StatelessWidget {
  final String pageUrl;
  final String driverName;
  const HallOfFameDriverDetailsScreen(this.pageUrl, this.driverName, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(driverName),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: FutureBuilder<Map>(
        future: FormulaOneScraper().scrapeHallOfFameDriverDetails(pageUrl),
        builder: (context, snapshot) => snapshot.hasError
            ? RequestErrorWidget(
                snapshot.error.toString(),
              )
            : snapshot.hasData
                ? SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Text(
                            driverName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              snapshot.data!['metaDescription'],
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          for (String textParagraph in snapshot.data!['parts'])
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                textParagraph,
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                : const LoadingIndicatorUtil(),
      ),
    );
  }
}
