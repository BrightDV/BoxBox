import 'package:boxbox/helpers/driver_image.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DriverImageProvider extends StatelessWidget {
  Future<String> getDriverImageUrl(String driverId) async {
    return await DriverResultsImage().getDriverImageURL(driverId);
  }

  final String driverId;

  const DriverImageProvider(this.driverId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDriverImageUrl(driverId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          RequestErrorWidget(snapshot.error.toString());
        }
        return snapshot.hasData
            ? CachedNetworkImage(
                imageUrl: snapshot.data.toString(),
                placeholder: (context, url) => const SizedBox(
                  width: 100,
                  child: LoadingIndicatorUtil(),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error_outlined),
                fadeOutDuration: const Duration(milliseconds: 500),
                fadeInDuration: const Duration(milliseconds: 500),
              )
            : const LoadingIndicatorUtil();
      },
    );
  }
}
