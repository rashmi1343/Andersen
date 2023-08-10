// To parse this JSON data, do
//
//     final country = countryFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

Country countryFromJson(String str) =>
    Country.fromCountryJson(json.decode(str));

String countryToJson(Country data) => json.encode(data.toJson());

class Country {
  Country({
    required this.country,
  });

  final List<CountryElement> country;

  factory Country.fromCountryJson(Map<String, dynamic> json) => Country(
        country: List<CountryElement>.from(
            json["Country"].map((x) => CountryElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Country": List<dynamic>.from(country.map((x) => x.toJson())),
      };
}

class CountryElement {
  CountryElement({
    required this.id,
    required this.countryname,
    required this.countrycode,
    required this.countrylocale,
    required this.isActive,
    required this.filepath,
  });

  final int id;
  final String countryname;
  final String countrycode;
  final String countrylocale;
  final int isActive;
   var filepath;

  factory CountryElement.fromJson(Map<String, dynamic> json) => CountryElement(
        id: json["id"],
        countryname: json["countryname"],
        countrycode: json["countrycode"],
        countrylocale: json["countrylocale"],
        isActive: json["isActive"],
        filepath: json["filepath"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "countryname": countryname,
        "countrycode": countrycode,
        "countrylocale": countrylocale,
        "isActive": isActive,
      };
}
