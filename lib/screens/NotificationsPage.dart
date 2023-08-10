import 'dart:convert';


import 'package:andersonappnew/constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Localization/localization/language_constants.dart';
import '../models/NotificationModel.dart';
import '../models/PushNotification.dart';
import 'package:http/http.dart' as http;
import '../widgets/notification.dart';
import 'NewExpandwidget.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late int _totalNotifications;
  late final FirebaseMessaging _messaging;
  PushNotification? _notificationInfo;

  String notificationTitle = 'No Title';
  String notificationBody = 'No Body';
  String notificationData = 'No Data';
  String? firebasetoken;

  bool isLoading = true;
  List<NotificationData> notificationDataArr = [];

  getFirebaseToken() async {
    firebasetoken = (await FirebaseMessaging.instance.getToken())!;
    print("firebasetoken:$firebasetoken");
  }

  @override
  void initState() {
    getAllNotificationData(ApiConstant.url + ApiConstant.Endpoint);

    final firebaseMessaging = FCM();
    firebaseMessaging.setNotifications();

    firebaseMessaging.streamCtlr.stream.listen(_changeData);
    firebaseMessaging.bodyCtlr.stream.listen(_changeBody);
    firebaseMessaging.titleCtlr.stream.listen(_changeTitle);
    getFirebaseToken();
    super.initState();
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accesstoken');
  }

  Future<String?> getlocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(LAGUAGE_CODE);
  }

  Future<List<NotificationData>> getAllNotificationData(String url) async {
    Map paramcountries = {
      "methodname": "getallnotification",
    };
    print('$url , $paramcountries');
    // final getlocalec = await getlocale();
    // getlocalecode = getlocalec ?? "en";
    // print(getlocalecode);

    var token = await getToken();

    print(token);

    final response =
        await http.post(Uri.parse(url), body: paramcountries, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (kDebugMode) {
      print(response.body);
    }

    if (response.statusCode == 200) {
      notificationDataArr = [];
      final notificationObj = notificationDataModelFromJson(response.body);

      if (notificationObj.notificationData.isNotEmpty) {
        notificationDataArr = notificationObj.notificationData;
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("No Notification Available"),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something_went_wrong_please_try_again'.tr),
      ));
      throw Exception('Failed to load data');
    }
    return notificationDataArr;
  }

  _changeData(String msg) => setState(() => notificationData = msg);
  _changeBody(String msg) => setState(() => notificationBody = msg);
  _changeTitle(String msg) => setState(() => notificationTitle = msg);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Container(
          padding: const EdgeInsets.only(right: 10),
          height: 24,
          width: 24,
          child: IconButton(
            icon: Image.asset(
              'assets/images/backarrow.png',
              color: Color(0xff8D0C18),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0.0,
        title: Transform(
          // you can forcefully translate values left side using Transform
          transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
          child: Text(
            "Notifications".capitalizeFirstofEach,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'HelveticaNueueMedium',
              fontSize: 18,
              color: Color(0xff243444),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            alignment: Alignment.centerLeft,
            icon: const Icon(
              Icons.more_vert_outlined,
              color: Color(0xff8D0C18), //0xff243444
            ),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const NewExpandablewidget())),
          ),
        ],
      ),
      body: Center(
        child: ListView.builder(
            itemCount: notificationDataArr.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: const Icon(
                  FontAwesomeIcons.bell,
                  color: Color(0xff8D0C18),
                  size: 20,
                ),
                title: Text(
                  notificationDataArr[index].msgtitle,
                  style: const TextStyle(
                    color: Color(0xff243444),
                    fontSize: 16,
                    fontFamily: 'HelveticaNueueMedium',
                  ),
                ),
                subtitle: Text(
                  notificationDataArr[index].msgbody,
                  style: const TextStyle(
                    color: Color(0xff243444),
                    fontSize: 14,
                    fontFamily: 'HelveticaNueueMedium',
                  ),
                ),
              );
            }),

        //
        // Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Text(
        //       notificationTitle,
        //       style: Theme.of(context).textTheme.headline4,
        //     ),
        //     Text(
        //       notificationBody,
        //       style: Theme.of(context).textTheme.headline6,
        //     ),
        //     Text(
        //       notificationData,
        //       style: Theme.of(context).textTheme.headline6,
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
// body: Center(
//   child: Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       Text(
//         'App for capturing Firebase Push Notifications',
//         textAlign: TextAlign.center,
//         style: TextStyle(
//           color: Colors.black,
//           fontSize: 20,
//         ),
//       ),
//       SizedBox(height: 16.0),
//       NotificationBadge(totalNotifications: _totalNotifications),
//       SizedBox(height: 16.0),
//       // TODO: add the notification text here
//     ],
//   ),
//   // ListView.builder(
//   //     itemCount: 10,
//   //     itemBuilder: (BuildContext context, int index) {
//   //       return const ListTile(
//   //         leading: Icon(
//   //           FontAwesomeIcons.bell,
//   //           color: Color(0xff8D0C18),
//   //           size: 20,
//   //         ),
//   //         title: Text(
//   //           'TITLE: Notification ',
//   //           style: TextStyle(
//   //             color: Color(0xff243444),
//   //             fontSize: 16,
//   //             fontFamily: 'HelveticaNueueMedium',
//   //           ),
//   //         ),
//   //         subtitle: Text(
//   //           'BODY: Push Notifications',
//   //           style: TextStyle(
//   //             color: Color(0xff243444),
//   //             fontSize: 14,
//   //             fontFamily: 'HelveticaNueueMedium',
//   //           ),
//   //         ),
//   //       );
//   //     }),
// ),
