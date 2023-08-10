// import 'dart:convert';
//
//
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// // ignore: import_of_legacy_library_into_null_safe
// import 'package:themify_flutter/themify_flutter.dart';
//
// import '../Localization/classes/language.dart';
// import '../Localization/localization/language_constants.dart';
// import '../Localization/router/route_constants.dart';
// import '../main.dart';
// import '../widgets/posts.dart';
// import '../widgets/top_bar.dart';
//
// class HomePage extends StatefulWidget {
//   HomePage({Key? key}) : super(key: key);
//
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// // ignore: non_constant_identifier_names
// void Gettokenfromapi(String url, Map jsonMap) async {
//   print('$url , $jsonMap');
//
//   final response = await http.post(Uri.parse(url), body: jsonMap, headers: {
//     'Accept': 'application/json',
//   });
//
//   if (response.statusCode == 200) {
//     String token = response.body;
//     print(token);
//     final parsedJson = jsonDecode(token);
//
//     final authdata = GetToken.fromJson(parsedJson);
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     prefs.setString('accesstoken', authdata.data!.token.toString());
//     print(authdata.data!.token.toString());
//   }
// }
//
// class Constant {
//   static String url = "https://anderson.broadwayinfotech.net.au";
// }
//
// class GetToken {
//   bool? success;
//   Data? data;
//   String? message;
//
//   GetToken({this.success, this.data, this.message});
//
//   GetToken.fromJson(Map<String, dynamic> json) {
//     success = json['success'];
//     data = json['data'] != null ? Data.fromJson(json['data']) : null;
//     message = json['message'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['success'] = success;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     data['message'] = message;
//     return data;
//   }
// }
//
// class Data {
//   String? token;
//   String? name;
//
//   Data({this.token, this.name});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     token = json['token'];
//     name = json['name'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['token'] = token;
//     data['name'] = name;
//     return data;
//   }
// }
//
// class _HomePageState extends State<HomePage> {
//   @override
//   void initState() {
//     super.initState();
//     print("init called");
//     setState(() {
//       //  _incrementCounter();
//       Map data = {
//         'email': 'vivek.chandra@broadwayinfotech.com',
//         'password': 'test@123'
//       };
//       //encode Map to JSON
//
//       Gettokenfromapi(Constant.url + "/public/api/login", data);
//     });
//   }
//
//   final GlobalKey<FormState> _key = GlobalKey<FormState>();
//
//   void _changeLanguage(Language language) async {
//     Locale _locale = await setLocale(language.languageCode);
//     MyApp.setLocale(context, _locale);
//   }
//
//   void _showSuccessDialog() {
//     showTimePicker(context: context, initialTime: TimeOfDay.now());
//   }
//
//   final List<String> items = [
//     'Pdf',
//     'Document',
//     'Video',
//   ];
//   String? selectedValue;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).primaryColor,
//       appBar: AppBar(
//         title: Text(getTranslated(context, 'home_page') ?? ""),
//         actions: <Widget>[
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: DropdownButton<Language>(
//               underline: const SizedBox(),
//               // ignore: prefer_const_constructors
//               icon: Icon(
//                 Icons.language,
//                 color: Colors.white,
//               ),
//               onChanged: (Language? language) {
//                 _changeLanguage(language!);
//               },
//               items: Language.languageList()
//                   .map<DropdownMenuItem<Language>>(
//                     (e) => DropdownMenuItem<Language>(
//                       value: e,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: <Widget>[
//                           Text(
//                             e.flag,
//                             style: const TextStyle(fontSize: 30),
//                           ),
//                           Text(e.name)
//                         ],
//                       ),
//                     ),
//                   )
//                   .toList(),
//             ),
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: _drawerList(),
//       ),
//       body: SafeArea(
//           child: ListView(
//         children: <Widget>[
//           Container(
//             height: 210,
//             width: MediaQuery.of(context).size.width,
//             decoration: BoxDecoration(color: Theme.of(context).primaryColor),
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   // const Text(
//                   //   "Choose following feature",
//                   //   style: TextStyle(
//                   //       color: Colors.white,
//                   //       fontSize: 12,
//                   //       fontStyle: FontStyle.italic),
//                   // ),
//                   Center(
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton2(
//                         isExpanded: true,
//                         hint: Row(
//                           children: const [
//                             Icon(
//                               Icons.list,
//                               size: 16,
//                               color: Colors.white,
//                             ),
//                             SizedBox(
//                               width: 4,
//                             ),
//                             Expanded(
//                               child: Text(
//                                 'Choose Following feature',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                         items: items
//                             .map((item) => DropdownMenuItem<String>(
//                                   value: item,
//                                   child: Text(
//                                     item,
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ))
//                             .toList(),
//                         value: selectedValue,
//                         onChanged: (value) {
//                           setState(() {
//                             selectedValue = value as String;
//                             // Navigator.push(
//                             //   context,
//                             //   MaterialPageRoute(
//                             //     builder: (context) => PdfView(),
//                             //   ),
//                             // );
//                           });
//                         },
//                         icon: const Icon(
//                           Icons.arrow_forward_ios_outlined,
//                         ),
//                         iconSize: 14,
//                         iconEnabledColor: Colors.white,
//                         iconDisabledColor: Colors.grey,
//                         buttonHeight: 50,
//                         buttonWidth: 160,
//                         buttonPadding:
//                             const EdgeInsets.only(left: 14, right: 14),
//                         buttonDecoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(14),
//                           border: Border.all(
//                             color: Colors.black26,
//                           ),
//                           color: const Color(0xFF333366),
//                         ),
//                         buttonElevation: 2,
//                         itemHeight: 40,
//                         itemPadding: const EdgeInsets.only(left: 14, right: 14),
//                         dropdownMaxHeight: 200,
//                         dropdownWidth: 200,
//                         dropdownPadding: null,
//                         dropdownDecoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(14),
//                           color: const Color(0xFF333366),
//                         ),
//                         dropdownElevation: 8,
//                         scrollbarRadius: const Radius.circular(40),
//                         scrollbarThickness: 6,
//                         scrollbarAlwaysShow: true,
//                         offset: const Offset(-20, 0),
//                       ),
//                     ),
//                   ),
//
//                   // Row(
//                   //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   //   children: [
//                   //     PdfPageBody(),
//                   //     DocumentPageBody(),
//                   //     VideoPageBody(),
//                   //   ],
//                   // ),
//                   Text(
//                     // "Sra, Forum",
//                     getTranslated(context, 'personal_information') ?? "",
//                     style: const TextStyle(
//                         fontSize: 20,
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                         fontFamily: 'Helvetica'),
//                   ),
//                   const SizedBox(height: 8.0),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: <Widget>[
//                       Text(
//                         // "Find Topics you like to read",
//                         getTranslated(context, 'find_topic') ?? "",
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.6),
//                           fontSize: 14.0,
//                           fontFamily: 'Helvetica',
//                         ),
//                       ),
//                       const Icon(
//                         Themify.search,
//                         size: 20,
//                         color: Colors.white,
//                       )
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),
//           Container(
//               decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(35.0),
//                       topRight: Radius.circular(35.0))),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   TopBar(),
//                   const Padding(
//                     padding: EdgeInsets.all(20.0),
//                     child: Text(
//                       "Popular Topics",
//                       style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           fontFamily: 'HelveticaBold',
//                           color: Colors.black),
//                     ),
//                   ),
//                   // AllPopularTopics(),
//                   const Padding(
//                     padding:
//                         EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
//                     child: Text(
//                       "Trending Posts",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         fontFamily: 'HelveticaBold',
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                   Posts()
//                 ],
//               ))
//         ],
//       )),
//     );
//   }
//
//   Container _drawerList() {
//     TextStyle _textStyle = const TextStyle(
//       color: Colors.white,
//       fontSize: 24,
//     );
//     return Container(
//       color: Theme.of(context).primaryColor,
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: <Widget>[
//           DrawerHeader(
//             child: Container(
//               height: 100,
//               child: const CircleAvatar(),
//             ),
//           ),
//           ListTile(
//             leading: const Icon(
//               Icons.info,
//               color: Colors.white,
//               size: 30,
//             ),
//             title: Text(
//               getTranslated(context, 'about_us') ?? "",
//               style: _textStyle,
//             ),
//             onTap: () {
//               // To close the Drawer
//               Navigator.pop(context);
//               // Navigating to About Page
//               Navigator.pushNamed(context, aboutRoute);
//             },
//           ),
//           ListTile(
//             leading: const Icon(
//               Icons.settings,
//               color: Colors.white,
//               size: 30,
//             ),
//             title: Text(
//               getTranslated(context, 'settings') ?? "",
//               style: _textStyle,
//             ),
//             onTap: () {
//               // To close the Drawer
//               Navigator.pop(context);
//               // Navigating to About Page
//               Navigator.pushNamed(context, settingsRoute);
//             },
//           ),
//           ListTile(
//             leading: const Icon(
//               Icons.contact_page,
//               color: Colors.white,
//               size: 30,
//             ),
//             title:
//                 // Text(
//                 //   "Contact Us",
//                 //   style: TextStyle(color: Colors.white, fontSize: 24),
//                 // ),
//                 Text(
//               getTranslated(context, 'contact_us') ?? "",
//               style: _textStyle,
//             ),
//             onTap: () {
//               // To close the Drawer
//               Navigator.pop(context);
//               // Navigating to About Page
//               Navigator.pushNamed(context, contactUsRoute);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
