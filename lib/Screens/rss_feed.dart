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

import 'package:boxbox/Screens/rss_feed_article.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import 'package:webfeed/webfeed.dart';

class RssFeedScreen extends StatefulWidget {
  final String feedName;
  final Future<List<RssItem>> getArticlesFunction;
  const RssFeedScreen(this.feedName, this.getArticlesFunction, {Key? key})
      : super(key: key);

  @override
  State<RssFeedScreen> createState() => _RssFeedScreenState();
}

class _RssFeedScreenState extends State<RssFeedScreen> {
  @override
  Widget build(BuildContext context) {
    bool useDarkMode =
        Hive.box('settings').get('darkMode', defaultValue: true) as bool;
    String newsLayout =
        Hive.box('settings').get('newsLayout', defaultValue: 'big') as String;
    Offset _tapPosition = Offset.zero;

    void _storePosition(TapDownDetails details) {
      _tapPosition = details.globalPosition;
    }

    void _showDetailsMenu() {
      final RenderObject overlay =
          Overlay.of(context)!.context.findRenderObject()!;

      showMenu(
        context: context,
        color: useDarkMode ? Color(0xff1d1d28) : Colors.white,
        items: <PopupMenuEntry<int>>[
          PopupMenuItem(
            value: 0,
            child: Row(
              children: [
                Icon(
                  Icons.language_outlined,
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                ),
                Text(
                  AppLocalizations.of(context)!.openInBrowser,
                  style: TextStyle(
                    color: useDarkMode ? Colors.white : Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 1,
            child: Row(
              children: [
                Icon(
                  Icons.share_outlined,
                  color: useDarkMode ? Colors.white : Colors.black,
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                ),
                Text(
                  AppLocalizations.of(context)!.share,
                  style: TextStyle(
                    color: useDarkMode ? Colors.white : Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
        position: RelativeRect.fromRect(_tapPosition & const Size(40, 40),
            Offset.zero & overlay.semanticBounds.size),
      ).then<void>(
        (int? delta) {
          if (delta == null) return;
          delta == 0
              ? launchUrl(
                  Uri.parse("https://www.formula1.com/en/latest/article..html"),
                  mode: LaunchMode.externalApplication,
                )
              : Share.share(
                  "https://www.formula1.com/en/latest/artihtml",
                );
        },
      );
    }

    return Scaffold(
      backgroundColor:
          useDarkMode ? Theme.of(context).backgroundColor : Colors.white,
      appBar: AppBar(
        title: Text(
          widget.feedName,
        ),
      ),
      body: FutureBuilder<List<RssItem>>(
        future: widget.getArticlesFunction,
        builder: (context, snapshot) => snapshot.hasError
            ? RequestErrorWidget(
                snapshot.error.toString(),
              )
            : snapshot.hasData
                ? ListView.builder(
                    itemCount: snapshot.data!.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Card(
                        elevation: 10.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: useDarkMode ? Color(0xff1d1d28) : Colors.white,
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RssFeedArticleScreen(
                                snapshot.data![index].title!,
                                snapshot.data![index].link!.indexOf('?utm') ==
                                        -1
                                    ? snapshot.data![index].link!
                                    : snapshot.data![index].link!.substring(
                                        0,
                                        snapshot.data![index].link!
                                            .indexOf('?utm'),
                                      ),
                              ),
                            ),
                          ),
                          onTapDown: (position) => _storePosition(position),
                          onLongPress: () {
                            Feedback.forLongPress(context);
                            _showDetailsMenu();
                          },
                          child: Column(
                            children: [
                              newsLayout != 'condensed' &&
                                      newsLayout != 'small' &&
                                      snapshot.data![index].enclosure!.url !=
                                          null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      ),
                                      child: Image.network(
                                        snapshot.data![index].enclosure!.url!,
                                      ),
                                    )
                                  : Container(
                                      height: 0.0,
                                      width: 0.0,
                                    ),
                              ListTile(
                                title: Text(
                                  snapshot.data![index].title!,
                                  style: TextStyle(
                                    color: useDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 5,
                                  textAlign: TextAlign.justify,
                                ),
                                subtitle: newsLayout != 'big' &&
                                        newsLayout != 'condensed'
                                    ? null
                                    : MarkdownBody(
                                        data: snapshot.data![index].description!
                                            .substring(
                                              0,
                                              snapshot.data![index].description!
                                                  .indexOf("<a "),
                                            )
                                            .replaceAll('<br>', ''),
                                        styleSheet: MarkdownStyleSheet(
                                          textAlign: WrapAlignment.spaceBetween,
                                          p: TextStyle(
                                            color: useDarkMode
                                                ? Colors.grey[400]
                                                : Colors.grey[800],
                                          ),
                                        ),
                                      ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  right: 16,
                                  bottom: 5,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: 8,
                                      ),
                                      child: Icon(
                                        Icons.schedule,
                                        color: useDarkMode
                                            ? Colors.grey.shade300
                                            : Colors.grey[800],
                                        size: 20.0,
                                      ),
                                    ),
                                    Text(
                                      timeago.format(
                                        snapshot.data![index].pubDate!,
                                        locale: Localizations.localeOf(context)
                                            .toString(),
                                      ),
                                      style: TextStyle(
                                        color: useDarkMode
                                            ? Colors.grey.shade300
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : LoadingIndicatorUtil(),
      ),
    );
  }
}
