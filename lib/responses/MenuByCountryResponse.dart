import 'package:meta/meta.dart';
import 'dart:convert';

MenuByCountryResponse menuByCountryResponseFromJson(String str) =>
    MenuByCountryResponse.fromJson(json.decode(str));

String menuByCountryResponseToJson(MenuByCountryResponse data) =>
    json.encode(data.toJson());

class MenuByCountryResponse {
  MenuByCountryResponse({
    required this.menubycountry,
  });

  List<Menubycountry> menubycountry;

  factory MenuByCountryResponse.fromJson(Map<String, dynamic> json) =>
      MenuByCountryResponse(
        menubycountry: List<Menubycountry>.from(
            json["menubycountry"].map((x) => Menubycountry.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "menubycountry":
            List<dynamic>.from(menubycountry.map((x) => x.toJson())),
      };
}

class Menubycountry {
  Menubycountry({
    required this.countryId,
    required this.menuId,
    required this.isActive,
    required this.countryname,
    required this.menuname,
    required this.locale,
    required this.parentId,
    required this.filepath,
    required this.listiconpath,
    required this.Submenu,
  });

  int countryId;
  int menuId;
  int isActive;
  String countryname;
  String menuname;
  String locale;
  int parentId;
  String filepath;
  String listiconpath;
  List<Menubycountry> Submenu;

  factory Menubycountry.fromJson(Map<String, dynamic> json) => Menubycountry(
        countryId: json["country_id"],
        menuId: json["menu_id"],
        isActive: json["isActive"],
        countryname: json["countryname"],
        menuname: json["menuname"],
        locale: json["locale"],
        parentId: json["parent_id"],
        filepath: json["filepath"],
        listiconpath: json["listiconpath"],
        Submenu: List<Menubycountry>.from(
            json["submenu"].map((x) => Menubycountry.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "country_id": countryId,
        "menu_id": menuId,
        "isActive": isActive,
        "countryname": countryname,
        "menuname": menuname,
        "locale": locale,
        "parent_id": parentId,
        "filepath": filepath,
        "Submenu": List<dynamic>.from(Submenu.map((x) => x.toJson())),
      };
}
