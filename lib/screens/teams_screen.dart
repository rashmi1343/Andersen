


import 'dart:convert';

import 'package:andersonappnew/Localization/localization/language_constants.dart';
import 'package:andersonappnew/Localization/pages/about_page.dart';
import 'package:andersonappnew/constant.dart';
import 'package:andersonappnew/models/getteam_model.dart';
import 'package:andersonappnew/screens/HomeMenuPage.dart';
import 'package:andersonappnew/screens/NewExpandwidget.dart';
import 'package:andersonappnew/screens/NotificationsPage.dart';
import 'package:andersonappnew/screens/Privacypolicy_screen.dart';
import 'package:andersonappnew/screens/countriesnew.dart';
import 'package:andersonappnew/screens/languagesnew.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:searchable_listview/searchable_listview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class teamscreen extends StatefulWidget {
  _teamwidgetState createState() => _teamwidgetState();
}


class _teamwidgetState extends State<teamscreen> {

  List<Teams> arteam = [];
  List<Teams> allteam = [];
  bool isLoading = true;
  bool isdataconnection = true;
  String selectedCountry = "";
  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accesstoken');
  }

  Future<String?> getSelectedCountry() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.getString('selectedCountry') ?? "";
    selectedCountry = data;

   // getMenuByCountryData(ApiConstant.url + ApiConstant.Endpoint);

    return data;
  }

  Future<String?> getlocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(LAGUAGE_CODE);
  }

  void updateLanguage() async {
    var locale = await getlocale();
    if (locale == 'US') {
      Get.updateLocale(const Locale(ENGLISH, 'US'));
    } else if (locale == 'SA') {
      Get.updateLocale(const Locale(ARABIC, 'SA'));
    }

    // setState(() {
    isLoading = true;
    // callApiToGetMenuData();
    //getMenuByCountryData(ApiConstant.url + ApiConstant.Endpoint);
    // });
  }





  @override
  void initState() {
    // TODO: implement initState

    print("team init called");
    getAllteam();
  }

  Future<List<Teams>> getAllteam() async {

    setState(() {
      isLoading = true;
    });

    Map paramcountries = {
      "methodname": "getteam",
    };

    print(paramcountries);
    // }
    // Locale locale = await setLocale(ENGLISH);
    // MyApp.setLocale(context, locale);



    var token = await getToken();

    print(token);

    final response =
    await http.post(Uri.parse(ApiConstant.url + ApiConstant.Endpoint), body: paramcountries, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    /*if (kDebugMode) {
      print(response.body);
    }*/

    if (response.statusCode == 200) {
      // data = json.decode(response.body);

      Map decoded = json.decode(response.body);

      final teamObj = teamFromJson(response.body);
      // print(decoded);

      // if (kDebugMode) {
      // print(decoded);
      // }
      print(decoded["Teams"]);
      // print(response.body);

      for (var objteam in decoded["Teams"]) {
        if (kDebugMode) {
          print(objteam['id']);
          print(objteam['name']);
          print(objteam['designation']);
          print(objteam['isActive']);
          print(objteam['isDeleted']);
        }

        if (objteam['isActive'] == 1) {
          arteam.add(Teams(
              id: objteam['id'],
              name: objteam['name'],
              designation: objteam['designation'],
              isActive: objteam['isActive'],
              isDeleted: objteam['isDeleted']));
        }
      }
    }

    return arteam;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
          bottom: true,
          top: false,
          left: true,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              titleSpacing: 0.0,
              elevation: 0,
              title: Transform(
                // you can forcefully translate values left side using Transform
                transform: Matrix4.translationValues(0.0, 0.0, 0.0),
                child: Text(
                  'team'.tr,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'HelveticaNueueBold',
                    fontSize: 18,
                    color: Color(0xff243444),
                  ),
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
              backgroundColor: Colors.white,
              leading: Builder(
                builder: (context) => Container(
                  margin: EdgeInsets.only(left: 10),
                  height: 14,
                  width: 18,
                  child: IconButton(
                    alignment: Alignment.centerLeft,
                    icon: Image.asset(
                      'assets/images/menuicon.png',
                      color: Color(0xff8D0C18),
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
              //iconTheme: const IconThemeData(color: Color(0xff243444)),
              actions: <Widget>[
                Stack(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => NotificationPage()));
                      },
                      icon: const Icon(FontAwesomeIcons.bell,
                        color: Color(0xff8D0C18),size: 27,),
                      //using font awesome icon in action list of appbar
                    ),

                    Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Color(0xff8D0C18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child:  Text(
                          Notificationtype.notificationcount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )

                  ],
                ),

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

              ],
            ),
            drawer: Drawer(
              // backgroundColor: HexColor.fromHex('#D0D3D4'),
              backgroundColor: Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          height: 41,
                          width: 74.83,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                  APIDATA.countryflag.toString()),
                              fit: BoxFit.fitWidth,
                              // alignment: Alignment.centerLeft,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              selectedCountry,
                              // "SAUDI ARABIA",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffA3AAAE),
                                  fontSize: 16.0,
                                  fontFamily: 'HelveticaNueueBold'),
                            ),
                            IconButton(

                              alignment: Alignment.centerRight,
                              icon: Image.asset(
                                  'assets/images/edit_icon.png'),
                              color: const Color(0xff243444),

                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const CountriesNew(
                                            isComingFromSideMenu:
                                            true)))
                                // const Languages(isComingFromSideMenu: true)))
                                    .then((value) {
                                  setState(() {
                                    // refresh state of Page1
                                    print('Refresh Selected Country');
                                    isLoading = true;
                                  //  getSelectedCountry();
                                  });
                                });
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  /* ListTile(
                  leading: IconButton(
                    padding: EdgeInsets.zero,
                    icon: ImageIcon(
                      AssetImage("assets/images/drawer/global.png"),
                      size: 32,
                    ),
                    onPressed: () {
                      print("You Pressed the icon!");
                    },
                  ),
                  title: Text(
                    'Change Language'.tr,
                    style: const TextStyle(
                        color: Color(0xff76848F),
                        fontSize: 18,
                        fontFamily: 'Helvetica',
                        fontWeight: FontWeight.normal),
                  ),
                  onTap: () {
                    // Navigator.of(context).push(MaterialPageRoute(
                    //     builder: (context) => EventPage()));
                  },
                ),*/
                  ListTile(
                    leading: Container(
                      child: Ink(
                        height: 30,
                        width: 30,
                        // decoration: ShapeDecoration(
                        //   color: Color(0xff76848F),
                        //   shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(8.0),
                        //   ),
                        // ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          /* icon: const Icon(
                          Icons.language,
                          color: Colors.black,
                          size: 20,
                        ),*/
                          icon: Image.asset(
                              'assets/images/drawer/global.png'),
                          // color: Colors.white,
                          onPressed: () {
                            print("You Pressed the icon!");
                          },
                        ),
                      ),
                    ),
                    title: Text(
                      'change_language'.tr,
                      style: const TextStyle(
                        color: Color(0xff76848F),
                        fontSize: 18,
                        fontFamily: 'HelveticaNueueMedium',
                      ),
                    ),
                    onTap: () {
                      /* Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => EventPage()));*/

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Languages(
                                  isComingFromSideMenu: true)))
                          .then((value) {
                        setState(() {
                          // refresh state of Page1
                          print('Refresh Homepage');
                          updateLanguage();
                        });
                      });
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) =>
                      //             const Languages(isComingFromSideMenu: true)));
                    },
                  ),
                  ListTile(
                    leading: Container(
                      child: Ink(
                        height: 30,
                        width: 30,
                        // decoration: ShapeDecoration(
                        //   color: Color(0xff76848F),
                        //   shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(8.0),
                        //   ),
                        // ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          /* icon: const Icon(
                          Icons.info_outline,
                          color: Colors.black,
                          size: 20,
                        ),*/
                          icon: Image.asset(
                              'assets/images/drawer/aboutus.png'),
                          //  color: Colors.white,
                          onPressed: () {
                            print("You Pressed the icon!");
                          },
                        ),
                      ),
                    ),
                    title: Text(
                      'about_us'.tr,
                      style: const TextStyle(
                        color: Color(0xff76848F),
                        fontSize: 18,
                        fontFamily: 'HelveticaNueueMedium',
                      ),
                    ),
                    // Text(
                    //   getTranslated(context, 'about_us') ?? "",
                    //   style: _textStyle,
                    // ),
                    onTap: () {

                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AboutPage()));
                    },
                  ),
                  /*ListTile(
                  leading: Container(
                    child: Ink(
                      height: 30,
                      width: 30,
                      decoration: ShapeDecoration(
                        color: Color(0xff76848F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        /*  icon: const Icon(
                          Icons.mail,
                          color: Colors.black,
                          size: 20,
                        ),*/
                        icon:
                            Image.asset('assets/images/drawer/messagebox.png'),
                        //  color: Colors.white,
                        onPressed: () {
                          print("You Pressed the icon!");
                        },
                      ),
                    ),
                  ),
                  title: Text(
                    'contact_us'.tr,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Helvetica'),
                  ),
                  // Text(
                  //   getTranslated(context, 'contact_us') ?? "",
                  //   style: _textStyle,
                  // ),
                  onTap: () {
                    // Navigator.of(context).push(MaterialPageRoute(
                    //     builder: (context) =>  ContactUsPage(eventData: '',)));
                  },
                ),*/
                  ListTile(
                    leading: Container(
                      child: Ink(
                        height: 30,
                        width: 30,
                        // decoration: ShapeDecoration(
                        //   color: Color(0xff76848F),
                        //   shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(8.0),
                        //   ),
                        // ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          /* icon: const Icon(
                          Icons.category,
                          color: Colors.black,
                          size: 20,
                        ),*/
                          icon:
                          Image.asset('assets/images/drawer/cat.png'),

                          //  color: Colors.white,
                          onPressed: () {
                            //      print("You Pressed the icon!");
                            //HomeGridPage
                            Navigator.pop(context);

                          },
                        ),
                      ),
                    ),
                    title: Text(
                      'categories'.tr,
                      style: TextStyle(
                          color: Color(0xff76848F),
                          fontSize: 18,
                          fontFamily: 'HelveticaNueueMedium'),
                    ),
                    // Text(
                    //   getTranslated(context, 'settings') ?? "",
                    //   style: _textStyle,
                    // ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const HomeGridPage()));

                    },
                  ),
                  ListTile(
                    leading: Container(
                      child: Ink(
                        height: 30,
                        width: 30,

                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon:
                          Image.asset('assets/images/drawer/teamnw.png'),

                          //  color: Colors.white,
                          onPressed: () {

                          },
                        ),
                      ),
                    ),
                    title: Text(
                      'team'.tr,
                      style: TextStyle(
                          color: Color(0xff76848F),
                          fontSize: 18,
                          fontFamily: 'HelveticaNueueMedium'),
                    ),
                    // Text(
                    //   getTranslated(context, 'settings') ?? "",
                    //   style: _textStyle,
                    // ),
                    onTap: () {

                    },
                  ),
                  ListTile(
                    leading: Container(
                      child: Ink(
                        height: 30,
                        width: 30,

                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon:
                          Image.asset('assets/images/drawer/privacypolicy.png'),

                          //  color: Colors.white,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>  Privacypolicy()));
                          },
                        ),
                      ),
                    ),
                    title: Text(
                      'privacy_policy'.tr,
                      style: TextStyle(
                          color: Color(0xff76848F),
                          fontSize: 18,
                          fontFamily: 'HelveticaNueueMedium'),
                    ),
                    // Text(
                    //   getTranslated(context, 'settings') ?? "",
                    //   style: _textStyle,
                    // ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>  Privacypolicy()));
                    },
                  ),

                ],
              ),
            ),
   /*   body:FutureBuilder<List<Teams>?>(
        future:getAllteam(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Image.network(
                    'https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50',
                  ),
                        title:Text("${snapshot.data![index].name.toString()}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'HelveticaNueueMedium'

                            )),
                        subtitle: Text("${snapshot.data![index].designation.toString()}",
                            style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'HelveticaNueueMedium'

                            )),
                      ),
                    ],
                  ),
                );
              });
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const Center(child: CircularProgressIndicator(color:  Color(0xff254fd5),));
        },
      ),*/
      body:  SizedBox(
        width: double.infinity,
        child: Column(
          children: [
           // const Text('Searchable list with divider'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: SearchableList<Teams>(
                  style: const TextStyle(fontSize: 25),
                  onPaginate: () async {
                    await Future.delayed(const Duration(milliseconds: 1000));
                    setState(() {
                       // getAllteam();
                    });
                  },
                  builder: (Teams actor) => MemberItem(actor: actor),
                  loadingWidget: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 20,
                      ),
                      Text('Loading Members...')
                    ],
                  ),
                  errorWidget: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text('Error while fetching Members')
                    ],
                  ),
                  asyncListCallback: () async {
                    await Future.delayed(
                      const Duration(
                        milliseconds: 1500, // strictly not changed
                      ),
                    );
                    return arteam;
                  },
                  asyncListFilter: (q, list) {


                    return list
                        .where((element) => element.name!.contains(q))
                        .toList();
                  },
                  emptyWidget: const EmptyView(),
                  onRefresh: () async {},
                  onItemSelected: (Teams item) {},
                  inputDecoration: InputDecoration(
                    labelText: "Search Member",
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ),
          /*  Align(
              alignment: Alignment.center,
              child: const Text('Add actor'),
            )*/
          ],
        )
      )));





  }








}



class MemberItem extends StatelessWidget {
  final Teams actor;

  const MemberItem({
    Key? key,
    required this.actor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Image.network(
              'https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50',
            ),
            title:Text("${actor.name.toString()}",
                style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'HelveticaNueueMedium'

                )),
            subtitle: Text("${actor.designation.toString()}",
                style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'HelveticaNueueMedium'

                )),
          ),
        ],
      ),
    );
  }
}



class EmptyView extends StatelessWidget {
  const EmptyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.error,
          color: Colors.red,
        ),
        Text('No Team Member'),
      ],
    );
  }
}