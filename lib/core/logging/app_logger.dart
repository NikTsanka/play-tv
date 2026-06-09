import 'package:logger/logger.dart';

/// App-wide logger. In later milestones this also tees to a rolling file in the
/// app-data directory and feeds the in-app Debug page.
final Logger log = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 6,
    lineLength: 100,
    colors: true,
    printEmojis: false,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);
