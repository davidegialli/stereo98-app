import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stereo98/controller/language_controller.dart';
import 'package:stereo98/utils/custom_color.dart';
import 'package:stereo98/utils/custom_style.dart';
import 'package:stereo98/utils/size.dart';
import 'package:stereo98/utils/strings.dart';
import 'package:stereo98/utils/themes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final languageController = Get.put(LanguageController());

  int dropdownValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: CustomColor.whiteColor,
          onPressed: (() {
            Get.close(1);
          }),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          Strings.settings.tr,
          style: const TextStyle(color: CustomColor.whiteColor),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).cardColor,
              Theme.of(context).canvasColor,
            ],
          ),
        ),
        child: ListView(
          children: [
            addVerticalSpace(18),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.darkModeSelect.tr,
                    style: CustomStyler.settingsScreenTextStyle,
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton(
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                          size: 35,
                        ),
                        value: dropdownValue,
                        items: [
                          DropdownMenuItem(
                            value: AppThemes.light,
                            child: Text(
                              AppThemes.toStr(AppThemes.light),
                              style:
                                  CustomStyler.settingsScreenDropDownTextStyle,
                            ),
                          ),
                          DropdownMenuItem(
                            value: AppThemes.dark,
                            child: Text(
                              AppThemes.toStr(AppThemes.dark),
                              style:
                                  CustomStyler.settingsScreenDropDownTextStyle,
                            ),
                          ),
                        ],
                        onChanged: (dynamic themeId) async {
                          await DynamicTheme.of(context)!.setTheme(themeId);
                          setState(() {
                            dropdownValue = themeId;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            addVerticalSpace(12),
            Obx(
              () => SizedBox(
                height: 50,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        Strings.changeLanguage.tr,
                        style: CustomStyler.settingsScreenDropDownTextStyle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 34),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          alignment: Alignment.topRight,
                          hint: const Center(child: Text("")),
                          value: languageController.locale.value,
                          items: languageController.optionsLocales.entries.map((
                            item,
                          ) {
                            return DropdownMenuItem<String>(
                              value: item.key,
                              child: Text(
                                item.value['description'],
                                style: CustomStyler
                                    .settingsScreenDropDownTextStyle,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            languageController.updateLocale(value.toString());
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
