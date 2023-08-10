import 'dart:async';

import 'package:andersonappnew/screens/app_arabic.dart';
import 'package:andersonappnew/screens/app_english.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ConnectionUtil.dart';
import '../Localization/classes/language.dart';
import '../Localization/localization/language_constants.dart';
import '../main.dart';

class objLanguage {
  objLanguage({
    required this.langname,
    required this.isSelected,
  });

  String langname;
  bool isSelected;

  factory objLanguage.fromJson(Map<String, dynamic> json) => objLanguage(
        langname: json["langname"],
        isSelected: false,
      );

  Map<String, dynamic> toJson() =>
      {"langname": langname, "isSelected": isSelected};
}

class Languages extends StatefulWidget {
  const Languages({Key? key, required this.isComingFromSideMenu})
      : super(key: key);

  final bool isComingFromSideMenu;

  @override
  _LanguagesState createState() => _LanguagesState();
}

class _LanguagesState extends State<Languages> {
  bool _isSelected = false;
  int _selectedIndex = -1;

  List<objLanguage> arrButtons = [];

  StreamSubscription? connection;
  bool isdataconnection = false;
  bool isLoading = true;
  var Internetstatus = "Unknown";

  @override
  void initState() {
    super.initState();
    setState(() {
      arrButtons.add(objLanguage(langname: "Arabic", isSelected: false));
      arrButtons.add(objLanguage(langname: "English", isSelected: false));
      ConnectionUtil connectionStatus = ConnectionUtil.getInstance();
      connectionStatus.initialize();
      connection = connectionStatus.connectionChange.listen(connectionChanged);
    });
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
    print("Back To Countries Page");

    if (["countryroute"].contains(info.currentRoute(context))) return true;

    //  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CountriesNew(isComingFromSideMenu: false,)),);

    return false;
  }

  void _setLanguage(Language language) async {
    Locale locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, locale);
  }

  Future<bool> _showAlert() async {
    return (await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            title: widget.isComingFromSideMenu
                ? Text(
                    'alert'.tr,
                    style: const TextStyle(
                      color: Color(0xffAB0E1E),
                      fontSize: 18,
                      fontFamily: 'Helvetica',
                    ),
                  )
                : const Text(
                    'Alert!!',
                    style: const TextStyle(
                      color: Color(0xffAB0E1E),
                      fontSize: 18,
                      fontFamily: 'Helvetica',
                    ),
                  ),
            content: widget.isComingFromSideMenu
                ? Text(
                    'choose_language'.tr,
                    style: const TextStyle(
                      color: Color(0xff243444),
                      fontSize: 18,
                      fontFamily: 'Helvetica',
                    ),
                  )
                : Text(
                    'Choose a language.'.tr,
                    style: const TextStyle(
                      color: Color(0xff243444),
                      fontSize: 18,
                      fontFamily: 'Helvetica',
                    ),
                  ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: widget.isComingFromSideMenu
                    ? Text(
                        'ok'.tr,
                        style: const TextStyle(
                          color: Color(0xffAB0E1E),
                          fontSize: 18,
                          fontFamily: 'Helvetica',
                        ),
                      )
                    : const Text(
                        'Ok',
                        style: const TextStyle(
                          color: Color(0xffAB0E1E),
                          fontSize: 18,
                          fontFamily: 'Helvetica',
                        ),
                      ),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    return isdataconnection
        ? Scaffold(
            body:
                // SingleChildScrollView(
                // alignment: Alignment.center,
                // scrollDirection: Axis.vertical,
                // child:
                Container(
              color: const Color(0xffFFFFFF),
              // padding:
              //     const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                        left: 10, top: 0, right: 10, bottom: 10),
                    // flex: 1,
                    child: ListTile(
                      leading: SizedBox(
                        // height: double.infinity,
                        child: Image.asset(
                          'assets/images/language.png',
                          height: 47,
                          width: 55,
                        ),
                        // Icon(
                        //   Icons.language,
                        //   size: 50,
                        // ),
                      ),

                      title: widget.isComingFromSideMenu
                          ? Text(
                              'choose_a_preferred'.tr,
                              style: TextStyle(
                                  color: Color(0xffA3AAAE),
                                  fontSize: 19,
                                  fontFamily: 'Helvetica'),
                            )
                          : Text(
                              'Choose a preferred',
                              style: TextStyle(
                                  color: Color(0xffA3AAAE),
                                  fontSize: 19,
                                  fontFamily: 'Helvetica'),
                            ),
                      subtitle: widget.isComingFromSideMenu
                          ? Text(
                              'language'.tr,
                              style: TextStyle(
                                  color: Color(0xff243444),
                                  fontSize: 38,
                                  fontFamily: 'HelveticaBold'),
                            )
                          : Text(
                              'Language',
                              style: TextStyle(
                                  color: Color(0xff243444),
                                  fontSize: 38,
                                  fontFamily: 'HelveticaBold'),
                            ),
                      tileColor: Colors.white,

                      minLeadingWidth: 0,
                      // ignore: sized_box_for_whitespace
                    ),
                  ),
                  // Center(
                  //   child:
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 20.0, left: 5, right: 5),
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemExtent: 90,
                      itemCount: arrButtons.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: 20.0, left: 5, right: 5),
                          child: GestureDetector(
                              onTap: () async {
                                setState(() {
                                  _selectedIndex = index;
                                });
                                if (arrButtons[index].langname == 'Arabic') {
                                  Locale locale = await setLocale(ARABIC);
                                  MyApp.setLocale(context, locale);
                                } else {
                                  Locale locale = await setLocale(ENGLISH);
                                  MyApp.setLocale(context, locale);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5.0),
                                //height: 60,
                                margin: const EdgeInsets.only(
                                    left: 15.0, right: 15),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(
                                        color: _selectedIndex == index
                                            ? const Color(0xffAB0E1E)
                                            : const Color(0xffD0D3D4),
                                        width:
                                            _selectedIndex == index ? 3 : 1)),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                          arrButtons[index]
                                              .langname
                                              .toUpperCase(),
                                          textAlign: TextAlign.left,
                                          style: _selectedIndex == index
                                              ? const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff000000),
                                                  fontFamily: 'HelveticaBold')
                                              : const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xffA3AAAE),
                                                  fontFamily: 'HelveticaBold')),
                                    ],
                                  ),
                                ),
                              )),
                        );
                      },
                    ),
                    // ],
                    // ),
                  ),
                  // bottomNavigationBar: Container(
                  //   width: 375,
                  //   height: 87,
                  //   decoration: const BoxDecoration(
                  //     color: Color(0xFFFFFFFF),
                  //     boxShadow: [
                  //       BoxShadow(
                  //           color: Color(0x76848F52),
                  //           spreadRadius: 4,
                  //           blurRadius: 10 //edited
                  //           )
                  //     ],
                  //   ),
                  //   child: Align(
                  //     alignment: Alignment.bottomCenter,
                  //     child: Container(
                  //       margin: const EdgeInsets.only(
                  //           top: 15, bottom: 14, left: 32, right: 32),
                  //       height: 58,
                  //       width: 311,
                  //       child: ElevatedButton(
                  //         style: ElevatedButton.styleFrom(
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(12), // <-- Radius
                  //           ),
                  //           // background color
                  //           // shadowColor:Color(0xff0000002B) ,
                  //           primary: const Color(0xffAB0E1E),
                  //           // padding: const EdgeInsets.symmetric(
                  //           //     horizontal: 100, vertical: 15),
                  //           textStyle: const TextStyle(fontSize: 20),
                  //         ),
                  //         onPressed: () {
                  //           if (arrButtons[_selectedIndex].langname == 'Arabic') {
                  //             Navigator.of(context).push(MaterialPageRoute(
                  //                 builder: (context) => Apparabic()));
                  //           } else {
                  //             Navigator.of(context).push(MaterialPageRoute(
                  //                 builder: (context) => const Appenglish()));
                  //           }
                  //         },
                  //         child: Text(
                  //           'Next'.toUpperCase(),
                  //           style: const TextStyle(
                  //               color: Colors.white, fontFamily: 'HelveticaBold'),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              // ),
            ),
            bottomNavigationBar: Container(
              width: 375,
              height: 87,
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x76848F52),
                      spreadRadius: 4,
                      blurRadius: 10 //edited
                      )
                ],
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(
                      top: 15, bottom: 14, left: 32, right: 32),
                  height: 58,
                  width: 311,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // <-- Radius
                      ),
                      // background color
                      // shadowColor:Color(0xff0000002B) ,
                      primary: const Color(0xffAB0E1E),
                      // padding: const EdgeInsets.symmetric(
                      //     horizontal: 100, vertical: 15),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      if (_selectedIndex > -1) {
                        if (widget.isComingFromSideMenu) {
                          if (arrButtons[_selectedIndex].langname == 'Arabic') {
                            // Locale locale = await setLocale(ARABIC);
                            // MyApp.setLocale(context, const Locale(ARABIC, "SA"));
                            saveLanguageCode(languageCode: 'ar');
                            Get.updateLocale(const Locale(ARABIC, "SA"));
                          } else {
                            // Locale locale = await setLocale(ENGLISH);
                            // MyApp.setLocale(context, const Locale(ENGLISH, 'US'));
                            saveLanguageCode(languageCode: 'en');
                            Get.updateLocale(const Locale(ENGLISH, "US"));
                          }
                          Navigator.pop(context);
                        } else {
                          if (arrButtons[_selectedIndex].langname == 'Arabic') {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Apparabic()));
                          } else {
                            // Navigator.of(context).push(MaterialPageRoute(
                            //     builder: (context) => const Appenglish()));
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Appenglish()),
                                (Route<dynamic> route) => false);
                          }
                        }
                      } else {
                        _showAlert();
                      }
                    },
                    child: Text(
                      'next'.tr.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontFamily: 'HelveticaBold'),
                    ),
                  ),
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

  Future<void> saveLanguageCode({required String languageCode}) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(LAGUAGE_CODE, languageCode);
  }
}
