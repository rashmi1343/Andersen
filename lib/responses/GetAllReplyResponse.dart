import 'package:meta/meta.dart';
import 'dart:convert';

GetAllReplyResponse getAllReplyResponseFromJson(String str) =>
    GetAllReplyResponse.fromJson(json.decode(str));

String getAllReplyResponseToJson(GetAllReplyResponse data) =>
    json.encode(data.toJson());

class GetAllReplyResponse {
  GetAllReplyResponse({
    required this.reply,
  });

  List<Reply> reply;

  factory GetAllReplyResponse.fromJson(Map<String, dynamic> json) =>
      GetAllReplyResponse(
        reply: List<Reply>.from(json["reply"].map((x) => Reply.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "reply": List<dynamic>.from(reply.map((x) => x.toJson())),
      };
}

class Reply {
  Reply(
      {required this.id,
      required this.userId,
      required this.discussionId,
      required this.bestAnswer,
      required this.content,
      required this.createdAt,
      required this.updatedAt,
      required this.name,
      required this.email,
      required this.likecount});

  int id;
  int userId;
  int discussionId;
  int bestAnswer;
  String content;
  String createdAt;
  String updatedAt;
  String name;
  String email;
  int likecount;
  bool isLikeButtonSelected = false;

  factory Reply.fromJson(Map<String, dynamic> json) => Reply(
      id: json["id"],
      userId: json["user_id"],
      discussionId: json["discussion_id"],
      bestAnswer: json["best_answer"],
      content: json["content"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      name: json["name"],
      email: json["email"],
      likecount: json["likecount"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "discussion_id": discussionId,
        "best_answer": bestAnswer,
        "content": content,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "name": name,
        "email": email,
        "likecount": likecount
      };
}
