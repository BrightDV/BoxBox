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

import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/scraping/formula_one.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HallOfFameScreen extends StatelessWidget {
  const HallOfFameScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.hallOfFame),
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
                    itemBuilder: (context, index) => Card(
                      elevation: 5,
                      child: Column(
                        children: [
                          Image(
                            image: NetworkImage(
                              snapshot.data![index].imageUrl,
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
                  )
                : LoadingIndicatorUtil(),
      ),
    );
  }
}
