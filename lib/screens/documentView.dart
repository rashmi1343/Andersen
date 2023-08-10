import 'dart:async';
import 'dart:convert';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../ConnectionUtil.dart';
import '../Localization/localization/language_constants.dart';
import '../constant.dart';
import '../responses/DocumentResponse.dart';
import '../widgets/pdfview.dart';

import 'NewExpandwidget.dart';

// class DocumentView extends StatefulWidget {
//   const DocumentView({Key? key}) : super(key: key);

//   @override
//   _DocumentViewState createState() => _DocumentViewState();
// }

// class _DocumentViewState extends State<DocumentView> {
//   bool isLoading = true;
//   int _selectedIndex = 0;

//   List<Document> document = [];

//   String? selectedValue;

//   Future<String?> getToken() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('accesstoken');
//   }

//   Future<List<Document>> getDocumentData(String url) async {
//     Map paramdocument = {"methodname": "documentlist"};

//     print('$url , $paramdocument');

//     var token = await getToken();
//     print(token);

//     final response =
//         await http.post(Uri.parse(url), body: paramdocument, headers: {
//       'Accept': 'application/json',
//       'Authorization': 'Bearer $token',
//     });

//     print(response.body);

//     if (response.statusCode == 200) {
//       //    data = json.decode(response.body);
//       Map decoded = json.decode(response.body);

//       print(decoded);

//       for (var objDocument in decoded["document"]) {
//         if (kDebugMode) {
//           print(objDocument['id']);
//           print(objDocument['orig_filename']);
//           print(objDocument['mime_type']);
//           print(objDocument['filesize'].toString());
//           print(objDocument['content']);
//         }

//         document.add(Document(
//             content: objDocument['content'],
//             id: objDocument['id'],
//             mimeType: objDocument['mime_type'],
//             filesize: objDocument['filesize'],
//             origFilename: objDocument['orig_filename']));

//         setState(() {
//           isLoading = false;
//         });
//       }
//     }

//     return document;
//   }

//   @override
//   void initState() {
//     super.initState();
//     setState(() {
//       isLoading = true;
//       getDocumentData(ApiConstant.url + ApiConstant.Endpoint);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Select Files'),
//       ),
//       body: SafeArea(
//         child: isLoading
//             ?
//             // ignore: prefer_const_constructors
//             Center(child: CircularProgressIndicator())
//             : ListView.builder(
//                 itemCount: document.length,
//                 itemBuilder: (context, index) => Card(
//                   color: Color(0xffbe1229),
//                   elevation: 6,
//                   margin: EdgeInsets.all(10),
//                   child: ListTile(
//                     title: Text(
//                       document[index].origFilename,
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     trailing: Icon(Icons.file_copy),
//                     onTap: () {},
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }
// }

class DocumentView extends StatefulWidget {
  const DocumentView({Key? key}) : super(key: key);

  @override
  State<DocumentView> createState() => _DocumentViewState();
}

class _DocumentViewState extends State<DocumentView> {
  bool isLoading = true;
  int _selectedIndex = 0;

  List<Document> document = [];

  List<Document> docitems = [];
  List<Document> doctempitems = [];
  bool isPopupLoading = false;

  int perPage = 10;
  int present = 0;

  String? selectedDoc;
  StreamSubscription? connection;
  // List<Document> selectedDocument = [];
  List<String> selectedDocument = [];

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accesstoken');
  }

  featuredDocument(String docName) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString("featuredDocName", docName);
  }

  Future<String?> getlocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(LAGUAGE_CODE);
  }

  getSelectedFeaturedDoc() async {
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   String featuredDoc = documentResponseToJson(selectedDocument);
    //   pref.setString('selectedfeaturedDoc', featuredDoc);
    SharedPreferences pref = await SharedPreferences.getInstance();
    final List<dynamic> json =
        jsonDecode(pref.getString('selectedfeaturedDoc') ?? "");

    final list = json.map<List<Document>>((json) {
      return json.map<Document>(json).toList();
    });
  }

  // getSavedFeaturedDoc() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final rawJson = prefs.getString('selectedfeaturedDoc') ?? '';
  //   // DocumentResponse docData = documentResponseFromJson(rawJson);
  //   final menuObj = documentResponseFromJson(rawJson);
  //   print(menuObj);
  // }

  // void saveSelectedFeaturedDoc(List<String> document) async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   List<String> documentEncoded =
  //       document.map((person) => jsonEncode(person)).toList();
  //   await sharedPreferences.setStringList(
  //       'selectedfeaturedDoc', documentEncoded);
  // }

  void saveSelectedFeaturedDoc(List<String> data) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setStringList('selectedfeaturedDoc', data);
  }

  retrieveDocListValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> docList = prefs.getStringList("selectedfeaturedDoc") ?? [];
    // print(docList);
  }

// List<Document> _getdocument(List<Document> document) async {
//    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//    await sharedPreferences.setStringList('selectedfeaturedDoc', accounts);
//    return document.map((person) => Document.fromJson(document)).toList();
// }

  Future<List<Document>> getDocumentData(String url) async {
    var token = await getToken();
    print(token);

    var locale = await getlocale();
    Map paramdocument = {"methodname": "documentlistnew", "locale": locale};
    print('$url , $paramdocument');

    final response =
        await http.post(Uri.parse(url), body: paramdocument, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    print(response.body);
    document = [];
    docitems = [];

    doctempitems = [];

    if (response.statusCode == 200) {
      //    data = json.decode(response.body);
      Map decoded = json.decode(response.body);

      // print(decoded);

      for (var objDocument in decoded["document"]) {
        // if (kDebugMode) {
        //   print(objDocument['id']);
        //   print(objDocument['orig_filename']);
        //   print(objDocument['mime_type']);
        //   print(objDocument['filesize'].toString());
        //   print(objDocument['content']);
        // }

        document.add(Document(
            content: objDocument['content'],
            id: objDocument['id'],
            mimeType: objDocument['mime_type'],
            filesize: objDocument['filesize'],
            origFilename: objDocument['orig_filename'],
            createdAt: objDocument['created_at'],
            updatedAt: objDocument['updated_at'],
            documenttitle: objDocument['documenttitle'],
            isDeleted: objDocument['isDeleted'],
            isActive: objDocument['isActive'],
            value: false));
        setState(() {
          isLoading = false;
        });
      }
      if (document.length < perPage) {
        perPage = document.length;
      }
      docitems.addAll(document.getRange(present, present + perPage));
      present = present + perPage;
      //   }

      doctempitems = docitems;

      if (docitems.length == 0) {
        setState(() {
          isLoading = false;
        });
      } else if (document.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('no_feature_document'.tr),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something_went_wrong_please_try_again'.tr),
      ));
      throw Exception('Failed to load data');
    }

    return document;
  }

  void loadMore() {
    setState(() {
      if ((present + perPage) > document.length) {
        docitems.addAll(document.getRange(present, document.length));
      } else {
        docitems.addAll(document.getRange(present, present + perPage));
      }
      present = present + perPage;
    });
  }


  bool isdataconnection = false;

  var Internetstatus = "Unknown";

  @override
  void initState() {
    super.initState();
    ConnectionUtil connectionStatus = ConnectionUtil.getInstance();
    connectionStatus.initialize();
   connection= connectionStatus.connectionChange.listen(connectionChanged);
    // present = 10;
    if (APIDATA.arselecteddocument.isEmpty) {
      APIDATA.arselecteddocument = [];
    }

    BackButtonInterceptor.add(myInterceptor);
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isdataconnection = hasConnection;
      if (isdataconnection) {
        Internetstatus = "Connected To The Internet";
        isdataconnection = true;
        print('Data connection is available.');
        setState(() {
          isLoading = true;
          getDocumentData(ApiConstant.url + ApiConstant.Endpoint);
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
    BackButtonInterceptor.remove(myInterceptor);
    connection?.cancel();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("Back To Home Page");
    //  Navigator.pop(context);
    if (["homeMenuRoute"].contains(info.currentRoute(context))) return true;

    return false;
  }

  // List<String> selectedDoc = "";
  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('are_you_sure'.tr),
            content: Text('do_you'.tr),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('no'.tr),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('yes'.tr),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<String> showSelectedDoc() async {
    // String selectedNames =
    //     selectedDocument.map((item) => item.origFilename).toList().join(", ");
    var selectedNames = selectedDocument.join(',');
    return selectedNames;
  }

  // void _savedocument(List<Document> document) async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   List<String> documentEncoded =
  //       document.map((person) => jsonEncode(person.toJson())).toList();
  //   await sharedPreferences.setStringList(
  //       'selectedfeaturedDoc', documentEncoded);
  // }

  // List<Document> _getPersons() async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   Map<String, dynamic> userMap = {};
  //   final String? userStr = sharedPreferences.getString('selectedfeaturedDoc');
  //   if (userStr != null) {
  //     userMap = jsonDecode(userStr) as Map<String, dynamic>;
  //   }
  //   return Document.fromJson(userMap).toList();
  // }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    return isdataconnection
        ? WillPopScope(
            onWillPop: () {
              print('Backbutton pressed (device or appbar button)');
              //trigger leaving and use own data
              Navigator.pop(context, false);
              //we need to return a future
              return Future.value(false);
            },
            child: Scaffold(
                backgroundColor: Colors.white,
                resizeToAvoidBottomInset: false,
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
                      'featured_document'.tr,
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
                  // iconTheme: const IconThemeData(color: Color(0xff243444)),
                  actions: <Widget>[
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
                    // PopupMenuButton(
                    //     icon: const Icon(
                    //       Icons.more_vert_outlined,
                    //       color: Color(0xff243444), //0xff243444
                    //     ), //Icons.more_horiz_outlined,
                    //     onSelected: (selectedValue) {
                    //       if (selectedValue == 1) {
                    //         print(selectedValue);
                    //       }
                    //     },
                    //     itemBuilder: (BuildContext ctx) => [
                    //           //  PopupMenuItem(child: Text(' Choose Document '), value: '1'),
                    //           PopupMenuItem<String>(
                    //             value: "1",
                    //             child: ListTile(
                    //               leading: const Icon(Icons.file_copy_rounded,
                    //                   color: Color(0xff8e0c18)),
                    //               //     title: Text("choose_document".tr),
                    //               title: Text("categories".tr),
                    //               onTap: () {
                    //                 Navigator.pop(context, "1");
                    //                 //  Navigator.of(context).push(MaterialPageRoute(
                    //                 //     builder: (context) => const DocumentView()));
                    //                 Navigator.of(context).push(
                    //                     MaterialPageRoute(
                    //                         builder: (context) =>
                    //                             const NewExpandablewidget()));
                    //               },
                    //             ),
                    //           ),
                    //         ]),
                    // const SizedBox(
                    //   width: 10.0,
                    // ),
                    const SizedBox(
                      width: 10.0,
                    ),
                  ],
                ),
                body: Padding(
                    // padding: const EdgeInsets.symmetric(
                    //     horizontal: 5.0, vertical: 5.0),
                    padding: const EdgeInsets.all(5),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    const Padding(
                                        padding: EdgeInsets.all(10.0)),
                                    Text(
                                      'view_document'.tr,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Color(0xff243444),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Helvetica'),
                                    ),
                                    const SizedBox(height: 10.0),
                                    /*Text(
                    selectedDoc ?? "",
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Helvetica'),
                  )*/
                                    const SizedBox(height: 10.0),
                                    ListView.separated(
                                      physics: ScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: (present <= document.length)
                                          ? docitems.length + 1
                                          : docitems.length,
                                      itemBuilder: (context, index) {
                                        return (index == docitems.length)
                                            ? Container(
                                                margin:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                  color: COLORS
                                                      .APP_THEME_DARK_RED_COLOR,
                                                  style: BorderStyle.solid,
                                                  width: 1.0,
                                                )),
                                                child: TextButton(

                                                  child: docitems.isNotEmpty
                                                      ? Text(
                                                    'load_more'.tr,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                      fontFamily: 'Helvetica',
                                                    ),
                                                  )
                                                      : Text('no_doc_available'.tr),
                                                  onPressed: () {
                                                    setState(() {
                                                      if ((present + perPage) >
                                                          document.length) {
                                                        docitems.addAll(
                                                            document.getRange(
                                                                present,
                                                                document
                                                                    .length));
                                                      } else {
                                                        docitems.addAll(
                                                            document.getRange(
                                                                present,
                                                                present +
                                                                    perPage));
                                                      }
                                                      present =
                                                          present + perPage;
                                                    });
                                                  },
                                                ),
                                              )
                                            : ListTile(
                                                title: Text(
                                                  (docitems[index]
                                                              .documenttitle ??
                                                          "")
                                                      .inCaps,
                                                  // document[index].documenttitle ??
                                                  //     "",
                                                  style: const TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.w100,
                                                      fontFamily: 'Helvetica',
                                                      //color: Color.fromARGB(255, 251, 249, 249),
                                                      color: Color(0xff243444)),
                                                ),
                                                trailing: const Icon(
                                                  Icons.file_copy,
                                                  size: 18,
                                                  color: Color(0xff243444),
                                                ),
                                                onTap: () {
                                                  APIDATA.pdfUrl = ApiConstant
                                                          .pdfUrlEndpoint +
                                                      document[index]
                                                          .origFilename
                                                          .toString();
                                                  print(APIDATA.pdfUrl);
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              PdfViewPage()));
                                                });
                                      },
                                      separatorBuilder: (context, index) {
                                        return const Divider();
                                      },
                                    ),
                                    // Column(
                                    //   children: List.generate(
                                    //     document.length,
                                    //     (index) => Column(children: <Widget>[
                                    //       ListTile(
                                    //           title: Text(
                                    //             (document[index].documenttitle ??
                                    //                     "")
                                    //                 .inCaps,
                                    //             // document[index].documenttitle ??
                                    //             //     "",
                                    //             style: const TextStyle(
                                    //                 fontSize: 15.0,
                                    //                 fontWeight: FontWeight.w100,
                                    //                 fontFamily: 'Helvetica',
                                    //                 //color: Color.fromARGB(255, 251, 249, 249),
                                    //                 color: Color(0xff243444)),
                                    //           ),
                                    //           trailing: const Icon(
                                    //             Icons.file_copy,
                                    //             size: 18,
                                    //             color: Color(0xff243444),
                                    //           ),
                                    //           onTap: () {
                                    //             APIDATA.pdfUrl =
                                    //                 ApiConstant.pdfUrlEndpoint +
                                    //                     document[index]
                                    //                         .origFilename
                                    //                         .toString();
                                    //             print(APIDATA.pdfUrl);
                                    //             Navigator.of(context).push(
                                    //                 MaterialPageRoute(
                                    //                     builder: (context) =>
                                    //                         PdfViewPage()));
                                    //           }),
                                    //       const Divider(),
                                    //     ]),
                                    //     // CheckboxListTile(
                                    //     //   controlAffinity:
                                    //     //       ListTileControlAffinity.leading,
                                    //     //   contentPadding: EdgeInsets
                                    //     //       .zero, //EdgeInsets.symmetric(horizontal: 16.0).
                                    //     //   // checkColor:const Color(0xff243444),
                                    //     //   checkColor: Colors.white,
                                    //     //   activeColor: const Color(0xffAB0E1E),
                                    //     //   dense: false,
                                    //     //   title: Column(children: <Widget>[
                                    //     //     ListTile(
                                    //     //       title: Text(
                                    //     //         (document[index].documenttitle ??
                                    //     //                 "")
                                    //     //             .inCaps,
                                    //     //         // document[index].documenttitle ??
                                    //     //         //     "",
                                    //     //         style: const TextStyle(
                                    //     //             fontSize: 14.0,
                                    //     //             fontWeight: FontWeight.w100,
                                    //     //             fontFamily: 'Helvetica',
                                    //     //             //color: Color.fromARGB(255, 251, 249, 249),
                                    //     //             color: Color(0xff000000)),
                                    //     //       ),
                                    //     //       trailing:
                                    //     //           const Icon(Icons.file_copy),
                                    //     //     ),
                                    //     //     const Divider(),
                                    //     //   ]),
                                    //
                                    //     //   value: document[index].value,
                                    //     //   onChanged: (value) {
                                    //     // setState(() {
                                    //     // for (var element in document) {
                                    //     //   element.value = false;
                                    //     // }
                                    //     // for (var e in document) {
                                    //     //   if (e.origFilename.toString() ==
                                    //     //       document[index].toString()) {
                                    //     //     document[index].selectedDocument?.add(e);
                                    //     //     // print(_multiSelectLoc);
                                    //     //   }
                                    //     // }
                                    //     // document.removeWhere((e) =>
                                    //     //     e.origFilename.toString() ==
                                    //     //     document[index].selectedDocument?.toString());
                                    //     // setState(() {
                                    //     //   print(document[index].selectedDocument);
                                    //     // });
                                    //
                                    //     // ignore: iterable_contains_unrelated_type
                                    //     // storeDocData(index, value);
                                    //     // selected += document[index].origFilename;
                                    //
                                    //     // selectedDocument
                                    //     // featuredDocument(selected);
                                    //     // });
                                    //     //   },
                                    //     // ),
                                    //   ),
                                    // ),
                                    // Align(
                                    //   alignment: Alignment.bottomCenter,
                                    //   child: Padding(
                                    //       padding: const EdgeInsets.all(10),
                                    //       child: ElevatedButton(
                                    //         style: ElevatedButton.styleFrom(
                                    //             primary: const Color(0xffAB0E1E),
                                    //             padding:
                                    //                 const EdgeInsets.symmetric(
                                    //                     horizontal: 30,
                                    //                     vertical: 10),
                                    //             textStyle: const TextStyle(
                                    //                 fontSize: 15,
                                    //                 fontWeight: FontWeight.bold)),
                                    //         child: Text('submit'.tr,
                                    //             style: const TextStyle(
                                    //                 fontFamily: 'Helvetica')),
                                    //         onPressed: () {
                                    //           Navigator.of(context).push(
                                    //               MaterialPageRoute(
                                    //                   builder: (context) =>
                                    //                       HomeGridPage()));
                                    //         },
                                    //       )),
                                    // )
                                  ],
                                ),
                              ),
                            ),
                          ))))
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
                  Icon(Icons.signal_wifi_statusbar_connected_no_internet_4, size: 70, color: Color(0xffAB0E1E),),
                  SizedBox(height: 10,),
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
                  SizedBox(height: 10,),
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

  void storeDocData(int index, bool? value) async {
    if (selectedDocument.contains(document[index].origFilename) == false) {
      print(selectedDocument.contains(document[index].origFilename));

      selectedDocument.add(document[index].origFilename ?? "");
      APIDATA.arselecteddocument.add(document[index]);
      setState(() {});
    } else {
      selectedDocument
          .removeWhere((element) => element == document[index].origFilename);
      setState(() {});

      print('deselcet');
    }

    print(selectedDocument);

    document[index].value = value;

    selectedDoc = await showSelectedDoc();
    saveSelectedFeaturedDoc(selectedDocument);
    retrieveDocListValue();
  }

// void storeDocData(int index, bool? value) async {
//   if (selectedDocument.contains(document[index]) == false) {
//     print(selectedDocument.contains(document[index]));

//     selectedDocument.add(document[index].origFilename ?? "");
//     setState(() {});
//   } else {
//     selectedDocument.removeWhere((element) => element == document[index]);
//     setState(() {});

//     print('deselcet');
//   }

//   print(selectedDocument);

//   document[index].value = value;

//   selectedDoc = await showSelectedDoc();
//   saveSelectedFeaturedDoc(selectedDocument);
//   retrieveDocListValue();
//   // getSelectedFeaturedDoc();
//   // getSavedFeaturedDoc();
// }
}
