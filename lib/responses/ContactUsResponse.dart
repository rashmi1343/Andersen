import 'package:meta/meta.dart';
import 'dart:convert';

ContactUsResponse contactUsResponseFromJson(String str) => ContactUsResponse.fromJson(json.decode(str));

String contactUsResponseToJson(ContactUsResponse data) => json.encode(data.toJson());

class ContactUsResponse {
  ContactUsResponse({
   required this.contactus,
  });

  List<Contactus> contactus;

  factory ContactUsResponse.fromJson(Map<String, dynamic> json) => ContactUsResponse(
    contactus: List<Contactus>.from(json["contactus"].map((x) => Contactus.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "contactus": List<dynamic>.from(contactus.map((x) => x.toJson())),
  };
}

class Contactus {
  Contactus({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.subject,
    required this.message,
    required this.eventId,
    required this.eventName,
  });

  int id;
  String name;
  String email;
  String phone;
  String subject;
  String message;
  int eventId;
  String eventName;

  factory Contactus.fromJson(Map<String, dynamic> json) => Contactus(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    subject: json["subject"],
    message: json["message"],
    eventId: json["event_id"],
    eventName: json["event_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "subject": subject,
    "message": message,
    "event_id": eventId,
    "event_name": eventName,
  };
}

// enum EventName { EMPTY, TAX_PROCEDURE }
//
// final eventNameValues = EnumValues({
//   "": EventName.EMPTY,
//   "Tax Procedure": EventName.TAX_PROCEDURE
// });
//
// class EnumValues<T> {
//   Map<String, T> map;
//   Map<T, String> reverseMap;
//
//   EnumValues(this.map);
//
//   Map<T, String> get reverse {
//     if (reverseMap == null) {
//       reverseMap = map.map((k, v) => new MapEntry(v, k));
//     }
//     return reverseMap;
//   }
//}
