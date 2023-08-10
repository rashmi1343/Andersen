import 'dart:ui';

import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/internacionalization.dart';

import '../lang/ar_SA.dart';
import '../lang/en_us.dart';


class LocalizationService extends Translations {
  // Default locale
  static final locale = Locale('ar', 'SA');

  static final localeen = Locale('en', 'US');

  // fallbackLocale saves the day when the locale gets in trouble
  // static final fallbackLocale = Locale('tr', 'TR');
  static final fallbackLocale = Locale('ar', 'SA');
  static final fallbackLocaleen = Locale('en', 'US');

  // Supported languages
  // Needs to be same order with locales
  static final langs = [
    'English',
    // 'Türkçe',
    // '日本語',
    'Arabic'
  ];

  // Supported locales
  // Needs to be same order with langs
  static final locales = [
    const Locale('en', 'US'),
    //  Locale('tr', 'TR'),
    //  Locale('ja', 'JP'),
    const Locale('ar', 'SA')
  ];

  // Keys and their translations
  // Translations are separated maps in `lang` file
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS, // lang/en_us.dart
        //   'tr_TR': trTR, // lang/tr_tr.dart
        //   'ja_JP': jaJP, // lang/ja_jp.dart
        'ar_SA': arSA,
      };

  // Gets locale from language, and updates the locale
  void changeLocale(String lang) {
    final locale = _getLocaleFromLanguage(lang);
    Get.updateLocale(locale!);
  }

  // Finds language in `langs` list and returns it as Locale
  Locale? _getLocaleFromLanguage(String lang) {
    for (int i = 0; i < langs.length; i++) {
      if (lang == langs[i]) return locales[i];
    }
    return Get.locale;
  }
}
