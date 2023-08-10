import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'demo_localization.dart';

class DemoLocalizationsSetup {
  static const Iterable<Locale> supportedLocales = [
    Locale("en", "US"),
    Locale("fa", "IR"),
    Locale("ar", "SA"),
    Locale("hi", "IN")
  ];

  static const Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates =
      [
    DemoLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static Locale localeResolutionCallback(
      Locale locale, Iterable<Locale> supportedLocales) {
    for (Locale supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode &&
          supportedLocale.countryCode == locale.countryCode) {
        return supportedLocale;
      }
    }
    return supportedLocales.first;
  }
}
