import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NoDataFoundWidget extends StatefulWidget {
  const NoDataFoundWidget({Key? key}) : super(key: key);

  @override
  _NoDataFoundWidgetState createState() => _NoDataFoundWidgetState();
}

class _NoDataFoundWidgetState extends State<NoDataFoundWidget> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child:
          Column(
        children: [
          const SizedBox(
            height: 64,
          ),
          Image.asset(
            'assets/images/submenuicon/nodatafound.png',
            height: 201.33,
            width: 253.99,
          ),
          SizedBox(
            height: 14.67,
          ),
          Text(
            'ooops'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 38,
              fontFamily: 'HelveticaBold',
              color: Color(0xFF8D0C18),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'we_couldn\'t_publish_content'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                fontFamily: 'Helvetica',
                color: Color(0xff76848F)),
          ),
          // Text(
          //   "couldn't publish content",
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //       fontSize: 14,
          //       fontFamily: 'Helvetica',
          //       color: Color(0xff76848F)),
          // ),
        ],
      )),
    );
  }
}
