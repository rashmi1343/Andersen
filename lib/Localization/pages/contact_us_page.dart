import 'dart:async';
import 'dart:convert';

import 'package:andersonappnew/Localization/localization/language_constants.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:get/get_utils/get_utils.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../ConnectionUtil.dart';
import '../../constant.dart';
import '../../responses/ContactUsResponse.dart';
import 'package:translator/translator.dart';

import '../../responses/EventsResponse.dart';

class ContactUsPage extends StatefulWidget {
  final Event eventData;

  const ContactUsPage({Key? key, required this.eventData}) : super(key: key);

  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  GoogleTranslator translator = GoogleTranslator();
  var output;
  String translated = 'Translation';

  // String dropdownValue;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>(); //key for form
  bool _autoValidate = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  bool isRTL = false;

  late String name;
  late String message;
  late String email;
  late String phone;
  late String subject;
  bool isLoading = false;
  final maxLines = 5;
  List<Contactus> arrcontactus = [];
  String? selectedValue;

  String selectdeventdatetime = '';

  List<Event> arrevents = [];
  bool submitButtonIsEnabled = true;

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accesstoken');
  }

  Future<List<Contactus>> getContactUsData(String url) async {
    //  SharedPreferences prefs = await SharedPreferences.getInstance();
    //  int? eventid = prefs.getInt('eventId');
    //  String? eventname = prefs.getString('eventName');

    Map paramdocument = {
      "methodname": "contactus",
      "name": nameController.text,
      "email": emailController.text,
      "phone": phoneController.text,
      "subject": subjectController.text,
      "message": messageController.text,
      "event_id": widget.eventData.id.toString(),
      //  "event_date ": widget.eventData.date.toString(),
      "event_name": widget.eventData.eventName
    };

    print('$url , $paramdocument');

    var token = await getToken();
    print(token);

    final response =
        await http.post(Uri.parse(url), body: paramdocument, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    print(response.body);

    if (response.statusCode == 200) {
      Map decoded = json.decode(response.body);

      print(decoded);

      for (var objContactUs in decoded["contactus"]) {
        if (kDebugMode) {
          print(objContactUs['id']);
          print(objContactUs['name']);
          print(objContactUs['email']);
          print(objContactUs['phone'].toString());
          print(objContactUs['subject']);
          print(objContactUs['message']);
          print(objContactUs['event_name']);
          print(objContactUs['event_id'].toString());
        }

        arrcontactus.add(Contactus(
            name: objContactUs['name'],
            message: objContactUs['message'],
            phone: objContactUs['phone'],
            email: objContactUs['email'],
            id: objContactUs['id'],
            subject: objContactUs['subject'],
            eventId: objContactUs['event_id'],
            eventName: objContactUs['event_name']));

        setState(() {
          isLoading = false;
          submitButtonIsEnabled = true;
        });
      }
      if (arrcontactus.length > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("representative".tr),
          ),
        );
        nameController.clear();
        phoneController.clear();
        emailController.clear();
        subjectController.clear();
        messageController.clear();
        myFocusNode.requestFocus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("something_went_wrong".tr),
          ),
        );
      }
    }

    // Navigator.of(context)
    //     .push(MaterialPageRoute(builder: (context) => HomeGridPage()));
    return arrcontactus;
  }

  static const Map<String, String> lang = {"English": "en", "Arabic": "ar"};

  Future<String?> getlocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(LAGUAGE_CODE);
  }

  void subjecttranslateLang() {
    translator
        .translate(subjectController.text, to: 'ar', from: 'en')
        .then((result) {
      setState(() {
        subjectController.text = result.toString();
      });
    });
  }

  void messagetranslateLang() {
    translator
        .translate(messageController.text, to: 'ar', from: 'en')
        .then((result) {
      setState(() {
        messageController.text = result.toString();
      });
    });
  }

  StreamSubscription? connection;
  bool isdataconnection = false;

  var Internetstatus = "Unknown";
  late FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    ConnectionUtil connectionStatus = ConnectionUtil.getInstance();
    connectionStatus.initialize();
    connection = connectionStatus.connectionChange.listen(connectionChanged);

    myFocusNode = FocusNode();
    //BackButtonInterceptor.add(myInterceptor);
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isdataconnection = hasConnection;
      if (isdataconnection) {
        Internetstatus = "Connected To The Internet";
        isdataconnection = true;
        print('Data connection is available.');
        setState(() {
          // getContactUsData(ApiConstant.url + ApiConstant.allChannelEndpoint);
          // getEventsData(ApiConstant.url + ApiConstant.Endpoint);
        });
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
    //  BackButtonInterceptor.remove(myInterceptor);
    connection?.cancel();
    myFocusNode.dispose();

    super.dispose();
  }

  // bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
  //   Navigator.push(
  //       context, MaterialPageRoute(builder: (context) => EventPage()));
  //
  //   print("Back To Event Page");
  //   return true;
  // }

  // String? _chosenValue;

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
                    icon: Image.asset(
                      'assets/images/backarrow.png',
                      color: Color(0xff8D0C18),
                    ),
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
                    'contact_us'.tr,
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
                //  iconTheme: const IconThemeData(color: Color(0xff243444)),
                /*actions: <Widget>[
             Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Icon(
                    color: Colors.black87,
                    Icons.search,
                    size: 26.0,
                  ),
                )),
          ],*/
              ),
              body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    widget.eventData.eventName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xffAB0E1E),
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'HelveticaBold',
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    widget.eventData.description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: COLORS.APP_THEME_DARK_GRAY_COLOR,
                                      fontWeight: FontWeight.normal,
                                      height: 1.3,
                                      fontFamily: 'Helvetica',
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    widget.eventData.date,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: COLORS.APP_THEME_DARK_GRAY_COLOR,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Helvetica',
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: TextFormField(
                                focusNode: myFocusNode,
                                onChanged: (val) async {
                                  // final translation= await val.translate(from: 'en',to: 'ar');
                                  // setState((){
                                  //   translated=translation.text;
                                  //
                                  // });
                                  // var locale = await getlocale();
                                  //
                                  // if (locale == 'ar') {
                                  //   translator
                                  //       .translate(nameController.text, to: 'ar', from: 'en')
                                  //       .then((result) {
                                  //     setState(() {
                                  //       nameController.text = result.toString();
                                  //     });
                                  //   });
                                  // }

                                  if (val != null || val.length > 0) name = val;
                                  // print(name);
                                },

                                controller: nameController,
                                keyboardType: TextInputType.text,
                                // onTap: () {
                                //   trans();
                                // },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'this_field_is_required'.tr;
                                  }
                                  if (value.trim().length < 4) {
                                    return 'username_must_be_length'.tr;
                                  }
                                  // Return null if the entered username is valid
                                  return null;
                                },

                                decoration: InputDecoration(
                                  fillColor: const Color(0xffe6e6e6),
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 20),
                                  hintText: 'your_name'.tr,
                                  hintStyle: const TextStyle(
                                      color: Colors.blueGrey,
                                      fontFamily: 'Helvetica'),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.0001,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: TextFormField(
                                onChanged: (val) {
                                  if (val != null || val.length > 0)
                                    phone = val;
                                },
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                //maxLength: 10,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(10),

                                  /// here char limit is 5
                                ],
                                //obscureText: true,
                                validator: (value) {
                                  if (value!.isEmpty ||
                                      !RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$')
                                          // !RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$')
                                          .hasMatch(value)) {
                                    //  r'^[0-9]{10}$' pattern plain match number with length 10
                                    // return 'mobile_number_is_required'.tr;
                                    return 'this_field_is_required'.tr;
                                  }
                                  // else if (value.length != 10) {
                                  //   return "mobile_number_10_digits".tr;
                                  // }
                                  else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  fillColor: const Color(0xffe6e6e6),
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 20),
                                  hintText: 'mobile_no'.tr,
                                  hintStyle: const TextStyle(
                                      color: Colors.blueGrey,
                                      fontFamily: 'Helvetica'),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.0001,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: TextFormField(
                                onChanged: (val) {
                                  if (val != null || val.length > 0)
                                    email = val;
                                },
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  // Check if this field is empty
                                  if (value == null || value.isEmpty) {
                                    return 'this_field_is_required'.tr;
                                  }

                                  // using regular expression
                                  if (!RegExp(r'\S+@\S+\.\S+')
                                      .hasMatch(value)) {
                                    return "please_enter_a_valid_email_address"
                                        .tr;
                                  }

                                  // the email is valid
                                  return null;
                                },
                                decoration: InputDecoration(
                                  fillColor: const Color(0xffe6e6e6),
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 20),
                                  hintText: 'email_id'.tr,
                                  hintStyle: const TextStyle(
                                      color: Colors.blueGrey,
                                      fontFamily: 'Helvetica'),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.0001,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: TextFormField(
                                onChanged: (val) async {
                                  // var locale = await getlocale();
                                  // if (locale == 'ar') {
                                  //   translator
                                  //       .translate(subjectController.text,
                                  //           to: 'ar', from: 'en')
                                  //       .then((result) {
                                  //     setState(() {
                                  //       subjectController.text = result.toString();
                                  //     });
                                  //   });
                                  // }
                                  if (val != null || val.length > 0)
                                    subject = val;
                                },
                                controller: subjectController,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value!.isEmpty ||
                                      !RegExp(r'^[a-z A-Z]+$')
                                          .hasMatch(value)) {
                                    //allow upper and lower case alphabets and space
                                    return 'this_field_is_required'.tr;
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  fillColor: const Color(0xffe6e6e6),
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 20),
                                  hintText: 'subject'.tr,
                                  hintStyle: const TextStyle(
                                      color: Colors.blueGrey,
                                      fontFamily: 'Helvetica'),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.0001,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: TextFormField(
                                onChanged: (val) async {
                                  // var locale = await getlocale();
                                  // if (locale == 'ar') {
                                  //   translator
                                  //       .translate(messageController.text,
                                  //           to: 'ar', from: 'en')
                                  //       .then((result) {
                                  //     setState(() {
                                  //       subjectController.text = result.toString();
                                  //     });
                                  //   });
                                  // }
                                  if (val != null || val.length > 0)
                                    subject = val;
                                },
                                controller: messageController,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                validator: ((value) {
                                  if (value!.isEmpty) {
                                    // return 'message_is_required'.tr;
                                    return 'this_field_is_required'.tr;
                                  }
                                  return null;
                                }),
                                // validator: (value) {
                                //   if (value!.isEmpty ||
                                //       !RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
                                //     //allow upper and lower case alphabets and space
                                //     return 'this_field_is_required'.tr;
                                //   } else {
                                //     return null;
                                //   }
                                // },
                                decoration: InputDecoration(
                                  fillColor: const Color(0xffe6e6e6),
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 20),
                                  hintText: 'your_message'.tr,
                                  hintStyle: const TextStyle(
                                      color: Colors.blueGrey,
                                      fontFamily: 'Helvetica'),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.0001,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14.0, horizontal: 13),
                              child: Text(
                                'hear_from_you'.tr,
                                style: const TextStyle(
                                  fontSize: 17.5,
                                  height: 1.3,
                                  fontFamily: 'HelveticaNueueBold',
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.0001,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: Center(
                                child: Container(
                                  height: 70,
                                  width: MediaQuery.of(context).size.width,
                                  alignment: Alignment.center,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: const Color(0xffbe1229),
                                        // shape: const StadiumBorder(),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 10),
                                        textStyle: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    onPressed: () {
                                      submitButtonIsEnabled
                                          ? submitApiCall()
                                          : null;
                                      // submitApiCall();
                                    },
                                    child: (isLoading)
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ))
                                        : Text('submit'.tr),
                                  ),
                                ),
                              ),
                              // ElevatedButton(
                              //   style: ElevatedButton.styleFrom(
                              //       primary: const Color(0xffbe1229),
                              //       padding: const EdgeInsets.symmetric(
                              //           horizontal: 30, vertical: 10),
                              //       textStyle: const TextStyle(
                              //           fontSize: 15,
                              //           fontWeight: FontWeight.bold)),
                              //   child: Text('submit'.tr,
                              //       style:
                              //           const TextStyle(fontFamily: 'Helvetica')),
                              //   onPressed: () {
                              //     final bool? isValid =
                              //         _formKey.currentState?.validate();

                              //     if (isValid == true) {
                              //       setState(() {
                              //         isLoading = true;
                              //       });
                              //       getContactUsData(
                              //           ApiConstant.url + ApiConstant.Endpoint);
                              //     } else {
                              //       print("something_is_wrong".tr);
                              //     }
                              //   },
                              // ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Container(
              //   height: 1000,
              //   padding: EdgeInsets.all(20),
              //   child: Form(
              //     key: formKey,
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       children: <Widget>[
              //         Text(
              //           'Contact Us',
              //           textAlign: TextAlign.center,
              //           style: TextStyle(fontSize: 15, fontFamily: 'HelveticaBold'),
              //         ),
              //         SizedBox(
              //           height: 5,
              //         ),
              //         TextFormField(
              //           controller: nameController,
              //           decoration: const InputDecoration(
              //             labelText: 'Name',
              //             icon: Icon(Icons.account_box),
              //           ),
              //           keyboardType: TextInputType.text,
              //           validator: (value) {
              //             if (value!.isEmpty ||
              //                 !RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
              //               //allow upper and lower case alphabets and space
              //               return "Enter Correct Name";
              //             } else {
              //               return null;
              //             }
              //           },
              //         ),
              //         SizedBox(
              //           height: 5,
              //         ),
              //         TextFormField(
              //           controller: phoneController,
              //           decoration: const InputDecoration(
              //             labelText: 'Mobile No',
              //             icon: Icon(Icons.phone),
              //           ),
              //           keyboardType: TextInputType.text,
              //           obscureText: true,
              //           validator: (value) {
              //             if (value!.isEmpty ||
              //                 !RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$')
              //                     .hasMatch(value)) {
              //               //  r'^[0-9]{10}$' pattern plain match number with length 10
              //               return "Enter Correct Phone Number";
              //             } else {
              //               return null;
              //             }
              //           },
              //         ),
              //         SizedBox(
              //           height: 5,
              //         ),
              //         TextFormField(
              //           controller: emailController,
              //           decoration: const InputDecoration(
              //             labelText: 'Email',
              //             icon: Icon(Icons.email),
              //           ),
              //           keyboardType: TextInputType.emailAddress,
              //           validator: (value) {
              //             // Check if this field is empty
              //             if (value == null || value.isEmpty) {
              //               return 'This field is required';
              //             }
              //
              //             // using regular expression
              //             if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
              //               return "Please enter a valid email address";
              //             }
              //
              //             // the email is valid
              //             return null;
              //           },
              //         ),
              //         SizedBox(
              //           height: 5,
              //         ),
              //         TextFormField(
              //           controller: subjectController,
              //           decoration: const InputDecoration(
              //             labelText: 'Subject',
              //             icon: Icon(Icons.subject),
              //           ),
              //           keyboardType: TextInputType.text,
              //         ),
              //         SizedBox(
              //           height: 5,
              //         ),
              //         TextFormField(
              //           controller: messageController,
              //           decoration: const InputDecoration(
              //             labelText: 'Message',
              //             icon: Icon(Icons.message),
              //           ),
              //           keyboardType: TextInputType.text,
              //         ),
              //         SizedBox(
              //           height: 10,
              //         ),
              //         ElevatedButton(
              //             onPressed: () {
              //               if (formKey.currentState!.validate()) {
              //                 formKey.currentState!.save();
              //                 //check if form data are valid,
              //                 // your process task ahed if all data are valid
              //               }
              //             },
              //             child: Text("Submit"))
              //       ],
              //     ),
              //   ),
              // ),
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
                    ))),
          );
  }

  void submitApiCall() {
    final bool? isValid = _formKey.currentState?.validate();
    if (isValid == true) {
      setState(() {
        isLoading = true;
      });
      getContactUsData(ApiConstant.url + ApiConstant.Endpoint);
      setState(() {
        submitButtonIsEnabled = false;
      });
    } else {
      print("something_is_wrong".tr);
    }
  }

  String getEventTime(String? chosenValue) {
    late String eventdatetime;

    for (var objdatetimeEvent in arrevents) {
      if (objdatetimeEvent.eventName == chosenValue) {
        eventdatetime = objdatetimeEvent.date;
        break;
      }
    }

    return eventdatetime;
  }
}
