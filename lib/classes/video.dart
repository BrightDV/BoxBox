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

class Video {
  final String videoId;
  final String videoUrl;
  final String caption;
  final String description;
  final String videoDuration;
  final String thumbnailUrl;
  final DateTime datePosted;

  Video(
    this.videoId,
    this.videoUrl,
    this.caption,
    this.description,
    this.videoDuration,
    this.thumbnailUrl,
    this.datePosted,
  );
}

class VideoDetails {
  final String title;
  final List qualities;
  final List urls;
  final String? thumbnailUrl;
  final String? localFilePath;

  VideoDetails(
    this.title,
    this.qualities,
    this.urls,
    this.thumbnailUrl, {
    this.localFilePath,
  });
}
