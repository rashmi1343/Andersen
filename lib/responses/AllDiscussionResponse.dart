// To parse this JSON data, do
//
//     final welcome = parseJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

AllDiscussionResponse parseJson(String str) =>
    AllDiscussionResponse.fromJson(json.decode(str));

String toJson(AllDiscussionResponse data) => json.encode(data.toJson());

class AllDiscussionResponse {
  AllDiscussionResponse({
    required this.discussionthreads,
  });

  final List<Discussionthread> discussionthreads;

  factory AllDiscussionResponse.fromJson(Map<String, dynamic> json) =>
      AllDiscussionResponse(
        discussionthreads: List<Discussionthread>.from(
            json["Discussionthreads"].map((x) => Discussionthread.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Discussionthreads":
            List<dynamic>.from(discussionthreads.map((x) => x.toJson())),
      };
}

class Discussionthread {
  Discussionthread({
    required this.id,
    required this.userId,
    required this.channelId,
    required this.featured,
    required this.title,
    required this.slug,
    required this.content,
    required this.subtitle,
    required this.reply,
    required this.createdAt,
    required this.updatedAt,
    required this.like,
    required this.filepath,
    required this.discussionlikebydevid,
    required this.discussionimage,
  });

  int id;
  int userId;
  int channelId;
  dynamic featured;
  String title;
  String slug;
  String content;
  String subtitle;
  int reply;
  int like;
  final String createdAt;
  final String updatedAt;
  String filepath;

  bool isLikeButtonSelected = false;

  List<Discussionimage> discussionimage;

  List<Discussionlikebydevid> discussionlikebydevid;

  factory Discussionthread.fromJson(Map<String, dynamic> json) =>
      Discussionthread(
        id: json["id"],
        userId: json["user_id"],
        channelId: json["channel_id"],
        featured: json["featured"],
        title: json["title"],
        slug: json["slug"],
        content: json["content"],
        subtitle: json["subtitle"],
        reply: json["reply"],
        like: json["like"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        filepath: json["filepath"],
        discussionimage: List<Discussionimage>.from(
            json["discussionimage"].map((x) => Discussionimage.fromJson(x))),
        discussionlikebydevid: List<Discussionlikebydevid>.from(
            json["discussionlikebydevid"]
                .map((x) => Discussionlikebydevid.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "channel_id": channelId,
        "featured": featured,
        "title": title,
        "slug": slug,
        "content": content,
        "subtitle": subtitle,
        "reply": reply,
        "like": like,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "filepath": filepath,
        "discussionimage":
            List<Discussionimage>.from(discussionimage.map((x) => x.toJson())),
        "discussionlikebydevid":
            List<dynamic>.from(discussionlikebydevid.map((x) => x.toJson())),
      };
}

class Discussionlikebydevid {
  Discussionlikebydevid({
    required this.id,
    required this.discussionId,
    required this.userId,
    required this.deviceId,
  });

  int id;
  int discussionId;
  int userId;
  String deviceId;

  factory Discussionlikebydevid.fromJson(Map<String, dynamic> json) =>
      Discussionlikebydevid(
        id: json["id"],
        discussionId: json["discussion_id"],
        userId: json["user_id"],
        deviceId: json["device_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "discussion_id": discussionId,
        "user_id": userId,
        "device_id": deviceId,
      };
}

class Discussionimage {
  Discussionimage({
    required this.id,
    this.createdAt,
    this.updatedAt,
    required this.discussionId,
    required this.articleimagepath,
  });

  int id;
  dynamic createdAt;
  dynamic updatedAt;
  int discussionId;
  String articleimagepath;

  factory Discussionimage.fromJson(Map<String, dynamic> json) =>
      Discussionimage(
        id: json["id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        discussionId: json["discussion_id"],
        articleimagepath: json["articleimagepath"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "discussion_id": discussionId,
        "articleimagepath": articleimagepath,
      };
}
