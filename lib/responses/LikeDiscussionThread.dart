// To parse this JSON data, do
//
//     final likeDiscussionThread = likeDiscussionThreadFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

LikeDiscussionThread likeDiscussionThreadFromJson(String str) =>
    LikeDiscussionThread.fromJson(json.decode(str));

String likeDiscussionThreadToJson(LikeDiscussionThread data) =>
    json.encode(data.toJson());

class LikeDiscussionThread {
  LikeDiscussionThread({
    required this.like,
  });

  List<DiscussionLike> like;

  factory LikeDiscussionThread.fromJson(Map<String, dynamic> json) =>
      LikeDiscussionThread(
        like: List<DiscussionLike>.from(
            json["like"].map((x) => DiscussionLike.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "like": List<dynamic>.from(like.map((x) => x.toJson())),
      };
}

class DiscussionLike {
  DiscussionLike({
    required this.id,
    required this.discussionId,
    required this.userId,
  });

  int id;
  int discussionId;
  int userId;

  factory DiscussionLike.fromJson(Map<String, dynamic> json) => DiscussionLike(
        id: json["id"],
        discussionId: json["discussion_id"],
        userId: json["user_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "discussion_id": discussionId,
        "user_id": userId,
      };
}
