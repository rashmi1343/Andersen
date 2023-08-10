import 'dart:async';
import 'dart:convert';

import 'package:andersonappnew/screens/Postbymenu.dart';
import 'package:andersonappnew/screens/documentView.dart';
import 'package:andersonappnew/screens/featuredArticle.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ConnectionUtil.dart';
import '../Localization/localization/language_constants.dart';

import '../constant.dart';
import '../responses/MenuByCountryResponse.dart';
import 'package:http/http.dart' as http;

import 'event_page_new.dart';

class NewExpandablewidget extends StatefulWidget {
  const NewExpandablewidget({Key? key}) : super(key: key);

  @override
  _NewExpandablewidgetState createState() => _NewExpandablewidgetState();
}

class _NewExpandablewidgetState extends State<NewExpandablewidget> {
  List<Menubycountry> menubycountry = [];

  String title = "";

  String selectedCountry = "";
  bool isLoading = true;
  int selected = -1;

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

  Future<String?> getlocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(LAGUAGE_CODE);
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

  StreamSubscription? connection;
  bool isdataconnection = false;
  var Internetstatus = "Unknown";

  @override
  void initState() {
    super.initState();
    ConnectionUtil connectionStatus = ConnectionUtil.getInstance();
    connectionStatus.initialize();
    connection=connectionStatus.connectionChange.listen(connectionChanged);
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isdataconnection = hasConnection;
      if (isdataconnection) {
        Internetstatus = "Connected To The Internet";
        isdataconnection = true;
        print('Data connection is available.');
        setState(() {
          getSelectedCountry();
          isLoading = true;
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

  @override
  void dispose() {
    connection?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    return isdataconnection
        ? Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              centerTitle: false,
              leading: Container(
                padding: const EdgeInsets.only(left: 15),
                height: 24,
                width: 24,
                child: IconButton(
                  icon: Image.asset('assets/images/backarrow.png',color: Color(0xff8D0C18), ),
                  iconSize: 24,

                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              // Container(
              //   padding: EdgeInsets.only(right: 10),
              //   height: 24,
              //   width: 24,
              //   child: IconButton(
              //     icon: Icon(
              //       Icons.arrow_back_outlined,
              //       size: 35,
              //       color: Colors.black,
              //       //color: Color(0xff243444),
              //     ),
              //     color: Colors.black,
              //     onPressed: () {
              //       Navigator.pop(context);
              //     },
              //   ),
              // ),

              // Icon(
              //   Icons.arrow_back_outlined,
              //   size: 25,
              //   color: Colors.black,
              //   // color: Color(0xff243444),
              // ),
              elevation: 0,
              // title: Text(
              //   'categories'.tr,
              //   style: const TextStyle(
              //       fontSize: 16,
              //       fontWeight: FontWeight.bold,
              //       color: Color(0xff243444),
              //       fontFamily: 'Helvetica'),
              // ),
              backgroundColor: Colors.white,
              //iconTheme: const IconThemeData(color: Color(0xff243444)),
            ),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    margin: EdgeInsets.only(left: 15, right: 15),
                    child: ListView.separated(
                      itemBuilder: (BuildContext context, int index) =>
                          ExpansionTile(
                        key: Key('builder ${selected.toString()}'),
                        // PageStorageKey<Menu>(menu[index]),
                        // backgroundColor: const Color(0xFFD0D3D4),
                        initiallyExpanded: index == selected,
                        onExpansionChanged: (bool isExpanded) {
                          if (isExpanded) {
                            setState(() {
                              Duration(seconds: 20000);
                              selected = index;
                            });
                            // got name of parent menu here
                            title = menubycountry[index].menuname;
                            print("Current Title " +
                                menubycountry[index].menuname);
                            APIDATA.menuicon = menubycountry[index].filepath;

                            if (title.contains("events".tr)) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const EventPageNew()));
                            } else if (title.contains("feature_articles".tr)) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => FeatureArticlePage()));
                            } else if (title.contains("featured_document".tr)) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => DocumentView()));
                            }
                          } else {
                            setState(() {
                              selected = -1;
                            });
                            print("nt expanded");
                          }
                          //  menuid = menu[index].id;
                          //   loadSubMenu(ApiConstant.url + ApiConstant.Endpoint);
                        },

                        //index == selected,
                        // maintainState: true,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Image.asset(imgdata[index],
                            //     height: 100,
                            //     width: 60,
                            //     color: Color(0xff243445)),
                            SizedBox(
                              height: 35,
                              width: 35,
                              // child: ElevatedButton(
                              //   onPressed: () {},
                              //   style: ElevatedButton.styleFrom(
                              //     shape: const CircleBorder(),
                              //     padding: const EdgeInsets.all(6),
                              //     primary: const Color(0xffffffff),
                              //     onPrimary: const Color(0xffAB0E1E),
                              //   ),
                              child: FadeInImage.assetNetwork(
                                placeholder: 'assets/images/no_image.png',
                                image: menubycountry[index]
                                        .listiconpath
                                        .isNotEmpty
                                    ? ApiConstant.menulisticonpoint +
                                        menubycountry[index].listiconpath
                                    : '${ApiConstant.menulisticonpoint}no_image.png',
                                height: 32,
                                width: 32,
                              ),
                              // ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Flexible(
                                child: Text(
                              menubycountry[index].menuname.capitalizeFirstofEach,
                              // menuitem[index],
                              textAlign: TextAlign.left,
                              textScaleFactor: 1,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff243444),
                                  fontFamily: 'Helvetica'),
                              maxLines: 3,
                              overflow: TextOverflow.clip,
                            )),
                          ],
                        ),
                        children: menubycountry[index]
                            .Submenu
                            .map<Widget>((club) => CategoriesExpandableWidget(
                                currentmenuitem: club,
                                submenuitem: menubycountry[index].Submenu,
                                title: title,
                                subtitle: club.menuname))
                            .toList(),
                      ),
                      itemCount: menubycountry.length,
                      separatorBuilder: (context, index) {
                        return Divider(
                          color: Color(0xffD0D3D4),
                          height: 0,
                        );
                      },
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
}

class CategoriesExpandableWidget extends StatefulWidget {
  final Menubycountry currentmenuitem;

  List<Menubycountry> submenuitem = [];

  String subtitle;
  String title;

  CategoriesExpandableWidget(
      {required this.currentmenuitem,
      required this.submenuitem,
      required this.title,
      required this.subtitle});

  @override
  _CategoriesExpandableWidgetState createState() =>
      _CategoriesExpandableWidgetState();
}

class _CategoriesExpandableWidgetState
    extends State<CategoriesExpandableWidget> {
  List<Menubycountry> submenulist = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    print("title" + widget.title);
    print("subtitle" + widget.subtitle);
    print("current menu name " + widget.currentmenuitem.menuname);
    // widget.generatedheader.add(widget.currentmenuitem.menuname);
    print("sub menu item " + widget.submenuitem.length.toString());

    APIDATA.currentmenuitem = widget.currentmenuitem;
    APIDATA.submenuitem = widget.submenuitem;

    APIDATA.postByMenuTitle = widget.title + " - " + widget.subtitle;

    // print("subtitle" + widget.subtitle.toString());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentmenuitem.Submenu.isEmpty) {
      return ListTile(
          tileColor: Color(0xffD0D3D4), //Colors.white,
          title: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              "- " + widget.currentmenuitem.menuname.capitalizeFirstofEach,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'HelveticaNueueMedium',
                  color: Color(0xFF76848F)),
            ),
          ),
          onTap: () {
            if (widget.currentmenuitem.menuId > 0) {
              APIDATA.menuname="${widget.title.capitalizeFirstofEach}";
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => Postbymenu(
                      title: "${widget.subtitle.capitalizeFirstofEach}",
                      submenuchild: widget.submenuitem,
                      currentmenuitem: widget.currentmenuitem)));
            }
          });
    } else {
      return ListTileTheme(
          tileColor: Color(0xffD0D3D4),
          // contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          // dense: true,
          // color: const Color(0xFFD0D3D4),
          // height: 60,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              // tilePadding: EdgeInsets.symmetric(vertical: 0),
              //  key: PageStorageKey<Menubycountry>(widget.currentmenuitem),
              // backgroundColor: const Color(0xFFD0D3D4),
              // tilePadding: EdgeInsets.zero,
              onExpansionChanged: (bool isExpanded) {
                if (isExpanded) {
                  print("Current Subtitle" + widget.currentmenuitem.menuname);
                  widget.subtitle = widget.currentmenuitem.menuname;
                  //    widget.generatedheader.add(widget.currentmenuitem.menuname);
                }
              },
              title: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    widget.currentmenuitem.menuname.capitalizeFirstofEach,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'HelveticaNueueBold',
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF76848F),
                    ),
                  )),

              children: widget.currentmenuitem.Submenu
                  .map<Widget>((club) => CategoriesExpandableWidget(
                        currentmenuitem: club,
                        submenuitem: widget.currentmenuitem.Submenu,
                        title: widget.title,
                        subtitle: widget.subtitle,
                      ))
                  .toList(),
            ),
          ));
    }
  }
}
