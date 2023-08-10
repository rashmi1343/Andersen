// To parse this JSON data, do
//
//     final notificationDataModel = notificationDataModelFromJson(jsonString);

import 'dart:convert';

NotificationModel notificationDataModelFromJson(String str) =>
    NotificationModel.fromJson(json.decode(str));

String notificationDataModelToJson(NotificationModel data) =>
    json.encode(data.toJson());

class NotificationModel {
  NotificationModel({
    required this.status,
    required this.notificationData,
  });

  int status;
  List<NotificationData> notificationData;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        status: json["status"],
        notificationData: List<NotificationData>.from(
            json["notification"].map((x) => NotificationData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "notification":
            List<dynamic>.from(notificationData.map((x) => x.toJson())),
      };
}

class NotificationData {
  NotificationData({
    required this.id,
    required this.msgtitle,
    required this.msgbody,
    required this.messageType,
  });

  int id;
  String msgtitle;
  String msgbody;
  int messageType;

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      NotificationData(
        id: json["id"],
        msgtitle: json["msgtitle"],
        msgbody: json["msgbody"],
        messageType: json["message_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "msgtitle": msgtitle,
        "msgbody": msgbody,
        "message_type": messageType,
      };
}
