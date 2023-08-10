import 'package:flutter/material.dart';

class TechSupport extends StatefulWidget {
  _TechSupportState createState() => _TechSupportState();
}

class _TechSupportState extends State<TechSupport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(400), // Set this height
        child: Container(
          height: 173,
          width: 375,
          color: const Color(0xffFFFFFF),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    alignment: Alignment.centerRight,
                    height: 10.47,
                    width: 10.47,
                    child: const ImageIcon(
                      AssetImage("assets/images/cancel.png"),
                      color: Color(0xff8D0C18),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.white,
                margin: const EdgeInsets.only(left: 10),
                child: const Text(
                  'I Want ',
                  style: TextStyle(
                    fontFamily: 'HelveticaBold',
                    fontSize: 18,
                    color: Color(0xff8D0C18),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Container(
                    height: 45,
                    width: 335,
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: const Color(0xffffffff),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xffD0D3D4), width: 1.0),
                    ),
                    child: Container(
                      height: 45,
                      width: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xff8D0C18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const SizedBox(
                        height: 14.75,
                        width: 14.75,
                        child: ImageIcon(
                          AssetImage("assets/images/forward_arrow.png"),
                          color: Color(0xffffffff),
                          size: 14,
                    ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
