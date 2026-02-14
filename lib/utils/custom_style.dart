import 'package:flutter/material.dart';
import 'package:stereo98/utils/custom_color.dart';
import 'package:stereo98/utils/dimsensions.dart';

class CustomStyler {
  static var splashTitleStyle = const TextStyle(
    color: CustomColor.primaryColor,
    fontSize: 14,
  );

  static var aboutDescriptionTextStyle = TextStyle(
    color: Colors.white,
    fontSize: Dimensions.textSize,
  );

  static var appbarTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: Dimensions.appbarTitleTextSize,
    fontWeight: FontWeight.bold,
  );

  static var defaultButtonStyle = TextStyle(
    color: Colors.white,
    fontSize: Dimensions.defaultButtonTextSize,
    fontWeight: FontWeight.w500,
  );

  static var skipStyle = TextStyle(
    color: Colors.black.withValues(alpha: 0.6),
    fontSize: Dimensions.skipButtonTextSize,
    fontWeight: FontWeight.w500,
  );

  //? Main Screen
  static var appbarTitleTextStyle = TextStyle(
    color: Colors.white,
    fontSize: Dimensions.mainScreenTitleTextSize,
    fontWeight: FontWeight.bold,
  );
  static var songNameTextStyle = TextStyle(
    color: Colors.white,
    fontSize: Dimensions.songNameTextSize,
    fontWeight: FontWeight.w500,
  );
  static var singerNameTextStyle = TextStyle(
    color: Colors.white.withValues(alpha: 0.6),
    fontSize: Dimensions.singerNameTextSize,
    fontWeight: FontWeight.w500,
  );

  //? Drawer Screen
  static var drawerTitleTextStyle = TextStyle(
    color: Colors.white,
    fontSize: Dimensions.drawerTitleTextSize,
    fontWeight: FontWeight.bold,
  );

  //? Schedule Screen
  static var scheduleTitleTextStyle = TextStyle(
    color: Colors.white,
    fontSize: Dimensions.scheduleTitleTextSize,
    fontWeight: FontWeight.w500,
  );
  static var scheduleSubtitleTextStyle = TextStyle(
    color: Colors.white.withValues(alpha: 0.7),
    fontSize: Dimensions.scheduleSubtitleTextSize,
  );

  //? About Screen
  static var aboutTitleTextStyle = TextStyle(
    color: Colors.white,
    fontSize: Dimensions.aboutTitleTextSize,
    fontWeight: FontWeight.bold,
  );
  // static var aboutDescriptionTextStyle = TextStyle(
  //   color: Colors.white.withValues(alpha:0.5),
  //   fontSize: Dimensions.aboutDescriptionTextSize,
  // );

  //? Sleep Timer Screen
  static var sleepTimerTitleTextStyle = TextStyle(
    color: Colors.white.withValues(alpha: 0.6),
    fontSize: Dimensions.sleepTimerTitleTextSize,
    fontWeight: FontWeight.bold,
  );
  static var sleepTimerSubtitleTextStyle = TextStyle(
    color: Colors.white,
    fontSize: Dimensions.sleepTimerSubtitleTextSize,
    fontWeight: FontWeight.bold,
  );

  //? Alarm Screen
  static var setAlarmTextStyle = TextStyle(
    color: Colors.white,
    fontSize: Dimensions.setAlarmTextSize,
    fontWeight: FontWeight.w500,
  );
  static var setAlarmTimeTextStyle = TextStyle(
    color: Colors.white,
    fontSize: Dimensions.setAlarmTimeTextSize,
    fontWeight: FontWeight.w500,
  );
  static var setAlarmTimeAMTextStyle = TextStyle(
    color: Colors.white,
    fontSize: Dimensions.setAlarmTimeAMTextSize,
  );

  static var alarm1TextStyle = TextStyle(
    color: Colors.white,
    fontSize: Dimensions.alarm1TextSize,
  );
  static var alarm1TimeTextStyle = TextStyle(
    color: Colors.white,
    fontSize: Dimensions.alarm1TimeTextSize,
    fontWeight: FontWeight.w500,
  );
  static var alarm1TimeAMTextStyle = TextStyle(
    color: Colors.white,
    fontSize: Dimensions.alarm1TimeAMTextSize,
  );

  //? Settings Screen
  static var settingsScreenTextStyle = TextStyle(
    color: Colors.white,
    fontSize: Dimensions.settingsScreenFontSize,
    fontWeight: FontWeight.w500,
  );

  static var settingsScreenDropDownTextStyle = TextStyle(
    color: Colors.white,
    fontSize: Dimensions.settingsScreenDropDownFontSize,
    fontWeight: FontWeight.w500,
  );
}
