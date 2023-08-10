import 'package:meta/meta.dart';
import 'dart:convert';

DocumentResponse documentResponseFromJson(String str) =>
    DocumentResponse.fromJson(json.decode(str));

String documentResponseToJson(DocumentResponse data) =>
    json.encode(data.toJson());

class DocumentResponse {
  DocumentResponse({
    required this.document,
  });

  List<Document> document;

  factory DocumentResponse.fromJson(Map<String, dynamic> json) =>
      DocumentResponse(
        document: List<Document>.from(
            json["document"].map((x) => Document.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "document": List<dynamic>.from(document.map((x) => x.toJson())),
      };
}

class Document {
  Document({
    this.id,
    this.origFilename,
    this.mimeType,
    this.filesize,
    this.content,
    required this.createdAt,
    required this.updatedAt,
    this.documenttitle,
    this.isDeleted,
    this.isActive,
    this.value,
  });



  int? id;
  String? origFilename;
  String? mimeType;
  int? filesize;
  String? content;
  String  createdAt;
  String  updatedAt;
  String? documenttitle;
  int? isDeleted;
  int? isActive;
  bool? value = false;

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    id: json["id"],
    origFilename: json["orig_filename"],
    mimeType: json["mime_type"],
    filesize: json["filesize"],
    content: json["content"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    documenttitle: json["documenttitle"],
    isDeleted: json["isDeleted"],
    isActive: json["isActive"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "orig_filename": origFilename,
    "mime_type": mimeType,
    "filesize": filesize,
    "content": content,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "documenttitle": documenttitle,
    "isDeleted": isDeleted,
    "isActive": isActive,
      };
}
