import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'demo_localization.dart';

// ignore: constant_identifier_names
const String LAGUAGE_CODE = 'languageCode';

//languages code
// ignore: constant_identifier_names
const String ENGLISH = 'en';
// ignore: constant_identifier_names
const String FARSI = 'fa';
// ignore: constant_identifier_names
const String ARABIC = 'ar';
// ignore: constant_identifier_names
const String HINDI = 'hi';

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LAGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LAGUAGE_CODE) ?? "en";
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return const Locale(ENGLISH, 'US');
    case FARSI:
      return const Locale(FARSI, "IR");
    case ARABIC:
      return const Locale(ARABIC, "SA");
    case HINDI:
      return const Locale(HINDI, "IN");
    default:
      return const Locale(ENGLISH, 'US');
  }
}

String? getTranslated(BuildContext context, String key) {
  return DemoLocalizations.of(context)?.translate(key);
}
