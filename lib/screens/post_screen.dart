import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_keyboard_aware_dialog/flutter_keyboard_aware_dialog.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:themify_flutter/themify_flutter.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

import '../ConnectionUtil.dart';
import '../Localization/localization/language_constants.dart';
import '../constant.dart';

import '../models/likeReply.dart';

import 'package:http/http.dart' as http;

import '../responses/AllDiscussionResponse.dart';
import '../responses/GetAllReplyResponse.dart';
import '../responses/LikeDiscussionThread.dart';
import '../responses/MenuByCountryResponse.dart';

import 'NewExpandwidget.dart';

import 'dart:async';

import 'package:url_launcher/url_launcher.dart';

class PostScreen extends StatefulWidget {
  // final Question question;
  final Discussionthread discussionthread;

  List<Menubycountry> submenuchild;

  Menubycountry currentmenuitem;
  String title;

  // const PostScreen({required this.discussionthread, required this.question});

  PostScreen({
    required this.discussionthread,
    required this.submenuchild,
    required this.currentmenuitem,
    required this.title,
  });

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<Reply> reply = [];

  //var items = List<Reply>();
  List<Reply> items = [];
  List<Reply> tempitems = [];
  TextEditingController editingController = TextEditingController();

  int likeIndex = -1;

  var likeData = Like();
  bool isLoading = true;
  bool isPopupLoading = false;
  bool isLikeButtonSelected = false;
  bool isSearchBarVisible = false;

  var limit = 10;
  int page = 1;
  bool hasMore = true;
  late List<Discussionimage> discussionimage = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  StreamSubscription? connection;
  final _formKey = GlobalKey<FormState>();

  // var discussionthreadLike = 0;
  String name = '';
  String email = '';

  late BuildContext dialogContext;

  bool isLikeLoading = false;

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accesstoken');
  }

  Future<String?> getlocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(LAGUAGE_CODE);
  }

  Future<List<Reply>> getReplyData(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int? id = prefs.getInt('id');
    var locale = await getlocale();

    Map paramReply = {
      "methodname": "replybydiscussionid",
      "discussion_id": widget.discussionthread.id.toString(),
      "locale": locale
    };

    print('$url , $paramReply');

    var token = await getToken();
    print(token);

    final response =
        await http.post(Uri.parse(url), body: paramReply, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    print(response.statusCode);

    if (response.statusCode == 200) {
      Map decoded = json.decode(response.body);
      //items = [];
      print(decoded);

      present = 0;
      perPage = 4;
      items = [];
      tempitems = [];
      for (var objReply in decoded["reply"]) {
//        if (kDebugMode) {
        // print(objReply['id']);
        // print(objReply['user_id']);
        // print(objReply['discussion_id']);
        // print(objReply['best_answer']);
        // print(objReply['content']);
        // print(objReply['created_at']);
        // print(objReply['updated_at']);
        //      }

        reply.add(Reply(
            bestAnswer: objReply['best_answer'],
            createdAt: objReply['created_at'],
            updatedAt: objReply['updated_at'],
            userId: objReply['user_id'],
            content: objReply['content'],
            discussionId: objReply['discussion_id'],
            id: objReply['id'],
            name: objReply['name'],
            email: objReply['email'],
            likecount: objReply['likecount']));

        setState(() {
          isLoading = false;
        });
      }

      //   if (items.isNotEmpty) {
      if (reply.length < perPage) {
        perPage = reply.length;
      }
      items.addAll(reply.getRange(present, present + perPage));
      present = present + perPage;
      //   }

      tempitems = items;
      // if (reply.length > 0) {
      //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text("Your reply has been submitted!!"),
      //   ));
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text("Something went wrong,Please try again!!"),
      //   ));
      // }

      if (items.length == 0) {
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

    return reply;
  }

  onSearch(String search) {
    setState(() {
      if (editingController.text.isEmpty) {
        items = tempitems;
      } else {
        items = tempitems
            .where((post) =>
                post.name.toLowerCase().contains(search.toLowerCase()) ||
                post.content.toLowerCase().contains(search.toLowerCase()) ||
                post.updatedAt.toLowerCase().contains(search.toLowerCase()))
            // post.name.contains(search) ||
            // post.content.contains(search) ||
            // post.updatedAt.contains(search))

            .toList();
      }
    });
  }

  void _showHideSearchBar() {
    setState(() {
      isSearchBarVisible = !isSearchBarVisible;
    });
  }

  void loadMore() {
    setState(() {
      if ((present + perPage) > reply.length) {
        items.addAll(reply.getRange(present, reply.length));
      } else {
        items.addAll(reply.getRange(present, present + perPage));
      }
      present = present + perPage;
    });
  }

  _launchURL() async {
    Uri url = Uri.parse(widget.discussionthread.filepath);
    print(url);
    if (await canLaunchUrl(url)) {
      if (Platform.isAndroid) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else if (Platform.isIOS) {
        await launchUrl(url);
      }
    } else {
      throw 'Could not launch $url';
    }
  }

  // _launchContentURL(String url) async {
  //   Uri url1 = Uri.parse(url);
  //   if (await canLaunchUrl(url1)) {
  //     if (Platform.isAndroid) {
  //       await launchUrl(url1, mode: LaunchMode.externalApplication);
  //     } else if (Platform.isIOS) {
  //       await launchUrl(url1);
  //     }
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  Future<List<Reply>> getSubmitReplyData(
      String url, String submitReply, String name, String email) async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();

    // int? id = prefs.getInt('id');
    var locale = await getlocale();
    Map paramSubmitReply = {
      "discussion_id":
          //  id.toString(),
          widget.discussionthread.id.toString(),
      "methodname": "submitreply",
      "reply": submitReply,
      "locale": locale,
      "name": name,
      "email": email
    };

    print('$url , $paramSubmitReply');

    var token = await getToken();
    // print(token);

    final response =
        await http.post(Uri.parse(url), body: paramSubmitReply, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    print(response.body);

    if (response.statusCode == 200) {
      Map decoded = json.decode(response.body);

      print(decoded);
      items = [];
      reply = [];
      tempitems = [];
      for (var objSubmitReply in decoded["reply"]) {
        if (kDebugMode) {
          // print(objSubmitReply['id']);
          // print(objSubmitReply['user_id']);
          // print(objSubmitReply['discussion_id']);
          // print(objSubmitReply['best_answer']);
          // print(objSubmitReply['content']);
          // print(objSubmitReply['created_at']);
          // print(objSubmitReply['updated_at']);
        }

        reply.add(Reply(
            bestAnswer: objSubmitReply['best_answer'],
            createdAt: objSubmitReply['created_at'],
            updatedAt: objSubmitReply['updated_at'],
            userId: objSubmitReply['user_id'],
            content: objSubmitReply['content'],
            discussionId: objSubmitReply['discussion_id'],
            id: objSubmitReply['id'],
            name: objSubmitReply['name'],
            email: objSubmitReply['email'],
            likecount: objSubmitReply['likecount']));
      }

      setState(() {
        isPopupLoading = false;
        present = 0;
        perPage = 4;

        if (reply.length < perPage) {
          perPage = reply.length;
        }
        items.addAll(reply.getRange(present, present + perPage));
        present = present + perPage;

        tempitems = items;
        widget.discussionthread.reply += 1;
      });

      if (reply.isNotEmpty) {
        commentController.clear();
        nameController.clear();
        emailController.clear();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('your_reply_has_been_submitted'.tr,
              style: TextStyle(fontFamily: 'Helvetica')),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Something_went_wrong_please_try_again'.tr,
              style: TextStyle(fontFamily: 'Helvetica')),
        ));
      }
    }

    return reply;
  }

  Future<LikeDiscussionThread> getLikeData(String url,
      {required int discussionId}) async {
    var token = await getToken();

    var locale = await getlocale();
    Map jsonMap = {
      "methodname": "likediscussion",
      "discussion_id": discussionId.toString(),
      "locale": locale,
      "device_id": APIDATA.deviceID
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
      // likeData = likeObj.like;
      // likeData = likeObj;

      // if (kDebugMode) {
      // print('likeData, $likeData');
      // }
      setState(() {
        widget.discussionthread.like += 1;

        widget.discussionthread.discussionlikebydevid.add(Discussionlikebydevid(
            deviceId: '', id: 0, discussionId: discussionId, userId: 0));
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

  Future<LikeDiscussionThread> getUnLikeData(String url,
      {required int discussionId}) async {
    var token = await getToken();
    var locale = await getlocale();
    Map jsonMap = {
      "methodname": "unlikediscussion",
      "discussion_id": discussionId.toString(),
      "locale": locale,
      "device_id": APIDATA.deviceID
    };
    print('$url , $jsonMap');
    final response = await http.post(Uri.parse(url), body: jsonMap, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    debugPrint('${response.statusCode}');
    if (response.statusCode == 200) {
      final likeObj = likeDiscussionThreadFromJson(response.body);

      // final likeObj = likeDiscussionThreadFromJson(response.body);
      // // likeData = likeObj.like;
      // likeData = likeObj;
      // print('UnlikeData $likeData');
      setState(() {
        if (widget.discussionthread.like > 0) {
          widget.discussionthread.like -= 1;
        }
        widget.discussionthread.discussionlikebydevid = [];
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

  int present = 0;
  int perPage = 4;

  bool isdataconnection = false;
  late BuildContext searchdialogContext;

  var Internetstatus = "Unknown";
  var _controller = TextEditingController();

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
                          padding: const EdgeInsets.only(top: 10, right: 2.0),
                          child: IconButton(
                            // padding: const EdgeInsets.only(top: 5.0),
                            icon: const Icon(Icons.close,
                                color: COLORS.APP_THEME_DARK_RED_COLOR,
                                size: 22),
                            onPressed: () {
                              setState(() {
                                items = tempitems;
                              });
                              editingController.text = "";
                              Navigator.pop(searchdialogContext);
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: Text(
                        'i_want'.tr,
                        style: TextStyle(
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
                                borderSide: BorderSide(
                                    color: Color(0xffD0D3D4), width: 0.7),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide(
                                    color: Color(0xffD0D3D4), width: 0.7),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide(
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
                                child: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: IconButton(
                                      alignment: Alignment.center,
                                      icon: Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 25, //Color(0xff243444),
                                      ),
                                      onPressed: () {
                                        // setState(() {
                                        //   items = tempitems;
                                        // });
                                        editingController.text = "";
                                        Navigator.pop(searchdialogContext);
                                      }),
                                ),
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
  void initState() {
    super.initState();
    ConnectionUtil connectionStatus = ConnectionUtil.getInstance();
    connectionStatus.initialize();
    connection = connectionStatus.connectionChange.listen(connectionChanged);

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

          // apiToLikePost();
          getReplyData(ApiConstant.url + ApiConstant.Endpoint);
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
    BackButtonInterceptor.remove(myInterceptor);
    connection?.cancel();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    /*Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Postbymenu(
                title: widget.title,
                submenuchild: widget.submenuchild,
                currentmenuitem: widget.currentmenuitem)));*/
    print("Back To Post By Menu Page");
    //  Navigator.pop(context);
    if (["postbymenuRoute"].contains(info.currentRoute(context))) return true;

    return false;
  }

  Future<LikeDiscussionThread> apiToLikePost({required int discussionId}) {
    return getLikeData(ApiConstant.url + ApiConstant.Endpoint,
        discussionId: discussionId);
  }

  Future<LikeDiscussionThread> apiToUnLikePost({required int discussionId}) {
    return getUnLikeData(ApiConstant.url + ApiConstant.Endpoint,
        discussionId: discussionId);
  }

  final formKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController();
  bool validateComment = false;

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

  bool _replyIsVisible = false;
  bool _replyArrow = false;

  void showReplies() {
    setState(() {
      _replyIsVisible = !_replyIsVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _screen = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    print(widget.discussionthread.content.length);
    return isdataconnection
        ? WillPopScope(
            //   onWillPop: () async => true,
            onWillPop: () async {
              Navigator.pop(context);
              return true;
            },
            child: RefreshIndicator(
                onRefresh: () {
                  return Future.delayed(const Duration(seconds: 1), () {
                    setState(() {
                      items = tempitems;
                    });
                  });
                },
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    // title: Text(
                    //   'reply'.tr.toUpperCase(),
                    //   style: const TextStyle(
                    //     fontFamily: 'Helvetica',
                    //     fontSize: 16,
                    //     color: Colors.black87,
                    //   ),
                    // ),
                    leading: Container(
                      padding: const EdgeInsets.only(right: 10),
                      height: 24,
                      width: 24,
                      child: IconButton(
                        icon: Image.asset(
                          'assets/images/backarrow.png',
                          color: COLORS.APP_THEME_DARK_RED_COLOR,
                        ),
                        // color: Colors.black,
                        color: COLORS.APP_THEME_DARK_RED_COLOR,
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
                    // ),

                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.pop(context);
                    //   },
                    //   child: IconButton(
                    //     icon: Image.asset('assets/images/backarrow.png'),
                    //     color: Colors.black,
                    //     onPressed: () {
                    //       Navigator.pop(context);
                    //     },
                    //   ),
                    //   // Icon(
                    //   //   Icons.arrow_back_outlined,
                    //   //   size: 35,
                    //   //   color: Colors.black,
                    //   //   //color: Color(0xff243444),
                    //   // ),
                    // ),
                    centerTitle: false,
                    titleSpacing: 0.0,
                    elevation: 0,
                    // title: Visibility(
                    //     visible: isSearchBarVisible,
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
                    backgroundColor: Colors.white,
                    iconTheme: const IconThemeData(color: Color(0xff243444)),
                    actions: <Widget>[
                      SizedBox(
                        width: 30,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 2.0),
                          child: IconButton(
                            // padding: const EdgeInsets.only(top: 5.0),
                            icon: isSearchBarVisible
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
                              // if (isSearchBarVisible) {
                              //   setState(() {
                              //     editingController.text = "";
                              //     items = tempitems;
                              //   });
                              // }
                              // _showHideSearchBar();
                              setState(() {
                                items = tempitems;
                              });
                              showSearchDialog();
                            },
                          ),
                          // GestureDetector(
                          //   onTap: () {},
                          //   child: Icon(
                          //     color: const Color(0xff243444),
                          //     Icons.search,
                          //     size: 19.0,
                          //   ),
                          // )
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 20,
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
                      SizedBox(
                        width: 20,
                      ),
                    ],
                    // bottom: PreferredSize(
                    //     child: Container(
                    //       color: Color(0xffbe1229),
                    //       height: 2.0,
                    //     ),
                    //     preferredSize: Size.fromHeight(2.0)),
                  ),

                  // body: SafeArea(
                  body: Column(children: [
                    Expanded(
                      child: ListView(children: <Widget>[
                        Container(
                          // margin: const EdgeInsets.all(5.0),
                          // decoration: const BoxDecoration(
                          // color: Colors.white,
                          // borderRadius: BorderRadius.circular(10.0),
                          // boxShadow: [
                          //   BoxShadow(
                          //       color: Colors.black26.withOpacity(0.05),
                          //       offset: const Offset(0.0, 6.0),
                          //       blurRadius: 10.0,
                          //       spreadRadius: 0.10)
                          // ]
                          // ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    // widget.discussionthread.title,
                                    widget.discussionthread.title.inCaps,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: Color(0xff243444),
                                      height: 1.1,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'HelveticaBold',
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                widget.discussionthread.content.length > 2400
                                    ?

                                widget.discussionthread.id==215?
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: HtmlWidget(
                                    widget.discussionthread.content,
                                    textStyle: const TextStyle(
                                      color: Color(0xff243444),
                                      fontSize: 14,
                                      height: 1.4,
                                      fontFamily: 'HelveticaNueueLight',
                                    ),
                                    customStylesBuilder: (element) {
                                      switch (element.localName) {
                                      // case 'html':
                                      //   return {
                                      //     'font-size': '16px',
                                      //   };
                                        case 'table':
                                          return {
                                            'border': '1px solid',
                                            'border-collapse': 'collapse',
                                            'text-align': 'center',
                                          };
                                        case 'td':
                                          return {
                                            'border': '1px solid',
                                            'text-align': 'center',
                                            'vertical-align': 'baseline',
                                          };
                                      }
                                      return null;
                                    },
                                  ),

                                  //     Html(
                                  //   data: widget.discussionthread.content,
                                  //   shrinkWrap: true,
                                  //   tagsList: Html.tags..addAll(["flutter"]),
                                  //   customRender: {
                                  //     "table": (context1, child) {
                                  //       return SingleChildScrollView(
                                  //         scrollDirection: Axis.horizontal,
                                  //         //padding: const EdgeInsets.all(5),
                                  //         child: SizedBox(
                                  //           width: MediaQuery.of(context)
                                  //               .size
                                  //               .width,
                                  //           child: (context1.tree
                                  //                   as TableLayoutElement)
                                  //               .toWidget(context1),
                                  //         ),
                                  //       );
                                  //     }
                                  //   },
                                  //   style: {
                                  //     // 'div': Style(
                                  //     //   block: Block(
                                  //     //     margin: EdgeInsets.all(16),
                                  //     //     border: Border.all(width: 6),
                                  //     //     backgroundColor: Colors.grey,
                                  //     //   ),
                                  //     //   textStyle: TextStyle(
                                  //     //     color: Colors.red,
                                  //     //   ),
                                  //     // ),
                                  //     "html":
                                  //         Style(textAlign: TextAlign.center),
                                  //     "mark": Style(
                                  //         padding: EdgeInsets.all(5.0),
                                  //         margin: EdgeInsets.all(5),
                                  //         backgroundColor: Colors.yellow,
                                  //         color: Colors.white,
                                  //         textAlign: TextAlign.justify),
                                  //     "body": Style(
                                  //         padding: EdgeInsets.all(5.0),
                                  //         margin: EdgeInsets.all(5),
                                  //         backgroundColor: Colors.white,
                                  //         color: Colors.white,
                                  //         textAlign: TextAlign.justify),
                                  //     // "div": Style(
                                  //     //   border: Border(
                                  //     //       bottom: BorderSide(
                                  //     //           width: 1,
                                  //     //           color: Colors.grey)),
                                  //     //   //width: 200,
                                  //     //   fontFamily: 'serif',
                                  //     // ),
                                  //     // "a": Style(
                                  //     //   textDecoration: TextDecoration.none,
                                  //     //   backgroundColor: Colors.deepPurple,
                                  //     // ),
                                  //     "#": Style(
                                  //       // padding: const EdgeInsets.all(0.3),
                                  //       fontSize: const FontSize(14),

                                  //       color: const Color(0xff243444),
                                  //       //fontWeight: FontWeight.normal,

                                  //       fontFamily: 'HelveticaNueueLight',
                                  //     ),
                                  //     "tbody": Style(
                                  //       verticalAlign: VerticalAlign.SUB,
                                  //     ),
                                  //     "table": Style(
                                  //       verticalAlign: VerticalAlign.SUB,
                                  //       backgroundColor: Colors.white,
                                  //       textAlign: TextAlign.center,
                                  //       // border: const Border(
                                  //       //   top: BorderSide(
                                  //       //       width: 0.5,
                                  //       //       color: Color(0xff243444)),
                                  //       //   bottom: BorderSide(
                                  //       //       width: 0.5,
                                  //       //       color: Color(0xff243444)),
                                  //       //   left: BorderSide(
                                  //       //       width: 0.5,
                                  //       //       color: Color(0xff243444)),
                                  //       //   right: BorderSide(
                                  //       //       width: 0.5,
                                  //       //       color: Color(0xff243444)),
                                  //       // ),
                                  //     ),
                                  //     "tr": Style(
                                  //         verticalAlign: VerticalAlign.SUB,
                                  //         alignment: Alignment.center,
                                  //         // padding: EdgeInsets.all(6),
                                  //         textAlign: TextAlign.center),
                                  //     "th": Style(
                                  //       padding: const EdgeInsets.all(10),
                                  //       fontFamily: 'HelveticaNueueBold',
                                  //       fontWeight: FontWeight.bold,
                                  //       textAlign: TextAlign.center,
                                  //       alignment: Alignment.center,
                                  //       verticalAlign: VerticalAlign.SUB,
                                  //     ),
                                  //     "td": Style(
                                  //         // width: 110,
                                  //         alignment: Alignment.topCenter,
                                  //         margin: const EdgeInsets.all(10),
                                  //         //padding: EdgeInsets.all(0.1),
                                  //         verticalAlign: VerticalAlign.SUB,
                                  //         border: const Border(
                                  //           top: BorderSide(
                                  //               width: 0.5,
                                  //               color: Color(0xff243444)),
                                  //           bottom: BorderSide(
                                  //               width: 0.5,
                                  //               color: Color(0xff243444)),
                                  //           left: BorderSide(
                                  //               width: 0.5,
                                  //               color: Color(0xff243444)),
                                  //           right: BorderSide(
                                  //               width: 0.5,
                                  //               color: Color(0xff243444)),
                                  //         ),
                                  //         // padding: EdgeInsets.all(6),
                                  //         textAlign: TextAlign.center),
                                  //     "thead": Style(
                                  //         alignment: Alignment.center,
                                  //         verticalAlign: VerticalAlign.SUB,
                                  //         textAlign: TextAlign.center),
                                  //   },
                                  //   // onLinkTap: (String? url,
                                  //   //     RenderContext context,
                                  //   //     Map<String, String> attributes,
                                  //   //     dom.Element? element) {
                                  //   //   //open URL in webview, or launch URL in browser, or any other logic here
                                  //   //   _launchContentURL(url ?? "");
                                  //   // },
                                  //   onImageError: (exception, stackTrace) {
                                  //     // print(exception);
                                  //   },
                                  // ),
                                  //   customTextAlign: (_) => TextAlign.justify,
                                  //  padding: const EdgeInsets.all(10),
                                ):

                                Container(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        padding: const EdgeInsets.all(10.0),
                                        child: WebViewPlus(
                                          javascriptMode:
                                              JavascriptMode.unrestricted,
                                          zoomEnabled: true,
                                          onWebViewCreated: (controller) {
                                            controller.loadString(widget
                                                .discussionthread.content);
                                          },
                                          // gestureRecognizers: Set()
                                          //   ..add(Factory<VerticalDragGestureRecognizer>(
                                          //           () => VerticalDragGestureRecognizer())),
                                          gestureRecognizers: <
                                              Factory<
                                                  OneSequenceGestureRecognizer>>{
                                            Factory<VerticalDragGestureRecognizer>(
                                                () =>
                                                    VerticalDragGestureRecognizer()),
                                            Factory<HorizontalDragGestureRecognizer>(
                                                () =>
                                                    HorizontalDragGestureRecognizer()),
                                            Factory<ScaleGestureRecognizer>(
                                                () => ScaleGestureRecognizer()),
                                          },
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: HtmlWidget(
                                          widget.discussionthread.content,
                                          textStyle: const TextStyle(
                                            color: Color(0xff243444),
                                            fontSize: 14,
                                            height: 1.4,
                                            fontFamily: 'HelveticaNueueLight',
                                          ),
                                          customStylesBuilder: (element) {
                                            switch (element.localName) {
                                              // case 'html':
                                              //   return {
                                              //     'font-size': '16px',
                                              //   };
                                              case 'table':
                                                return {
                                                  'border': '1px solid',
                                                  'border-collapse': 'collapse',
                                                  'text-align': 'center',
                                                };
                                              case 'td':
                                                return {
                                                  'border': '1px solid',
                                                  'text-align': 'center',
                                                  'vertical-align': 'baseline',
                                                };
                                            }
                                            return null;
                                          },
                                        ),

                                        //     Html(
                                        //   data: widget.discussionthread.content,
                                        //   shrinkWrap: true,
                                        //   tagsList: Html.tags..addAll(["flutter"]),
                                        //   customRender: {
                                        //     "table": (context1, child) {
                                        //       return SingleChildScrollView(
                                        //         scrollDirection: Axis.horizontal,
                                        //         //padding: const EdgeInsets.all(5),
                                        //         child: SizedBox(
                                        //           width: MediaQuery.of(context)
                                        //               .size
                                        //               .width,
                                        //           child: (context1.tree
                                        //                   as TableLayoutElement)
                                        //               .toWidget(context1),
                                        //         ),
                                        //       );
                                        //     }
                                        //   },
                                        //   style: {
                                        //     // 'div': Style(
                                        //     //   block: Block(
                                        //     //     margin: EdgeInsets.all(16),
                                        //     //     border: Border.all(width: 6),
                                        //     //     backgroundColor: Colors.grey,
                                        //     //   ),
                                        //     //   textStyle: TextStyle(
                                        //     //     color: Colors.red,
                                        //     //   ),
                                        //     // ),
                                        //     "html":
                                        //         Style(textAlign: TextAlign.center),
                                        //     "mark": Style(
                                        //         padding: EdgeInsets.all(5.0),
                                        //         margin: EdgeInsets.all(5),
                                        //         backgroundColor: Colors.yellow,
                                        //         color: Colors.white,
                                        //         textAlign: TextAlign.justify),
                                        //     "body": Style(
                                        //         padding: EdgeInsets.all(5.0),
                                        //         margin: EdgeInsets.all(5),
                                        //         backgroundColor: Colors.white,
                                        //         color: Colors.white,
                                        //         textAlign: TextAlign.justify),
                                        //     // "div": Style(
                                        //     //   border: Border(
                                        //     //       bottom: BorderSide(
                                        //     //           width: 1,
                                        //     //           color: Colors.grey)),
                                        //     //   //width: 200,
                                        //     //   fontFamily: 'serif',
                                        //     // ),
                                        //     // "a": Style(
                                        //     //   textDecoration: TextDecoration.none,
                                        //     //   backgroundColor: Colors.deepPurple,
                                        //     // ),
                                        //     "#": Style(
                                        //       // padding: const EdgeInsets.all(0.3),
                                        //       fontSize: const FontSize(14),

                                        //       color: const Color(0xff243444),
                                        //       //fontWeight: FontWeight.normal,

                                        //       fontFamily: 'HelveticaNueueLight',
                                        //     ),
                                        //     "tbody": Style(
                                        //       verticalAlign: VerticalAlign.SUB,
                                        //     ),
                                        //     "table": Style(
                                        //       verticalAlign: VerticalAlign.SUB,
                                        //       backgroundColor: Colors.white,
                                        //       textAlign: TextAlign.center,
                                        //       // border: const Border(
                                        //       //   top: BorderSide(
                                        //       //       width: 0.5,
                                        //       //       color: Color(0xff243444)),
                                        //       //   bottom: BorderSide(
                                        //       //       width: 0.5,
                                        //       //       color: Color(0xff243444)),
                                        //       //   left: BorderSide(
                                        //       //       width: 0.5,
                                        //       //       color: Color(0xff243444)),
                                        //       //   right: BorderSide(
                                        //       //       width: 0.5,
                                        //       //       color: Color(0xff243444)),
                                        //       // ),
                                        //     ),
                                        //     "tr": Style(
                                        //         verticalAlign: VerticalAlign.SUB,
                                        //         alignment: Alignment.center,
                                        //         // padding: EdgeInsets.all(6),
                                        //         textAlign: TextAlign.center),
                                        //     "th": Style(
                                        //       padding: const EdgeInsets.all(10),
                                        //       fontFamily: 'HelveticaNueueBold',
                                        //       fontWeight: FontWeight.bold,
                                        //       textAlign: TextAlign.center,
                                        //       alignment: Alignment.center,
                                        //       verticalAlign: VerticalAlign.SUB,
                                        //     ),
                                        //     "td": Style(
                                        //         // width: 110,
                                        //         alignment: Alignment.topCenter,
                                        //         margin: const EdgeInsets.all(10),
                                        //         //padding: EdgeInsets.all(0.1),
                                        //         verticalAlign: VerticalAlign.SUB,
                                        //         border: const Border(
                                        //           top: BorderSide(
                                        //               width: 0.5,
                                        //               color: Color(0xff243444)),
                                        //           bottom: BorderSide(
                                        //               width: 0.5,
                                        //               color: Color(0xff243444)),
                                        //           left: BorderSide(
                                        //               width: 0.5,
                                        //               color: Color(0xff243444)),
                                        //           right: BorderSide(
                                        //               width: 0.5,
                                        //               color: Color(0xff243444)),
                                        //         ),
                                        //         // padding: EdgeInsets.all(6),
                                        //         textAlign: TextAlign.center),
                                        //     "thead": Style(
                                        //         alignment: Alignment.center,
                                        //         verticalAlign: VerticalAlign.SUB,
                                        //         textAlign: TextAlign.center),
                                        //   },
                                        //   // onLinkTap: (String? url,
                                        //   //     RenderContext context,
                                        //   //     Map<String, String> attributes,
                                        //   //     dom.Element? element) {
                                        //   //   //open URL in webview, or launch URL in browser, or any other logic here
                                        //   //   _launchContentURL(url ?? "");
                                        //   // },
                                        //   onImageError: (exception, stackTrace) {
                                        //     // print(exception);
                                        //   },
                                        // ),
                                        //   customTextAlign: (_) => TextAlign.justify,
                                        //  padding: const EdgeInsets.all(10),
                                      ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  height: 100,
                                  width: double.infinity,
                                  child:
                                      // Expanded(
                                      //     child: Swiper(
                                      //
                                      //       itemBuilder: (context, index) {
                                      //         return Image.network(widget
                                      //             .discussionthread
                                      //             .discussionimage[index]
                                      //             .articleimagepath);
                                      //       },
                                      //       autoplay: false,
                                      //       itemCount: widget.discussionthread
                                      //           .discussionimage.length,
                                      //       scrollDirection: Axis.horizontal,
                                      //       pagination: const SwiperPagination(
                                      //           alignment: Alignment.centerLeft,
                                      //           builder: SwiperPagination.fraction),
                                      //     )),

                                      ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: widget.discussionthread
                                              .discussionimage.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                children: <Widget>[
                                                  SizedBox(
                                                      height: 100,
                                                      width: 100,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .only(
                                                                topLeft:
                                                                    Radius
                                                                        .circular(
                                                                            10),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10)),
                                                        child: Image.network(widget
                                                            .discussionthread
                                                            .discussionimage[
                                                                index]
                                                            .articleimagepath),
                                                      ))
                                                ],
                                              ),
                                            );
                                          }),
                                ),
                                widget.discussionthread.filepath.isNotEmpty
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                              onTap: _launchURL,
                                              child: Text('article_link'.tr,
                                                  style: const TextStyle(
                                                      decoration: TextDecoration
                                                          .underline,
                                                      color: Colors.blue))),
                                        ))
                                    : const SizedBox(),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Divider(
                                  height: 1,
                                  color: Color(0xffD0D3D4),
                                ),
                                Padding(
                                  //   padding: const EdgeInsets.symmetric(vertical: 5.0),

                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          // Icon(
                                          //   Themify.thumb_up,
                                          //   color: Colors.black.withOpacity(0.5),
                                          //   size: 22,
                                          // ),
                                          // const Icon(Themify.heart,
                                          //     color: Color(0xffAB0E1E),
                                          //     size: 18),
                                          SizedBox(
                                            height: 20.0,
                                            width: 20.0,
                                            child: IconButton(
                                              padding: const EdgeInsets.only(
                                                  bottom: 2),
                                              // constraints: BoxConstraints(maxHeight: 36),
                                              icon: widget
                                                      .discussionthread
                                                      .discussionlikebydevid
                                                      .isNotEmpty //isLikeButtonSelected
                                                  ? const Icon(
                                                      Icons.favorite,
                                                      color: Color(0xffAB0E1E),
                                                      size: 18,
                                                    )
                                                  : const Icon(Themify.heart,
                                                      color: Color(0xffAB0E1E),
                                                      //.withOpacity(0.5),
                                                      size: 18),
                                              onPressed: () {
                                                print("tapppp");
                                                setState(() {
                                                  // isLikeButtonSelected =
                                                  //     !isLikeButtonSelected;

                                                  // setState(() {
                                                  isLikeLoading = true;
                                                  // });

                                                  _showLikeUnlikeProgressDialog(
                                                      'processing');
                                                  _likeUnlikeBackEndData();
                                                });
                                                //statements
                                                print('IconButton is pressed');
                                              },
                                            ),
                                          ),
                                          // IconButton(
                                          //   icon: isLikeButtonSelected
                                          //       ?
                                          //       // Icon(Icons.favorite_border)
                                          //       const Icon(Icons.favorite,
                                          //           color: Color(0xffAB0E1E),
                                          //           size: 14)
                                          //       : const Icon(
                                          //           Themify.heart,
                                          //           color: Color(0xffAB0E1E),
                                          //           size: 14,
                                          //         ),
                                          //   onPressed: () {
                                          //     print("tapppp");
                                          //     setState(() {
                                          //       isLikeButtonSelected =
                                          //           !isLikeButtonSelected;

                                          //       setState(() {
                                          //         isLikeLoading = true;
                                          //       });

                                          //       _showLikeUnlikeProgressDialog(
                                          //           'processing');
                                          //       _likeUnlikeBackEndData();
                                          //     });
                                          //     //statements
                                          //     print('IconButton is pressed');
                                          //   },
                                          // ),
                                          const SizedBox(width: 4.0),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                // isLikeButtonSelected =
                                                //     !isLikeButtonSelected;

                                                setState(() {
                                                  isLikeLoading = true;
                                                });

                                                _showLikeUnlikeProgressDialog(
                                                    'processing');
                                                _likeUnlikeBackEndData();
                                              });

                                              print(
                                                  'Like IconButton is pressed');
                                            },
                                            child: Text(
                                              '${widget.discussionthread.like} ',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Helvetica',
                                                color: Color(0xffAB0E1E),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 25.0),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Image.asset(
                                            'assets/images/reply.png',
                                            height: 18,
                                            width: 20,
                                          ),
                                          const SizedBox(width: 4.0),
                                          Text(
                                            // "${widget.question.views} views",
                                            // "${widget.question.views} ${getTranslated(context, 'views') ?? ""}",
                                            // "${reply.length} replies",
                                            '${widget.discussionthread.reply} ',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Color(0xff243444),
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'HelveticaBold'),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  color: Color(0xffD0D3D4),
                                ),
                                isLoading
                                    ? const Center(
                                        child: SizedBox(
                                          width: 25,
                                          height: 25,
                                          child: CircularProgressIndicator(
                                            color: Color(0xff243444),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        // margin: const EdgeInsets.all(5),
                                        padding: const EdgeInsets.all(5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                // Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}")
                                                Text(
                                                  'show_replies'.tr,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xffAB0E1E),
                                                    fontFamily: 'Helvetica',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  alignment: Alignment.center,
                                                  height: 30,
                                                  width: 30,
                                                  // decoration: BoxDecoration(
                                                  //   borderRadius:
                                                  //       BorderRadius.circular(5),
                                                  //   color: const Color(0xffAB0E1E),
                                                  // ),
                                                  child: IconButton(
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                    icon: Icon(
                                                      _replyArrow
                                                          ? Icons
                                                              .keyboard_arrow_up
                                                          : Icons
                                                              .keyboard_arrow_down,
                                                      color: const Color(
                                                          0xff243444),
                                                      size: 30,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _replyArrow =
                                                            !_replyArrow;
                                                        showReplies();
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _replyIsVisible,
                          child: ListView.builder(
                            // controller: replycontroller,
                            shrinkWrap: true,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: (present <= reply.length)
                                ? items.length + 1
                                : items.length,
                            itemBuilder: (BuildContext context, int index) {
                              // if (index < reply.length) {
                              // final replyItem = reply[index];
                              return (index == items.length)
                                  ? Container(
                                      // color: const Color(0xFFFFFFFF),
                                      margin: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                        color: COLORS.APP_THEME_DARK_RED_COLOR,
                                        style: BorderStyle.solid,
                                        width: 1.0,
                                      )),
                                      child: TextButton(
                                        child: items.isNotEmpty
                                            ? Text('load_more'.tr)
                                            : Text('no_reply_available'.tr),
                                        onPressed: () {
                                          setState(() {
                                            if ((present + perPage) >
                                                reply.length) {
                                              items.addAll(reply.getRange(
                                                  present, reply.length));
                                            } else {
                                              // if (items.asMap().containsKey(present) &&
                                              //     items
                                              //         .asMap()
                                              //         .containsKey(present + perPage)) {
                                              items.addAll(reply.getRange(
                                                  present, present + perPage));
                                              // }
                                            }
                                            present = present + perPage;
                                          });
                                        },
                                      ),
                                    )
                                  : Container(
                                      child: Card(
                                        // elevation: 1,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 10),
                                        // margin: const EdgeInsets.only(
                                        //     left: 15.0, right: 15.0, top: 20.0),

                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                height: 40,
                                                color: Colors.white38,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Row(
                                                      children: <Widget>[
                                                        // CircleAvatar(
                                                        //   backgroundImage: AssetImage(
                                                        //       reply.author.imageUrl ??
                                                        //           ""),
                                                        //   radius: 18,
                                                        // ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 8.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              /*   Text(
                                                    items[index]
                                                        .name
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Color(0x243444),
                                                        fontFamily: 'Helvetica',
                                                        letterSpacing: .4),
                                                  ),*/
                                                              const SizedBox(
                                                                  height: 2.0),
                                                              Text(
                                                                //  widget.question.created_at,
                                                                items[index]
                                                                    .createdAt
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    color: const Color(
                                                                            0x243444)
                                                                        .withOpacity(
                                                                            0.4)),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 1.0),
                                                child: Html(
                                                  data: items[index]
                                                      .content, //.substring(0, 90) + '..',
                                                  style: {
                                                    '#': Style(
                                                      fontSize:
                                                          const FontSize(14),
                                                      fontFamily: 'Helvetica',
                                                      maxLines: 8,
                                                      color: const Color(
                                                          0xff243444),
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  },
                                                ),
                                                /*Text(
                                  reply.content,
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),*/
                                              ),
                                              const Divider(
                                                height: 1,
                                                color: Color(0xD0D3D4),
                                              ),
                                              const SizedBox(
                                                height: 1,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(2),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    // Icon(
                                                    //   Themify.thumb_up,
                                                    //   color: Color(0x243444).withOpacity(0.5),
                                                    //   size: 20,
                                                    // ),

                                                    // SizedBox(
                                                    //     width: _screen.width * 0.05,
                                                    //     child: IconButton(
                                                    //       icon: items[index]
                                                    //               .isLikeButtonSelected
                                                    //           ? const Icon(
                                                    //               Themify.thumb_up,
                                                    //               color:
                                                    //                   Color(0xffAB0E1E),
                                                    //               size: 16,
                                                    //             )
                                                    //           : Icon(Icons.thumb_up,
                                                    //               color: const Color(
                                                    //                       0x243444)
                                                    //                   .withOpacity(0.5),
                                                    //               size: 16),
                                                    //       onPressed: () {
                                                    //         setState(() {
                                                    //           likeIndex = index;
                                                    //           items[index]
                                                    //                   .isLikeButtonSelected =
                                                    //               !items[index]
                                                    //                   .isLikeButtonSelected;
                                                    //
                                                    //           if (items[index]
                                                    //               .isLikeButtonSelected) {
                                                    //             apiToLikePost(
                                                    //                 replyId:
                                                    //                     items[index]
                                                    //                         .id);
                                                    //           } else {
                                                    //             apiToUnLikePost(
                                                    //                 replyId:
                                                    //                     items[index]
                                                    //                         .id);
                                                    //           }
                                                    //         });
                                                    //         //statements
                                                    //         print(
                                                    //             'Thumb IconButton is pressed');
                                                    //       },
                                                    //     )),

                                                    // SizedBox(
                                                    //     width: _screen.width * 0.05,
                                                    //     child: items[index].likecount >
                                                    //             0
                                                    //         ? Text(
                                                    //             '${items[index].likecount}',
                                                    //             style: const TextStyle(
                                                    //                 fontSize: 14,
                                                    //                 color: Color(
                                                    //                     0xff243444),
                                                    //                 fontWeight:
                                                    //                     FontWeight.w600,
                                                    //                 fontFamily:
                                                    //                     'HelveticaBold'),
                                                    //           )
                                                    //         : const SizedBox()),
                                                    SizedBox(
                                                      width:
                                                          _screen.width * 0.70,
                                                      child: items[index]
                                                              .name
                                                              .isNotEmpty
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 0,
                                                                      top: 3,
                                                                      right: 1,
                                                                      bottom:
                                                                          5),
                                                              child: Text(
                                                                //  widget.question.created_at,
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                '${'commented_by'.tr}: ${items[index].name}',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    color: const Color(
                                                                            0x243444)
                                                                        .withOpacity(
                                                                            0.4)),
                                                              ))
                                                          : Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 0,
                                                                      top: 5,
                                                                      right: 0,
                                                                      bottom:
                                                                          5),
                                                              child: Text(
                                                                //  widget.question.created_at,

                                                                items[index]
                                                                    .name
                                                                    .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Helvetica',
                                                                    color: const Color(
                                                                            0x243444)
                                                                        .withOpacity(
                                                                            0.4)),
                                                              )),
                                                    ),
                                                    const SizedBox(width: 1.0),
                                                    // Text(
                                                    //   "${reply.likes}",
                                                    //   style: TextStyle(
                                                    //       fontFamily: 'Helvetica',
                                                    //       color: Colors.black
                                                    //           .withOpacity(0.5)),
                                                    // )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                              // } else {
                              //   return Padding(
                              //     padding: EdgeInsets.symmetric(vertical: 32),
                              //     child: Center(
                              //       child: hasMore
                              //           ? const CircularProgressIndicator()
                              //           : const Text('No more Data to load'),
                              //     ),
                              //   );
                              // }
                            },
                          ),
                        ),
                        // Visibility(
                        //     visible: _replyIsVisible,
                        //     child: Column(
                        //       children: reply
                        //           .map((reply) => Card(
                        //               elevation: 5,
                        //               margin: const EdgeInsets.only(
                        //                   left: 15.0, right: 15.0, top: 20.0),
                        //               // decoration: BoxDecoration(
                        //               //   // color: Colors.grey.shade200,
                        //               //   color: Colors.white38,
                        //               //   border: Border.all(color: Colors.white, width: 1),
                        //               //   borderRadius: BorderRadius.circular(10.0),
                        //               //   boxShadow: [
                        //               //     BoxShadow(
                        //               //         color: Colors.black26.withOpacity(0.03),
                        //               //         offset: const Offset(0.0, 6.0),
                        //               //         blurRadius: 10.0,
                        //               //         spreadRadius: 0.10)
                        //               //   ],
                        //               // ),
                        //               child: Padding(
                        //                 padding: const EdgeInsets.all(15.0),
                        //                 child: Column(
                        //                   crossAxisAlignment: CrossAxisAlignment.start,
                        //                   children: <Widget>[
                        //                     Container(
                        //                       height: 60,
                        //                       color: Colors.white38,
                        //                       child: Row(
                        //                         mainAxisAlignment:
                        //                             MainAxisAlignment.spaceBetween,
                        //                         children: <Widget>[
                        //                           Row(
                        //                             children: <Widget>[
                        //                               // CircleAvatar(
                        //                               //   backgroundImage: AssetImage(
                        //                               //       reply.author.imageUrl ??
                        //                               //           ""),
                        //                               //   radius: 18,
                        //                               // ),
                        //                               Padding(
                        //                                 padding: const EdgeInsets.only(
                        //                                     left: 8.0),
                        //                                 child: Column(
                        //                                   crossAxisAlignment:
                        //                                       CrossAxisAlignment.start,
                        //                                   mainAxisAlignment:
                        //                                       MainAxisAlignment.center,
                        //                                   children: <Widget>[
                        //                                     Text(
                        //                                       reply.userId.toString(),
                        //                                       style: const TextStyle(
                        //                                           fontSize: 16,
                        //                                           color: Color(0x243444),
                        //                                           fontFamily: 'Helvetica',
                        //                                           letterSpacing: .4),
                        //                                     ),
                        //                                     const SizedBox(height: 2.0),
                        //                                     Text(
                        //                                       //  widget.question.created_at,
                        //                                       reply.createdAt.toString(),
                        //                                       style: TextStyle(
                        //                                           fontFamily: 'Helvetica',
                        //                                           color: Color(0x243444)
                        //                                               .withOpacity(0.4)),
                        //                                     )
                        //                                   ],
                        //                                 ),
                        //                               )
                        //                             ],
                        //                           ),
                        //                         ],
                        //                       ),
                        //                     ),
                        //                     Padding(
                        //                         padding: const EdgeInsets.symmetric(
                        //                             vertical: 15.0),
                        //                         child: Html(
                        //                           data: reply
                        //                               .content, //.substring(0, 90) + '..',
                        //                           style: {
                        //                             '#': Style(
                        //                               fontSize: const FontSize(14),
                        //                               fontFamily: 'Helvetica',
                        //                               maxLines: 8,
                        //                               textOverflow: TextOverflow.ellipsis,
                        //                             ),
                        //                           },
                        //                         )
                        //                         /*Text(
                        //                       reply.content,
                        //                       style: TextStyle(
                        //                         fontFamily: 'Helvetica',
                        //                         color: Colors.black,
                        //                         fontSize: 16,
                        //                       ),
                        //                     ),*/
                        //                         ),
                        //                     const Divider(
                        //                       height: 1,
                        //                       color: Color(0xD0D3D4),
                        //                     ),
                        //                     Padding(
                        //                       padding: const EdgeInsets.all(5),
                        //                       child: Row(
                        //                         mainAxisAlignment: MainAxisAlignment.start,
                        //                         crossAxisAlignment:
                        //                             CrossAxisAlignment.center,
                        //                         children: <Widget>[
                        //                           // Icon(
                        //                           //   Themify.thumb_up,
                        //                           //   color: Color(0x243444).withOpacity(0.5),
                        //                           //   size: 20,
                        //                           // ),
                        //                           IconButton(
                        //                             icon: reply.isLikeButtonSelected
                        //                                 ? const Icon(
                        //                                     Themify.thumb_up,
                        //                                     color: Color(0xffAB0E1E),
                        //                                     size: 16,
                        //                                   )
                        //                                 : Icon(Icons.thumb_up,
                        //                                     color: Color(0x243444)
                        //                                         .withOpacity(0.5),
                        //                                     size: 16),
                        //                             onPressed: () {
                        //                               setState(() {
                        //                                 reply.isLikeButtonSelected =
                        //                                     !reply.isLikeButtonSelected;

                        //                                 if (reply.isLikeButtonSelected) {
                        //                                   apiToLikePost(replyId: reply.id);
                        //                                 } else {
                        //                                   apiToUnLikePost(
                        //                                       replyId: reply.id);
                        //                                 }
                        //                               });
                        //                               //statements
                        //                               print('Thumb IconButton is pressed');
                        //                             },
                        //                           ),
                        //                           const SizedBox(width: 5.0),
                        //                           // Text(
                        //                           //   "${reply.likes}",
                        //                           //   style: TextStyle(
                        //                           //       fontFamily: 'Helvetica',
                        //                           //       color: Colors.black
                        //                           //           .withOpacity(0.5)),
                        //                           // )
                        //                         ],
                        //                       ),
                        //                     )
                        //                   ],
                        //                 ),
                        //               )))
                        //           .toList(),
                        //     )),
                        /*Row(
                children: [
                   Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: 70,
                        child: CommentBox(
                          userImage:
                              "https://lh3.googleusercontent.com/a-/AOh14GjRHcaendrf6gU5fPIVd8GIl1OgblrMMvGUoCBj4g=s400",
                          child: commentChild(reply),
                          labelText: 'Write a comment...',
                          withBorder: false,
                          errorText: 'Comment cannot be blank',
                          sendButtonMethod: () {
                            if (formKey.currentState!.validate()) {
                              print(commentController.text);

                              _showDialog();
                              // getSubmitReplyData(
                              //     ApiConstant.url + ApiConstant.Endpoint,
                              //     commentController.text);
                              // Navigator.pop(context);

                              commentController.clear();
                              FocusScope.of(context).unfocus();
                            } else {
                              print("Not validated");
                            }
                          },
                          formKey: formKey,
                          commentController: commentController,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          sendWidget: const Icon(Icons.send_sharp,
                              size: 30, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              )*/
                        Container(
                          margin: const EdgeInsets.all(19),
                          height: 139,
                          width: 336,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: COLORS.APP_THEME_DARK_RED_COLOR,
                              style: BorderStyle.solid,
                              width: 1.0,
                            ),
                            color: COLORS.APP_THEME_DARK_RED_COLOR,
                            borderRadius: BorderRadius.circular(39.0),
                          ),
                          child: Column(
                            children: <Widget>[
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 5, right: 5, top: 5),
                                        //    padding: EdgeInsets.all(5),
                                        width: 110,
                                        height: 80,
                                        // color: Color(0xffAB0E1E),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Container(
                                                width: 52,
                                                height: 52,
                                                child: Image.asset(
                                                  'assets/images/userimg.png',
                                                ),
                                              ),
                                              Container(
                                                  width: 242,
                                                  height: 64,
                                                  margin: const EdgeInsets.only(
                                                    left: 7.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xffFFFFFF),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                  child: TextField(
                                                      keyboardType:
                                                          TextInputType.text,
                                                      scrollPhysics:
                                                          const ScrollPhysics(),
                                                      expands: true,
                                                      maxLines: null,
                                                      controller:
                                                          commentController,
                                                      autocorrect: true,
                                                      decoration:
                                                          InputDecoration(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                20.0,
                                                                15.0,
                                                                20.0,
                                                                10.0),
                                                        hintText:
                                                            'write_a_comments'
                                                                .tr,
                                                        errorText: validateComment
                                                            ? 'please_write_a_comments'
                                                                .tr
                                                            : null,
                                                        hintStyle:
                                                            const TextStyle(
                                                                color: Color(
                                                                    0xFF243444),
                                                                fontSize: 14,
                                                                // color: Color(0xff243444),
                                                                letterSpacing:
                                                                    0.3,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontFamily:
                                                                    'Helvetica'),
                                                        //filled: true,
                                                        //fillColor: Colors.white,
                                                        border:
                                                            InputBorder.none,
                                                      )))
                                            ]),
                                      ),
                                    )
                                  ]),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                          // margin: const EdgeInsets.all(3),
                                          //    padding: EdgeInsets.all(5),
                                          width: 40,
                                          height: 40,
                                          margin: const EdgeInsets.only(
                                              right: 15, bottom: 10),
                                          // color: Color(0xffAB0E1E),
                                          child: SizedBox(
                                            width: 40,
                                            height: 40,
                                            // margin: const EdgeInsets.only(
                                            //
                                            //     right: 15,
                                            //     bottom: 5),
                                            child: IconButton(
                                              alignment: Alignment.centerRight,
                                              icon: Image.asset(
                                                'assets/images/send.png',
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  commentController.text.isEmpty
                                                      ? validateComment = true
                                                      : validateComment = false;

                                                  if (!validateComment) {
                                                    _showDialog();
                                                  }
                                                });
                                              },
                                            ),
                                          )),
                                    )
                                  ])
                            ],
                          ),
                        )
                      ]),
                    )
                  ]),
                )),
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

  Future<void> likeUnlikeApiCall() async {
    // if (isLikeButtonSelected) {
    if (widget.discussionthread.discussionlikebydevid.isNotEmpty) {
      apiToUnLikePost(discussionId: widget.discussionthread.id)
          .then((_) => Navigator.pop(dialogContext));
    } else {
      apiToLikePost(discussionId: widget.discussionthread.id)
          .then((_) => Navigator.pop(dialogContext));
      ;
    }
  }

  Future<void> _likeUnlikeBackEndData() async {
    await likeUnlikeApiCall();
  }

  _showLikeUnlikeProgressDialog(String msg) async {
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

  Future<void> _fetchBackEndData() async {
    await getSubmitReplyData(ApiConstant.url + ApiConstant.Endpoint,
        commentController.text, nameController.text, emailController.text);
  }

  _showDialog() async {
    await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ButtonBarTheme(
                data: const ButtonBarThemeData(
                    alignment: MainAxisAlignment.center),
                child: KeyboardAwareAlertDialog(
                  contentPadding:
                      const EdgeInsets.only(top: 10, left: 10, right: 10),
                  content: SizedBox(
                    height: 180,
                    child: isPopupLoading
                        ? Dialog(
                            // The background color
                            elevation: 0,
                            insetPadding: EdgeInsets.zero,
                            // insetPadding:
                            //     const EdgeInsets.symmetric(horizontal: 8),
                            backgroundColor: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              // padding: const EdgeInsets.only(
                              //     top: 0, left: 0, right: 0, bottom: 5),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Center(
                                    child: Text(
                                        //'processing'.tr,
                                        '${'hello'.tr} $name',
                                        style: const TextStyle(
                                            color: Color(0xff243444),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Center(
                                    child:
                                        Text('comment_submission_procress'.tr,
                                            style: const TextStyle(
                                              color: Color(0xff243444),
                                              fontSize: 14,
                                            )),
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  const CircularProgressIndicator(),
                                  // const SizedBox(
                                  //   height: 10,
                                  // ),
                                ],
                              ),
                            ),
                          )
                        // Container(
                        //     padding: const EdgeInsets.only(top: 40.0),
                        //     height: 100.0,
                        //     child: Column(
                        //       children: <Widget>[
                        //         Center(
                        //             child: Text(
                        //           //'processing'.tr,
                        //           "Your Comment Submission is in Process",
                        //           style:
                        //               const TextStyle(color: Color(0xff243444)),
                        //         )),
                        //         const SizedBox(
                        //           height: 10,
                        //         ),
                        //         const Center(
                        //           child: SizedBox(
                        //             width: 40,
                        //             height: 40,
                        //             child: CircularProgressIndicator(
                        //               color: Color(0xff243444),
                        //             ),
                        //           ),
                        //         ),
                        //       ],
                        //     ))
                        : Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 10,
                                    bottom: 5,
                                  ),
                                  child: Text(
                                    'Enter Details',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Color(0xff243444),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'HelveticaBold',
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    // inputFormatters: [
                                    //   FilteringTextInputFormatter.deny(new RegExp(r"\s\b|\b\s"))
                                    // ],
                                    onChanged: (val) async {
                                      if (val.isNotEmpty) name = val;
                                    },
                                    controller: nameController,
                                    keyboardType: TextInputType.text,
                                    onSaved: (val) {
                                      name = val!;
                                      setState(() {});
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value!.isEmpty ||

                                          // !RegExp(r'^[A-Za-z ]+( [A-Za-z ]+ )*$')
                                          !RegExp(r'^[\u0600-\u065F\u066A-\u06EF\u06FA-\u06FFa-zA-Z ]+( [\u0600-\u065F\u066A-\u06EF\u06FA-\u06FFa-zA-Z-_ ]+ )*$')
                                              // !RegExp(r'^[\u0600-\u065F\u066A-\u06EF\u06FA-\u06FFa-zA-Z]+[\u0600-\u065F\u066A-\u06EF\u06FA-\u06FFa-zA-Z-_]*$')
                                              .hasMatch(value)) {
                                        //allow upper and lower case alphabets and space
                                        return 'enter_correct_name'.tr;
                                      } else {
                                        return null;
                                      }
                                    },
                                    textCapitalization:
                                        TextCapitalization.words,
                                    style: const TextStyle(
                                        color: Color(0xff243444)),
                                    decoration: InputDecoration(
                                      // fillColor: const Color(0xffe6e6e6),
                                      // filled: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 5),
                                      // hintText: 'your_name'.tr,
                                      labelText: 'your_name'.tr,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    onChanged: (val) {
                                      if (val.isNotEmpty) email = val;
                                    },
                                    textCapitalization: TextCapitalization.none,
                                    style: const TextStyle(
                                        color: Color(0xff243444)),
                                    controller: emailController,
                                    onSaved: (val) {
                                      email = val!;
                                      setState(() {});
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      // Check if this field is empty
                                      if (value == null || value.isEmpty) {
                                        return 'this_field_is_required'.tr;
                                      }

                                      // using regular expression
                                      if (!RegExp(r'\S+@\S+\.\S+')
                                          .hasMatch(value)) {
                                        return "please_enter_a_valid_email_address"
                                            .tr;
                                      }

                                      // the email is valid
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      //fillColor: const Color(0xffe6e6e6),
                                      // filled: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 5),
                                      labelText: 'email_id'.tr,
                                      // hintStyle: const TextStyle(
                                      //     color: Colors.blueGrey, fontFamily: 'Helvetica'),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                  ),
                  actions: <Widget>[
                    Center(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: COLORS.APP_THEME_DARK_RED_COLOR,
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.normal)),
                          child: Text('cancel'.tr),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Center(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: COLORS.APP_THEME_DARK_RED_COLOR,
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.normal)),
                          onPressed: () {
                            final bool? isValid =
                                _formKey.currentState?.validate();

                            if (isValid == true) {
                              /*   nameController.clear();
                        emailController.clear();
                        commentController.clear;*/

                              setState(() => isPopupLoading = true);
                              _fetchBackEndData().then((_) =>
                                  // print('Processing completed'));
                                  Navigator.pop(context));
                            } else {
                              print("something_is_wrong".tr);
                            }
                          },
                          child: Text('send'.tr)),
                      // const SizedBox(
                      //   width: 30,
                    ),
                  ],
                ));
          },
        );
      },
    );
  }
}

class _SystemPadding extends StatelessWidget {
  final Widget child;

  const _SystemPadding({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
        padding: mediaQuery.viewInsets,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}
