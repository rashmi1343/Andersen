


import 'package:andersonappnew/models/getteam_model.dart';
import 'package:andersonappnew/screens/NewExpandwidget.dart';
import 'package:andersonappnew/screens/Privacypolicy_screen.dart';
import 'package:andersonappnew/screens/SplashScreen.dart';
import 'package:andersonappnew/screens/documentView.dart';
import 'package:andersonappnew/screens/languagesnew.dart';
import 'package:andersonappnew/screens/submenunew.dart';
import 'package:andersonappnew/screens/team_screen_new.dart';
import 'package:andersonappnew/screens/teams_screen.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';


import 'package:shared_preferences/shared_preferences.dart';


import '../ConnectionUtil.dart';

import '../Localization/localization/language_constants.dart';
import '../Localization/pages/about_page.dart';

import '../constant.dart';

import '../responses/AllDiscussionResponse.dart';
import '../responses/MenuByCountryResponse.dart';
import '../responses/MenuByIdResponse.dart';



import 'NotificationsPage.dart';
import 'countriesnew.dart';


import 'event_page_new.dart';
import 'featuredArticle.dart';


extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class AppIndex extends StatelessWidget {
  const AppIndex({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    return const MaterialApp(home: HomeGridPage());
  }
}

class HomeGridPage extends StatefulWidget {
  const HomeGridPage({Key? key}) : super(key: key);

  @override
  _HomeGridPageState createState() => _HomeGridPageState();
}

class _HomeGridPageState extends State<HomeGridPage> {
  bool isLoading = true;
  int _selectedIndex = 0;
  String selectedCountry = "";

  List<String> menuitem = [];

  StreamSubscription? connection;
  bool isdataconnection = false;

  var Internetstatus = "Unknown";

  // final List localeList = [
  //   {'name': 'ENGLISH', 'locale': const Locale('en', 'US')},
  //   {'name': "اَلْعَرَبِيَّةُ‎", 'locale': const Locale('ar', 'SA')}
  // ];

  // void updateLanguage(Language language) async {
  //   SharedPreferences _prefs = await SharedPreferences.getInstance();
  //   await _prefs.setString(LAGUAGE_CODE, language.languageCode);
  //   // Get.back();
  //   Get.updateLocale(language.locale);

  //   // setState(() {
  //   isLoading = true;
  //   // callApiToGetMenuData();
  //   getMenuByCountryData(ApiConstant.url + ApiConstant.Endpoint);
  //   // });
  // }

  void updateLanguage() async {
    var locale = await getlocale();
    if (locale == 'US') {
      Get.updateLocale(const Locale(ENGLISH, 'US'));
    } else if (locale == 'SA') {
      Get.updateLocale(const Locale(ARABIC, 'SA'));
    }

    // setState(() {
    isLoading = true;
    // callApiToGetMenuData();
    getMenuByCountryData(ApiConstant.url + ApiConstant.Endpoint);
    // });
  }

  List<String> docList = [];
  List<Menubycountry> menubycountry = [];

  List<Menu> menu = [];

//  List imgdata = [];

  //List<Document> document = [];
  final List<String> items = [
    'Pdf',
    'Document',
  ];
  String? selectedValue;
  String? featuredDocument;

  final Connectivity _connectivity = Connectivity();

  // Map _source = {ConnectivityResult.none: false};

  // final CheckInternet _checknetworkConnectivity = CheckInternet.instance;
  // final NetworkConnectivity _checkInternetConnectivity =
  //     NetworkConnectivity.instance;
  bool isInternetAvailable = false;

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accesstoken');
  }

  Future<String?> getSelectedCountry() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.getString('selectedCountry') ?? "";
    selectedCountry = data;

    getMenuByCountryData(ApiConstant.url + ApiConstant.Endpoint);

    return data;
  }

  checkConectivity() async {
    ConnectivityResult connectivityResult =
        await _connectivity.checkConnectivity();

    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
    }
  }

  // getFeaturedDocument() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String data = prefs.getString('featuredDocName') ?? "";
  //   featuredDocument = data;
  //   return data;
  // }

  // Future<Locale> setLocale(String languageCode) async {
  //   SharedPreferences _prefs = await SharedPreferences.getInstance();
  //   await _prefs.setString(LAGUAGE_CODE, languageCode);
  //   return _locale(languageCode);
  // }

  _refresh() {
    retrieveDocListValue();
  }

  Future<String?> getlocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(LAGUAGE_CODE);
  }

  Future<List<Discussionthread>> apiToGetDiscussionData(BuildContext ctx) {
    return getDiscussionData(ctx, ApiConstant.url + ApiConstant.Endpoint);
  }

  Future<List<String>> callapitotallikebydiscussionthread(
      BuildContext ctx, String discussionid) {
    return gettotallikebydiscussionthread(
        ctx, ApiConstant.url + ApiConstant.Endpoint, discussionid);
  }

  Future<List<String>> gettotallikebydiscussionthread(
      BuildContext ctx, String url, String disucssionid) async {
    var token = await getToken();

    var locale = await getlocale();
    Map jsonMap = {
      "methodname": "countlikebydiscussionid",
      "discussion_id": disucssionid.toString()
    };
    print('$url , $jsonMap');
    final response = await http.post(Uri.parse(url), body: jsonMap, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    // debugPrint('${response.statusCode}');
    if (response.statusCode == 200) {
      // final threadsObj = parseJson(response.body);
      // discussionthreads = threadsObj.discussionthreads;
      Map decoded = json.decode(response.body);
      print(response.body);
      print(decoded["likes"].toString());
      //  setState(() {
      //    isLoading = true;
      //_foundedPost = [];
      if (decoded["likes"] != "0") {
        APIDATA.totallike.add(decoded["likes"].toString());
      } else {
        APIDATA.totallike.add("0");
      }
      //    _foundedPost = threadsObj.discussionthreads;
      //  if (kDebugMode) {
      //  print(_foundedPost);
      //   }
      gettotalreplybydiscussionthread(ctx, url, disucssionid);
      //});
      // print(APIDATA.totallike.length);
      return APIDATA.totallike;
      // }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something_went_wrong_please_try_again'.tr),
      ));
      throw Exception('Failed to load data');
    }
  }

  Future<List<String>> gettotalreplybydiscussionthread(
      BuildContext ctx, String url, String disucssionid) async {
    var token = await getToken();

    var locale = await getlocale();
    Map jsonMap = {
      "methodname": "replybydiscussionid",
      "discussion_id": disucssionid.toString()
    };
    //print('$url , $jsonMap');
    final response = await http.post(Uri.parse(url), body: jsonMap, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    //debugPrint('${response.statusCode}');
    if (response.statusCode == 200) {
      // final threadsObj = parseJson(response.body);
      // discussionthreads = threadsObj.discussionthreads;
      Map decoded = json.decode(response.body);
      print(response.body);
      //  setState(() {
      isLoading = false;
      //_foundedPost = [];
      APIDATA.totalreply.add(decoded["replies"].toString());
      //    _foundedPost = threadsObj.discussionthreads;
      //  if (kDebugMode) {
      //  print(_foundedPost);
      //   }
      //  });

      return APIDATA.totalreply;
      // }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something_went_wrong_please_try_again'.tr),
      ));
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
  }

  Future<List<Discussionthread>> getDiscussionData(ctx, String url) async {
    var token = await getToken();

    var locale = await getlocale();
    Map jsonMap = {"methodname": "getalldisucssionthread", "locale": locale};
    print('$url , $jsonMap');
    final response = await http.post(Uri.parse(url), body: jsonMap, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    debugPrint('${response.statusCode}');
    if (response.statusCode == 200) {
      final threadsObj = parseJson(response.body);
      APIDATA.discussionthreads = threadsObj.discussionthreads;

      for (var discussion in APIDATA.discussionthreads) {
        // return new Text(name);
        callapitotallikebydiscussionthread(ctx, discussion.id.toString());
      }

      //setState(() {
      //isLoading = true;
      APIDATA.foundedPost = [];
      APIDATA.foundedPost = threadsObj.discussionthreads;
      //  if (kDebugMode) {
      print(APIDATA.foundedPost);
      //   }
      //});

      return APIDATA.discussionthreads;
      // }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something_went_wrong_please_try_again'.tr),
      ));
      throw Exception('Failed to load data');
    }
  }

  Future<List<Menu>> getMenuData(String url) async {
    var locale = await getlocale();
    Map parammenu = {
      "parent_id": "0",
      "methodname": "getmenubyid",
      "locale": locale
    };

    // if (kDebugMode) {
    print('$url , $parammenu');
    // }

    var token = await getToken();
    if (kDebugMode) {
      print(token);
    }

    final response = await http.post(Uri.parse(url), body: parammenu, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (kDebugMode) {
      print(response.body);
    }

    if (response.statusCode == 200) {
      // data = json.decode(response.body);
      Map decoded = json.decode(response.body);

      final menuObj = menuByIdResponseFromJson(response.body);
      menu = menuObj.menu;

      // if (kDebugMode) {
      print(decoded);
      // }

      // for (var objMenu in decoded["menu"]) {
      //   if (kDebugMode) {
      //     print(objMenu['id']);
      //     print(objMenu['title'].toString());
      //     print(objMenu['locale']);
      //     print(objMenu['parent_id']);
      //     print(objMenu['isActive']);
      //     print(objMenu['Countryname']);
      //   }
      //   // menu.add(objMenu['title']);
      //   menu.add(Menu(
      //       title: objMenu['title'].toString(),
      //       locale: objMenu['locale'],
      //       countryname: objMenu['Countryname'],
      //       id: objMenu['id'],
      //       isActive: objMenu['isActive'],
      //       parentId: objMenu['parent_id']));

      setState(() {
        isLoading = false;
      });
      // }

      /* imgdata.add("assets/images/dashboardicon/vat.png");
      imgdata.add("assets/images/dashboardicon/corporate_tax.png");
      imgdata.add("assets/images/dashboardicon/excise_tax.png");
      imgdata.add("assets/images/dashboardicon/economic.png");
      imgdata.add("assets/images/dashboardicon/custom.png");
      imgdata.add("assets/images/dashboardicon/laborlaw.png");
      imgdata.add("assets/images/dashboardicon/tax_treaties.png");
      imgdata.add("assets/images/dashboardicon/tax_treaties.png");*/
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something_went_wrong_please_try_again'.tr),
      ));
      throw Exception('Failed to load data');
    }
    return menu;
  }

  Future<List<Menubycountry>> getMenuByCountryData(String url) async {
    var locale = await getlocale();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? country_id = prefs.getInt('countryId');
    Map parammenubycountry = {
      "methodname": "getmenubycountryid",
      "locale": locale,
      "country_id": country_id.toString(),
      "parent_id": "0"
    };

    print('$url , $parammenubycountry');

    var token = await getToken();

    print(token);

    //  var available = await isInternet();
    //print(available);

    final response =
        await http.post(Uri.parse(url), body: parammenubycountry, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    print('response Body : ${response.body}');

    /*  if (response.statusCode == 200) {
      Map decoded = json.decode(response.body);

      menubycountry = [];

      if (decoded["menubycountry"].length > 0) {
        for (var objMenuCountry in decoded["menubycountry"]) {
          if (kDebugMode) {
            print(objMenuCountry['country_id']);
            print(objMenuCountry['menu_id']);
            print(objMenuCountry['isActive']);
            print(objMenuCountry['countryname']);
            print(objMenuCountry['menuname']);
            print(objMenuCountry['locale']);
            print(objMenuCountry['parent_id']);
          }

          if (objMenuCountry['isActive'] == 1) {
            menubycountry.add(Menubycountry(
              menuId: objMenuCountry['menu_id'],
              parentId: objMenuCountry['parent_id'],
              isActive: objMenuCountry['isActive'],
              menuname: objMenuCountry['menuname'],
              countryname: objMenuCountry['countryname'],
              locale: objMenuCountry['locale'],
              countryId: objMenuCountry['country_id'],
              filepath: objMenuCountry['filepath'],
              Submenu: objMenuCountry['submenu'],
            ));
          }
          setState(() {
            isLoading = false;
          });
        }

        // menubycountry.add(Menubycountry(
        //     menuId: 14,
        //     parentId: 0,
        //     isActive: 1,
        //     menuname: "Feature Document",
        //     countryname: "United State",
        //     locale: "en",
        //     countryId: 1));

        /*imgdata.add("assets/images/dashboardicon/vat.png");
        imgdata.add("assets/images/dashboardicon/corporate_tax.png");
        imgdata.add("assets/images/dashboardicon/excise_tax.png");
        imgdata.add("assets/images/dashboardicon/economic.png");
        imgdata.add("assets/images/dashboardicon/custom.png");
        imgdata.add("assets/images/dashboardicon/laborlaw.png");
        imgdata.add("assets/images/dashboardicon/tax_treaties.png");
        imgdata.add("assets/images/dashboardicon/tax_treaties.png");
        imgdata.add("assets/images/dashboardicon/tax_treaties.png");*/
      } else {
        setState(() {
          isLoading = false;
        });
        return menubycountry;
      }
    }*/
    if (response.statusCode == 200) {
      Map decoded = json.decode(response.body);

      final menuObj = menuByCountryResponseFromJson(response.body);
      if (menuObj.menubycountry.isNotEmpty) {
        menubycountry = menuObj.menubycountry;
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something_went_wrong_please_try_again'.tr),
      ));
      throw Exception('Failed to load data');
    }
    return menubycountry;
  }





  retrieveDocListValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    docList = prefs.getStringList("selectedfeaturedDoc") ?? [];
   // getAllteam();
    // final doclist = APIDATA.arselecteddocument.toSet().toList();
    // APIDATA.arselecteddocument = doclist;
    // docList = list.toSet().toList();
    // print(docList);
  }
  late Timer timer;
  @override
  void initState() {
    super.initState();
    ConnectionUtil connectionStatus = ConnectionUtil.getInstance();
    connectionStatus.initialize();
   connection= connectionStatus.connectionChange.listen(connectionChanged);

    // getFeaturedDocument();

    BackButtonInterceptor.add(myInterceptor);
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isdataconnection = hasConnection;
      if (isdataconnection) {
        Internetstatus = "Connected TO The Internet";
        isdataconnection = true;
        print('Data connection is available.');
        setState(() {


          retrieveDocListValue();
          getSelectedCountry();

          timer = Timer.periodic(Duration(seconds: 5), (Timer t) =>  getcountfornotification());

        });
      } else if (!isdataconnection) {
        Internetstatus = "No Data Connection";
        isdataconnection = false;
        print('You are disconnected from the internet.');
        setState(() {
          isLoading = false;
        });
      }
    });
  }


  getcountfornotification() async {



    var token = await getToken();
    Map jsonparamdeviceid = {

      "methodname": "getcountfornotification",


    };
    print(jsonparamdeviceid.toString());
    final response = await http.post(Uri.parse(ApiConstant.url + ApiConstant.Endpoint), body: jsonparamdeviceid, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      String token = response.body;
      print(token);
      final parsedJson = jsonDecode(token);

      final notifcationcount = NotificationCount.fromJson(parsedJson);

      print(notifcationcount.status);
      print(notifcationcount.notification_count);
      setState(() {
        Notificationtype.notificationcount =
            notifcationcount.notification_count;
      });
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    connection?.cancel();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("Back To Language Page");
    //  Navigator.pop(context);

    if (["languageroute"].contains(info.currentRoute(context))) return true;

    return false;
  }

  @override
  void didUpdateWidget(HomeGridPage oldWidget) {
    print("didUpdateWidget");
    retrieveDocListValue();
    // getFeaturedDocument();
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  Future<List<Menu>> callApiToGetMenuData() =>
      getMenuData(ApiConstant.url + ApiConstant.Endpoint);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return isdataconnection
        ? RefreshIndicator(
            onRefresh: () {
              return Future.delayed(const Duration(seconds: 1), () {
                setState(() {
                  getSelectedCountry();
                });
              });
            },
            child: SafeArea(
                bottom: true,
                top: false,
                left: true,
                child: Scaffold(
                  appBar: AppBar(
                    centerTitle: false,
                    titleSpacing: 0.0,
                    elevation: 0,
                    title: Transform(
                      // you can forcefully translate values left side using Transform
                      transform: Matrix4.translationValues(0.0, 0.0, 0.0),
                      child: Text(
                        'categories'.tr,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'HelveticaNueueBold',
                          fontSize: 18,
                          color: Color(0xff243444),
                        ),
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                    ),
                    backgroundColor: Colors.white,
                    leading: Builder(
                      builder: (context) => Container(
                        margin: EdgeInsets.only(left: 10),
                        height: 14,
                        width: 18,
                        child: IconButton(
                          alignment: Alignment.centerLeft,
                          icon: Image.asset(
                            'assets/images/menuicon.png',
                            color: Color(0xff8D0C18),
                          ),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                    ),
                    //iconTheme: const IconThemeData(color: Color(0xff243444)),
                    actions: <Widget>[
                      Stack(
                        children: <Widget>[
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => NotificationPage()));
                            },
                            icon: const Icon(FontAwesomeIcons.bell,
                              color: Color(0xff8D0C18),size: 27,),
                            //using font awesome icon in action list of appbar
                          ),

                          Positioned(
                            right: 11,
                            top: 11,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Color(0xff8D0C18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              child:  Text(
                                Notificationtype.notificationcount.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )

                        ],
                      ),

                      IconButton(
                        alignment: Alignment.centerLeft,
                        icon: const Icon(
                          Icons.more_vert_outlined,
                          color: Color(0xff8D0C18), //0xff243444
                        ),
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                const NewExpandablewidget())),
                      ),

                    ],
                  ),
                  drawer: Drawer(
                    // backgroundColor: HexColor.fromHex('#D0D3D4'),
                    backgroundColor: Colors.white,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        DrawerHeader(
                          decoration: BoxDecoration(color: Colors.white),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.centerLeft,
                                height: 41,
                                width: 74.83,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        APIDATA.countryflag.toString()),
                                    fit: BoxFit.fitWidth,
                                    // alignment: Alignment.centerLeft,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    selectedCountry,
                                    // "SAUDI ARABIA",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xffA3AAAE),
                                        fontSize: 16.0,
                                        fontFamily: 'HelveticaNueueBold'),
                                  ),
                                  IconButton(

                                    alignment: Alignment.centerRight,
                                    icon: Image.asset(
                                        'assets/images/edit_icon.png'),
                                    color: const Color(0xff243444),

                                    onPressed: () {
                                      Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const CountriesNew(
                                                          isComingFromSideMenu:
                                                              true)))
                                          // const Languages(isComingFromSideMenu: true)))
                                          .then((value) {
                                        setState(() {
                                          // refresh state of Page1
                                          print('Refresh Selected Country');
                                          isLoading = true;
                                          getSelectedCountry();
                                        });
                                      });
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        /* ListTile(
                  leading: IconButton(
                    padding: EdgeInsets.zero,
                    icon: ImageIcon(
                      AssetImage("assets/images/drawer/global.png"),
                      size: 32,
                    ),
                    onPressed: () {
                      print("You Pressed the icon!");
                    },
                  ),
                  title: Text(
                    'Change Language'.tr,
                    style: const TextStyle(
                        color: Color(0xff76848F),
                        fontSize: 18,
                        fontFamily: 'Helvetica',
                        fontWeight: FontWeight.normal),
                  ),
                  onTap: () {
                    // Navigator.of(context).push(MaterialPageRoute(
                    //     builder: (context) => EventPage()));
                  },
                ),*/
                        ListTile(
                          leading: Container(
                            child: Ink(
                              height: 30,
                              width: 30,
                              // decoration: ShapeDecoration(
                              //   color: Color(0xff76848F),
                              //   shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(8.0),
                              //   ),
                              // ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                /* icon: const Icon(
                          Icons.language,
                          color: Colors.black,
                          size: 20,
                        ),*/
                                icon: Image.asset(
                                    'assets/images/drawer/global.png'),
                                // color: Colors.white,
                                onPressed: () {
                                  print("You Pressed the icon!");
                                },
                              ),
                            ),
                          ),
                          title: Text(
                            'change_language'.tr,
                            style: const TextStyle(
                              color: Color(0xff76848F),
                              fontSize: 18,
                              fontFamily: 'HelveticaNueueMedium',
                            ),
                          ),
                          onTap: () {
                            /* Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => EventPage()));*/

                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Languages(
                                            isComingFromSideMenu: true)))
                                .then((value) {
                              setState(() {
                                // refresh state of Page1
                                print('Refresh Homepage');
                                updateLanguage();
                              });
                            });
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //             const Languages(isComingFromSideMenu: true)));
                          },
                        ),
                        ListTile(
                          leading: Container(
                            child: Ink(
                              height: 30,
                              width: 30,
                              // decoration: ShapeDecoration(
                              //   color: Color(0xff76848F),
                              //   shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(8.0),
                              //   ),
                              // ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                /* icon: const Icon(
                          Icons.info_outline,
                          color: Colors.black,
                          size: 20,
                        ),*/
                                icon: Image.asset(
                                    'assets/images/drawer/aboutus.png'),
                                //  color: Colors.white,
                                onPressed: () {
                                  print("You Pressed the icon!");
                                },
                              ),
                            ),
                          ),
                          title: Text(
                            'about_us'.tr,
                            style: const TextStyle(
                              color: Color(0xff76848F),
                              fontSize: 18,
                              fontFamily: 'HelveticaNueueMedium',
                            ),
                          ),
                          // Text(
                          //   getTranslated(context, 'about_us') ?? "",
                          //   style: _textStyle,
                          // ),
                          onTap: () {
                            // To close the Drawer
                            // Navigator.pop(context);
                            // Navigating to About Page
                            // Navigator.pushNamed(context, aboutRoute);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AboutPage()));
                          },
                        ),
                        /*ListTile(
                  leading: Container(
                    child: Ink(
                      height: 30,
                      width: 30,
                      decoration: ShapeDecoration(
                        color: Color(0xff76848F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        /*  icon: const Icon(
                          Icons.mail,
                          color: Colors.black,
                          size: 20,
                        ),*/
                        icon:
                            Image.asset('assets/images/drawer/messagebox.png'),
                        //  color: Colors.white,
                        onPressed: () {
                          print("You Pressed the icon!");
                        },
                      ),
                    ),
                  ),
                  title: Text(
                    'contact_us'.tr,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Helvetica'),
                  ),
                  // Text(
                  //   getTranslated(context, 'contact_us') ?? "",
                  //   style: _textStyle,
                  // ),
                  onTap: () {
                    // Navigator.of(context).push(MaterialPageRoute(
                    //     builder: (context) =>  ContactUsPage(eventData: '',)));
                  },
                ),*/
                        ListTile(
                          leading: Container(
                            child: Ink(
                              height: 30,
                              width: 30,
                              // decoration: ShapeDecoration(
                              //   color: Color(0xff76848F),
                              //   shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(8.0),
                              //   ),
                              // ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                /* icon: const Icon(
                          Icons.category,
                          color: Colors.black,
                          size: 20,
                        ),*/
                                icon:
                                    Image.asset('assets/images/drawer/cat.png'),

                                //  color: Colors.white,
                                onPressed: () {
                                  //      print("You Pressed the icon!");
                                  //HomeGridPage
                                  Navigator.pop(context);
                                  // Navigator.of(context).push(MaterialPageRoute(
                                  //     builder: (context) => const HomeGridPage()));
                                },
                              ),
                            ),
                          ),
                          title: Text(
                            'categories'.tr,
                            style: TextStyle(
                                color: Color(0xff76848F),
                                fontSize: 18,
                                fontFamily: 'HelveticaNueueMedium'),
                          ),
                          // Text(
                          //   getTranslated(context, 'settings') ?? "",
                          //   style: _textStyle,
                          // ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const HomeGridPage()));

                          },
                        ),
                        ListTile(
                          leading: Container(
                            child: Ink(
                              height: 30,
                              width: 30,

                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon:
                                Image.asset('assets/images/drawer/teamnw.png'),

                                //  color: Colors.white,
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>  teamscreen()));
                                },
                              ),
                            ),
                          ),
                          title: Text(
                            'team'.tr,
                            style: TextStyle(
                                color: Color(0xff76848F),
                                fontSize: 18,
                                fontFamily: 'HelveticaNueueMedium'),
                          ),

                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>  teamscreen()));

                          },
                        ),
                        ListTile(
                          leading: Container(
                            child: Ink(
                              height: 30,
                              width: 30,

                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon:
                                Image.asset('assets/images/drawer/privacypolicy.png'),

                                //  color: Colors.white,
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>  Privacypolicy()));
                                },
                              ),
                            ),
                          ),
                          title: Text(
                            'privacy_policy'.tr,
                            style: TextStyle(
                                color: Color(0xff76848F),
                                fontSize: 18,
                                fontFamily: 'HelveticaNueueMedium'),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>  Privacypolicy()));
                          },
                        ),

                      ],
                    ),
                  ),
                  body: Stack(children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Container(
                          color: Colors.white,
                          alignment: Alignment.topCenter,
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : getGridView(context)),
                    ),
                  ]),
                )),
          )
        : Container(
      color: Colors.white,
      child: Center(
          child:
          Container(
              margin: EdgeInsets.only(
                  left: 30, top: 30, right: 30, bottom: 50),
              height: 150,
              width: 300,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xffD0D3D4),
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.signal_wifi_statusbar_connected_no_internet_4, size: 70, color: Color(0xffAB0E1E),),
                  SizedBox(height: 10,),
                  DefaultTextStyle(
                    style: TextStyle(decoration: TextDecoration.none),
                    child: Text(
                      'No Internet Connection Found! ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'HelveticaNueueMedium',
                        color: Color(0xffAB0E1E),
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  DefaultTextStyle(
                    style: TextStyle(decoration: TextDecoration.none),
                    child: Text(
                      'Please enable your internet ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'HelveticaNueueThin',
                        color: Color(0xff243444),
                      ),
                    ),
                  ),
                ],
              ))),
    );
  }

  Widget getGridView(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    if (menubycountry.isNotEmpty) {
      return Scaffold(
          backgroundColor: const Color(0xffFFFFFF),
          body: SingleChildScrollView(
            // alignment: Alignment.center,
            scrollDirection: Axis.vertical,
            child: Container(
              // padding: const EdgeInsets.all(20),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    //width: 335,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xff243444),
                      boxShadow: const [
                        BoxShadow(blurRadius: 1),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        selectedCountry,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'HelveticaBold',
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const CountriesNew(
                                        isComingFromSideMenu: true)))
                            // const Languages(isComingFromSideMenu: true)))
                            .then((value) {
                          setState(() {
                            // refresh state of Page1
                            print('Refresh Selected Country');
                            isLoading = true;
                            getSelectedCountry();
                          });
                        });
                      },
                      trailing: const ImageIcon(
                          AssetImage('assets/images/edit_icon.png'),
                          size: 12,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  child: InkWell(
                    child: Container(
                      height: 106,
                      // width:
                      // padding: const EdgeInsets.only(left: 5, right: 5),
                      width: screenSize.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        // color: const Color(0xff8e0c18),
                      ),

                      // child: Expanded(

                      child:
                          // APIDATA.arselecteddocument.isNotEmpty
                          //     ? CarouselSlider(
                          //         options: CarouselOptions(
                          //           // height: 300.0,
                          //           initialPage: 0,
                          //           viewportFraction:
                          //               1, // For full width of carousal card
                          //           enableInfiniteScroll: false,
                          //           reverse: false,
                          //           enlargeCenterPage: true,
                          //         ),
                          //         items: APIDATA.arselecteddocument.map((doc) {
                          //           return Builder(
                          //             builder: (BuildContext context) {
                          //               return GestureDetector(
                          //                 onTap: () {
                          //                   APIDATA.pdfUrl =
                          //                       ApiConstant.pdfUrlEndpoint +
                          //                           doc.origFilename.toString();
                          //                   print(APIDATA.pdfUrl);
                          //                   Navigator.of(context).push(
                          //                       MaterialPageRoute(
                          //                           builder: (context) =>
                          //                               PdfViewPage()));
                          //                 },
                          //                 child: Container(
                          //                     padding: const EdgeInsets.only(
                          //                         left: 5, right: 5),
                          //                     width: screenSize.width,
                          //                     margin: EdgeInsets.symmetric(
                          //                         horizontal: 5.0),
                          //                     decoration: BoxDecoration(
                          //                       color: Color(0xff8D0C18),
                          //                       borderRadius:
                          //                           BorderRadius.circular(10),
                          //                     ),
                          //                     child: Align(
                          //                       alignment: Alignment.center,
                          //                       child: Text(
                          //                         // doc.documenttitle.toString(),
                          //                         doc.documenttitle
                          //                             .toString()
                          //                             .inCaps,
                          //                         textAlign: TextAlign.center,
                          //                         style: TextStyle(
                          //                             fontSize: 16.0,
                          //                             color: Colors.white),
                          //                       ),
                          //                     )),
                          //               );
                          //             },
                          //           );
                          //         }).toList(),
                          //       )
                          //     :
                          GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const DocumentView()));
                        },
                        child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: Image.asset(
                              'assets/images/featuredDocument.png',
                              fit: BoxFit.fill,
                            )),
                      ),
                    ),
                    onTap: () {
                      //   //print("Click event on Container");
                      //   Navigator.of(context).push(
                      //       MaterialPageRoute(builder: (context) => DocumentView()));
                    },
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: GridView.builder(
                    // scrollDirection: Axis.vertical,
                    // shrinkWrap: true,
                    // physics: const NeverScrollableScrollPhysics(),
                    // gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    //     maxCrossAxisExtent: 300,
                    //     // childAspectRatio: (MediaQuery.of(context).size.width) /
                    //     //     (MediaQuery.of(context).size.height / 2.4),
                    //     childAspectRatio: 3 / 1.8,
                    //     crossAxisSpacing: 20,
                    //     mainAxisSpacing: 20),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 13,
                      // width / height: fixed for *all* items
                      mainAxisExtent: 100,
                      // childAspectRatio: 3 / 1.8,
                    ),
                    padding: const EdgeInsets.all(10),
                    itemCount: menubycountry.length,
                    //menu.length,
                    itemBuilder: (BuildContext ctx, index) {
                      return GestureDetector(
                          onTap: () async {
                            // setState(() async {
                            _selectedIndex = index;
                            // print(menu[index].id);
                            // debugPrint(menuitem[index]);
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            // prefs.setInt('id', menu[index].id);
                            prefs.setInt('id', menubycountry[index].menuId);

                            // if (menubycountry[index].menuname.contains("Economics")) {
                            //   prefs.setString('menuname',
                            //       menubycountry[index].menuname.substring(1, 9));
                            // } else {
                            prefs.setString(
                                'menuname', menubycountry[index].menuname);
                            APIDATA.menuname = menubycountry[index].menuname;
                            APIDATA.menuicon = menubycountry[index].filepath;
                            // }

                            // if (menubycountry[index]
                            //     .menuname
                            //     .contains("Feature Document")) {
                            //   Navigator.of(ctx).push(MaterialPageRoute(
                            //       builder: (ctx) => const DocumentView()));
                            // } else {
                            /* Navigator.of(ctx).push(MaterialPageRoute(
                          builder: (ctx) => Postbymenu(
                                title: menubycountry[index].menuname,
                              )));*/
                            // Navigator.of(ctx).push(
                            //     MaterialPageRoute(builder: (ctx) => Submenulatest()));
                            if (menubycountry[index]
                                .menuname
                                .contains("events".tr)) {
                              Navigator.of(ctx).push(MaterialPageRoute(
                                  builder: (ctx) => const EventPageNew()));
                            } else if (menubycountry[index]
                                .menuname
                                .contains("feature_articles".tr)) {
                              Navigator.of(ctx).push(MaterialPageRoute(
                                  builder: (ctx) => FeatureArticlePage()));
                            } else if (menubycountry[index]
                                .menuname
                                .contains("featured_document".tr)) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => DocumentView()));
                            } else {
                              /* Navigator.of(ctx).push(MaterialPageRoute(
                            builder: (ctx) => RepeatedMenu(
                                submenuid: menubycountry[index].menuId)));*/

                              APIDATA.submenuid = menubycountry[index].menuId;
                              APIDATA.submenuitem =
                                  menubycountry[index].Submenu;
                              Navigator.of(ctx).push(MaterialPageRoute(
                                  builder: (ctx) => submenunew(
                                      submenuid: menubycountry[index].menuId,
                                      submenu: menubycountry[index].Submenu)));
                            }
                            // }
                          },
                          child: Container(
                              height: 92,
                              width: 161,
                              alignment: Alignment.topLeft,
                              // padding: const EdgeInsets.only(
                              //     left: 10, top: 10, right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xffD0D3D4),
                                    blurRadius: 10.0,
                                  ),
                                ],
                                color: HexColor.fromHex('#d9dbdc'),
                              ),
                              child: Column(
                                //crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Image.asset(imgdata[index],
                                        //     height: 100,
                                        //     width: 60,
                                        //     color: Color(0xff243445)),
                                        SizedBox(
                                          height: 48,
                                          width: 48,
                                          /* decoration: const BoxDecoration(
                                      image: DecorationImage(
                                      image: AssetImage(
                                          "assets/images/rectangle.png"),
                                    )*/
                                          child: FadeInImage.assetNetwork(
                                            placeholder:
                                                'assets/images/no_image.png',
                                            image: menubycountry[index]
                                                    .filepath
                                                    .isNotEmpty
                                                ? ApiConstant.menuiconpoint +
                                                    menubycountry[index]
                                                        .filepath
                                                : '${ApiConstant.menuiconpoint}no_image.png',
                                            height: 48,
                                            width: 48,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                            child: Text(
                                          menubycountry[index]
                                              .menuname
                                              .capitalizeFirstofEach,
                                          // menuitem[index],
                                          //textAlign: TextAlign.left,
                                          textScaleFactor: 1,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              color: Color(0xff243444),
                                              fontFamily: 'HelveticaNueueBold'),
                                          maxLines: 3,
                                          overflow: TextOverflow.clip,
                                        )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 5, bottom: 5),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          // Icon(
                                          //   Icons.arrow_forward_outlined,
                                          //   color: Color(0xff8e0c18),
                                          //   size: 25,
                                          // ),
                                          Image.asset(
                                            'assets/images/right_arrow.png',
                                            height: 15,
                                            width: 15,
                                          ),
                                          SizedBox(width: 5),
                                        ]),
                                  ),
                                ],
                              )));
                    },
                  ),
                ),
              ]),
            ),
          ));
    } else {
      return Center(
          child: Text(
        'no_data_found'.tr,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 14, fontFamily: 'HelveticaMedium', color: Color(0xffAB0E1E)),
      ));
    }
  }
}
