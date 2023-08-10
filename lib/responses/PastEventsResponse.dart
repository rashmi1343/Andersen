import 'package:meta/meta.dart';
import 'dart:convert';

PastEventsResponse pastEventsResponseFromJson(String str) => PastEventsResponse.fromJson(json.decode(str));

String pastEventsResponseToJson(PastEventsResponse data) => json.encode(data.toJson());

class PastEventsResponse {
  PastEventsResponse({
    required this.events,
  });

  List<Event> events;

  factory PastEventsResponse.fromJson(Map<String, dynamic> json) => PastEventsResponse(
    events: List<Event>.from(json["Events"].map((x) => Event.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Events": List<dynamic>.from(events.map((x) => x.toJson())),
  };
}

class Event {
  Event({
    required this.id,
    required this.date,
    required this.origFilename,
    required this.mimeType,
    required this.filesize,
    required this.description,
    required this.time,
    required this.eventName,
  });

  int id;
  String date;
  String origFilename;
  String mimeType;
  int filesize;
  String description;
  String time;
  String eventName;

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: json["id"],
    date: json["date"],
    origFilename: json["orig_filename"],
    mimeType: json["mime_type"],
    filesize: json["filesize"],
    description: json["description"],
    time: json["time"],
    eventName: json["event_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date,
    "orig_filename": origFilename,
    "mime_type": mimeType,
    "filesize": filesize,
    "description": description,
    "time": time,
    "event_name": eventName,
  };
}
