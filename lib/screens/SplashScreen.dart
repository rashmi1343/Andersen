import 'dart:async';
import 'dart:convert';

import 'dart:io';



import 'package:andersonappnew/screens/countriesnew.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;


import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';

import 'getstarted.dart';

MaterialColor generateMaterialColorFromColor(Color color) {
  return MaterialColor(color.value, {
    50: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
    100: Color.fromRGBO(color.red, color.green, color.blue, 0.2),
    200: Color.fromRGBO(color.red, color.green, color.blue, 0.3),
    300: Color.fromRGBO(color.red, color.green, color.blue, 0.4),
    400: Color.fromRGBO(color.red, color.green, color.blue, 0.5),
    500: Color.fromRGBO(color.red, color.green, color.blue, 0.6),
    600: Color.fromRGBO(color.red, color.green, color.blue, 0.7),
    700: Color.fromRGBO(color.red, color.green, color.blue, 0.8),
    800: Color.fromRGBO(color.red, color.green, color.blue, 0.9),
    900: Color.fromRGBO(color.red, color.green, color.blue, 1.0),
  });
}

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {


  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  bool _flexibleUpdateAvailable = false;

  // Platform messages are asynchronous, so we initialize in an async method.


  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }
  @override
  void initState() {
    super.initState();


    print("splash call");
    _getDeviceDetails();


    /*Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => CountriesNew())));*/
  }


  Future<void> _getDeviceDetails() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        APIDATA.deviceID = build.androidId;
        print("DEVICEID : ${APIDATA.deviceID}");

        //UUID for Android
      }


      /* else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        setState(() {
          deviceName = data.name;
          deviceVersion = data.systemVersion;
          deviceID = data.identifierForVendor;

         // getDiscussionDatabymenuid(widget.currentmenuitem.menuId);
        }); //UUID for iOS
      }*/
      checkAppHasToken();

      // print('Device Info: ${deviceName}, ${deviceVersion}, ${deviceID}');
    } on PlatformException {
      print('Failed to get platform version');
    }
  }

  checkAppHasToken() async {

    String token = await getToken() ?? "";
    if (kDebugMode) {
      print('Old token $token');
    }

    if (token.isEmpty) {
      Map data = {
        'email': 'vivek.chandra@broadwayinfotech.com',
        'password': 'test@123'
      };
      Gettokenfromapi(ApiConstant.url + ApiConstant.loginEndpoint, data);

    } else {
      getFirebaseToken();
      Timer(
        const Duration(seconds: 2),
            () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const GetStartedPage())),
      );
      // Navigator.pushReplacement(
      //     context, MaterialPageRoute(builder: (context) => CountriesNew()));
    }
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accesstoken');
  }
  String? firebasetoken;
  getFirebaseToken() async {
    firebasetoken = (await FirebaseMessaging.instance.getToken())!;
    print("firebasetoken:$firebasetoken");


    var token = await getToken();
    Map jsonparamdeviceid = {

      "methodname": "registerdevice",
      "device_id":  APIDATA.deviceID,
      "device_token": firebasetoken

    };
      print(jsonparamdeviceid.toString());
    final response = await http.post(Uri.parse(ApiConstant.url + ApiConstant.Endpoint), body: jsonparamdeviceid, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      String token = response.body;
      print(token);
      Timer(
        const Duration(seconds: 3),
            () =>
           /* Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CountriesNew(isComingFromSideMenu: false))*/
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const GetStartedPage())
      ),
      );
    }
  }

  void Gettokenfromapi(String url, Map jsonMap) async {
    print('$url , $jsonMap');

    final response = await http.post(Uri.parse(url), body: jsonMap, headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      String token = response.body;
      print(token);
      final parsedJson = jsonDecode(token);

      final authdata = GetToken.fromJson(parsedJson);
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString('accesstoken', authdata.data!.token.toString());
      print(authdata.data!.token.toString());
      getFirebaseToken();

    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // return
    //   Container(
    //     decoration: const BoxDecoration(
    //       image: DecorationImage(
    //           image: AssetImage("assets/images/splash.jpg"), fit: BoxFit.cover),
    //     ),
    //     child: Image.asset('assets/images/logo.png'));

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(0),
      //decoration: const BoxDecoration(color: Color(0xffD0D3D4)),
      child: Center(
        child: Image.asset(
          'assets/images/splash.png',
          // alignment: Alignment.center,
          width: screenSize.width,
          height: screenSize.height,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
    //   MaterialApp(
    //   title: 'Anderson Demo',
    //   theme: ThemeData(
    //
    //       // This is the theme of your application.
    //
    //       //
    //
    //       // Try running your application with "flutter run". You'll see the
    //
    //       // application has a blue toolbar. Then, without quitting the app, try
    //
    //       // changing the primarySwatch below to Colors.green and then invoke
    //
    //       // "hot reload" (press "r" in the console where you ran "flutter run",
    //
    //       // or simply save your changes to "hot reload" in a Flutter IDE).
    //
    //       // Notice that the counter didn't reset back to zero; the application
    //
    //       // is not restarted.
    //
    //       primarySwatch: generateMaterialColorFromColor(Colors.black)),
    //   home: SplashScreen(
    //       seconds: 5,
    //       navigateAfterSeconds: CountriesNew(),
    //
    //       //navigateAfterSeconds: fleydata(),
    //
    //       //  title: const Text('Welcome In SplashScreen'),
    //
    //       //   image: Image.network('https://i.imgur.com/TyCSG9A.png'),
    //
    //       image: Image.asset('assets/images/andersonappnew_black_logo.png'),
    //      // backgroundColor: HexColor.fromHex('#76848F'),
    //       backgroundColor: const Color(0xffD0D3D4),
    //       styleTextUnderTheLoader:  TextStyle(),
    //       photoSize: 150.0,
    //       onClick: () => print("Flutter Egypt"),
    //       loaderColor: HexColor.fromHex('#AB0E1E')),
    // );
  }
}

class GetToken {
  bool? success;
  Data? data;
  String? message;

  GetToken({this.success, this.data, this.message});

  GetToken.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}


class NotificationCount {
  late int status;
  late int notification_count;

  NotificationCount({required this.status, required this.notification_count});

  NotificationCount.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    notification_count = json['notification_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['notification_count'] = notification_count;
    return data;
  }

}

class Data {
  String? token;
  String? name;

  Data({this.token, this.name});

  Data.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['name'] = name;
    return data;
  }
}
