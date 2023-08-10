import 'dart:async';

import 'package:andersonappnew/screens/HomeMenuPage.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ConnectionUtil.dart';
import '../../screens/NewExpandwidget.dart';

class AboutPage extends StatefulWidget {
  AboutPage({Key? key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  StreamSubscription? connection;
  bool isdataconnection = false;
  bool isLoading = true;
  var Internetstatus = "Unknown";

  @override
  void initState() {
    super.initState();
    ConnectionUtil connectionStatus = ConnectionUtil.getInstance();
    connectionStatus.initialize();
   connection= connectionStatus.connectionChange.listen(connectionChanged);
    BackButtonInterceptor.add(myInterceptor);
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isdataconnection = hasConnection;
      if (isdataconnection) {
        Internetstatus = "Connected To The Internet";
        isdataconnection = true;
        print('Data connection is available.');
        // setState(() {});
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
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeGridPage()));

    print("Back To Event Page");
    return true;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    return isdataconnection
        ? WillPopScope(
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

                centerTitle: false,
                titleSpacing: 0.0,
                elevation: 0,
                title: Transform(
                  // you can forcefully translate values left side using Transform
                  transform: Matrix4.translationValues(0.0, 0.0, 0.0),
                  child: Text(
                    'about_us'.tr,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'HelveticaBold',
                      fontSize: 18,
                      color: Color(0xff243444),
                    ),
                  ),
                ),
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
              body: Container(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    "coming_soon".tr,
                    style: const TextStyle(
                      color: Color(0xff243444),
                      fontSize: 24,
                      fontFamily: 'HelveticaNueueMedium',
                    ),
                  ),
                ),
              ),
            ),
            onWillPop: () {
              print(
                  'Backbutton pressed (device or appbar button), do whatever you want.');

              //trigger leaving and use own data
              Navigator.pop(context, false);

              //we need to return a future
              return Future.value(false);
            },
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
