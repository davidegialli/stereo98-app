import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stereo98/controller/home_controller.dart';
import 'package:stereo98/services/notification_service.dart';
import 'package:stereo98/controller/language_controller.dart';
import 'package:stereo98/utils/custom_style.dart';
import 'package:stereo98/utils/size.dart';
import 'package:stereo98/utils/strings.dart';
import 'package:stereo98/utils/themes.dart';
import 'package:stereo98/utils/theme_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final languageController = Get.put(LanguageController());
  final _box = GetStorage();

  int dropdownValue = AppThemes.scuro;

  // Per Automatico: tema scuro e chiaro preferiti
  int _autoDarkTheme  = AppThemes.scuro;
  int _autoLightTheme = AppThemes.chiaro;

  @override
  void initState() {
    super.initState();
    dropdownValue   = _box.read('stereo98_theme_mode')  ?? AppThemes.scuro;
    _autoDarkTheme  = _box.read('stereo98_dark_theme')   ?? AppThemes.scuro;
    _autoLightTheme = _box.read('stereo98_light_theme')  ?? AppThemes.chiaro;
  }

  void _applyTheme(int themeId) {
    _box.write('stereo98_theme_mode', themeId);
    setState(() => dropdownValue = themeId);
    if (themeId == AppThemes.auto) {
      final brightness = MediaQuery.of(context).platformBrightness;
      final effectiveTheme = brightness == Brightness.dark ? _autoDarkTheme : _autoLightTheme;
      DynamicTheme.of(context)?.setTheme(effectiveTheme);
    } else {
      // Salva come preferito scuro o chiaro per l'auto
      if (AppThemes.isLight(themeId)) {
        _box.write('stereo98_light_theme', themeId);
        _autoLightTheme = themeId;
      } else {
        _box.write('stereo98_dark_theme', themeId);
        _autoDarkTheme = themeId;
      }
      DynamicTheme.of(context)?.setTheme(themeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.s98Text),
          onPressed: (() {
            Get.close(1);
          }),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          Strings.settings.tr,
          style: TextStyle(color: context.s98Text),
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
            // === TEMA ===
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.darkModeSelect.tr,
                    style: CustomStyler.settingsScreenTextStyle(context),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton(
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: context.s98Icon,
                          size: 35,
                        ),
                        value: dropdownValue,
                        items: [
                          // ── Automatico ──
                          DropdownMenuItem(
                            value: AppThemes.auto,
                            child: Text('${AppThemes.icon(AppThemes.auto)} ${AppThemes.toStr(AppThemes.auto)}',
                              style: CustomStyler.settingsScreenDropDownTextStyle(context)),
                          ),
                          // ── Temi scuri ──
                          ...AppThemes.darkThemes.map((id) => DropdownMenuItem(
                            value: id,
                            child: Text('${AppThemes.icon(id)} ${AppThemes.toStr(id)}',
                              style: CustomStyler.settingsScreenDropDownTextStyle(context)),
                          )),
                          // ── Temi chiari ──
                          ...AppThemes.lightThemes.map((id) => DropdownMenuItem(
                            value: id,
                            child: Text('${AppThemes.icon(id)} ${AppThemes.toStr(id)}',
                              style: CustomStyler.settingsScreenDropDownTextStyle(context)),
                          )),
                        ],
                        onChanged: (dynamic themeId) {
                          _applyTheme(themeId);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Sub-dropdown per Automatico: scuro + chiaro preferiti ──
            if (dropdownValue == AppThemes.auto) ...[
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 24, top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tema scuro', style: TextStyle(color: context.s98TextMuted, fontSize: 13)),
                    DropdownButton<int>(
                      icon: Icon(Icons.arrow_drop_down, color: context.s98IconMuted, size: 28),
                      value: _autoDarkTheme,
                      items: AppThemes.darkThemes.map((id) => DropdownMenuItem(
                        value: id,
                        child: Text('${AppThemes.icon(id)} ${AppThemes.toStr(id)}',
                          style: TextStyle(color: context.s98Text, fontSize: 13)),
                      )).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _autoDarkTheme = value);
                          _box.write('stereo98_dark_theme', value);
                          // Se attualmente è scuro, applica subito
                          final brightness = MediaQuery.of(context).platformBrightness;
                          if (brightness == Brightness.dark) {
                            DynamicTheme.of(context)?.setTheme(value);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 24, top: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tema chiaro', style: TextStyle(color: context.s98TextMuted, fontSize: 13)),
                    DropdownButton<int>(
                      icon: Icon(Icons.arrow_drop_down, color: context.s98IconMuted, size: 28),
                      value: _autoLightTheme,
                      items: AppThemes.lightThemes.map((id) => DropdownMenuItem(
                        value: id,
                        child: Text('${AppThemes.icon(id)} ${AppThemes.toStr(id)}',
                          style: TextStyle(color: context.s98Text, fontSize: 13)),
                      )).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _autoLightTheme = value);
                          _box.write('stereo98_light_theme', value);
                          final brightness = MediaQuery.of(context).platformBrightness;
                          if (brightness == Brightness.light) {
                            DynamicTheme.of(context)?.setTheme(value);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],

            addVerticalSpace(12),
            // === QUALITÀ STREAMING ===
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Qualità streaming',
                    style: CustomStyler.settingsScreenTextStyle(context),
                  ),
                  Obx(() {
                    final controller = Get.find<HomeController>();
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<String>(
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: context.s98Icon,
                          size: 35,
                        ),
                        value: controller.streamQuality.value,
                        items: [
                          DropdownMenuItem(
                            value: '320',
                            child: Text('Alta (320 kbps)',
                              style: TextStyle(color: context.s98Text, fontSize: 14)),
                          ),
                          DropdownMenuItem(
                            value: '256',
                            child: Text('Media (256 kbps)',
                              style: TextStyle(color: context.s98Text, fontSize: 14)),
                          ),
                          DropdownMenuItem(
                            value: '128',
                            child: Text('Bassa (128 kbps)',
                              style: TextStyle(color: context.s98Text, fontSize: 14)),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            controller.setStreamQuality(value);
                          }
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            addVerticalSpace(12),
            // === NOTIFICA PALINSESTO ===
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifica programmi',
                    style: CustomStyler.settingsScreenTextStyle(context),
                  ),
                  Obx(() {
                    final controller = Get.find<HomeController>();
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<int>(
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: context.s98Icon,
                          size: 35,
                        ),
                        value: controller.notifyMinutesBefore.value,
                        items: [
                          DropdownMenuItem(
                            value: 5,
                            child: Text('5 min prima',
                              style: TextStyle(color: context.s98Text, fontSize: 14)),
                          ),
                          DropdownMenuItem(
                            value: 10,
                            child: Text('10 min prima',
                              style: TextStyle(color: context.s98Text, fontSize: 14)),
                          ),
                          DropdownMenuItem(
                            value: 15,
                            child: Text('15 min prima',
                              style: TextStyle(color: context.s98Text, fontSize: 14)),
                          ),
                          DropdownMenuItem(
                            value: 30,
                            child: Text('30 min prima',
                              style: TextStyle(color: context.s98Text, fontSize: 14)),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            controller.setNotifyMinutes(value);
                          }
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            addVerticalSpace(12),
            // === LINGUA ===
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
                        style: CustomStyler.settingsScreenDropDownTextStyle(context),
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
                                    .settingsScreenDropDownTextStyle(context),
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
