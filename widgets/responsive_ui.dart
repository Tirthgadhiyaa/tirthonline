import 'package:flutter/material.dart';

class Device {
  Device._();

  static double width(BuildContext context) => MediaQuery.of(context).size.width;

  static DeviceType getDeviceType(BuildContext context) {
    final double screenWidth = width(context);

    if (screenWidth >= 1200) {
      return DeviceType.desktop;
    } else if (screenWidth >= 600) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  static bool desktop(BuildContext context) => getDeviceType(context) == DeviceType.desktop;
  static bool tablet(BuildContext context) => getDeviceType(context) == DeviceType.tablet;
  static bool mobile(BuildContext context) => getDeviceType(context) == DeviceType.mobile;
}

enum DeviceType { desktop, tablet, mobile }
