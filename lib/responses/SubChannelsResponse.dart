import 'package:meta/meta.dart';
import 'dart:convert';

SubChannelResponse subChannelResponseFromJson(String str) =>
    SubChannelResponse.fromJson(json.decode(str));

String subChannelResponseToJson(SubChannelResponse data) =>
    json.encode(data.toJson());

class SubChannelResponse {
  SubChannelResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  bool success;
  Data data;
  String message;

  factory SubChannelResponse.fromJson(Map<String, dynamic> json) =>
      SubChannelResponse(
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
    required this.subchannels,
  });

  List<Subchannel> subchannels;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        subchannels: List<Subchannel>.from(
            json["subchannels"].map((x) => Subchannel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "subchannels": List<dynamic>.from(subchannels.map((x) => x.toJson())),
      };
}

class Subchannel {
  Subchannel({
    required this.id,
    required this.channelId,
    required this.subchannelname,
    required this.isActive,
    required this.locale,
  });

  int id;
  int channelId;
  String subchannelname;
  int isActive;
  String locale;

  factory Subchannel.fromJson(Map<String, dynamic> json) => Subchannel(
        id: json["id"],
        channelId: json["channel_id"],
        subchannelname: json["subchannelname"],
        isActive: json["isActive"],
        locale: json["locale"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "channel_id": channelId,
        "subchannelname": subchannelname,
        "isActive": isActive,
        "locale": locale,
      };
}
