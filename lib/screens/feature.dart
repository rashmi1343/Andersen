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

import 'package:andersonappnew/Localization/classes/language.dart';

import 'package:andersonappnew/responses/MenuByCountryResponse.dart';
import 'package:andersonappnew/screens/post_screen.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
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
import '../constant.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Localization/localization/language_constants.dart';
import '../models/post_model.dart';
import '../models/likeReply.dart';
import '../models/unlikeReply.dart';

import '../responses/AllDiscussionResponse.dart';
import '../responses/LikeDiscussionThread.dart';
import '../responses/MenuByIdResponse.dart';
import 'documentView.dart';

class sortBy {
  sortBy({required this.id, required this.title, required this.isAscending});

  int id;
  String title;
  bool isAscending = false;

  static List<sortBy> sortByArr() {
    return <sortBy>[
      sortBy(id: 1, title: 'by_last_modified_date'.tr, isAscending: false),
      sortBy(id: 2, title: 'by_no_of_likes'.tr, isAscending: false),
      sortBy(id: 3, title: 'by_no._of_reply'.tr, isAscending: false)
    ];
  }
}

class FeatureArticlePage extends StatefulWidget {
  @override
  _FeatureArticlePageState createState() => _FeatureArticlePageState();
}

class _FeatureArticlePageState extends State<FeatureArticlePage> {
  List<Discussionthread> _foundedPost = [];
  List<DiscussionLike> likeData = <DiscussionLike>[];
  TextEditingController editingController = TextEditingController();

  DateTime displayDate = DateTime.now();

  // Map<UnlikeReply, String> unlikeData = <UnlikeReply, String>{};

  bool isLoading = true;
  List data = [];
  String shortbyModifiedDate = 'desc';
  bool isCountryNameVisible = false;
  late BuildContext dialogContext;
  int selectedLikeIndex = -1;

  List<Discussionthread> discussionthreads = [];

  //  sortBy sortByArr = sortBy(id: 1, title:'By last modified date', isAscending: false);
  // List<sortBy> sortByArr = <sortBy>[];

  int _selectedIndex = 0;

  // bool isLikeButtonSelected = false;

  List<Menu> menu = [];

  var selectedMenu;
  var selectedSortMenu = 'sort_by'.tr;

  // var _selectedSortOption;

  var isModifiedDateAscending = false;
  var isLikeAscending = false;
  var isReplyAscending = false;

  bool isLikeLoading = false;

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
      isLoading = true;
      //callApiToGetMenuData();
    });
  }

  Future<List<Discussionthread>> getFeaturedArticleData() async {
    var token = await getToken();

    var locale = await getlocale();
    //  var menuid = await getmenuid();
    Map jsonMap = {
      "methodname": "getfeaturedarticlenew",
      "locale": locale,
      "shortby": shortbyModifiedDate
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

      setState(() {
        isLoading = false;
        _foundedPost = [];
        _foundedPost = threadsObj.discussionthreads;
        //  if (kDebugMode) {

        // print(_foundedPost.map((e) => e.title));
        // print(_foundedPost.map((e) => e.subtitle));
        //   }
      });

      return discussionthreads;
      // }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something_went_wrong_please_try_again'.tr),
      ));
      throw Exception('Failed to load data');
    }
  }

  Future<LikeDiscussionThread> apiToLikePost({required int discussionId}) {
    return getLikeData(ApiConstant.url + ApiConstant.Endpoint,
        discussionId: discussionId);
  }

  Future<LikeDiscussionThread> apiToUnLikePost({required int discussionId}) {
    return getUnLikeData(ApiConstant.url + ApiConstant.Endpoint,
        discussionId: discussionId);
  }

  Future<LikeDiscussionThread> getLikeData(String url,
      {required int discussionId}) async {
    var token = await getToken();

    var locale = await getlocale();
    Map jsonMap = {
      "methodname": "likediscussion",
      "discussion_id": discussionId.toString(),
      "locale": locale
    };
    // if (kDebugMode) {
    print('$url , $jsonMap');
    // }

    final response = await http.post(Uri.parse(url), body: jsonMap, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    debugPrint('${response.statusCode}');
    if (response.statusCode == 200) {
      final likeObj = likeDiscussionThreadFromJson(response.body);
      likeData = likeObj.like;
      // likeData = likeObj;

      // if (kDebugMode) {
      // print('likeData, $likeData');
      // }
      setState(() {
        discussionthreads[selectedLikeIndex].like += 1;
        isLikeLoading = false;

        // isLoading = false;
      });

      return likeObj;
      // }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
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
      "locale": locale
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
        discussionthreads[selectedLikeIndex].like -= 1;
        isLikeLoading = false;
      });

      return likeObj;
      // }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
  }

  resetmenu(int pst) async {
    var idx = 0;
    // setState(() {
    //   isLoading = true;
    // });
    for (var objMenu in menu) {
      if (pst == idx) {
        // objMenu.isSelected = true;
        //    SharedPreferences prefs = await SharedPreferences.getInstance();
        //    prefs.setInt('submenuid', objMenu.id);
        // getDiscussionDatabymenuid(objMenu.id); //objMenu.id.toString()
        getFeaturedArticleData(); //objMenu.id.toString()
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
  late StreamSubscription<DataConnectionStatus> listener;
  bool isdataconnection = false;
  var Internetstatus = "Unknown";

  @override
  void initState() {
    super.initState();
    debugPrint('featured article by called');
    ConnectionUtil connectionStatus = ConnectionUtil.getInstance();
    connectionStatus.initialize();
    connectionStatus.connectionChange.listen(connectionChanged);
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
          // isLoading = false;

          getFeaturedArticleData();
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
    listener.cancel();
    super.dispose();
  }

  onSearch(String search) {
    setState(() {
      if (editingController.text.isEmpty) {
        _foundedPost = discussionthreads;
      } else {
        _foundedPost = discussionthreads
            .where((post) =>
                post.title.toLowerCase().contains(search) ||
                post.content.toLowerCase().contains(search))
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

  // bool shouldPop = true;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    return isdataconnection
        ? RefreshIndicator(
            onRefresh: getFeaturedArticleData,
            child: Scaffold(
              appBar: AppBar(
                leading: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back_outlined,
                    size: 25,
                    color: Colors.black,
                    // color: Color(0xff243444),
                  ),
                ),
                elevation: 0,
                //  backgroundColor: Colors.grey.shade900,
                centerTitle: false,
                titleSpacing: 0.0,
                title: Visibility(
                    visible: isCountryNameVisible,
                    child: Container(
                      // SearchBox
                      // margin: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xffD0D3D4),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          autofocus: true,
                          controller: editingController,
                          onChanged: (value) => onSearch(value),
                          style: const TextStyle(
                              fontSize: 16.0, color: Color(0xff243444)),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(5),
                            // prefixIcon: Icon(
                            //   Icons.search,
                            //   color: Color(0xffD0D3D4),
                            // ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                            hintStyle: const TextStyle(
                                fontSize: 16, color: Color(0xff243444)),
                            //hintText: 'search'.tr
                            // getTranslated(context, 'search_post') ?? ""
                          ), //"Search Post"),
                        ),
                      ),
                    )),
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
                      IconButton(
                        // padding: const EdgeInsets.only(top: 5.0),
                        icon: isCountryNameVisible
                            ? const Icon(Icons.close,
                                color: Color(0xff8D0C18), size: 25)
                            : const Icon(
                                Icons.search,
                                color: Color(0xff273343),
                                size: 25,
                              ),
                        onPressed: () {
                          if (isCountryNameVisible) {
                            setState(() {
                              editingController.text = "";
                              _foundedPost = discussionthreads;
                            });
                          }
                          _showHideCountryName();
                        },
                      ),
                      Visibility(
                        visible: !isCountryNameVisible,
                        // child: Padding(
                        //   padding: const EdgeInsets.all(2.0),
                        child: Icon(
                          size: 20,
                          Icons.language,
                          color: Color(
                              0xff273343), //const Color.fromARGB(255, 36, 52, 68),
                        ),
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
                      ),
                      const SizedBox(
                        width: 3.0,
                      ),
                      Visibility(
                          visible: !isCountryNameVisible,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              selectedCountry,
                              maxLines: 2,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontFamily: 'Helvetica'),
                            ),
                          )),
                      const SizedBox(
                        width: 10.0,
                      ),
                    ],
                  )
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
                        // Icon(
                        //   Icons.language,
                        //   size: 50,
                        // ),
                      ),
                      title: Text(
                        "feature_articles".tr,
                        style: const TextStyle(
                            color: Color(0xff243444),
                            fontSize: 24,
                            fontFamily: 'HelveticaBold'),
                      ),
                      tileColor: Colors.white,
                      minLeadingWidth: 0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    // child:
                    // SizedBox(
                    // width: 30.0,
                    child: Container(
                      padding: const EdgeInsets.only(right: 20, top: 10),
                      height: 55,
                      margin: EdgeInsets.only(
                          left: 10, right: 0, top: 5, bottom: 5),
                      //     // width: MediaQuery.of(context).size.width - 25,
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            DropdownButton<sortBy>(
                              underline: const SizedBox(),
                              // ignore: prefer_const_constructors
                              // value: _selectedText,
                              icon: Icon(
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
                            const SizedBox(width: 5),
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
                  const SizedBox(height: 5),
                  Expanded(
                      child: Container(
                    color: Colors.white,
                    child: _foundedPost.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(15),
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
                            : Center(
                                child: Text(
                                  'no_data_found'.tr,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                  )),
                ],
              ),
            ))
        : Container(
            color: Colors.white,
            child: Center(
                child: Text(
              'Check Your Internet Status',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'HelveticaBold',
                color: Color(0xff243444),
              ),
            )),
          );
  }

  void callApiToGetDiscussionDatabymenu() {
    setState(() {
      isLoading = true;
    });
    final id = menu.indexOf(selectedMenu);
    resetmenu(id);
  }

  void sortByMethod(sortBy sortMenu) {
    if (sortMenu.id == 1) {
      isModifiedDateAscending = !isModifiedDateAscending;
      if (isModifiedDateAscending) {
        shortbyModifiedDate = 'asc';
        // sortByUpdatedDateInAscending();
      } else {
        shortbyModifiedDate = 'desc';
        // sortByUpdatedDateInDescending();
      }
      getFeaturedArticleData();
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
      padding: const EdgeInsets.only(bottom: 20.0),
      child: GestureDetector(
        onTap: () {
          APIDATA.selecteddiscussionthreads = post;
          APIDATA.currentmenuitem = Menubycountry(
              countryId: 0,
              menuId: 0,
              isActive: 1,
              countryname: '',
              menuname: '',
              locale: '',
              parentId: 0,
              filepath: '',
              listiconpath: '',
              Submenu: []);

          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (_) => PostScreen(
          //               discussionthread: post,
          //               submenuchild: [],
          //               currentmenuitem: APIDATA.currentmenuitem,
          //               title: '',
          //             )));

          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PostScreen(
                            discussionthread: post,
                            submenuchild: const [],
                            currentmenuitem: APIDATA.currentmenuitem,
                            title: '',
                          )))
              // const Languages(isComingFromSideMenu: true)))
              .then((value) {
            setState(() {
              // refresh state of Page1
              print('Refresh feature article');
              isLoading = true;
            });
          });
        },
        // child: Expanded(
        child: Container(
          //height: 160,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            // color: Colors.white,
            border: Border.all(color: const Color(0xffD0D3D4), width: 1),
            borderRadius: BorderRadius.circular(10.0),
          ),
          constraints: const BoxConstraints(
            maxHeight: double.infinity,
          ),
          margin: const EdgeInsets.only(left: 0),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
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
                            left: 5.0, right: 5.0, top: 5, bottom: 5),
                        // child: Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        //   children: <Widget>[
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Text(
                            post.title,
                            // discussionthread.title,
                            style: const TextStyle(
                                color: Color(0xff000000), //Colors.black,
                                fontFamily: 'HelveticaBold',
                                fontSize: 14,
                                //  fontWeight: FontWeight.bold,
                                letterSpacing: .4),
                          ),
                        ),
                      ),
                    )),
                Html(
                  data: '${post.subtitle}..',
                  //.substring(0, 90) + '..',
                  // data:
                  //     'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged',
                  style: {
                    '#': Style(
                        fontSize: const FontSize(14),
                        color: Color(0xff243444),
                        maxLines: 4,
                        fontFamily: 'Helvetica',
                        fontWeight: FontWeight.w100,
                        textOverflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.justify),
                  },
                ),
                const Divider(
                  height: 1,
                  color: Color(0xffD0D3D4),
                ),
                const SizedBox(height: 5),
                bottomRow(index: index),
              ],
            ),
          ),
        ),
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
              // Row(
              //   children: <Widget>[
              //     const Icon(
              //       Themify.heart,
              //       color: Color(0xffAB0E1E),
              //       size: 15,
              //     ),
              //     const SizedBox(width: 4.0),
              //     Text(
              //       '${_foundedPost[index].like}',
              //       textAlign: TextAlign.left,
              //       style: const TextStyle(
              //         fontSize: 14,
              //         color: Color(0xffAB0E1E),
              //         fontFamily: 'Helvetica',
              //       ),
              //     )
              //   ],
              // ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 20.0,
                    width: 20.0,
                    child: IconButton(
                      padding: const EdgeInsets.only(bottom: 2),
                      // constraints: BoxConstraints(maxHeight: 36),
                      icon: discussionthreads[index].isLikeButtonSelected
                          ? const Icon(
                              Icons.favorite,
                              color: Color(0xffAB0E1E),
                              size: 16,
                            )
                          : Icon(Themify.heart,
                              color: Color(0xffAB0E1E), //.withOpacity(0.5),
                              size: 16),
                      onPressed: () {
                        discussionthreads[index].isLikeButtonSelected =
                            !discussionthreads[index].isLikeButtonSelected;

                        // String msg = '';

                        setState(() {
                          isLikeLoading = true;
                          // if (discussionthreads[index].isLikeButtonSelected) {
                          //   msg = 'Like is in process';
                          // } else {
                          //   msg = 'Unlike is in process';
                          // }
                        });

                        _showDialog('processing');
                        _fetchBackEndData(index);

                        // Navigator.pop(context);
                        //setState(() => isLikeLoading = false);
                        // });
                        //statements
                        print('Like IconButton is pressed');
                      },
                    ),
                  ),
                  const SizedBox(width: 3.0),
                  Text(
                    '${discussionthreads[index].like}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xff243444),
                      fontFamily: 'Helvetica',
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
                    height: 15,
                    width: 18,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    '${_foundedPost[index].reply}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xff243444),
                      fontFamily: 'Helvetica',
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
    if (discussionthreads[index].isLikeButtonSelected) {
      apiToLikePost(discussionId: discussionthreads[index].id)
          .then((_) => Navigator.pop(dialogContext));
    } else {
      apiToUnLikePost(discussionId: discussionthreads[index].id)
          .then((_) => Navigator.pop(dialogContext));
      ;
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
                                    style: TextStyle(
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
}
