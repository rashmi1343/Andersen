import 'package:flutter/material.dart';

class Language {
  final int id;
  final String name;
  final String flag;
  final String languageCode;
  final Locale locale;

  Language(this.id, this.flag, this.name, this.locale, this.languageCode);

  static List<Language> languageList() {
    return <Language>[
      Language(1, "🇺🇸", "English", const Locale('en', 'US'), "en"),
      Language(2, "🇸🇦", "اَلْعَرَبِيَّةُ‎", const Locale('ar', 'SA'), "ar"),
    ];
  }
}
