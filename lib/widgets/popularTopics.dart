import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Localization/localization/language_constants.dart';
import '../constant.dart';

import '../responses/MenuByIdResponse.dart';

class AllPopularTopics extends StatefulWidget {
  const AllPopularTopics({Key? key}) : super(key: key);

  @override
  _AllPopularTopicsState createState() => _AllPopularTopicsState();
}

class _AllPopularTopicsState extends State<AllPopularTopics> {
  List<String> contents = ["C##", "Laravel", "Node Js", "Android"];
  List<Color> colors = [
    Colors.purple,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.redAccent
  ];
  bool isLoading = true;
  int _selectedIndex = 0;

  List<Menu> menu = [];

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accesstoken');
  }

  Future<String?> getlocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(LAGUAGE_CODE);
  }

  Future<List<dynamic>> loadSubMenu(String url) async {
    var locale = await getlocale();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    int? id = prefs.getInt('id');

    Map paramsubmenu = {"parent_id": id, "methodname": "getmenubyid"};

    print('$url , $paramsubmenu');

    var token = await getToken();

    final response =
        await http.post(Uri.parse(url), body: paramsubmenu, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    print(response);

    if (response.statusCode == 200) {
      //    data = json.decode(response.body);
      Map decoded = json.decode(response.body);
      print(decoded);

      for (var objMenu in decoded["menu"]) {
        if (kDebugMode) {
          print(objMenu['id']);
          print(objMenu['title'].toString());
          print(objMenu['locale']);
          print(objMenu['parent_id']);
          print(objMenu['isActive']);
          print(objMenu['Countryname']);
        }

        menu.add(objMenu['title']);
        menu.add(Menu(
            title: objMenu['title'].toString(),
            locale: objMenu['locale'],
            countryname: objMenu['Countryname'],
            id: objMenu['id'],
            isActive: objMenu['isActive'],
            parentId: objMenu['parent_id'],
            isSelected: false, Submenu: [], listiconpath: ''));

        setState(() {
          isLoading = false;
        });
      }
    }

    return menu;
  }

  @override
  void initState() {
    super.initState();
    print("initcalled");
    setState(() {
      loadSubMenu(ApiConstant.url + ApiConstant.Endpoint);
    });
  }

  // void loadTopics() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     int? selectedId = prefs.getInt('channelId');
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: menu.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.only(left: 20.0),
            height: 180,
            width: 170,
            decoration: BoxDecoration(
              color: colors[index],
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    menu[index].title,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2),
                  ),
                  SizedBox(height: 10),
                  // Text(
                  //   "30 posts",
                  //   style: TextStyle(
                  //       color: Colors.white, fontSize: 18, letterSpacing: .7),
                  // )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
