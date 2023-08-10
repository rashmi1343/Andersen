import 'dart:async';
import 'dart:convert';

import 'package:andersonappnew/ConnectionUtil.dart';
import 'package:andersonappnew/screens/getstarted.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Localization/localization/language_constants.dart';
import '../constant.dart';
import '../main.dart';
import '../models/GetCountry.dart';

import '../widgets/NoDataFoundWidget.dart';
import 'languagesnew.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

class CountriesNew extends StatefulWidget {
  final bool isComingFromSideMenu;

  const CountriesNew({Key? key, required this.isComingFromSideMenu})
      : super(key: key);

  @override
  _CountriesNewState createState() => _CountriesNewState();
}

class _CountriesNewState extends State<CountriesNew> {
  String? _selectedCountry;

  List<CountryElement> arcountry = [];
  List<String> strcountry = [];
  bool isLoading = true;
  bool isdataconnection = true;
  String getlocalecode = '';
  List countryName = [
    'India',
    'Bahrain',
    'Oman',
    'Saudi Arabia',
    'UAE',
    'Australia'
  ];
  StreamSubscription? connection;

  // StreamSubscription<InternetConnectionStatus> listener =
  // InternetConnectionChecker().onStatusChange.listen(
  //       (InternetConnectionStatus status) {
  //     switch (status) {
  //       case InternetConnectionStatus.connected:
  //         print('Data connection is available.');
  //         break;
  //       case InternetConnectionStatus.disconnected:
  //         print('You are disconnected from the internet.');
  //         break;
  //     }
  //   },
  // );

  var Internetstatus = "Unknown";

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accesstoken');
  }

  Future<String?> getlocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(LAGUAGE_CODE);
  }

/*
  CheckInternet() async {
    // Simple check to see if we have internet
    print("The statement 'this machine is connected to the Internet' is: ");
    print(await DataConnectionChecker().hasConnection);
    // returns a bool

    // We can also get an enum instead of a bool
    print("Current status: ${await DataConnectionChecker().connectionStatus}");
    // prints either DataConnectionStatus.connected
    // or DataConnectionStatus.disconnected

    // This returns the last results from the last call
    // to either hasConnection or connectionStatus
    print("Last results: ${DataConnectionChecker().lastTryResults}");

    // actively listen for status updates
    listener = DataConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case DataConnectionStatus.connected:
          Internetstatus = "Connectd TO THe Internet";
          isdataconnection = true;
          print('Data connection is available.');
          setState(() {
            getAllCountriesData(ApiConstant.url + ApiConstant.Endpoint);
          });
          break;
        case DataConnectionStatus.disconnected:
          Internetstatus = "No Data Connection";
          isdataconnection = false;
          print('You are disconnected from the internet.');
          setState(() {
            isLoading = false;
          });
          break;
      }
    });

    // close listener after 30 seconds, so the program doesn't run forever
//    await Future.delayed(Duration(seconds: 30));
//    await listener.cancel();
    return await await DataConnectionChecker().connectionStatus;
  }*/

  Future<List<CountryElement>> getAllCountriesData(String url) async {
    Map paramcountries = {
      "methodname": "getallcountry",
    };

    print('$url , $paramcountries');
    // }
    // Locale locale = await setLocale(ENGLISH);
    // MyApp.setLocale(context, locale);

    final getlocalec = await getlocale();
    getlocalecode = getlocalec ?? "en";
    print(getlocalecode);

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
      // data = json.decode(response.body);
      arcountry = [];
      Map decoded = json.decode(response.body);

      final countryObj = countryFromJson(response.body);
      // print(decoded);

      // if (kDebugMode) {
      // print(decoded);
      // }
      if (countryObj.country.isNotEmpty) {
        arcountry = countryObj.country;
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No Country Available"),
        ));
      }

      /*  for (var objCountry in decoded["Country"]) {
          if (kDebugMode) {
            print(objCountry['id']);
            print(objCountry['countrycode']);
            print(objCountry['countrylocale']);
            print(objCountry['countryname']);
            print(objCountry['isActive']);
          }

          if (objCountry['isActive'] == 1) {
            arcountry.add(CountryElement(
                id: objCountry['id'],
                countryname: objCountry['countryname'],
                countrycode: objCountry['countrycode'],
                countrylocale: objCountry['countrylocale'],
                isActive: objCountry['isActive'],
                filepath: objCountry['filepath']));
          }
          // strcountry.add(objCountry['countryname']);


          // }

        }*/
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something_went_wrong_please_try_again'.tr),
      ));
      throw Exception('Failed to load data');
    }
    return arcountry;
  }

  saveSelectedCountry({String? country}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedCountry', country ?? "");

    final index =
        arcountry.indexWhere((element) => element.countryname == country);
    prefs.setInt('countryId', arcountry[index].id);
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
                    'choose_country'.tr,
                    style: const TextStyle(
                      color: Color(0xff243444),
                      fontSize: 18,
                      fontFamily: 'Helvetica',
                    ),
                  )
                : Text(
                    'Choose a country.'.tr,
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
  void initState() {
    super.initState();

    //  setState(() {
    // CheckInternet();
    ConnectionUtil connectionStatus = ConnectionUtil.getInstance();
    connectionStatus.initialize();
    connection = connectionStatus.connectionChange.listen(connectionChanged);
    //  });
    BackButtonInterceptor.add(myInterceptor);
  }

  void connectionChanged(dynamic hasConnection) {
    // setState(() {
    isdataconnection = hasConnection;
    if (isdataconnection) {
      Internetstatus = "Connected To The Internet";
      isdataconnection = true;
      print('Data connection is available.');
     // setState(() {
        getAllCountriesData(ApiConstant.url + ApiConstant.Endpoint);
    //  });
    } else if (!isdataconnection) {
      Internetstatus = "No Data Connection";
      isdataconnection = false;
      print('You are disconnected from the internet.');
      setState(() {
        isLoading = false;
        isdataconnection = false;
      });
    }
    //});
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    connection?.cancel();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("Back To Get Started Page");
    //  Navigator.pop(context);
    if (["getStartedRoute"].contains(info.currentRoute(context))) return true;
    //  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GetStartedPage()),);

    return false;
  }

  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    if (arcountry.isNotEmpty) {
      return SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: isdataconnection
              ? SizedBox(
                  height: screenSize.height * 4.5,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(5),
                    child: Padding(
                        padding: const EdgeInsets.only(top: 66),
                        child: Column(
                          children: [
                            ListTile(
                              leading: SizedBox(
                                child: Image.asset(
                                  'assets/images/countryicon/country.png',
                                  height: 50,
                                  width: 45,
                                ),
                                // Icon(
                                //   Icons.language,
                                //   size: 50,
                                // ),
                              ),
                              title: widget.isComingFromSideMenu
                                  ? Text(
                                      'choose_a'.tr,
                                      // textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Color(0xff76848F),
                                          fontSize: 18,
                                          // fontWeight: FontWeight.bold,
                                          fontFamily: 'HelveticaBold'),
                                    )
                                  : Text(
                                      "Choose a",
                                      // textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Color(0xff76848F),
                                          fontSize: 18,
                                          // fontWeight: FontWeight.bold,
                                          fontFamily: 'HelveticaBold'),
                                    ),
                              subtitle: widget.isComingFromSideMenu
                                  ? Text(
                                      'country'.tr,
                                      //textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 38,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'HelveticaBold'),
                                    )
                                  : Text(
                                      'Country',
                                      //textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 38,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'HelveticaBold'),
                                    ),
                              tileColor: Colors.white,

                              minLeadingWidth: 0,
                              // ignore: sized_box_for_whitespace
                            ),
                            // ),

                            const SizedBox(height: 30),

                            isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : GridView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 44,
                                      crossAxisSpacing: 22,
                                      // width / height: fixed for *all* items
                                      //childAspectRatio: 3 / 2.4,
                                      mainAxisExtent: 130,
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    itemCount: arcountry.length,
                                    //countryName.length, // arcountry.length,

                                    itemBuilder: (BuildContext ctx, index) {
                                      return GestureDetector(
                                          onTap: () async {
                                            setState(() {
                                              _selectedIndex = index;

                                              // _selectedCountry =
                                              //     countryName[index];
                                              // print(_selectedCountry);
                                              _selectedCountry =
                                                  arcountry[index].countryname;
                                              APIDATA.countryflag =
                                                  arcountry[index].filepath;
                                            });
                                          },
                                          child: Container(
                                            height: 122,
                                            width: 150,
                                            // height: 50,
                                            padding: const EdgeInsets.all(5),
                                            //alignment: Alignment.topLeft,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: const <BoxShadow>[
                                                  BoxShadow(
                                                    color: Color(0xff76848F),
                                                    offset: Offset(0.0, 0.75),
                                                    blurRadius: 2.0,
                                                  ),
                                                ],
                                                border: Border.all(
                                                    color: _selectedIndex ==
                                                            index
                                                        ? const Color(
                                                            0xffAB0E1E)
                                                        : Color.fromRGBO(
                                                            255, 255, 255, 1),
                                                    width:
                                                        5), //Color.fromARGB(255, 150, 7, 29)
                                                color: Colors.white),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 9.0, top: 12),

                                              //Image.network(src)
                                              child: Column(
                                                crossAxisAlignment:
                                                    // CrossAxisAlignment.end,
                                                    getlocalecode == 'en'
                                                        ? CrossAxisAlignment
                                                            .start
                                                        : CrossAxisAlignment
                                                            .end,

                                                // mainAxisAlignment:
                                                //     MainAxisAlignment.start,
                                                children: [
                                                  // Image.asset(
                                                  //   'assets/images/flag.png', //imgdata[index],
                                                  //   height: 30,
                                                  //   width: 54,
                                                  //   alignment: Alignment.topLeft,
                                                  //   //fit: BoxFit.fill,
                                                  // ),
                                                  // Padding(
                                                  //   padding:
                                                  //       const EdgeInsets.only(
                                                  //           left: 9.0, top: 12),

                                                  //   //Image.network(src)
                                                  //   child:
                                                  Container(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .only(
                                                              topLeft: Radius
                                                                  .circular(5),
                                                              topRight: Radius
                                                                  .circular(5),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          5),
                                                              bottomLeft: Radius
                                                                  .circular(5)),
                                                      child: FadeInImage.assetNetwork(
                                                          placeholder:
                                                              "assets/images/no_image.png",
                                                          image: arcountry[
                                                                      index]
                                                                  .filepath
                                                                  .isNotEmpty
                                                              ? arcountry[index]
                                                                  .filepath
                                                              : '${ApiConstant.menuiconpoint}no_image.png',
                                                          height: 30,
                                                          width: 54.83,
                                                          alignment:
                                                              Alignment.topLeft
                                                          // getlocalecode ==
                                                          //         'en'
                                                          //     ? Alignment
                                                          //         .topLeft
                                                          //     : Alignment
                                                          //         .topRight,
                                                          ),
                                                    ),
                                                  ),

                                                  // Image.network(
                                                  //   arcountry[index].filepath,
                                                  //   height: 30,
                                                  //   width: 54,
                                                  //   alignment: Alignment.topLeft,
                                                  // ),
                                                  // ),
                                                  const SizedBox(height: 19),
                                                  // Padding(
                                                  //   padding: EdgeInsets.only(
                                                  //       left: 9),
                                                  //   child:
                                                  Text(
                                                    arcountry[index]
                                                        .countryname
                                                        .toUpperCase(),
                                                    // countryName[index].toUpperCase(),
                                                    // menuitem[index],
                                                    textAlign: TextAlign.left,
                                                    style: _selectedIndex ==
                                                            index
                                                        ? const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xff000000),
                                                            fontFamily:
                                                                'HelveticaBold')
                                                        : const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xffA3AAAE),
                                                            fontFamily:
                                                                'HelveticaBold'),
                                                    maxLines: 3,
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                  // )
                                                ],
                                              ),
                                            ),
                                          ));
                                    })
                          ],
                        )),
                  ),
                )
              : Container(
                  child: Center(
                    //child: Text("$Internetstatus"),
                    child: Text(""),
                  ),
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
                        borderRadius: BorderRadius.circular(13), // <-- Radius
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
                        saveSelectedCountry(country: _selectedCountry);

                        if (widget.isComingFromSideMenu) {
                          Navigator.pop(context);
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Languages(
                                        isComingFromSideMenu: false,
                                      )));
                        }
                      } else {
                        //_showAlert();
                        isdataconnection ? _showAlert() : null;
                      }
                    },
                    child: isdataconnection
                        ? Text(
                            'next'.tr.toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'HelveticaBold'),
                          )
                        : Text(
                            'Check your Internet Connection',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontFamily: 'HelveticaBold'),
                          )),
              ),
            ),
          ),
        ),
      );
    } else {
      return isdataconnection
          ? Container(
              height: screenSize.height,
              padding: const EdgeInsets.all(5),
              color: Colors.white,
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.black))
                  : Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 64,
                      ),
                      Image.asset(
                        'assets/images/submenuicon/nodatafound.png',
                        height: 201.33,
                        width: 253.99,
                      ),
                      const SizedBox(
                        height: 14.67,
                      ),
                      const Text(
                        'Ooops',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 38,
                          fontFamily: 'HelveticaBold',
                          color: Color(0xFF8D0C18),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Something went wrong and we \n couldn\'t publish content',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Helvetica',
                            color: Color(0xff76848F)),
                      ),
                    ],
                  )),
            )
          : Container(
              margin: EdgeInsets.only(left: 30, top: 30, right: 30, bottom: 50),
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
              ));
    }
  }
}
// @override
// Widget build(BuildContext context) {
//   final size = MediaQuery.of(context).size;

//   return WillPopScope(
//     onWillPop: _onWillPop,
//     child: Scaffold(
//       body: SingleChildScrollView(
//         // alignment: Alignment.center,
//         scrollDirection: Axis.vertical,
//         child: Container(
//           color: const Color(0xffD0D3D4),
//           padding: const EdgeInsets.only(
//               left: 10, top: 100, right: 10, bottom: 10),
//           height: MediaQuery.of(context).size.height,
//           width: MediaQuery.of(context).size.width,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 10),
//               Container(
//                 margin: const EdgeInsets.only(
//                     left: 20, top: 20, right: 10, bottom: 0),
//                 alignment: Alignment.center,
//                 // padding: const EdgeInsets.all(10),
//                 height: 150,
//                 child: Center(
//                     child: Image.asset(
//                   'assets/images/andersonappnew_black_logo.png',
//                   alignment: Alignment.center,
//                   fit: BoxFit.fitWidth,
//                 )),
//               ),
//               const SizedBox(height: 10),
//               /* const Text(
//                         ' andersonappnew provides a wide range \n '
//                         'of tax,valuation, financial \n  '
//                         'advisory and related consulting \n'
//                         'services to individual and \n '
//                         'commercial clients.',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Color(0xff000000),
//                           fontWeight: FontWeight.normal,
//                           fontFamily: 'Helvetica',
//                         ),
//                       ),*/
//               Container(
//                   margin: const EdgeInsets.only(
//                       left: 20, top: 4, right: 10, bottom: 10),
//                   alignment: Alignment.center,
//                   // padding: const EdgeInsets.all(10),
//                   height: 200,
//                   child: Center(
//                       child: Html(
//                           data:
//                               "<p>andersonappnew provides a wide range of tax valuation, financial advisory and related consulting services to individual and commercial clients.<p>",
//                           style: {
//                         '#': Style(
//                           fontSize: const FontSize(24),
//                           color: const Color(0xff000000),
//                           fontWeight: FontWeight.w300,
//                           fontFamily: 'Helvetica-Oblique',
//                           textAlign: TextAlign.center,
//                         ),
//                       }))),
//               isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : const SizedBox(height: 30),
//               // const Padding(
//               //     padding: EdgeInsets.only(
//               //         left: 20, top: 30, right: 20, bottom: 0)),
//               const Text(
//                 'Select a Country',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 23,
//                   fontWeight: FontWeight.w400,
//                   fontFamily: 'Helvetica-Oblique',

//                   //color: HexColor.fromHex('')
//                 ),
//                 // fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                   // width: 42.0,
//                   height: 60.0,
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 25, right: 25),
//                     child: DecoratedBox(
//                         decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(40)),
//                         child: Padding(
//                             padding: const EdgeInsets.only(
//                                 top: 7, left: 25, right: 25),
//                             child: DropdownSearch<String>(
//                               // label: "Country",
//                               //mode of dropdown
//                               mode: Mode.DIALOG,
//                               //to show search box

//                               dropdownSearchDecoration: const InputDecoration(
//                                   border: InputBorder.none),
//                               showSearchBox: true,
//                               searchBoxDecoration: const InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                               ),

//                               showSelectedItem: true,
//                               showAsSuffixIcons: true,
//                               showClearButton: false,
//                               //list of dropdown items
//                               items: strcountry,

//                               hint: "Choose a Country",
//                               onChanged: (value) {
//                                 // setState(() {
//                                 _selectedCountry = value!;
//                                 saveSelectedCountry(country: _selectedCountry);

//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           const Languages()),
//                                 );
//                                 // });
//                               },
//                               //show selected item
//                               // selectedItem: "India",
//                             ))),
//                   )),
//               const SizedBox(height: 20),
//               // Expanded(
//               // child: Align(
//               const Expanded(
//                 child: Align(
//                   alignment: FractionalOffset.bottomCenter,
//                   child: Padding(
//                       padding: EdgeInsets.only(bottom: 20.0),
//                       child: Text('About this App ',
//                           style: TextStyle(
//                               fontWeight: FontWeight.normal,
//                               fontSize: 16,
//                               color: Color(0xffAB0E1E),
//                               fontFamily: 'Helvetica'))),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }
//}
