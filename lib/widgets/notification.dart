import 'dart:async';


import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../screens/NotificationsPage.dart';

Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.data.containsKey('data')) {
    // Handle data message
    final data = message.data['data'];
  }

  if (message.data.containsKey('notification')) {
    // Handle notification message
    final notification = message.data['notification'];
  }


  // Or do other work.
}

class FCM {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final streamCtlr = StreamController<String>.broadcast();
  final titleCtlr = StreamController<String>.broadcast();
  final bodyCtlr = StreamController<String>.broadcast();

  setNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print("body" + event.notification!.body.toString());
    });
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // do something




      print
        ('App open Message clicked!');
    }
    );
    FirebaseMessaging.onMessage.listen((message) async {
      print
        ('Message clicked!');
      if
      (
      message.data.containsKey('data')) {
// Handle data message
        streamCtlr.sink.add(message.data['data']);
      }
      if
      (
      message.data.containsKey('notification')) {
// Handle notification message
        streamCtlr.sink.add(message.data['notification']);
      }
// Or do other work.
      titleCtlr.sink.add(message.notification!.
      title!);
      bodyCtlr.sink.add(message.notification!.
      body!);

      print
        ("message123"
          +
          message.toString()
      );
    }
      ,
    );
// With this token you can test it easily on your phone
    final token =
    _firebaseMessaging.getToken().then((value) => print('Token: $value'));
  }

  dispose() {
    streamCtlr.close();
    bodyCtlr.close();
    titleCtlr.close();
  }
}