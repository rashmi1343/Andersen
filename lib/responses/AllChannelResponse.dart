import 'package:meta/meta.dart';
import 'dart:convert';

AllChannelResponse allChannelResponseFromJson(String str) =>
    AllChannelResponse.fromJson(json.decode(str));

String allChannelResponseToJson(AllChannelResponse data) =>
    json.encode(data.toJson());

class AllChannelResponse {
  AllChannelResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  bool success;
  Data data;
  String message;

  factory AllChannelResponse.fromJson(Map<String, dynamic> json) =>
      AllChannelResponse(
        success: json["success"],
        data: Data.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data.toJson(),
        "message": message,
      };
}

class Data {
  Data({
    required this.channels,
  });

  List<Channel> channels;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        channels: List<Channel>.from(
            json["channels"].map((x) => Channel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "channels": List<dynamic>.from(channels.map((x) => x.toJson())),
      };
}

class Channel {
  Channel({
    required this.id,
    required this.title,
    required this.slug,
  });

  int id;
  String title;
  String slug;

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
        id: json["id"],
        title: json["title"],
        slug: json["slug"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "slug": slug,
      };
}
