// To parse this JSON data, do
//
//     final unlikeReply = unlikeReplyParseJson(jsonString);

import 'dart:convert';

UnlikeReply unlikeReplyParseJson(String str) =>
    UnlikeReply.fromJson(json.decode(str));

String unlikeReplyToJson(UnlikeReply data) => json.encode(data.toJson());

class UnlikeReply {
  UnlikeReply({
    this.success,
    this.data,
    this.message,
  });

  final bool? success;
  final Data? data;
  final String? message;

  factory UnlikeReply.fromJson(Map<String, dynamic> json) => UnlikeReply(
        success: json["success"],
        data: Data.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
      };
}

class Data {
  Data({
    required this.status,
  });

  final int status;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
      };
}


/* To parse this JSON data, do
//
//     final unlike = unlikeFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

Unlike unlikeFromJson(String str) => Unlike.fromJson(json.decode(str));

String unlikeToJson(Unlike data) => json.encode(data.toJson());

class Unlike {
    Unlike({
        @required this.like,
    });

    final List<Like> like;

    factory Unlike.fromJson(Map<String, dynamic> json) => Unlike(
        like: List<Like>.from(json["like"].map((x) => Like.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "like": List<dynamic>.from(like.map((x) => x.toJson())),
    };
}

class Like {
    Like({
        @required this.id,
        @required this.replyId,
        @required this.userId,
        @required this.createdAt,
        @required this.updatedAt,
    });

    final int id;
    final int replyId;
    final int userId;
    final DateTime createdAt;
    final DateTime updatedAt;

    factory Like.fromJson(Map<String, dynamic> json) => Like(
        id: json["id"],
        replyId: json["reply_id"],
        userId: json["user_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "reply_id": replyId,
        "user_id": userId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
    };
}
 */