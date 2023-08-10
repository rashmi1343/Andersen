import 'package:meta/meta.dart';
import 'dart:convert';

EventsResponse eventsResponseFromJson(String str) => EventsResponse.fromJson(json.decode(str));

String eventsResponseToJson(EventsResponse data) => json.encode(data.toJson());

class EventsResponse {
  EventsResponse({
    required this.events,
  });

  List<Event> events;

  factory EventsResponse.fromJson(Map<String, dynamic> json) => EventsResponse(
    events: List<Event>.from(json["Events"].map((x) => Event.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Events": List<dynamic>.from(events.map((x) => x.toJson())),
  };
}

class Event {
  Event({
   required this.id,
    required this.eventName,
    required this.from,
    required this.to,
    required this.date,
    required this.origFilename,
    required this.mimeType,
    required this.filesize,
    required this.description,
    required this.time,
  });

  int id;
  String eventName;
  String from;
  String to;
  String date;
  String origFilename;
  String mimeType;
  int filesize;
  String description;
  String time;

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: json["id"],
    eventName: json["event_name"],
    from: json["from"],
    to: json["to"],
    date: json["date"],
    origFilename: json["orig_filename"],
    mimeType: json["mime_type"],
    filesize: json["filesize"],
    description: json["description"],
    time: json["time"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "event_name": eventName,
    "from": from,
    "to": to,
    "date": date,
    "orig_filename": origFilename,
    "mime_type": mimeType,
    "filesize": filesize,
    "description": description,
    "time": time,
  };
}
