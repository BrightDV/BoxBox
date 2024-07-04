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

import 'package:animations/animations.dart';
import 'package:boxbox/Screens/video.dart';
import 'package:boxbox/api/formulae.dart';
import 'package:boxbox/api/videos.dart';
import 'package:boxbox/helpers/hover.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import "package:story_view/story_view.dart";
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class VideosScreen extends StatefulWidget {
  final ScrollController _scrollController;
  const VideosScreen(this._scrollController, {Key? key}) : super(key: key);
  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  static const _pageSize = 24;
  final PagingController<int, Video> _pagingController = PagingController(
    firstPageKey: 0,
  );

  @override
  void initState() {
    _pagingController.addPageRequestListener(
      (offset) {
        _fetchPage(offset);
      },
    );
    super.initState();
  }

  Future<void> _fetchPage(int offset) async {
    try {
      String championship = Hive.box('settings')
          .get('championship', defaultValue: 'Formula 1') as String;
      List<Video> newItems;
      if (championship == 'Formula 1') {
        newItems = await F1VideosFetcher().getLatestVideos(
          24,
          offset,
        );
      } else {
        newItems = await FormulaE().getLatestVideos(
          24,
          offset,
        );
      }
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = offset + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    List<VideoItem> headerVideos = [];
    return width < 500
        ? RefreshIndicator(
            onRefresh: () => Future.sync(
              () => _pagingController.refresh(),
            ),
            child: PagedListView<int, Video>(
              pagingController: _pagingController,
              scrollController: widget._scrollController,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              builderDelegate: PagedChildBuilderDelegate<Video>(
                itemBuilder: (context, video, index) {
                  if (index < 3) {
                    headerVideos.add(
                      VideoItem(
                        index,
                        _pagingController.itemList!,
                      ),
                    );
                    return Container();
                  } else if (index == 3) {
                    headerVideos.add(
                      VideoItem(
                        index,
                        _pagingController.itemList!,
                      ),
                    );
                    return VideosHeader(headerVideos);
                  } else {
                    return VideoItem(
                      index,
                      _pagingController.itemList!,
                    );
                  }
                },
                firstPageProgressIndicatorBuilder: (_) =>
                    const LoadingIndicatorUtil(),
                firstPageErrorIndicatorBuilder: (_) =>
                    FirstPageExceptionIndicator(
                  title: AppLocalizations.of(context)!.errorOccurred,
                  message: AppLocalizations.of(context)!.errorOccurredDetails,
                  onTryAgain: () => _pagingController.refresh(),
                ),
                newPageProgressIndicatorBuilder: (_) =>
                    const LoadingIndicatorUtil(),
              ),
            ),
          )
        : PagedGridView<int, Video>(
            pagingController: _pagingController,
            scrollController: widget._scrollController,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: width < 800
                  ? 2
                  : width < 1200
                      ? 3
                      : width < 1400
                          ? 4
                          : 5,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
            ),
            builderDelegate: PagedChildBuilderDelegate<Video>(
              itemBuilder: (context, video, index) {
                return VideoItem(
                  index,
                  _pagingController.itemList!,
                );
              },
              firstPageProgressIndicatorBuilder: (_) =>
                  const LoadingIndicatorUtil(),
              firstPageErrorIndicatorBuilder: (_) =>
                  FirstPageExceptionIndicator(
                title: AppLocalizations.of(context)!.errorOccurred,
                message: AppLocalizations.of(context)!.errorOccurredDetails,
                onTryAgain: () => _pagingController.refresh(),
              ),
              newPageProgressIndicatorBuilder: (_) =>
                  const LoadingIndicatorUtil(),
            ),
          );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

class VideosHeader extends StatelessWidget {
  final List<VideoItem> videos;
  VideosHeader(this.videos, {Key? key}) : super(key: key);

  final StoryController controller = StoryController();
  @override
  Widget build(BuildContext context) {
    List<StoryItem> storyItems = [];
    for (var video in videos) {
      storyItems.add(
        StoryItem(
          video,
          duration: const Duration(seconds: 7),
        ),
      );
    }
    return SizedBox(
      height: MediaQuery.of(context).size.width / (16 / 9) + 5,
      child: StoryView(
        storyItems: storyItems,
        progressPosition: ProgressPosition.bottom,
        repeat: true,
        inline: true,
        controller: controller,
      ),
    );
  }
}

class VideosList extends StatelessWidget {
  final List<Video> videos;
  final bool verticalScroll;
  const VideosList(
    this.videos, {
    this.verticalScroll = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: verticalScroll ? Axis.vertical : Axis.horizontal,
      itemCount: videos.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => VideoItem(
        index,
        videos,
      ),
    );
  }
}

class VideoItem extends StatelessWidget {
  final int index;
  final List<Video> videos;
  const VideoItem(
    this.index,
    this.videos, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
      child: kIsWeb
          ? Hover(
              builder: (isHovered) => PhysicalModel(
                color: Colors.transparent,
                elevation: isHovered ? 16 : 0,
                child: Card(
                  elevation: 5.0,
                  color: Colors.transparent,
                  child: OpenContainer(
                    closedColor: Colors.transparent,
                    openColor: Colors.transparent,
                    transitionDuration: const Duration(milliseconds: 500),
                    openBuilder: (context, action) => Swiper(
                      itemBuilder: (context, index) {
                        return VideoScreen(videos[index]);
                      },
                      itemCount: videos.length,
                      scrollDirection: Axis.vertical,
                      control: SwiperControl(
                        disableColor: Theme.of(context).primaryColor,
                      ),
                      index: index,
                      loop: false,
                    ),
                    closedBuilder: (context, action) => Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: videos[index].thumbnailUrl,
                            placeholder: (context, url) => SizedBox(
                              height:
                                  MediaQuery.of(context).size.width / (16 / 9) -
                                      7,
                              child: const LoadingIndicatorUtil(
                                replaceImage: true,
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.error_outlined,
                            ),
                            fadeOutDuration: const Duration(seconds: 1),
                            fadeInDuration: const Duration(seconds: 1),
                            colorBlendMode: BlendMode.darken,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 20, 15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(
                                  bottom: 8,
                                ),
                                child: Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 5,
                                  bottom: 2,
                                ),
                                child: Text(
                                  videos[index].videoDuration,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 5,
                                ),
                                child: Text(
                                  videos[index].caption,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 22,
                                  ),
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
          : Card(
              elevation: 5.0,
              color: Colors.transparent,
              child: OpenContainer(
                closedColor: Colors.transparent,
                openColor: Colors.transparent,
                transitionDuration: const Duration(milliseconds: 500),
                openBuilder: (context, action) => Swiper(
                  itemBuilder: (context, index) {
                    return VideoScreen(videos[index]);
                  },
                  itemCount: videos.length,
                  scrollDirection: Axis.vertical,
                  control: SwiperControl(
                    color: Theme.of(context).colorScheme.onPrimary,
                    disableColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  index: index,
                  loop: false,
                ),
                closedBuilder: (context, action) => Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: videos[index].thumbnailUrl,
                        placeholder: (context, url) => SizedBox(
                          height:
                              MediaQuery.of(context).size.width / (16 / 9) - 7,
                          child: const LoadingIndicatorUtil(
                            replaceImage: true,
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.error_outlined,
                        ),
                        fadeOutDuration: const Duration(seconds: 1),
                        fadeInDuration: const Duration(seconds: 1),
                        colorBlendMode: BlendMode.darken,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 20, 15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(
                              bottom: 8,
                            ),
                            child: Icon(
                              Icons.play_circle_fill_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 5,
                              bottom: 2,
                            ),
                            child: Text(
                              videos[index].videoDuration,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 5,
                            ),
                            child: Text(
                              videos[index].caption,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
