import 'dart:ui';

import 'package:andersonappnew/models/getteam_model.dart';
import 'package:andersonappnew/responses/AllDiscussionResponse.dart';
import 'package:andersonappnew/responses/DocumentResponse.dart';
import 'package:andersonappnew/responses/MenuByCountryResponse.dart';
import 'package:andersonappnew/responses/MenuByIdResponse.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApiConstant {
  //static String url = "https://anderson.broadwayinfotech.net.au";
  static String url = "https://beta.andersen.broadwayinfotech.net.au";

  static String loginEndpoint = "/public/api/login";
  static String Endpoint = "/public/api/Andersonforumresources";
  static String menuiconpoint =
      "https://beta.andersen.broadwayinfotech.net.au/public/menuicon/";
  static String menulisticonpoint =
      "https://beta.andersen.broadwayinfotech.net.au/public/menulisticon/";
  static String pdfUrlEndpoint =
      "https://beta.andersen.broadwayinfotech.net.au/public/files/";



  static void message() {
    print('You are Calling Static Method');
  }
}

extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';

  String get allInCaps => this.toUpperCase();

  String get capitalizeFirstofEach =>
      this.split(" ").map((str) => str.capitalize).join(" ");
}

class MESSAGES {
  static const String INTERNET_ERROR = "No Internet Connection";
  static const String INTERNET_ERROR_RETRY =
      "No Internet Connection.\nPlease Retry";
}

class COLORS {
// App Colors //

// ignore: constant_identifier_names

  static const Color APP_THEME_RED_COLOR = Color(0xFFAB0E1E);

  static const Color APP_THEME_DARK_RED_COLOR = Color(0xFF8D0C18);

  static const Color APP_THEME_DARK_BLACK_COLOR = Color(0xFF000000);

  static const Color APP_THEME_LIGHT_BLACK_COLOR = Color(0xFF243444);

  static const Color APP_THEME_DARK_GRAY_COLOR = Color(0xFF76848F);

  static const Color APP_THEME_GRAY_COLOR = Color(0xFFA3AAAE);

  static const Color APP_THEME_LIGHT_GRAY_COLOR = Color(0xFFD0D3D4);
}

class APIDATA {
  //static List<MyObject> myObjectList = [];
  static List<Discussionthread> foundedPost = [];
  static List<String> totallike = [];
  static List<String> totalreply = [];
  static List<Discussionthread> discussionthreads = [];

  static String? countryflag;
  static String? menuicon;
  static String postByMenuTitle = '';
  static String? menuname;

  static String? deviceID;
  // static String selectedMainExpansiontitle = '';
  // static String selectedchildExpansiontitle = '';

  //static List<Menu> selectedsubmenu = [];
  static int submenuid = 0;
  static late Discussionthread selecteddiscussionthreads;

  static late Menubycountry currentmenuitem;
  static late List<Menubycountry> submenuitem;
  static String pdfUrl = '';
  static List<Document> arselecteddocument = [];



}


class Notificationtype {
  static bool notificationcategories=true;
  static bool notificationcontent =true;
  static bool notificationdocumnt=true;
  static int notificationcount =0;
}