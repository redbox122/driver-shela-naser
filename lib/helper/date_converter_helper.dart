import 'package:shellafood_delivery/features/splash/controllers/splash_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class DateConverterHelper {
  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd hh:mm:ss').format(dateTime);
  }

  static String estimatedDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  static String dateTimeStringToDateTime(String dateTime) {
    return DateFormat('dd MMM yyyy  ${_timeFormatter()}')
        .format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime));
  }

  static String dateTimeStringToDateOnly(String dateTime) {
    return DateFormat('dd MMM yyyy')
        .format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime));
  }

  static DateTime dateTimeStringToDate(String dateTime) {
    try {
      // Always normalize to local time before any comparisons
      if (dateTime.contains('T') || dateTime.contains('Z')) {
        return DateTime.parse(dateTime).toLocal();
      }
      final DateTime parsed =
          DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime, true);
      return parsed.toLocal();
    } catch (e) {
      // Fallback to basic parsing and local normalization
      return DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime).toLocal();
    }
  }

  static DateTime convertStringToDatetime(String dateTime) {
    return DateFormat("yyyy-MM-ddTHH:mm:ss.SSS").parse(dateTime);
  }

  static DateTime isoStringToLocalDate(String dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(dateTime).toLocal();
  }

  static String isoStringToLocalTimeOnly(String dateTime) {
    return DateFormat(_timeFormatter()).format(isoStringToLocalDate(dateTime));
  }

  static String isoStringToLocalDateOnly(String dateTime) {
    return DateFormat('dd MMM yyyy').format(isoStringToLocalDate(dateTime));
  }

  static String isoStringToLocalAMPM(String dateTime) {
    return DateFormat('a').format(isoStringToLocalDate(dateTime));
  }

  static String isoStringToLocalDateAnTime(String dateTime) {
    return DateFormat('dd/MMM/yyyy ${_timeFormatter()}')
        .format(isoStringToLocalDate(dateTime));
  }

  static String localDateToIsoString(DateTime dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(dateTime);
  }

  static String convertTimeToTime(String time) {
    return DateFormat(_timeFormatter())
        .format(DateFormat('hh:mm:ss').parse(time));
  }

  static int timeDistanceInMin(String time) {
    try {
      DateTime currentTime = Get.find<SplashController>().currentTime;
      DateTime rangeTime = dateTimeStringToDate(time);
      Duration difference = currentTime.difference(rangeTime);

      // Ensure we return positive minutes only (avoid negative values)
      int minutes = difference.inMinutes.abs();

      // Cap at reasonable maximum to prevent showing huge numbers
      // Max 1 day = 1440 minutes
      const int maxMinutes = 1440;
      return minutes > maxMinutes ? maxMinutes : minutes;
    } catch (e) {
      // Return 0 if parsing fails to avoid showing errors
      return 0;
    }
  }

  /// Returns human-readable time difference in minutes based on server time
  static String timeDistanceAgo(String time) {
    try {
      DateTime currentTime = Get.find<SplashController>().currentTime;
      DateTime rangeTime = dateTimeStringToDate(time);
      Duration difference = currentTime.difference(rangeTime);
      if (difference.isNegative) {
        debugPrint('Server time skew detected; showing time with abs diff.');
        difference = rangeTime.difference(currentTime);
      }

      final int minutes = difference.inMinutes;
      return '$minutes ${'mins_ago'.tr}';
    } catch (e) {
      // Fallback - show capped minutes
      int mins = timeDistanceInMin(time);
      return '$mins ${'mins_ago'.tr}';
    }
  }

  static String _timeFormatter() {
    return Get.find<SplashController>().configModel!.timeformat == '24'
        ? 'HH:mm'
        : 'hh:mm a';
  }

  static String localDateToIsoStringAMPM(DateTime dateTime) {
    return DateFormat('${_timeFormatter()} | d-MMM-yyyy ')
        .format(dateTime.toLocal());
  }

  static String dateTimeStringForDisbursement(String time) {
    var newTime = '${time.substring(0, 10)} ${time.substring(11, 23)}';
    return DateFormat('dd MMM, yyyy')
        .format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(newTime));
  }

  static String dateTimeForCoupon(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }
}
