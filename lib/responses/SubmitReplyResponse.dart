import 'package:meta/meta.dart';
import 'dart:convert';

SubmitReplyResponse submitReplyResponseFromJson(String str) =>
    SubmitReplyResponse.fromJson(json.decode(str));

String submitReplyResponseToJson(SubmitReplyResponse data) =>
    json.encode(data.toJson());

class SubmitReplyResponse {
  SubmitReplyResponse({
    required this.reply,
  });

  List<Reply> reply;

  factory SubmitReplyResponse.fromJson(Map<String, dynamic> json) =>
      SubmitReplyResponse(
        reply: List<Reply>.from(json["reply"].map((x) => Reply.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "reply": List<dynamic>.from(reply.map((x) => x.toJson())),
      };
}

class Reply {
  Reply({
    required this.id,
    required this.userId,
    required this.discussionId,
    required this.bestAnswer,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  int userId;
  int discussionId;
  int bestAnswer;
  String content;
  String createdAt;
  String updatedAt;

  factory Reply.fromJson(Map<String, dynamic> json) => Reply(
        id: json["id"],
        userId: json["user_id"],
        discussionId: json["discussion_id"],
        bestAnswer: json["best_answer"],
        content: json["content"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "discussion_id": discussionId,
        "best_answer": bestAnswer,
        "content": content,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
