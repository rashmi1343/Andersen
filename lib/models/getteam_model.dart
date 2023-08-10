


import 'dart:convert';

GetTeamModel teamFromJson(String str) =>
    GetTeamModel.fromJson(json.decode(str));

String teamToJson(GetTeamModel data) => json.encode(data.toJson());

class GetTeamModel {

  final List<Teams>? teams;

  GetTeamModel({
    this.teams,
  });

  GetTeamModel.fromJson(Map<String, dynamic> json)
      : teams = (json['Teams'] as List?)?.map((dynamic e) => Teams.fromJson(e as Map<String,dynamic>)).toList();

  Map<String, dynamic> toJson() => {
    'Teams' : teams?.map((e) => e.toJson()).toList()
  };
}

class Teams {
  final int? id;
  final String? name;
  final String? designation;
  final int? isActive;
  final int? isDeleted;

  Teams({
    this.id,
    this.name,
    this.designation,
    this.isActive,
    this.isDeleted,
  });

  Teams.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        name = json['name'] as String?,
        designation = json['designation'] as String?,
        isActive = json['isActive'] as int?,
        isDeleted = json['isDeleted'] as int?;

  Map<String, dynamic> toJson() => {
    'id' : id,
    'name' : name,
    'designation' : designation,
    'isActive' : isActive,
    'isDeleted' : isDeleted
  };
}