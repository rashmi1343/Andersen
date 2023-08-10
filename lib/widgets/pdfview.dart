

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../constant.dart';

class PdfViewPage extends StatefulWidget {
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  bool _isLoading = true;

  // late PDFDocument _pdf;
  //
  // void _loadFile() async {
  //   // Load the pdf file from the internet
  //   _pdf = await PDFDocument.fromURL(
  //       'https://www.clickdimensions.com/links/TestPDFfile.pdf');
  //
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }
  //
  // @override
  // void initState() {
  //   super.initState();
  //   _loadFile();
  // }

  late PdfViewerController _pdfViewerController;
  final GlobalKey<SfPdfViewerState> _pdfViewerStateKey = GlobalKey();

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("Back To Home Page");
    //  Navigator.pop(context);
    if (["homeMenuRoute"].contains(info.currentRoute(context))) return true;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    return WillPopScope(
      child: SafeArea(
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
          backgroundColor: Colors.white,
          // iconTheme: const IconThemeData(color: Color(0xff243444)),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  _pdfViewerStateKey.currentState!.openBookmarkView();
                },
                icon: const Icon(
                  Icons.bookmark,
                  color: Color(0xff8D0C18),
                  // color: Colors.black,
                )),
            IconButton(
                onPressed: () {
                  _pdfViewerController.nextPage();
                },
                icon: const Icon(
                  Icons.arrow_drop_down_circle,
                  color: Color(0xff8D0C18),
                  // color: Colors.black,
                )),
            IconButton(
                onPressed: () {
                  _pdfViewerController.zoomLevel = 1.25;
                },
                icon: const Icon(
                  Icons.zoom_in,
                  color: Color(0xff8D0C18),
                  // color: Colors.black,
                ))
          ],
        ),
        body: SfPdfViewer.network(
            //'http://www.africau.edu/images/default/sample.pdf',
            APIDATA.pdfUrl,
            controller: _pdfViewerController,
            key: _pdfViewerStateKey),
      )),
      onWillPop: () async {
        Navigator.of(context).pop();
        return true;
      },
    );
  }
}
