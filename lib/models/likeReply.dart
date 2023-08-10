// // To parse this JSON data, do
// //
// //     final likeReply = likeReplyFromJson(jsonString);

// import 'dart:convert';

// LikeReply likeReplyFromJson(String str) => LikeReply.fromJson(json.decode(str));

// String likeReplyToJson(LikeReply data) => json.encode(data.toJson());

// class LikeReply {
//   LikeReply({
//     required this.like,
//   });

//   final List<Like> like;

//   factory LikeReply.fromJson(Map<String, dynamic> json) => LikeReply(
//         like: List<Like>.from(json["like"].map((x) => Like.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "like": List<dynamic>.from(like.map((x) => x.toJson())),
//       };
// }

// class Like {
//   Like({
//     required this.id,
//     required this.replyId,
//     required this.userId,
//     this.createdAt,
//     this.updatedAt,
//   });

//   final int id;
//   final int replyId;
//   final int userId;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;

//   factory Like.fromJson(Map<String, dynamic> json) => Like(
//         id: json["id"],
//         replyId: json["reply_id"],
//         userId: json["user_id"],
//         createdAt: DateTime.parse(json["created_at"]),
//         updatedAt: DateTime.parse(json["updated_at"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "reply_id": replyId,
//         "user_id": userId,
//         "created_at": createdAt?.toIso8601String() ?? "",
//         "updated_at": updatedAt?.toIso8601String() ?? "",
//       };
// }

// To parse this JSON data, do
//
//     final like = likeReplyFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

Like likeReplyFromJson(String str) => Like.fromJson(json.decode(str));

String likeReplyToJson(Like data) => json.encode(data.toJson());

class Like {
  Like({
    this.like,
  });

  final LikeClass? like;

  factory Like.fromJson(Map<String, dynamic> json) => Like(
        like: LikeClass.fromJson(json["like"]),
      );

  Map<String, dynamic> toJson() => {
        "like": like?.toJson(),
      };
}

class LikeClass {
  LikeClass({
    this.replyId,
    this.userId,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  final String? replyId;
  final int? userId;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final int? id;

  factory LikeClass.fromJson(Map<String, dynamic> json) => LikeClass(
        replyId: json["reply_id"],
        userId: json["user_id"],
        updatedAt: DateTime.parse(json["updated_at"]),
        createdAt: DateTime.parse(json["created_at"]),
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "reply_id": replyId,
        "user_id": userId,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "id": id,
      };
}
