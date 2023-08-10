

import 'dart:convert';

GetPrivacypolicy PPFromJson(String str) =>
    GetPrivacypolicy.fromJson(json.decode(str));

String PPToJson(GetPrivacypolicy data) => json.encode(data.toJson());

class GetPrivacypolicy {
  final int? status;
  final String? privacyPolicy;

  GetPrivacypolicy({
   required this.status,
   required this.privacyPolicy,
  });

  GetPrivacypolicy.fromJson(Map<String, dynamic> json)
      : status = json['status'] as int?,
        privacyPolicy = json['PrivacyPolicy'] as String?;

  Map<String, dynamic> toJson() => {
    'status' : status,
    'PrivacyPolicy' : privacyPolicy
  };
}