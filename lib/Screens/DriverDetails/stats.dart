import 'package:boxbox/api/news.dart';
import 'package:boxbox/helpers/driver_image.dart';
import 'package:boxbox/helpers/loading_indicator_util.dart';
import 'package:boxbox/helpers/request_error.dart';
import 'package:boxbox/scraping/formula_one.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DriverStats extends StatelessWidget {
  final String driverId;

  const DriverStats(this.driverId, {super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}