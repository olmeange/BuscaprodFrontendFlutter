// To parse this JSON data, do
//
//     final verifyTokenModel = verifyTokenModelFromJson(jsonString);

import 'dart:convert';

VerifyTokenModel verifyTokenModelFromJson(String str) =>
    VerifyTokenModel.fromJson(json.decode(str));

String verifyTokenModelToJson(VerifyTokenModel data) =>
    json.encode(data.toJson());

class VerifyTokenModel {
  String? message;
  int? statusCode;

  VerifyTokenModel({
    this.message,
    this.statusCode,
  });

  VerifyTokenModel.empty() {
    message = 'EMPTY';
    statusCode = 0;
  }

  factory VerifyTokenModel.fromJson(Map<String, dynamic> json) =>
      VerifyTokenModel(
        message: json["message"],
        statusCode: json["status_code"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "status_code": statusCode,
      };
}
