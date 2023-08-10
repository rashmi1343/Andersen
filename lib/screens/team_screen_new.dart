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
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TeamScreenNew extends StatefulWidget {
  @override
  _TeamScreenNewState createState() => _TeamScreenNewState();
}

class _TeamScreenNewState extends State<TeamScreenNew> {

  List<Teams> ? teamList = [];
  List<Teams> ? tempList = [];
  bool isLoading = false;
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
    super.initState();
    _fetchDogsBreed();
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
                builder: (context) =>
                    Container(
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
                        color: Color(0xff8D0C18), size: 27,),
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
                        child: Text(
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
                  onPressed: () =>
                      Navigator.of(context).push(
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
                              builder: (context) =>
                              const Languages(
                                  isComingFromSideMenu: true)))
                          .then((value) {
                        setState(() {
                          // refresh state of Page1
                          print('Refresh Homepage');
                          //  updateLanguage();
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
                                builder: (context) => Privacypolicy()));
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
                          builder: (context) => Privacypolicy()));
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
            body:
            Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _searchBar(),
                      Expanded(
                        flex: 1,
                        child: _mainData(),
                      )
                    ],
                  ),
                )
            )));
  }

  Widget _searchBar() {
    return Container(
      padding: EdgeInsets.only(bottom: 16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search Team Here...",
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (text) {
          _filterDogList(text);
        },
      ),
    );
  }

  Widget _mainData() {
    return Center(
      child: isLoading ?
      CircularProgressIndicator() :
      ListView.builder(
          itemCount: teamList?.length,
          itemBuilder: (context, index) {
            return ListTile(
                title: Text(teamList![index].name.toString())
            );
          }),
    );
  }

  _filterDogList(String text) {
    if (text.isNotEmpty) {
      final List<Teams> filteredBreeds = [];
      tempList?.map((breed) {
        if (breed.name!.contains(text.toString())) {
          filteredBreeds.add(breed);
        }
      }).toList();
      setState(() {
        teamList?.clear();
        teamList?.addAll(filteredBreeds);
      });
      return;
    }
    else {
      setState(() {
        teamList?.clear();
        teamList = tempList;
       // teamList?.addAll(tempList);
      });
    }
  }

  _fetchDogsBreed() async {
    setState(() {
      isLoading = true;
    });
    tempList = [];
    Map paramcountries = {
      "methodname": "getteam",
    };

    print(paramcountries);

    var token = await getToken();
    final response =
    await http.post(
        Uri.parse(ApiConstant.url + ApiConstant.Endpoint), body: paramcountries,
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        });

    if (response.statusCode == 200) {
      //  final jsonResponse = jsonDecode(response.body);
      //List<dynamic> responseJson=  json.decode(utf8.decode(response.bodyBytes));
      // jsonResponse['Teams'].forEach((team){
      // tempList.add(team);
      //});
      Map decoded = json.decode(response.body);

      final teamObj = teamFromJson(response.body);
      if (teamObj.teams!.isNotEmpty) {
        tempList = teamObj.teams;
        //  print(jsonResponse);
      }
      else {
        throw Exception("Failed to load Dogs Breeds.");
      }
      setState(() {
        teamList = tempList;
        isLoading = false;
      });
    }
  }
}
