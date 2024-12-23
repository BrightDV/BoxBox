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

import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RequestErrorWidget extends StatelessWidget {
  final String snapshotError;

  const RequestErrorWidget(this.snapshotError, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
        10,
      ),
      child: Column(
        children: [
          Center(
            child: Text(
              AppLocalizations.of(context)!.requestError,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: SelectableText(
                AppLocalizations.of(context)!.crashError,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Center(
            child: SelectableText(
              snapshotError,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FirstPageExceptionIndicator extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onTryAgain;
  final dynamic pagingController;

  const FirstPageExceptionIndicator({
    required this.title,
    this.message,
    this.onTryAgain,
    this.pagingController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
            ),
            if (message != null)
              const SizedBox(
                height: 16,
              ),
            if (message != null)
              Text(
                message,
                textAlign: TextAlign.center,
              ),
            if (pagingController != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  pagingController.error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            if (onTryAgain != null)
              const SizedBox(
                height: 48,
              ),
            if (onTryAgain != null)
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onTryAgain,
                  icon: const Icon(
                    Icons.refresh,
                    // same
                  ),
                  label: Text(
                    AppLocalizations.of(context)!.tryAgain,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ImageRequestErrorUtil extends StatelessWidget {
  final double? width;
  final double? height;
  const ImageRequestErrorUtil({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          LoadingIndicatorUtil(
            replaceImage: true,
            fullBorderRadius: false,
          ),
          SizedBox(
            height: 100,
            child: Icon(
              Icons.error_outlined,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }
}
