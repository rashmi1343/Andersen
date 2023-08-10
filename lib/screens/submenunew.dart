

import 'package:andersonappnew/screens/NewExpandwidget.dart';
import 'package:andersonappnew/screens/Postbymenu.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'dart:async';


import 'package:shared_preferences/shared_preferences.dart';

import '../ConnectionUtil.dart';

import '../Localization/localization/language_constants.dart';

import '../constant.dart';

import '../responses/MenuByCountryResponse.dart';




import '../widgets/NoDataFoundWidget.dart';



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

class submenunew extends StatefulWidget {
  int submenuid;
  List<Menubycountry> submenu;

  submenunew({required this.submenuid, required this.submenu});

  @override
  _submenunewState createState() => _submenunewState();
}

class _submenunewState extends State<submenunew> {
  bool isLoading = true;

  // List<Menubycountry> submenu = [];
  String selectedCountry = "";

  String getlocalecode = '';

  String menuname = "";
  StreamSubscription? connection;
  bool isGrid = false;

  bool isdataconnection = false;

  var Internetstatus = "Unknown";

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accesstoken');
  }

  Future<String?> getSelectedCountry() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.getString('selectedCountry') ?? "";
    selectedCountry = data;
    return data;
  }

  Future<String?> getlocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    getlocalecode = prefs.getString(LAGUAGE_CODE) ?? "";
    print(getlocalecode);
    return prefs.getString(LAGUAGE_CODE);
  }

  Future<String?> getmenuname() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // int? menuid = prefs.getInt('id');
    return prefs.getString('menuname')!;
  }

  /* Future<List<Menu>> getsubmenu() async {
    var locale = await getlocale();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');

    print("get data from api call");
    menuname = prefs.getString('menuname')!;

    Map parammenu = {
      "parent_id": id.toString(),
      "methodname": "getmenubyid",
      "locale": locale
    };

    // if (kDebugMode) {
    print('$parammenu');
    // }

    var token = await getToken();
    if (kDebugMode) {
      print(token);
    }

    final response = await http.post(
        Uri.parse(ApiConstant.url + ApiConstant.Endpoint),
        body: parammenu,
        headers: {
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
      if (menuObj.menu.isNotEmpty) {
        // Parentmenu = menuObj.menu;
        submenu = menuObj.menu;
        //   IsGrid = true;
        //    int midx = 0;
        /*  for (var objMenu in decoded["menu"]) {
          // parentid = objMenu['id'];

          // Menu mm = objMenu;
          submenu.add(Menu(
              id: objMenu['id'],
              title: objMenu['title'],
              parentId: objMenu['parentId'],
              isActive: objMenu['isActive'],
              locale: objMenu['locale'],
              countryname: objMenu['countryname'],
              isSelected: objMenu['isSelected'],
              Submenu: objMenu['submenu']));

          // getchilddatafromapi(submenu[midx]);
          midx = midx + 1;
        }*/
      } else {
        submenu = [];
      }

      //   getchilddatafromapi(ctx, parentid);
      // if (kDebugMode) {
      print(decoded);
      // }

      setState(() {
        isLoading = false;
      });
      // }

    }
    return submenu;
  }




  Future<List<Menubycountry>> getMenuByCountryData(String url) async {
    var locale = await getlocale();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('countryId');

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // int? menuid = prefs.getInt('id');
    menuname = prefs.getString('menuname')!;

    print("get data from menuby country api call");

    Map parammenubycountry = {
      "methodname": "getmenubycountryid",
      "locale": locale,
      "country_id": id.toString(),
      // "parent_id": menuid.toString()
      "parent_id": widget.submenuid.toString()
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
        submenu = menuObj.menubycountry;
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

    return submenu;
  }*/

  @override
  void initState() {
    super.initState();
    ConnectionUtil connectionStatus = ConnectionUtil.getInstance();
    connectionStatus.initialize();
   connection= connectionStatus.connectionChange.listen(connectionChanged);
    menuname = APIDATA.menuname.toString();
    // setState(() {
    //   isLoading = true;
    // });
    BackButtonInterceptor.add(myInterceptor);
  }


  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isdataconnection = hasConnection;
      if (isdataconnection) {
        Internetstatus = "Connectd TO THe Internet";
        isdataconnection = true;
        print('Data connection is available.');
        setState(() {
          getSelectedCountry();
          isLoading = false;
          // getsubmenu();
          //   getMenuByCountryData(ApiConstant.url + ApiConstant.Endpoint);
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

  titleString(int index) {
    final title = widget.submenu[index].menuname;
    final firstWordOfTitle = title.split(' ').first;
    String a = "This is an Apple";
    String b = a.replaceFirst(" ${firstWordOfTitle} ", "\n");
    print(b);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    final mediaQuery = MediaQuery.of(context);
    return isdataconnection
        ? RefreshIndicator(
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                leading: Container(
                  padding: EdgeInsets.only(right: 10),
                  height: 24,
                  width: 24,
                  child: IconButton(

                    icon: Image.asset('assets/images/backarrow.png',color: Color(0xff8D0C18), ),

                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                // Icon(
                //   Icons.arrow_back_outlined,
                //   size: 25,
                //   color: Colors.black,
                //   // color: Color(0xff243444),
                // ),
                elevation: 0,
                centerTitle: false,
                titleSpacing: 0.0,
                title: Transform(
                  // you can forcefully translate values left side using Transform
                  transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
                  child: Text(
                    (APIDATA.menuname ?? "".tr).capitalizeFirstofEach,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'HelveticaNueueMedium',
                      fontSize: 18,
                      color: Color(0xff243444),
                    ),
                  ),
                ),

                //  title: Text(menuname.tr,
                //     style: const TextStyle(
                //       fontFamily: 'Helvetica',
                //       fontSize: 18,
                //       color: Colors.black87,
                //     )),
                backgroundColor: Colors.white,
                // iconTheme: const IconThemeData(color: Color(0xff243444)),
                actions: <Widget>[
                  IconButton(
                    alignment: Alignment.centerLeft,
                    icon: const Icon(
                      Icons.more_vert_outlined,

                      color: Color(0xff8D0C18), //0xff243444
                    ),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
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
                // bottom: PreferredSize(
                //     child: Container(
                //       color: const Color(0xffbe1229),
                //       height: 2.0,
                //     ),
                //     preferredSize: const Size.fromHeight(2.0)),
              ),
              body: Stack(children: <Widget>[
                SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Container(
                      color: Colors.white,
                      alignment: Alignment.topCenter,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : //getlistview(context)),
                          getlistview(context),
                      //         Text("test"),
                    )),
              ]),
            ),
            onRefresh: () {
              return Future.delayed(const Duration(seconds: 1), () {
                setState(() {
                  getSelectedCountry();
                });
              });
            },
          )
        :Container(
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

  Widget getlistview(BuildContext ctx) {
    // var readLines = ['Test1', 'Test2', 'Test3'];
    // String getNewLineString() {
    //   StringBuffer sb = new StringBuffer();
    //   for (String line in readLines) {
    //     sb.write(line + "\n");
    //   }
    //   return sb.toString();
    // }

    final mediaQuery = MediaQuery.of(context);
    if (widget.submenu.isNotEmpty) {
      return GridView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 13,
          // width / height: fixed for *all* items
          mainAxisExtent: 110,
          // childAspectRatio: 3 / 2,
        ),
        padding: const EdgeInsets.all(10),
        itemCount: widget.submenu.length,
        itemBuilder: (BuildContext ctx, index) {
          return GestureDetector(
              onTap: () async {
                var childmenulength = widget.submenu[index].Submenu.length;
                //var childidx = 0;
                print(childmenulength);
                if (childmenulength == 0) {
                  Navigator.of(ctx).push(MaterialPageRoute(
                      builder: (ctx) => Postbymenu(
                            title: widget
                                .submenu[index].menuname.capitalizeFirstofEach,
                            submenuchild: widget.submenu,
                            currentmenuitem:
                                widget.submenu[index], // .Submenu[sindex],
                          )));
                }
                // only 1 item condition
                // to resolve range exception for 0th Position
                else if (childmenulength >= 0) {
                  if (childmenulength == 1) {
                    childmenulength = 0;
                  } else {
                    childmenulength = 1;
                  }
                  // Condition to show bottom sheet or come back to submenunew if lastmenu has 0length bottom sheet open & if it has length come to same screen
                  if (widget.submenu[index].Submenu[childmenulength].Submenu
                          .length ==
                      0) {
                    /* showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(25.0),
                          ),
                        ),
                        backgroundColor: Color(0xffffffff), // <-- SEE HERE
                        builder: (context) {
                          return SizedBox(
                            height: 300,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.all(10),
                                  width: 200,
                                  height: 100,
                                  alignment: Alignment.centerLeft,
                                  // decoration: BoxDecoration(
                                  //     color: Colors.blueAccent,
                                  //     borderRadius:
                                  //         BorderRadius.all(Radius.circular(50))),
                                  child: Text(
                                    widget.submenu[index].menuname,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontFamily: 'HelveticaBold',
                                      color: Color(0xFF8D0C18),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GridView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 5,
                                      crossAxisSpacing: 5,
                                      // width / height: fixed for *all* items
                                      childAspectRatio: 3 / 2.8,
                                    ),
                                    padding: const EdgeInsets.all(5),
                                    itemCount:
                                        widget.submenu[index].Submenu.length,
                                    itemBuilder:
                                        (BuildContext context, int sindex) {
                                      return ActionChip(
                                        backgroundColor: Color(0xffD0D3D4),
                                        elevation: 6.0,
                                        padding: EdgeInsets.all(2.0),
                                        label: Text(
                                          widget.submenu[index].Submenu[sindex]
                                              .menuname,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Helvetica',
                                            color: Color(0xFF243444),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(ctx)
                                              .push(MaterialPageRoute(
                                                  builder: (ctx) => Postbymenu(
                                                        title:
                                                            "$menuname-${widget.submenu[index].menuname}",
                                                        // widget.submenu[index].menuname,
                                                        submenuchild: widget
                                                            .submenu[index]
                                                            .Submenu,
                                                        currentmenuitem: widget
                                                            .submenu[index]
                                                            .Submenu[sindex],
                                                      )));
                                        },
                                        shape: StadiumBorder(
                                            side: BorderSide(
                                          width: 2,
                                          color: Color(0xffA3AAAE),
                                        )),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          );
                        });*/
                    /*   Navigator.of(ctx).push(MaterialPageRoute(
                        builder: (ctx) => Postbymenu(
                              title:
                                  "$menuname-${widget.submenu[index].menuname}",
                              // widget.submenu[index].menuname,
                              submenuchild: widget.submenu[index].Submenu,
                              currentmenuitem: widget.submenu[index].Submenu[0],
                            )));*/
                    Navigator.of(ctx).push(MaterialPageRoute(
                        builder: (ctx) => submenunew(
                              submenuid:
                                  widget.submenu[index].Submenu[0].menuId,
                              submenu: widget.submenu[index].Submenu,
                            )));
                  } else if (widget.submenu[index].Submenu[0].Submenu.length >
                      0) {
                    // redirect to submenunew.dart
                    //  APIDATA.submenuid =
                    //      submenu[index].Submenu[childmenulength].menuId;
                    Navigator.of(ctx).push(MaterialPageRoute(
                        builder: (ctx) => submenunew(
                              submenuid: widget.submenu[index]
                                  .Submenu[childmenulength].menuId,
                              submenu: widget.submenu[index].Submenu,
                            )));
                  }
                } else {
                  //condition for morethan 1 item
                  if (widget.submenu[index].Submenu[index].Submenu.length ==
                      0) {
                    /*  showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(25.0),
                          ),
                        ),
                        backgroundColor: Color(0xffffffff), // <-- SEE HERE
                        builder: (context) {
                          return SizedBox(
                            height: 300,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.all(10),
                                  width: 200,
                                  height: 100,
                                  alignment: Alignment.centerLeft,
                                  // decoration: BoxDecoration(
                                  //     color: Colors.blueAccent,
                                  //     borderRadius:
                                  //         BorderRadius.all(Radius.circular(50))),
                                  child: Text(
                                    widget.submenu[index].menuname,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontFamily: 'HelveticaBold',
                                      color: Color(0xFF8D0C18),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GridView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 5,
                                      crossAxisSpacing: 5,
                                      // width / height: fixed for *all* items
                                      childAspectRatio: 3 / 2.8,
                                    ),
                                    padding: const EdgeInsets.all(5),
                                    itemCount:
                                        widget.submenu[index].Submenu.length,
                                    itemBuilder:
                                        (BuildContext context, int sindex) {
                                      return ActionChip(
                                        backgroundColor: Color(0xffD0D3D4),
                                        elevation: 6.0,
                                        padding: EdgeInsets.all(2.0),
                                        label: Text(
                                          widget.submenu[index].Submenu[sindex]
                                              .menuname,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Helvetica',
                                            color: Color(0xFF243444),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();

                                          Navigator.of(ctx)
                                              .push(MaterialPageRoute(
                                                  builder: (ctx) => Postbymenu(
                                                        title:
                                                            "$menuname-${widget.submenu[index].menuname}",
                                                        submenuchild: widget
                                                            .submenu[index]
                                                            .Submenu,
                                                        currentmenuitem: widget
                                                            .submenu[index]
                                                            .Submenu[sindex],
                                                      )));
                                        },
                                        shape: StadiumBorder(
                                            side: BorderSide(
                                          width: 2,
                                          color: Color(0xffA3AAAE),
                                        )),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          );
                        });*/
                    Navigator.of(ctx).push(MaterialPageRoute(
                        builder: (ctx) => Postbymenu(
                              title: widget.submenu[index].menuname
                                  .capitalizeFirstofEach,
                              // title:
                              //     "$menuname-${widget.submenu[index].menuname}",
                              submenuchild: widget.submenu[index].Submenu,
                              currentmenuitem: widget.submenu[index].Submenu[0],
                            )));
                  } else if (widget
                          .submenu[index].Submenu[index].Submenu.length >
                      0) {
                    // redirect to submenunew.dart
                    Navigator.of(ctx).push(MaterialPageRoute(
                        builder: (ctx) => submenunew(
                              submenuid:
                                  widget.submenu[index].Submenu[index].menuId,
                              submenu: widget.submenu[index].Submenu,
                            )));
                  }
                }
                ;
              },
              child: Container(
                  height: 104,
                  width: 161,
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    // boxShadow: const [
                    //   BoxShadow(blurRadius: 1),
                    // ],
                    color: HexColor.fromHex('#243444'),
                  ),
                  child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 60.0,
                            width: 60.0,
                            alignment: Alignment.topLeft,
                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(50.0),
                                    bottomRight: Radius.circular(0.0),
                                    topLeft: Radius.circular(50),
                                    bottomLeft: Radius.circular(50)),
                                color: Color(0xffAB0E1E),
                              ),
                            ),
                          ),
                          Container(
                            margin: //getlocalecode == 'en'
                                // const EdgeInsets.only(left:13,top: 16,right: 35),
                                const EdgeInsets.only(
                                    left: 10, top: 5, right: 10),

                            //: const EdgeInsets.only(right: 10, top: 20),
                            alignment: // getlocalecode == 'en'
                                //?
                                Alignment.topLeft,
                            //: Alignment.topRight,
                            child: Container(
                              // width: 120,

                              height: 65,
                              // padding: EdgeInsets.fromLTRB(0.0, 0.0, 30.0, 0.0),
                              //width: mediaQuery.size.width * 0.9,
                              child: Text(
                                //'${widget.submenu[index].menuname}',
                                widget.submenu[index].menuname
                                    .capitalizeFirstofEach,
                                //   '''
                                // ${widget.submenu[index].menuname}\n
                                //                        ''',
                                // '''${widget.submenu[index].menuname}''',
                                // titleString(index),
                                // menuitem[index],
                                textAlign: TextAlign.left,
                                softWrap: true,
                                textScaleFactor: 1,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xffffffff),
                                    fontFamily: 'HelveticaNueueBold'),
                                maxLines:4,
                                overflow: TextOverflow.clip,
                                // overflow: TextOverflow.ellipsis,
                                // textAlign: TextAlign.justify,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10, bottom: 5),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Image.asset(
                                'assets/images/right_arrow.png',
                                height: 15,
                                width: 15,
                                color: Colors.white,
                              ),
                              //SizedBox(width: 5),
                            ]),
                      ),
                    ],
                  )));
        },
      );
    } else {
      return NoDataFoundWidget();
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    connection?.cancel();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    //Navigator.of(context).pop();

    print("Back To SubMenu homemenue Page");

    if (["subMenuRoute", "homeMenuRoute"].contains(info.currentRoute(context)))
      return true;

    return false;
  }
}
