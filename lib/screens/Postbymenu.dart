// import 'package:flutter/material.dart';

// import '../constant.dart';
// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import '../Localization/localization/language_constants.dart';
// import '../constant.dart';
// import 'package:andersonappnewapp/response/MenuByIdResponse.dart';
// import '../response/AllDiscussionResponse.dart';

import 'dart:async';

import 'package:andersonappnew/screens/post_screen.dart';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:flutter_html/flutter_html.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_html/style.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:themify_flutter/themify_flutter.dart';

import '../ConnectionUtil.dart';
import '../Localization/classes/language.dart';
import '../constant.dart';

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Localization/localization/language_constants.dart';

import '../responses/AllDiscussionResponse.dart';
import '../responses/LikeDiscussionThread.dart';
import '../responses/MenuByCountryResponse.dart';

import '../widgets/NoDataFoundWidget.dart';
import 'NewExpandwidget.dart';

import 'package:device_info/device_info.dart';

class sortBy {
  sortBy({required this.id, required this.title});

  int id;
  String title;

  // bool isAscending = false;

  static List<sortBy> sortByArr() {
    return <sortBy>[
      sortBy(id: 1, title: 'by_last_modified_date'.tr),
      sortBy(id: 2, title: 'by_no_of_likes'.tr),
      sortBy(id: 3, title: 'by_no._of_reply'.tr)
    ];
  }
}

class Postbymenu extends StatefulWidget {
  Postbymenu(
      {Key? key,
      required this.title,
      required this.submenuchild,
      required this.currentmenuitem})
      : super(key: key);
  String title = '';

  List<Menubycountry> submenuchild;

  Menubycountry currentmenuitem;

  @override
  _PostbymenuState createState() => _PostbymenuState();
}

class _PostbymenuState extends State<Postbymenu> {
  List<Discussionthread> _foundedPost = [];
  List<DiscussionLike> likeData = <DiscussionLike>[];

  int selectedLikeIndex = -1;
  TextEditingController editingController = TextEditingController();

  String shortbyModifiedDate = 'desc';
  DateTime displayDate = DateTime.now();
  late BuildContext dialogContext;
  late BuildContext searchdialogContext;

  // Map<UnlikeReply, String> unlikeData = <UnlikeReply, String>{};

  bool isLoading = true;
  StreamSubscription? connection;
  bool isdataconnection = false;

  var Internetstatus = "Unknown";
  bool isLikeLoading = false;
  List data = [];

  bool isCountryNameVisible = false;

  List<Discussionthread> discussionthreads = [];

  //  sortBy sortByArr = sortBy(id: 1, title:'By last modified date', isAscending: false);
  // List<sortBy> sortByArr = <sortBy>[];

  int _selectedIndex = 0;

  // bool isLikeButtonSelected = false;

  // List<Menu> menu = [];
  List<Menubycountry> menu = [];
  String menuname = "";
  var selectedMenu;
  var selectedSortMenu = 'sort_by'.tr;

  String deviceName = '';
  String deviceVersion = '';
  String deviceID = '';

  // var _selectedSortOption;

  var isModifiedDateAscending = false;
  var isLikeAscending = false;
  var isReplyAscending = false;

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accesstoken');
  }

  Future<String?> getmenuid() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('submenuid').toString();
  }

  Future<String?> getlocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(LAGUAGE_CODE);
  }

  void updateLanguage(Language language) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(LAGUAGE_CODE, language.languageCode);
    //Get.back();
    Get.updateLocale(language.locale);

    setState(() {
      //isLoading = true;
      //callApiToGetMenuData();
    });
  }

  Future<List<Discussionthread>> getDiscussionDatabymenuid(
      int childmenuidforpost) async {
    var token = await getToken();

    var locale = await getlocale();
    //  var menuid = await getmenuid();
    Map jsonMap = {
      "methodname": "getdisucssionthreadbychannelidlatest",
      // "getdisucssionthreadbychannelidnew", //"getdisucssionthreadbychannelid",
      "locale": locale,
      "menu_id": childmenuidforpost.toString(),
      "shortby": shortbyModifiedDate,
      "device_id": deviceID
    };
    print('$jsonMap');
    final response = await http.post(
        Uri.parse(ApiConstant.url + ApiConstant.Endpoint),
        body: jsonMap,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });

    debugPrint('${response.statusCode}');
    if (response.statusCode == 200) {
      final threadsObj = parseJson(response.body);
      discussionthreads = threadsObj.discussionthreads;

      debugPrint('${discussionthreads}');
      setState(() {
        if (discussionthreads.isEmpty) {
          _foundedPost = [];
          discussionthreads = [];
        } else {
          _foundedPost = [];
          _foundedPost = threadsObj.discussionthreads;
        }
        isLoading = false;

        //  if (kDebugMode) {

        // print(_foundedPost.map((e) => e.title));
        // print(_foundedPost.map((e) => e.subtitle));
        //   }
      });

      return discussionthreads;
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

  Future<LikeDiscussionThread> getLikeData(String url,
      {required int discussionId}) async {
    var token = await getToken();

    var locale = await getlocale();
    Map jsonMap = {
      "methodname": "likediscussion",
      "discussion_id": discussionId.toString(),
      "locale": locale,
      "device_id": deviceID
    };
    // if (kDebugMode) {
    print('$url , $jsonMap');
    // }

    final response = await http.post(Uri.parse(url), body: jsonMap, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    debugPrint('${response.statusCode}');
    debugPrint('${response.body}');
    if (response.statusCode == 200) {
      final likeObj = likeDiscussionThreadFromJson(response.body);
      likeData = likeObj.like;
      // likeData = likeObj;

      // if (kDebugMode) {
      // print('likeData, $likeData');
      // }
      setState(() {
        discussionthreads[selectedLikeIndex].like += 1;
        discussionthreads[selectedLikeIndex].discussionlikebydevid.add(
            Discussionlikebydevid(
                deviceId: '', id: 0, discussionId: discussionId, userId: 0));
        isLikeLoading = false;

        // isLoading = false;
      });

      return likeObj;
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

  Future<LikeDiscussionThread> getUnLikeData(String url,
      {required int discussionId}) async {
    var token = await getToken();
    var locale = await getlocale();
    Map jsonMap = {
      "methodname": "unlikediscussion",
      "discussion_id": discussionId.toString(),
      "locale": locale,
      "device_id": deviceID
    };
    print('$url , $jsonMap');
    final response = await http.post(Uri.parse(url), body: jsonMap, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    debugPrint('${response.statusCode}');
    if (response.statusCode == 200) {
      final likeObj = likeDiscussionThreadFromJson(response.body);
      // // likeData = likeObj.like;
      // likeData = likeObj;
      // print('UnlikeData $likeData');
      setState(() {
        if (discussionthreads[selectedLikeIndex].like > 0) {
          discussionthreads[selectedLikeIndex].like -= 1;
        }
        discussionthreads[selectedLikeIndex].discussionlikebydevid = [];
        // .remove(
        //     Discussionlikebydevid(
        //         deviceId: '', id: 0, discussionId: discussionId, userId: 0));
        isLikeLoading = false;
      });

      return likeObj;
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

  resetmenu(int pst) async {
    var idx = 0;
    setState(() {
      isLoading = true;
    });
    for (var objMenu in menu) {
      if (pst == idx) {
        // objMenu.isSelected = true;
        //    SharedPreferences prefs = await SharedPreferences.getInstance();
        //    prefs.setInt('submenuid', objMenu.id);
        getDiscussionDatabymenuid(objMenu.menuId); //objMenu.id.toString()
      } else {
        //objMenu.isSelected = false;
      }
      idx = idx + 1;
    }
  }

  Future<String?> getSelectedCountry() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.getString('selectedCountry') ?? "";
    selectedCountry = data;
    return data;
  }

  bool shouldPop = true;
  String selectedCountry = "";

  @override
  void initState() {
    super.initState();

    debugPrint('Post menu by called');
    ConnectionUtil connectionStatus = ConnectionUtil.getInstance();
    connectionStatus.initialize();
   connection= connectionStatus.connectionChange.listen(connectionChanged);

    print('widget.submenuchild');
    print(widget.submenuchild);

    if (APIDATA.menuname != null) {
      menuname = APIDATA.menuname.toString();
    }
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isdataconnection = hasConnection;
      if (isdataconnection) {
        Internetstatus = "Connected To The Internet";
        isdataconnection = true;
        print('Data connection is available.');
        setState(() {
          //encode Map to JSON
          //  loadSubMenu(ApiConstant.url + ApiConstant.Endpoint);
          //  apiToGetDiscussionData();
          //  apiToLikePost();
          _getDeviceDetails();
          //  var menuid = getmenuid();
          getSelectedCountry();
          // isLoading = false;

          // getDiscussionDatabymenuid(widget.currentmenuitem.menuId);
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

  /* Future<List<Discussionthread>> apiToGetDiscussionData() {
    return getDiscussionData(ApiConstant.url + ApiConstant.Endpoint);
  }*/

  // Future<LikeDiscussionThread> apiToLikePost({required int discussionId}) {
  //   return getLikeData(ApiConstant.url + ApiConstant.Endpoint,
  //       discussionId: discussionId);
  // }

  // Future<LikeDiscussionThread> apiToUnLikePost({required int discussionId}) {
  //   return getUnLikeData(ApiConstant.url + ApiConstant.Endpoint,
  //       discussionId: discussionId);
  // }

  Future<LikeDiscussionThread> apiToLikePost({required int discussionId}) {
    return getLikeData(ApiConstant.url + ApiConstant.Endpoint,
        discussionId: discussionId);
  }

  Future<LikeDiscussionThread> apiToUnLikePost({required int discussionId}) {
    return getUnLikeData(ApiConstant.url + ApiConstant.Endpoint,
        discussionId: discussionId);
  }

  // onSearch(String search) {
  //   setState(() {
  //     _foundedPost = discussionthreads
  //         .where((post) => post.title.toLowerCase().contains(search))
  //         .toList();
  //   });
  // }

  onSearch(String search) {
    setState(() {
      if (editingController.text.isEmpty) {
        _foundedPost = discussionthreads;
      } else {
        _foundedPost = discussionthreads
            .where((post) =>
                // post.title.toLowerCase().contains(search) ||
                // post.content.toLowerCase().contains(search) ||
                // post.createdAt.toLowerCase().contains(search) ||
                // post.updatedAt.toLowerCase().contains(search))
                post.title.toLowerCase().contains(search.toLowerCase()) ||
                post.content.toLowerCase().contains(search.toLowerCase()) ||
                post.createdAt.toLowerCase().contains(search.toLowerCase()) ||
                post.updatedAt.toLowerCase().contains(search.toLowerCase()))
            .toList();
      }
    });
  }

  sortByUpdatedDateInAscending() {
    setState(() {
      _foundedPost.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    });
  }

  sortByUpdatedDateInDescending() {
    setState(() {
      _foundedPost.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    });
  }

  sortByLikeInAscending() {
    setState(() {
      _foundedPost.sort((a, b) => a.like.compareTo(b.like));
    });
  }

  sortByLikeInDescending() {
    setState(() {
      _foundedPost.sort((a, b) => b.like.compareTo(a.like));
    });
  }

  sortByReplyInAscending() {
    setState(() {
      _foundedPost.sort((a, b) => a.reply.compareTo(b.reply));
    });
  }

  sortByReplyInDescending() {
    setState(() {
      _foundedPost.sort((a, b) => b.reply.compareTo(a.reply));
    });
  }

  Future<bool> onbackpress() async {
    //Navigator.of(context).pop();
    return true;
  }

  void _showHideCountryName() {
    setState(() {
      isCountryNameVisible = !isCountryNameVisible;
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('are_you_sure'.tr),
            content: Text('do_you'.tr),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('no'.tr),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('yes'.tr),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<bool> _willPopCallback() async {
    // await showDialog or Show add banners or whatever
    // then
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('are_you_sure'.tr),
        content: Text('do_you'.tr),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('no'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('yes'.tr),
          ),
        ],
      ),
    );
    return Future.value(true);
  }

  @override
  void dispose() {
    connection?.cancel();
    super.dispose();
  }

  var _controller = TextEditingController();

  // bool shouldPop = true;

  void showSearchDialog() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      useSafeArea: false,
      builder: (BuildContext cxt) {
        searchdialogContext = cxt;
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Material(
              type: MaterialType.canvas,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 30,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 2.0),
                          child: IconButton(
                            // padding: const EdgeInsets.only(top: 5.0),
                            icon: const Icon(Icons.close,
                                color: COLORS.APP_THEME_DARK_RED_COLOR,
                                size: 20),

                            onPressed: () {
                              editingController.text = "";
                              setState(() {
                                _foundedPost = discussionthreads;
                              });

                              Navigator.pop(searchdialogContext);
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: Text(
                        'i_want'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          color: COLORS.APP_THEME_DARK_RED_COLOR,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'HelveticaBold',
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                            child: SizedBox(
                          height: 45,
                          child: TextField(
                            autofocus: true,
                            controller: editingController,
                            onChanged: (value) => onSearch(value),
                            textAlign: TextAlign.left,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: const BorderSide(
                                    color: Color(0xffD0D3D4), width: 0.7),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: const BorderSide(
                                    color: Color(0xffD0D3D4), width: 0.7),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: const BorderSide(
                                    color: Color(0xffD0D3D4), width: 0.7),
                              ),
                              suffixIcon: Container(
                                height: 50,
                                width: 55,
                                // padding: const EdgeInsets.all(5),
                                //alignment: Alignment.topLeft,
                                decoration: BoxDecoration(
                                  color: COLORS.APP_THEME_DARK_RED_COLOR,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                    alignment: Alignment.center,
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 25, //Color(0xff243444),
                                    ),
                                    onPressed: () {
                                      editingController.text = "";
                                      Navigator.pop(searchdialogContext);
                                    }),
                              ),
                              // IconButton(
                              //   onPressed: _controller.clear,
                              //   icon: Icon(Icons.clear),
                              // ),
                            ),
                          ),
                        )),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    return isdataconnection
        ? RefreshIndicator(
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                leading: Container(
                  padding: const EdgeInsets.only(right: 10),
                  height: 24,
                  width: 24,
                  child: IconButton(
                    icon: Image.asset(
                      'assets/images/backarrow.png',
                      color: COLORS.APP_THEME_DARK_RED_COLOR,
                    ),
                    iconSize: 24,
                    // color: Colors.black,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                // Icon(
                //   Icons.arrow_back_outlined,
                //   size: 35,
                //   color: Colors.black,
                //   //color: Color(0xff243444),
                // ),
                //Image.asset('assets/images/backarrow.png'),

                elevation: 0,
                //  backgroundColor: Colors.grey.shade900,
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
                // title: Visibility(
                //     visible: isCountryNameVisible,
                //     child: Container(
                //       // SearchBox
                //       // margin: const EdgeInsets.all(5),
                //       decoration: const BoxDecoration(
                //         boxShadow: [
                //           BoxShadow(
                //             color: Color(0xffD0D3D4),
                //             blurRadius: 10,
                //             offset: Offset(0, 3),
                //           ),
                //         ],
                //       ),
                //       child: SizedBox(
                //         height: 50,
                //         child: TextField(
                //           autofocus: true,
                //           controller: editingController,
                //           onChanged: (value) => onSearch(value),
                //           style: const TextStyle(
                //               fontSize: 16.0, color: Color(0xff243444)),
                //           decoration: InputDecoration(
                //             filled: true,
                //             fillColor: Colors.white,
                //             contentPadding: const EdgeInsets.all(5),
                //             // prefixIcon: Icon(
                //             //   Icons.search,
                //             //   color: Color(0xffD0D3D4),
                //             // ),
                //             border: OutlineInputBorder(
                //                 borderRadius: BorderRadius.circular(10),
                //                 borderSide: BorderSide.none),
                //             hintStyle: const TextStyle(
                //                 fontSize: 16, color: Color(0xff243444)),
                //             //hintText: 'search'.tr
                //             // getTranslated(context, 'search_post') ?? ""
                //           ), //"Search Post"),
                //         ),
                //       ),
                //     )),
                // title: Transform(
                //   // you can forcefully translate values left side using Transform
                //   transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
                //   child: Text(
                //     widget.title.toUpperCase(),
                //     softWrap: false,
                //     maxLines: 3,
                //     overflow: TextOverflow.fade,
                //     style: const TextStyle(
                //       fontFamily: 'Helvetica',
                //       fontSize: 16,
                //       // fontWeight: FontWeight.bold,
                //       color: Colors.black87,
                //     ),
                //   ),
                // ),
                actions: <Widget>[
                  Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: IconButton(
                          // padding: const EdgeInsets.only(top: 5.0),
                          icon: isCountryNameVisible
                              ? const Icon(Icons.close,
                                  color: COLORS.APP_THEME_DARK_RED_COLOR,
                                  size: 25)
                              : const Icon(
                                  Icons.search,
                                  // color: Color(0xff273343),
                                  color: COLORS.APP_THEME_DARK_RED_COLOR,
                                  size: 25,
                                ),
                          onPressed: () {
                            // if (isCountryNameVisible) {
                            //   setState(() {
                            //     editingController.text = "";
                            //     _foundedPost = discussionthreads;
                            //   });
                            // }
                            // _showHideCountryName();
                            setState(() {
                              _foundedPost = discussionthreads;
                            });
                            showSearchDialog();
                          },
                        ),
                      ),
                      // Visibility(
                      //   visible: !isCountryNameVisible,
                      //   // child: Padding(
                      //   //   padding: const EdgeInsets.all(2.0),
                      //   child: Icon(
                      //     size: 20,
                      //     Icons.language,
                      //     color: Color(
                      //         0xff273343), //const Color.fromARGB(255, 36, 52, 68),
                      //   ),
                      // Align(
                      //   alignment: Alignment.centerLeft,
                      //   // child:
                      //   // SizedBox(
                      //   // width: 30.0,
                      //   child: DropdownButton<Language>(
                      //     underline: const SizedBox(),
                      //     // ignore: prefer_const_constructors
                      //     icon: Icon(
                      //       size: 30,
                      //       Icons.language,
                      //       color: Colors
                      //           .black54, //const Color.fromARGB(255, 36, 52, 68),
                      //     ),
                      //     onChanged: (Language? language) {
                      //       updateLanguage(language!);
                      //     },
                      //     items: Language.languageList()
                      //         .map<DropdownMenuItem<Language>>(
                      //           (e) => DropdownMenuItem<Language>(
                      //             value: e,
                      //             child: Row(
                      //               mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //               children: <Widget>[
                      //                 Text(
                      //                   e.flag,
                      //                   style: const TextStyle(fontSize: 30),
                      //                 ),
                      //                 Text(e.name)
                      //               ],
                      //             ),
                      //           ),
                      //         )
                      //         .toList(),
                      //   ),
                      // ),
                      // ),
                      // const SizedBox(
                      //   width: 3.0,
                      // ),
                      // Visibility(
                      //     visible: !isCountryNameVisible,
                      //     child: Align(
                      //       alignment: Alignment.centerRight,
                      //       child: Text(
                      //         selectedCountry,
                      //         maxLines: 2,
                      //         softWrap: false,
                      //         overflow: TextOverflow.fade,
                      //         textAlign: TextAlign.center,
                      //         style: const TextStyle(
                      //             color: Colors.black87,
                      //             fontSize: 16,
                      //             fontFamily: 'Helvetica'),
                      //       ),
                      //     )),
                      // const SizedBox(
                      //   width: 10.0,
                      // ),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 30,
                    child: IconButton(
                      alignment: Alignment.centerLeft,
                      icon: const Icon(
                        Icons.more_vert_outlined,
                        // color: Color(0xff243444), //0xff243444
                        color: COLORS.APP_THEME_DARK_RED_COLOR,
                      ),
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  const NewExpandablewidget())),
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
                    //                 Navigator.of(context).push(
                    //                     MaterialPageRoute(
                    //                         builder: (context) =>
                    //                             const NewExpandablewidget()));
                    //               },
                    //             ),
                    //           ),
                    //         ]),
                    // const SizedBox(
                    //   width: 10.0,
                    // ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
                backgroundColor: Colors.white, //Color(0xffD0D3D4),
              ), //const Text("Forum")),
              body: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    color: Colors.white,
                    // flex: 1,
                    child: ListTile(
                      leading: SizedBox(
                        height: 60, //double.infinity,
                        child: FadeInImage.assetNetwork(
                          placeholder: "assets/images/no_image.png",
                          image: (APIDATA.menuicon ??
                                      '${ApiConstant.menuiconpoint}no_image.png')
                                  .isNotEmpty
                              ? ApiConstant.menuiconpoint +
                                  (APIDATA.menuicon ?? "")
                              : '${ApiConstant.menuiconpoint}no_image.png',
                          height: 30,
                          width: 54,
                          alignment: Alignment.topLeft,
                        ),
                        // Image.asset(
                        //   'assets/images/group.png',
                        //   height: 48,
                        //   width: 48,
                        // ),
                      ),
                      title: Text(
                        // widget.title,
                        widget.currentmenuitem.menuname.capitalizeFirstofEach,
                        style: const TextStyle(
                            color: COLORS
                                .APP_THEME_DARK_RED_COLOR, //Color(0xff243444),
                            fontSize: 24,
                            fontFamily: 'HelveticaBold'),
                      ),
                      tileColor: Colors.white,
                      minLeadingWidth: 0,
                    ),
                  ),
                   Visibility(
                     visible: widget.submenuchild.isNotEmpty ? true : false,
                     child:
                  Container(
                    // padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    // height: MediaQuery.of(context).size.height * 0.1,
                    // margin: const EdgeInsets.only(bottom: 10),
                    // color: Colors.white,
                    // padding: const EdgeInsets.all(10),
                    // alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 10,top:8,right: 5),
                    height: getlocale()=="ar"?60:55,
                    width: MediaQuery.of(context).size.width - 25,
                    decoration: BoxDecoration(
                      color: Colors.white, //Color(0xffD0D3D4),
                      borderRadius: BorderRadius.circular(
                        5.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xffD0D3D4),
                          blurRadius: 5,
                          spreadRadius: 2,
                          // offset: Offset(10, 10),
                        ),
                      ],
                    ),

                    // child: Center(
                    child: DropdownButton(
                      isExpanded: true,
                     // underline: const SizedBox(),
                      underline: Container(
                        height: 1,
                        color: Colors.transparent,
                      ),
                     // alignment: Alignment.center,
                      //hint: const Text('Please choose a Menu'),
                      // value: selectedMenu,
                      value: widget.currentmenuitem,
                      onChanged: (newValue) {
                        setState(() {
                          isLoading = true;
                          selectedMenu = newValue;

                          //print(selectedMenu);
                          widget.currentmenuitem = selectedMenu;
                          //callApiToGetDiscussionDatabymenu();
                          getDiscussionDatabymenuid(
                              widget.currentmenuitem.menuId);
                        });
                      },
                      items: widget.submenuchild.map((menu) {
                        return DropdownMenuItem(
                          value: menu,
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: double.maxFinite,
                                // alignment: Alignment.centerLeft,


                                padding: const EdgeInsets.only(
                                  top: 12,
                                  bottom: 14.5, // adjust the way you like
                                ),

                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xff243444),
                                      width: 0.1,
                                    ),
                                  ),
                                ),
                                  // decoration: const BoxDecoration(
                                  //   // border: index == 0
                                  //   //     ? const Border() // This will create no border for the first item
                                  //   //     : const Border(
                                  //   //         top: BorderSide(
                                  //   //             width: 1,
                                  //   //             color: Colors
                                  //   //                 .grey)),
                                child: Text(
                                  menu.menuname.capitalizeFirstofEach,
                                  style: const TextStyle(
                                      color: Color(0xff243444),
                                      fontSize: 14,
                                      fontFamily: 'Helvetica'),
                                ),
                              ),
                              // const Divider()
                            ],

                            // ),
                            // value: menu,
                            // child: Text(
                            //   menu.menuname.capitalizeFirstofEach,
                            //   style: const TextStyle(
                            //       color: Color(0xff243444),
                            //       fontSize: 14,
                            //       fontFamily: 'HelveticaNueueLight'),
                          ),

                        );
                      }).toList(),
                    ),
                  ),
                  ),
                  // const SizedBox(height: 10),

                  Padding(
                    padding: widget.submenuchild.isNotEmpty
                        ? const EdgeInsets.only(top: 10)
                        : const EdgeInsets.only(top: 0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      // child:
                      // SizedBox(
                      // width: 30.0,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.only(right: 20),
                        height: 40,
                        // margin: const EdgeInsets.only(
                        //     left: 10, right: 0, top: 5, bottom: 10),
                        //     // width: MediaQuery.of(context).size.width - 25,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              DropdownButton<sortBy>(
                                underline: const SizedBox(),
                                // ignore: prefer_const_constructors
                                // value: _selectedText,
                                icon:  Icon(
                                  size: 30,
                                  Icons.sort,
                                  color: Color(
                                      0xff243444), //const Color.fromARGB(255, 36, 52, 68),
                                ),
                                onChanged: (sortBy? seletedSort) {
                                  // print(seletedSort?.id);
                                  setState(() {
                                    selectedSortMenu = seletedSort?.title ?? "";
                                    sortByMethod(seletedSort!);
                                  });
                                },
                                items: sortBy
                                    .sortByArr()
                                    .map<DropdownMenuItem<sortBy>>(
                                      (e) => DropdownMenuItem<sortBy>(
                                        value: e,
                                        child: Text(
                                          e.title,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xff243444)),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              // const SizedBox(width: 5),
                              Text(
                                selectedSortMenu,
                                maxLines: 2,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Color(0xff243444),
                                    fontSize: 16,
                                    fontFamily: 'Helvetica'),
                              ),
                              // const SizedBox(width: 10),
                            ]),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 5),
                  // ListView.builder(
                  //   shrinkWrap: true,
                  //   scrollDirection: Axis.horizontal,
                  //   itemCount: menu.length,
                  //   itemExtent: 170,
                  //   itemBuilder: (BuildContext context, int index) {
                  //     return GestureDetector(
                  //         onTap: () {
                  //           //const AllPopularTopics();
                  //           setState(() {
                  //             //  menu[index].isSelected = true;
                  //             resetmenu(index);
                  //           });
                  //         },
                  //         child: Container(
                  //           padding: const EdgeInsets.all(5.0),
                  //           //  width: MediaQuery.of(context).size.width * 0.4,
                  //           // width: MediaQuery.of(context).size.width * 0.4,
                  //           margin: const EdgeInsets.only(right: 25.0),
                  //           decoration: BoxDecoration(
                  //               color: menu[index].isSelected
                  //                   ? const Color(0xff8D0C18)
                  //                   : const Color(0xFFFFFFFF),
                  //               //     color: const Color.fromARGB(255, 61, 60, 60),
                  //               borderRadius: BorderRadius.circular(
                  //                 30.0,
                  //               ),
                  //               border: Border.all(
                  //                   color: menu[index].isSelected
                  //                       ? const Color(0xFFFFFFFF)
                  //                       : const COLORS.APP_THEME_DARK_RED_COLOR,
                  //                   width: 2)),
                  //           child: Padding(
                  //             padding: const EdgeInsets.all(2.0),
                  //             child: Column(
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               crossAxisAlignment: CrossAxisAlignment.center,
                  //               children: <Widget>[
                  //                 Text(
                  //                   menu[index].title,
                  //                   textAlign: TextAlign.center,
                  //                   maxLines: 2,
                  //                   style: TextStyle(
                  //                       color: menu[index].isSelected
                  //                           ? const Color(0xFFFFFFFF)
                  //                           : const Color(0xff243444),
                  //                       fontSize: 14,
                  //                       fontFamily: 'Helvetica',
                  //                       fontWeight: FontWeight.w500,
                  //                       letterSpacing: 1),
                  //                 ),
                  //                 // const SizedBox(height: 10),
                  //                 // Text(
                  //                 //   "30 posts",
                  //                 //   style: TextStyle(
                  //                 //       color: Colors.white, fontSize: 18, letterSpacing: .7),
                  //                 // )
                  //               ],
                  //             ),
                  //           ),
                  //         ));
                  //   },
                  // ),
                  // ),
                  Expanded(
                      child: Container(
                    color: Colors.white,
                    child: _foundedPost.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(10),
                            child: ListView.builder(
                              itemCount: _foundedPost.length,
                              itemBuilder: (context, index) {
                                //child: new Text(wordPair.asPascalCase), // Change this line to...
                                //var selectedpost = _foundedPost[index];

                                return postComponent(
                                    post: _foundedPost[index], index: index);
                                // ... this line.
                              },
                              // separatorBuilder: (context, index) {
                              //   return const Divider();
                              // },
                            ))
                        : isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : /*Center(
                            child: Text(
                              'no_data_found'.tr,
                              style: TextStyle(color: Colors.black),
                            ),
                          )*/
                            const NoDataFoundWidget(),
                  )),
                ],
              ),
            ),
            onRefresh: () {
              return Future.delayed(const Duration(seconds: 1), () {
                setState(() {
                  getDiscussionDatabymenuid(widget.currentmenuitem.menuId);
                });
              });
            })
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

  void callApiToGetDiscussionDatabymenu() {
    /*setState(() {
      isLoading = true;
    });*/
    final id = menu.indexOf(widget.currentmenuitem);
    // print(menu.map((e) => e.menuname));
    print(widget.currentmenuitem);
    resetmenu(id);
  }

  void sortByMethod(sortBy sortMenu) {
    if (sortMenu.id == 1) {
      isModifiedDateAscending = !isModifiedDateAscending;
      if (isModifiedDateAscending) {
        // final objID =
        //     sortBy.sortByArr().firstWhere((item) => item.id == sortMenu.id);
        // setState(() => objID.title = 'By Last modified date(asc)');

        // sortByUpdatedDateInAscending();

        shortbyModifiedDate = 'asc';
        getDiscussionDatabymenuid(widget.currentmenuitem.menuId);
      } else {
        shortbyModifiedDate = 'desc';
        getDiscussionDatabymenuid(widget.currentmenuitem.menuId);
        // final objID =
        //     sortBy.sortByArr().firstWhere((item) => item.id == sortMenu.id);
        // setState(
        //     () => sortBy.sortByArr()[0].title = 'By Last modified date(desc)');

        // sortByUpdatedDateInDescending();
      }
    } else if (sortMenu.id == 2) {
      if (isLikeAscending) {
        sortByLikeInAscending();
      } else {
        sortByLikeInDescending();
      }
      isLikeAscending = !isLikeAscending;
    } else if (sortMenu.id == 3) {
      if (isReplyAscending) {
        sortByReplyInAscending();
      } else {
        sortByReplyInDescending();
      }
      isReplyAscending = !isReplyAscending;
    }
  }

  Widget postComponent({required Discussionthread post, required int index}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        margin: const EdgeInsets.all(10),
        //height: 160,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          // color: Colors.white,
          border: Border.all(color: const Color(0xffD0D3D4), width: 1),
          borderRadius: BorderRadius.circular(20.0),
        ),
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                APIDATA.selecteddiscussionthreads = post;

                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (_) => PostScreen(
                //               discussionthread: post,
                //               submenuchild: widget.submenuchild,
                //               currentmenuitem: widget.currentmenuitem,
                //               title: widget.title,
                //             )));

                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PostScreen(
                                  discussionthread: post,
                                  submenuchild: widget.submenuchild,
                                  currentmenuitem: widget.currentmenuitem,
                                  title: widget.title,
                                )))
                    // const Languages(isComingFromSideMenu: true)))
                    .then((value) {
                  setState(() {
                    // refresh state of Page1
                    print('Refresh postbymenu');
                    isLoading = true;
                  });
                });
              },
              // child: Expanded(
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                        //height: 30,
                        width: MediaQuery.of(context).size.width,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 13.0, right: 5.0, top: 15, bottom: 1),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: Text(
                                post.title.inCaps,
                                // discussionthread.title,
                                style: const TextStyle(
                                    color: COLORS.APP_THEME_DARK_RED_COLOR,
                                    //Color(0xff000000), //Colors.black,
                                    fontFamily: 'HelveticaNueueBold',
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    height: 1.4,
                                    letterSpacing: .2),
                              ),
                            ),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Html(
                        data: '${post.subtitle}...',
                        //.substring(0, 90) + '..',
                        // data:
                        //     'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged',
                        style: {
                          '#': Style(
                              fontSize: const FontSize(14),
                              color: const Color(0xff243444),
                              maxLines: 4,
                              fontFamily: 'HelveticaNueueLight',
                              letterSpacing: 0.2,
                              lineHeight: const LineHeight(1.5),
                              fontWeight: FontWeight.normal,
                              textOverflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left),
                        },
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: Color(0xffD0D3D4),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
              child: bottomRow(index: index),
            ),
          ],
        ),
        //const SizedBox(height: 5),
      ),
    );
  }

  Widget bottomRow({required int index}) {
    return Padding(
      // padding: const EdgeInsets.only(left: 5.0, top: 5.0, bottom: 5),
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Text("${displayDate.day}/${displayDate.month}/${displayDate.year}")
              Text(
                discussionthreads[index].updatedAt,
                // "${displayDate.day}-${MONTHS[displayDate.month - 1]}-${displayDate.year}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xff243444),
                  fontFamily: 'Helvetica',
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 25.0,
                    width: 25.0,
                    child: IconButton(
                      padding: const EdgeInsets.only(bottom: 2),
                      // constraints: BoxConstraints(maxHeight: 36),
                      icon: discussionthreads[index]
                              .discussionlikebydevid
                              .isNotEmpty //discussionthreads[index].isLikeButtonSelected
                          ? const Icon(
                              Icons.favorite, // Fill
                              color: COLORS
                                  .APP_THEME_DARK_RED_COLOR, //Color(0xffAB0E1E),
                              size: 20,
                            )
                          : const Icon(Themify.heart, // Blank
                              color: COLORS.APP_THEME_DARK_RED_COLOR,
                              //Color(0xffAB0E1E), //.withOpacity(0.5),
                              size: 18),
                      onPressed: () {
                        // discussionthreads[index].isLikeButtonSelected =
                        //     !discussionthreads[index].isLikeButtonSelected;

                        setState(() {
                          isLikeLoading = true;
                        });

                        _showDialog('processing');
                        _fetchBackEndData(index);

                        print('Like IconButton is pressed');
                      },
                    ),
                  ),
                  const SizedBox(width: 3.0),
                  GestureDetector(
                    onTap: () {
                      // discussionthreads[index].isLikeButtonSelected =
                      //     !discussionthreads[index].isLikeButtonSelected;
                      setState(() {
                        isLikeLoading = true;
                      });

                      _showDialog('processing');
                      _fetchBackEndData(index);

                      print('Like IconButton is pressed');
                    },
                    child: Text(
                      '${discussionthreads[index].like}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xffAB0E1E),
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Helvetica',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 25.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/reply.png',
                    height: 18,
                    width: 20,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    '${_foundedPost[index].reply}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff243444),
                      fontFamily: 'HelveticaNueueMedium',
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 15.0),
              // // const Divider(height: 5, color: Color.fromRGBO(232, 222, 12, 1)),
              // const SizedBox(width: 4.0),
            ],
          )
        ],
      ),
    );
  }

  Future<void> likeUnlikeApiCall(int index) async {
    selectedLikeIndex = index;
    // if (discussionthreads[index].isLikeButtonSelected) {
    if (discussionthreads[index].discussionlikebydevid.isNotEmpty) {
      apiToUnLikePost(discussionId: discussionthreads[index].id)
          .then((_) => Navigator.pop(dialogContext));
    } else {
      apiToLikePost(discussionId: discussionthreads[index].id)
          .then((_) => Navigator.pop(dialogContext));
    }
  }

  Future<void> _getDeviceDetails() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        setState(() {
          deviceName = build.model;
          deviceVersion = build.version.toString();
          deviceID = build.androidId;

          getDiscussionDatabymenuid(widget.currentmenuitem.menuId);
        });
        //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        setState(() {
          deviceName = data.name;
          deviceVersion = data.systemVersion;
          deviceID = data.identifierForVendor;

          getDiscussionDatabymenuid(widget.currentmenuitem.menuId);
        }); //UUID for iOS
      }

      APIDATA.deviceID = deviceID;
      print('Device Info: ${deviceName}, ${deviceVersion}, ${deviceID}');
    } on PlatformException {
      print('Failed to get platform version');
    }
  }

  Future<void> _fetchBackEndData(int index) async {
    await likeUnlikeApiCall(index);
  }

  _showDialog(String msg) async {
    await showDialog<String>(
        context: context,
        builder: (context) {
          dialogContext = context;
          return StatefulBuilder(
            builder: (context, setState) {
              return Visibility(
                  visible: isLikeLoading,
                  child: AlertDialog(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    content: SizedBox(
                      width: 150.0,
                      height: 100.0,
                      child: isLikeLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    msg.tr,
                                    style: const TextStyle(
                                      fontFamily: "Helvetica",
                                      color: Color(0xFF5B6978),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                              ],
                            )
                          : const Center(
                              child: Text('success'),
                            ),
                    ),
                  ));
            },
          );
        });
  }
// _showDialog() async {
//   await showDialog<String>(
//     context: context,
//     builder: (context) {
//       return StatefulBuilder(
//         builder: (context, setState) {
//           return ButtonBarTheme(
//               data: const ButtonBarThemeData(
//                   alignment: MainAxisAlignment.center),
//               child: AlertDialog(
//                 contentPadding:
//                     const EdgeInsets.only(top: 10, left: 10, right: 10),
//                 content: SizedBox(
//                     height: 160,
//                     child: Dialog(
//                       // The background color
//                       elevation: 0,
//                       insetPadding: EdgeInsets.zero,
//                       // insetPadding:
//                       //     const EdgeInsets.symmetric(horizontal: 8),
//                       backgroundColor: Colors.white,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 15),
//                         // padding: const EdgeInsets.only(
//                         //     top: 0, left: 0, right: 0, bottom: 5),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Center(
//                               child: Text('Discussion like is in process',
//                                   style: const TextStyle(
//                                       color: Color(0xff243444),
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold)),
//                             ),
//                             const SizedBox(
//                               height: 20,
//                             ),
//                             Center(
//                               child: Text('comment_submission_process'.tr,
//                                   style: TextStyle(
//                                     color: Color(0xff243444),
//                                     fontSize: 14,
//                                   )),
//                             ),
//                             const SizedBox(
//                               height: 25,
//                             ),
//                             const CircularProgressIndicator(),
//                             // const SizedBox(
//                             //   height: 10,
//                             // ),
//                           ],
//                         ),
//                       ),
//                     )),
//                 actions: <Widget>[
//                   Center(
//                     child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                             primary: const Color(0xff243444),
//                             textStyle: const TextStyle(
//                                 fontSize: 14, fontWeight: FontWeight.normal)),
//                         onPressed: () {
//                           print("something_is_wrong".tr);
//                         },
//                         child: Text('ok'.tr)),
//                     // const SizedBox(
//                     //   width: 30,
//                   ),
//                 ],
//               ));
//         },
//       );
//     },
//   );
// }
}
