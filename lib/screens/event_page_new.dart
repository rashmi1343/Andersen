import 'dart:async';
import 'dart:convert';

import 'package:andersonappnew/Localization/localization/language_constants.dart';
import 'package:andersonappnew/Localization/pages/about_page.dart';
import 'package:andersonappnew/Localization/pages/contact_us_page.dart';
import 'package:andersonappnew/screens/HomeMenuPage.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../constant.dart';
import '../../../responses/EventsResponse.dart';

import '../../ConnectionUtil.dart';
import '../../responses/MenuByCountryResponse.dart';
import '../../screens/NewExpandwidget.dart';
import '../../screens/countriesnew.dart';
import '../../screens/languagesnew.dart';

class EventPageNew extends StatefulWidget {
  const EventPageNew({super.key});

  @override
  _EventPageNewState createState() => _EventPageNewState();
}

class _EventPageNewState extends State<EventPageNew>
    with SingleTickerProviderStateMixin {
  @override
  bool wantKeepAlive = true;

  bool isLoading = true;
  int _selectedIndex = 0;
  List<Tab> myTabs = <Tab>[
    Tab(text: 'upcoming'.tr),
    Tab(text: 'previous'.tr),
  ];
  List<Event> arrevents = [];
  List<Event> arrpastevents = [];
  late TabController _tabController;

  String? selectedDoc;
  StreamSubscription? connection;
  bool isdataconnection = false;

  var Internetstatus = "Unknown";

  // List<Events> selectedEvents = [];
  List<String> selectedEvents = [];

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accesstoken');
  }

  Future<String?> getlocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(LAGUAGE_CODE);
  }

  Future<List<Event>> getEventsData(String url) async {
    var locale = await getlocale();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Map paramevents = {"methodname": "getevents", "locale": locale};

    print('$url , $paramevents');

    var token = await getToken();

    print(token);

    final response =
    await http.post(Uri.parse(url), body: paramevents, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    print(response.body);

    if (response.statusCode == 200) {
      Map decoded = json.decode(response.body);
      final eventObj = eventsResponseFromJson(response.body);
      if (eventObj.events.isNotEmpty) {
        arrevents = eventObj.events;
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No Events Available!"),
        ));
      }

      // print(decoded);
      // arrevents = [];
      // for (var objEvent in decoded["Events"]) {
      //   if (kDebugMode) {
      //     print(objEvent['id']);
      //     print(objEvent['event_name']);
      //     print(objEvent['from']);
      //     print(objEvent['to']);
      //     print(objEvent['date']);
      //     print(objEvent['orig_filename']);
      //     print(objEvent['mime_type']);
      //     print(objEvent['filesize']);
      //     print(objEvent['description']);
      //     print(objEvent['time']);
      //   }
      //
      //   arrevents.add(Event(
      //     id: objEvent['id'],
      //     eventName: objEvent['event_name'],
      //     from: objEvent['from'],
      //     to: objEvent['to'],
      //     date: objEvent['date'],
      //     origFilename: objEvent['orig_filename'],
      //     mimeType: objEvent['mime_type'],
      //     filesize: objEvent['filesize'],
      //     description: objEvent['description'],
      //     time: objEvent['time'],
      //   ));
      //
      //   setState(() {
      //     isLoading = false;
      //   });
      // }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something_went_wrong_please_try_again'.tr),
      ));
      throw Exception('Failed to load data');
    }
    return arrevents;
  }

  Future<List<Event>> getPastEventsData(String url) async {
    var locale = await getlocale();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Map parampastevents = {"methodname": "getpastevents", "locale": locale};

    print('$url , $parampastevents');

    var token = await getToken();

    print(token);

    final response =
    await http.post(Uri.parse(url), body: parampastevents, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    print(response.body);

    if (response.statusCode == 200) {
      Map decoded = json.decode(response.body);
      final pasteventObj = eventsResponseFromJson(response.body);
      if (pasteventObj.events.isNotEmpty) {
        arrpastevents = pasteventObj.events;
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No Past Events Available!"),
        ));
      }

      // print(decoded);
      // arrpastevents = [];
      // for (var objPastEvent in decoded["Events"]) {
      //   if (kDebugMode) {
      //     print(objPastEvent['id']);
      //     print(objPastEvent['event_name']);
      //     print(objPastEvent['from']);
      //     print(objPastEvent['to']);
      //     print(objPastEvent['date']);
      //     print(objPastEvent['orig_filename']);
      //     print(objPastEvent['mime_type']);
      //     print(objPastEvent['filesize']);
      //     print(objPastEvent['description']);
      //     print(objPastEvent['time']);
      //   }
      //
      //   arrpastevents.add(Event(
      //       id: objPastEvent['id'],
      //       eventName: objPastEvent['event_name'],
      //       date: objPastEvent['date'],
      //       origFilename: objPastEvent['orig_filename'],
      //       mimeType: objPastEvent['mime_type'],
      //       filesize: objPastEvent['filesize'],
      //       description: objPastEvent['description'],
      //       time: objPastEvent['time'],
      //       from: '',
      //       to: ''));
      //
      //   setState(() {
      //     isLoading = false;
      //   });
      // }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something_went_wrong_please_try_again'.tr),
      ));
      throw Exception('Failed to load data');
    }
    return arrpastevents;
  }

  @override
  void initState() {
    super.initState();
    ConnectionUtil connectionStatus = ConnectionUtil.getInstance();
    connectionStatus.initialize();
    connection = connectionStatus.connectionChange.listen(connectionChanged);
    _tabController = TabController(vsync: this, length: myTabs.length);

    BackButtonInterceptor.add(myInterceptor);
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isdataconnection = hasConnection;
      if (isdataconnection) {
        Internetstatus = "Connected To The Internet";
        isdataconnection = true;
        print('Data connection is available.');
        setState(() {
          isLoading = true;
          getSelectedCountry();
          // getEvents();
          // getPastEvents();
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

  // late NavigatorState _navigator;
  //
  // @override
  // void didChangeDependencies() {
  //   _navigator = Navigator.of(context);
  //   super.didChangeDependencies();
  // }

  @override
  void dispose() {
    // BackButtonInterceptor.remove(myInterceptor);
    connection?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (["homeMenuRoute"].contains(info.currentRoute(context))) return true;

    print("Back To Home Page");
    return false;
  }

  Future<List<Event>> getEvents() =>
      getEventsData(ApiConstant.url + ApiConstant.Endpoint);

  Future<List<Event>> getPastEvents() =>
      getPastEventsData(ApiConstant.url + ApiConstant.Endpoint);

  // Future<bool> _onWillPop() async {
  //   return false;
  // }
  Future<bool> _onWillPop() async {
    print("on will pop");
    if (_tabController.index == 0) {
      await SystemNavigator.pop();
    }

    Future.delayed(Duration(milliseconds: 200), () {
      print("set index");
      _tabController.index = 0;
    });

    print("return");
    return _tabController.index == 0;
  }

  String selectedCountry = "";
  List<Menubycountry> menubycountry = [];

  Future<String?> getSelectedCountry() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.getString('selectedCountry') ?? "";
    selectedCountry = data;

    getMenuByCountryData(ApiConstant.url + ApiConstant.Endpoint);

    return data;
  }

  Future<List<Menubycountry>> getMenuByCountryData(String url) async {
    var locale = await getlocale();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('countryId');
    Map parammenubycountry = {
      "methodname": "getmenubycountryid",
      "locale": locale,
      "country_id": id.toString(),
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

    if (response.statusCode == 200) {
      Map decoded = json.decode(response.body);

      final menuObj = menuByCountryResponseFromJson(response.body);
      if (menuObj.menubycountry.isNotEmpty) {
        menubycountry = menuObj.menubycountry;
        setState(() {
          getEvents();
          getPastEvents();

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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    return isdataconnection
        ? Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0.0,
        elevation: 0,
        title: Transform(
          // you can forcefully translate values left side using Transform
          transform: Matrix4.translationValues(0.0, 0.0, 0.0),
          child: Text(
            'events'.tr,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'HelveticaNueueBold',
              fontSize: 18,
              color: Color(0xff243444),
            ),
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
          IconButton(
            alignment: Alignment.centerLeft,
            icon: const Icon(
              Icons.more_vert_outlined,

              color: Color(0xff8D0C18), //0xff243444
            ),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const NewExpandablewidget())),
          ),
          // PopupMenuButton(
          //     icon: const Icon(
          //       Icons.more_vert_outlined,
          //       color: Color(0xff243444), //0xff243444
          //     ), //Icons.more_horiz_outlined,
          //     onSelected: (selectedValue) {
          //       if (selectedValue == 1) {
          //         print(selectedValue);
          //       }
          //     },
          //     itemBuilder: (BuildContext ctx) => [
          //           //  PopupMenuItem(child: Text(' Choose Document '), value: '1'),
          //           PopupMenuItem<String>(
          //             value: "1",
          //             child: ListTile(
          //               leading: const Icon(Icons.file_copy_rounded,
          //                   color: Color(0xff8e0c18)),
          //               //     title: Text("choose_document".tr),
          //               title: Text("categories".tr),
          //               onTap: () {
          //                 Navigator.pop(context, "1");
          //                 //  Navigator.of(context).push(MaterialPageRoute(
          //                 //     builder: (context) => const DocumentView()));
          //                 Navigator.of(context).push(MaterialPageRoute(
          //                     builder: (context) =>
          //                         NewExpandablewidget()));
          //               },
          //             ),
          //           ),
          //         ]),
          const SizedBox(
            width: 10.0,
          ),
        ],
      ),
      drawer: Drawer(
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
                        image:
                        NetworkImage(APIDATA.countryflag.toString()),
                        fit: BoxFit.fitWidth,
                        // alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        selectedCountry,
                        // "SAUDI ARABIA",
                        style: const TextStyle(
                          // fontWeight: FontWeight.bold,
                            color: Color(0xffA3AAAE),
                            fontSize: 16.0,
                            fontFamily: 'HelveticaNueueBold'),
                      ),
                      IconButton(
                        alignment: Alignment.centerRight,
                        icon: Image.asset('assets/images/edit_icon.png'),
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
                    icon: Image.asset('assets/images/drawer/global.png'),
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
                            isComingFromSideMenu: true))).then((value) {
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
                    icon: Image.asset('assets/images/drawer/aboutus.png'),
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
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AboutPage()));
              },
            ),
            ListTile(
              leading: Container(
                child: Ink(
                  height: 30,
                  width: 30,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    /* icon: const Icon(
                          Icons.category,
                          color: Colors.black,
                          size: 20,
                        ),*/
                    icon: Image.asset('assets/images/drawer/cat.png'),

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
                style: const TextStyle(
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
          ],
        ),
      ),

      // backgroundColor: HexColor.fromHex('#D0D3D4'),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),

              Padding(
                padding: EdgeInsets.zero,
                child: SizedBox(
                  //alignment: Alignment.bottomCenter,
                  // padding: const EdgeInsets.all(10),
                  //  height: 138.96,
                  //  width: 138.96,
                  child: Center(
                      child: Image.asset(
                        'assets/images/announcement.png',
                        alignment: Alignment.center,
                        fit: BoxFit.fitHeight,
                      )),
                ),
              ),
              // const Padding(
              //   padding: EdgeInsets.only(top: 0),
              //   child: SizedBox(
              //     height: 2,
              //     width: 375,
              //     child: ImageIcon(
              //       AssetImage('assets/images/line.png'),
              //       color: Color(0xffD0D3D4),
              //     ),
              //   ),
              // ),

              Container(
                decoration: const BoxDecoration(
                  /*border: Border(
                          top: BorderSide(
                            width: 2,
                            color: Color(0xffD0D3D4),
                          ),
                        ),*/
                ),
                width: 375,
                child: Container(
                  width: 334.5,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(height: 8.0),
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 5, color: Color(0xff8D0C18)),
                            ),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: const Color(0xffAB0E1E),
                            labelPadding:
                            EdgeInsets.symmetric(horizontal: 18),
                            unselectedLabelColor: Colors.black,
                            // indicator: BoxDecoration(
                            //   image:  DecorationImage(
                            //     alignment: Alignment.bottomCenter,
                            //     image: ExactAssetImage('assets/images/triangle_indicator.png'),
                            //
                            //   ),),
                            indicator: TriangleTabIndicator(
                                color: const Color(0xff8D0C18),
                                radius: 2),

                            indicatorColor: Color(0xff8D0C18),

                            tabs: [
                              Tab(text: 'upcoming'.tr),
                              Tab(text: 'previous'.tr),
                            ],
                            // tabs: myTabs,
                          ),
                        ),
                        Container(
                            height: MediaQuery.of(context)
                                .size
                                .height, //height of TabBarView

                            child: TabBarView(
                                controller: _tabController,
                                children: <Widget>[
                                  SingleChildScrollView(
                                    child: SizedBox(
                                      height: 500,
                                      width: MediaQuery.of(context)
                                          .size
                                          .width,
                                      child: Center(
                                        child: Column(
                                          children: <Widget>[
                                            Expanded(
                                              child: isLoading
                                                  ? const Center(
                                                  child:
                                                  CircularProgressIndicator())
                                                  : ListView.separated(
                                                padding:
                                                const EdgeInsets
                                                    .only(
                                                    bottom:
                                                    100),
                                                itemCount: arrevents
                                                    .length,
                                                // itemExtent: 120.0, // the length
                                                itemBuilder:
                                                    (context,
                                                    index) {
                                                  return Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .only(
                                                        bottom:
                                                        8),
                                                    child: Column(
                                                      mainAxisSize:
                                                      MainAxisSize
                                                          .max,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: <
                                                          Widget>[
                                                        setEventsData(
                                                            eventsData:
                                                            arrevents[index])
                                                      ],
                                                    ),
                                                  );
                                                },
                                                separatorBuilder:
                                                    (context,
                                                    index) {
                                                  return Divider(
                                                    color: Color(
                                                        0xff76848F),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    child: SizedBox(
                                      height: 500,
                                      width: MediaQuery.of(context)
                                          .size
                                          .width,
                                      child: Center(
                                        child: Column(
                                          children: <Widget>[
                                            Expanded(
                                              child: isLoading
                                                  ? const Center(
                                                  child:
                                                  CircularProgressIndicator())
                                                  : ListView.separated(
                                                padding:
                                                const EdgeInsets
                                                    .only(
                                                    bottom:
                                                    100),
                                                itemCount:
                                                arrpastevents
                                                    .length,
                                                // itemExtent: 120.0, // the length
                                                itemBuilder:
                                                    (context,
                                                    index) {
                                                  return Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .only(
                                                        bottom:
                                                        8),
                                                    child: Column(
                                                      mainAxisSize:
                                                      MainAxisSize
                                                          .max,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: <
                                                          Widget>[
                                                        setPastEventsData(
                                                            pastEventsData:
                                                            arrpastevents[index])
                                                      ],
                                                    ),
                                                  );
                                                },
                                                separatorBuilder:
                                                    (context,
                                                    index) {
                                                  return Divider(
                                                    color: Color(
                                                        0xff76848F),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ]))
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        : Container(
      color: Colors.white,
      child: Center(
          child: Container(
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
                  Icon(
                    Icons.signal_wifi_statusbar_connected_no_internet_4,
                    size: 70,
                    color: Color(0xffAB0E1E),
                  ),
                  SizedBox(
                    height: 10,
                  ),
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
                  SizedBox(
                    height: 10,
                  ),
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

  Widget setEventsData({required Event eventsData}) {
    return Container(
      margin: const EdgeInsets.only(left: 5.0, top: 12, right: 5, bottom: 5),
      // color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10)),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/images/events.png',
                  image: eventsData.origFilename.isNotEmpty
                      ? eventsData.origFilename
                      : 'assets/images/events.png',
                  height: 140,
                  width: 316,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    eventsData.eventName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xff243444),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'HelveticaBold',
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(width: 15),
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        side: const BorderSide(
                            width: 1.0, color: Color(0xff8D0C18)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        primary: const Color(0xff8D0C18),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        minimumSize: Size(90, 26),
                        textStyle: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    child: Text('contact_us'.tr,
                        style: const TextStyle(fontFamily: 'Helvetica')),
                    onPressed: () {
                      setState(() async {
                        SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                        prefs.setInt('eventId', eventsData.id);
                        prefs.setString('eventName', eventsData.eventName);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                ContactUsPage(eventData: eventsData)));
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15),
              child: ExpandableText(
                eventsData.description,
                expandText: 'show more',
                collapseText: 'show less',
                maxLines: 4,
                style: const TextStyle(
                  fontSize: 14,
                  // color: COLORS.APP_THEME_DARK_GRAY_COLOR,
                  height: 1.5,
                  color: Color(0xff243444),
                  fontWeight: FontWeight.normal,
                  fontFamily: 'HelveticaNueueLight',
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget setPastEventsData({required Event pastEventsData}) {
    return Container(
      // color: Colors.white,
      margin: const EdgeInsets.only(left: 5.0, top: 12, right: 5, bottom: 5),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10)),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/images/events.png',
                  image: pastEventsData.origFilename.isNotEmpty
                      ? pastEventsData.origFilename
                      : 'assets/images/events.png',
                  height: 140,
                  width: 316,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text(
                pastEventsData.eventName,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xff243444),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'HelveticaBold',
                ),
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15),
              child: ExpandableText(
                pastEventsData.description,
                expandText: 'show more',
                collapseText: 'show less',
                maxLines: 4,
                style: const TextStyle(
                  fontSize: 14,
                  // color: COLORS.APP_THEME_DARK_GRAY_COLOR,
                  height: 1.5,
                  color: Color(0xff243444),
                  fontWeight: FontWeight.normal,
                  fontFamily: 'HelveticaNueueLight',
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TriangleTabIndicator extends Decoration {
  final BoxPainter _painter;

  TriangleTabIndicator({required Color color, required double radius})
      : _painter = DrawTriangle(color);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _painter;
  }
}

class DrawTriangle extends BoxPainter {
  late Paint _paint;

  DrawTriangle(Color color) {
    _paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
  }

  // void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
  //   final Offset triangleOffset =
  //       offset + Offset(cfg.size!.width / 2, cfg.size!.height);
  //   var path = Path();
  //
  //   path.moveTo(triangleOffset.dx, triangleOffset.dy);
  //   path.lineTo(triangleOffset.dx + 10, triangleOffset.dy - 10);
  //   path.lineTo(triangleOffset.dx - 10, triangleOffset.dy - 10);
  //   path.close();
  //
  //   canvas.drawPath(path, _paint);
  // }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset triangleOffset =
        offset + Offset(cfg.size!.width / 2, cfg.size!.height - 10);
    var path = Path();

    path.moveTo(triangleOffset.dx, triangleOffset.dy);
    path.lineTo(triangleOffset.dx + 10, triangleOffset.dy + 10);
    path.lineTo(triangleOffset.dx - 10, triangleOffset.dy + 10);

    path.close();
    canvas.drawPath(path, _paint);
  }
}
