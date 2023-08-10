import 'dart:async';
import 'dart:convert';

import 'package:andersonappnew/constant.dart';
import 'package:andersonappnew/screens/SplashScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'countriesnew.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({Key? key}) : super(key: key);

  @override
  GetStartedPageState createState() => GetStartedPageState();
}

class GetStartedPageState extends State<GetStartedPage> {

 //
  @override
  void initState() { 
    super.initState();
  //  getcountfornotification();
   //
  }


 /* @override
  void dispose() {
   // timer?.cancel();
    super.dispose();
  }*/


  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accesstoken');
  }





  @override
  Widget build(BuildContext context) {   
    final screenSize = MediaQuery.of(context).size;

    return
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(0),
        //decoration: const BoxDecoration(color: Color(0xffD0D3D4)),
        child: SingleChildScrollView(
            // alignment: Alignment.center,
            scrollDirection: Axis.vertical,
            child: Container(
              height: screenSize.height,
              padding: const EdgeInsets.all(0),
              color: Colors.white, //Color(0xffffffff),
              child:
                  Stack(alignment: Alignment.bottomCenter, children: <Widget>[
                Center(
                  child: Image.asset(
                    'assets/images/Info.png',
                    width: screenSize.width,
                    height: screenSize.height,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 80),
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xffAB0E1E)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      side: const BorderSide(
                                          color: Color(0xffbe1229))))),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CountriesNew(
                                    isComingFromSideMenu: false)));
                      },
                      child: const Text(
                        'GET STARTED',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'HelveticaBold'),
                      ),
                    ),
                  ),
                ),
              ]),
            )));
  }
}
