import 'package:flutter/material.dart';
import 'package:stereo98/utils/custom_color.dart';
import 'package:stereo98/utils/dimsensions.dart';
import 'package:stereo98/utils/theme_helper.dart';

class CustomStyler {
  static var splashTitleStyle = const TextStyle(
    color: CustomColor.primaryColor,
    fontSize: 14,
  );

  // ── Stili adattivi (richiedono BuildContext) ─────────────────────────────

  static TextStyle aboutDescriptionTextStyle(BuildContext context) => TextStyle(
    color: context.s98Text,
    fontSize: Dimensions.textSize,
  );

  static TextStyle appbarTitleStyle(BuildContext context) => TextStyle(
    color: context.s98Text,
    fontSize: Dimensions.appbarTitleTextSize,
    fontWeight: FontWeight.bold,
  );

  static TextStyle defaultButtonStyle(BuildContext context) => TextStyle(
    color: context.s98Text,
    fontSize: Dimensions.defaultButtonTextSize,
    fontWeight: FontWeight.w500,
  );

  static var skipStyle = TextStyle(
    color: Colors.black.withValues(alpha: 0.6),
    fontSize: Dimensions.skipButtonTextSize,
    fontWeight: FontWeight.w500,
  );

  //? Main Screen
  static TextStyle appbarTitleTextStyle(BuildContext context) => TextStyle(
    color: context.s98Text,
    fontSize: Dimensions.mainScreenTitleTextSize,
    fontWeight: FontWeight.bold,
  );

  static TextStyle songNameTextStyle(BuildContext context) => TextStyle(
    color: context.s98Text,
    fontSize: Dimensions.songNameTextSize,
    fontWeight: FontWeight.w500,
  );

  static TextStyle singerNameTextStyle(BuildContext context) => TextStyle(
    color: context.s98TextSecondary,
    fontSize: Dimensions.singerNameTextSize,
    fontWeight: FontWeight.w500,
  );

  //? Drawer Screen
  static TextStyle drawerTitleTextStyle(BuildContext context) => TextStyle(
    color: context.s98Text,
    fontSize: Dimensions.drawerTitleTextSize,
    fontWeight: FontWeight.bold,
  );

  //? Schedule Screen
  static TextStyle scheduleTitleTextStyle(BuildContext context) => TextStyle(
    color: context.s98Text,
    fontSize: Dimensions.scheduleTitleTextSize,
    fontWeight: FontWeight.w500,
  );

  static TextStyle scheduleSubtitleTextStyle(BuildContext context) => TextStyle(
    color: context.s98TextSecondary,
    fontSize: Dimensions.scheduleSubtitleTextSize,
  );

  //? About Screen
  static TextStyle aboutTitleTextStyle(BuildContext context) => TextStyle(
    color: context.s98Text,
    fontSize: Dimensions.aboutTitleTextSize,
    fontWeight: FontWeight.bold,
  );

  //? Sleep Timer Screen
  static TextStyle sleepTimerTitleTextStyle(BuildContext context) => TextStyle(
    color: context.s98TextMuted,
    fontSize: Dimensions.sleepTimerTitleTextSize,
    fontWeight: FontWeight.bold,
  );

  static TextStyle sleepTimerSubtitleTextStyle(BuildContext context) => TextStyle(
    color: context.s98Text,
    fontSize: Dimensions.sleepTimerSubtitleTextSize,
    fontWeight: FontWeight.bold,
  );

  //? Alarm Screen
  static TextStyle setAlarmTextStyle(BuildContext context) => TextStyle(
    color: context.s98Text,
    fontSize: Dimensions.setAlarmTextSize,
    fontWeight: FontWeight.w500,
  );

  static TextStyle setAlarmTimeTextStyle(BuildContext context) => TextStyle(
    color: context.s98Text,
    fontSize: Dimensions.setAlarmTimeTextSize,
    fontWeight: FontWeight.w500,
  );

  static TextStyle setAlarmTimeAMTextStyle(BuildContext context) => TextStyle(
    color: context.s98Text,
    fontSize: Dimensions.setAlarmTimeAMTextSize,
  );

  static TextStyle alarm1TextStyle(BuildContext context) => TextStyle(
    color: context.s98Text,
    fontSize: Dimensions.alarm1TextSize,
  );

  static TextStyle alarm1TimeTextStyle(BuildContext context) => TextStyle(
    color: context.s98Text,
    fontSize: Dimensions.alarm1TimeTextSize,
    fontWeight: FontWeight.w500,
  );

  static TextStyle alarm1TimeAMTextStyle(BuildContext context) => TextStyle(
    color: context.s98Text,
    fontSize: Dimensions.alarm1TimeAMTextSize,
  );

  //? Settings Screen
  static TextStyle settingsScreenTextStyle(BuildContext context) => TextStyle(
    color: context.s98Text,
    fontSize: Dimensions.settingsScreenFontSize,
    fontWeight: FontWeight.w500,
  );

  static TextStyle settingsScreenDropDownTextStyle(BuildContext context) => TextStyle(
    color: context.s98Text,
    fontSize: Dimensions.settingsScreenDropDownFontSize,
    fontWeight: FontWeight.w500,
  );
}
