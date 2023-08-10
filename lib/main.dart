
import 'package:andersonappnew/screens/NotificationsPage.dart';
import 'package:andersonappnew/screens/SplashScreen.dart';
import 'package:andersonappnew/widgets/GlobalVariable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';

import 'Localization/localization/demo_localization.dart';
import 'Localization/localization/language_constants.dart';
import 'Localization/router/custom_router.dart';
import 'Localization/router/route_constants.dart';


// @dart=2.9
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(MyApp()));
  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  //await Firebase.initializeApp();

  print(" background message: ${message.notification!.body}");
}

late AndroidNotificationChannel channel;

MaterialColor generateMaterialColorFromColor(Color color) {
  return MaterialColor(color.value, {
    50: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
    100: Color.fromRGBO(color.red, color.green, color.blue, 0.2),
    200: Color.fromRGBO(color.red, color.green, color.blue, 0.3),
    300: Color.fromRGBO(color.red, color.green, color.blue, 0.4),
    400: Color.fromRGBO(color.red, color.green, color.blue, 0.5),
    500: Color.fromRGBO(color.red, color.green, color.blue, 0.6),
    600: Color.fromRGBO(color.red, color.green, color.blue, 0.7),
    700: Color.fromRGBO(color.red, color.green, color.blue, 0.8),
    800: Color.fromRGBO(color.red, color.green, color.blue, 0.9),
    900: Color.fromRGBO(color.red, color.green, color.blue, 1.0),
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

// This widget is the root of your application.
class _MyAppState extends State<MyApp> {
  late final FirebaseMessaging _firebaseMessaging;

  // Locale? _locale;
  Locale _locale = const Locale('en');

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      print("click :" + notification!.android!.clickAction.toString());
    });
    // print("isnotify"+ Notificationtype.notificationcontent.toString());
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new messageopen app event was published');
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(GlobalVariable.navState.currentContext!)
            .push(MaterialPageRoute(builder: (context) => NotificationPage()));
      });
      // Navigator.of(context).pushNamed(notifyroute);
      // runApp(MaterialApp(home: NotificationPage(),
      //   onGenerateRoute: CustomRouter.generatedRoute,
      //     // routes: <String, WidgetBuilder> {
      //     //   '/homeMenuRoute': (BuildContext context) =>  HomeGridPage(),
      //     //   '/notifyRoute' : (BuildContext context) =>  NotificationPage(),
      //     //
      //     // },
      //   initialRoute: notifyRoute));
    });
  }

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    if (_locale == null) {
      return const Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 20, 110, 212))),
      );
    } else {
      return MaterialApp(
        //key: UniqueKey(),
        navigatorKey: GlobalVariable.navState,
        title: 'Anderson App',

        theme: ThemeData(
            primarySwatch: generateMaterialColorFromColor(Colors.black)),
        home: SplashScreenPage(),
        // routes: {
        //   "/homeMenuRoute": (_) =>  HomeGridPage(),
        // },
        // SplashScreen(
        //     seconds: 5,
        //     navigateAfterSeconds: CountriesNew(),
        //     //  title: const Text('Welcome In SplashScreen'),
        //     //   image: Image.network('https://i.imgur.com/TyCSG9A.png'),
        //     image: Image.asset('assets/images/logo.png'),
        //     backgroundColor: Colors.black,
        //     styleTextUnderTheLoader: const TextStyle(),
        //     photoSize: 100.0,
        //     onClick: () => debugPrint("Flutter Egypt"),
        //     loaderColor: Colors.red),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          DemoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: _locale,
        supportedLocales: const [
          Locale("en", "US"),
          Locale("ar", "SA"),
          //  Locale("fa", "IR"),
          // Locale("hi", "IN")
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode &&
                supportedLocale.countryCode == locale?.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        debugShowMaterialGrid: false,
        onGenerateRoute: CustomRouter.generatedRoute,
        initialRoute: splashroute,
      );
    }
  }
}

// void Gettokenfromapi(String url, Map jsonMap) async {
//   print('$url , $jsonMap');
//   /*HttpClient httpClient = new HttpClient();
//   HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
//   request.headers.set('Content-Type', 'application/json; charset=UTF-8');
//   request.add(utf8.encode(json.encode(jsonMap)));
//   HttpClientResponse response = await request.close();
//   String reply = await response.transform(utf8.decoder).join();
//   print(reply);
//
//   final parsedJson = jsonDecode(reply);
// // type: Restaurant
//   final authdata = GetToken.fromJson(parsedJson);
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//
//   prefs.setString('accesstoken', authdata.data!.token.toString());
//   print(authdata.data!.token.toString());
//   httpClient.close();*/
//   /* final client = HttpClient();
//   final request = await client.postUrl(Uri.parse(url));
//   request.headers
//       .set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
//   request.write(jsonMap);
//
//   final response = await request.close();
//
//   response.transform(utf8.decoder).listen((contents) {
//     print(contents);
//   });*/
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
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);
//
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//
//       _counter++;
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
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
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(
//          title: Text(widget.title),
//       ),
//       body: Center(
//          child: Column(
//            mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
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
//     data = json['data'] != null ? new Data.fromJson(json['data']) : null;
//     message = json['message'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['success'] = this.success;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     data['message'] = this.message;
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
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['token'] = this.token;
//     data['name'] = this.name;
//     return data;
//   }
// }
//
// class Constant {
//   static String url = "https://anderson.broadwayinfotech.net.au";
//
//   static void message() {
//     print('You are Calling Static Method');
//   }
// }
