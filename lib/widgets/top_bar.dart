import 'dart:ffi';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../Localization/localization/language_constants.dart';
import '../constant.dart';
import '../main.dart';
import '../responses/AllChannelResponse.dart';

class TopBar extends StatefulWidget {
  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  bool isLoading = true;
  final List<String> contents = [
    "Popular",
    "Recommended",
    "New Topic",
    "Latest",
    "Trending",
    "Open",
    "Close"
  ];
  int _selectedIndex = 0;
  List data = [];
  List<Channel> allChannels = [];

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accesstoken');
  }

  Future<String?> getlocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(LAGUAGE_CODE);
  }

  Future<List<dynamic>> getSWData(String url) async {
    var locale = await getlocale();
    Map paramchannel = {"methodname": "getAllchannel", "locale": locale};

    print('$url , $paramchannel');

    var token = await getToken();

    final response =
        await http.post(Uri.parse(url), body: paramchannel, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      //    data = json.decode(response.body);
      Map decoded = json.decode(response.body);

//data = decoded[''];
      for (var objchannel in decoded["allchannels"]) {
        if (kDebugMode) {
          print(objchannel['id'].toString());
          print(objchannel['title'].toString());
          print(objchannel['slug'].toString());
        }
        // data.add(objchannel['id'].toString());
        data.add(objchannel['title'].toString());
        allChannels.add(Channel(
            id: objchannel['id'],
            title: objchannel['title'],
            slug: objchannel['slug']));
        //  data.add(objchannel['slug'].toString());
        setState(() {
          isLoading = false;
        });
      }
    }

    return data;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      //  _incrementCounter();

      //encode Map to JSON

      getSWData(ApiConstant.url + ApiConstant.Endpoint);
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ?
        // ignore: prefer_const_constructors
        Center(child: CircularProgressIndicator())
        : Container(
            height: 90,
            padding: const EdgeInsets.only(top: 40, bottom: 15),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    //const AllPopularTopics();
                    setState(() async {
                      _selectedIndex = index;
                      print(allChannels[index].id);
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      prefs.setInt('channelId', allChannels[index].id);
                      //AllPopularTopics();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 20.0),
                    decoration: BoxDecoration(
                        color: _selectedIndex == index
                            ? Theme.of(context).primaryColor.withOpacity(0.25)
                            : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        data[index],
                        style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Helvetica',
                            color: _selectedIndex == index
                                ? Theme.of(context).primaryColor
                                : Colors.black38,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }
}

class channels {
  late int id;
  String? title;
  String? slug;

  channels(this.id, this.title, this.slug);

  channels.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['title'] = title;
    data['slug'] = slug;
    return data;
  }
}
