import 'dart:ffi';

import 'package:meta/meta.dart';
import 'dart:convert';

MenuByIdResponse menuByIdResponseFromJson(String str) =>
    MenuByIdResponse.fromJson(json.decode(str));

String menuByIdResponseToJson(MenuByIdResponse data) =>
    json.encode(data.toJson());

class MenuByIdResponse {
  MenuByIdResponse({
    required this.menu,
  });

  List<Menu> menu;

  factory MenuByIdResponse.fromJson(Map<String, dynamic> json) =>
      MenuByIdResponse(
        menu: List<Menu>.from(json["menu"].map((x) => Menu.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "menu": List<dynamic>.from(menu.map((x) => x.toJson())),
      };
}

class Menu {
  Menu({
    required this.id,
    required this.title,
    required this.parentId,
    required this.isActive,
    required this.locale,
    required this.countryname,
    required this.isSelected,
    required this.listiconpath,
    required this.Submenu,
  });

  int id;
  String title;
  int parentId;
  int isActive;
  String locale;
  String countryname;
  bool isSelected;
  String listiconpath;
  List<Menu> Submenu;

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        id: json["id"],
        title: json["title"],
        parentId: json["parent_id"],
        isActive: json["isActive"],
        locale: json["locale"],
        countryname: json["Countryname"],
        isSelected: false,
        listiconpath: json["listiconpath"],
        Submenu: List<Menu>.from(json["submenu"].map((x) => Menu.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "parent_id": parentId,
        "isActive": isActive,
        "locale": locale,
        "Countryname": countryname,
        "isSelected": isSelected,
//        "Submenu": Submenu,
        "Submenu": List<dynamic>.from(Submenu.map((x) => x.toJson())),
      };
}
