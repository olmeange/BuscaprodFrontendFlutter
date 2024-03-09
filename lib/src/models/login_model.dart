import 'dart:convert';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  String? token;
  String? rf;
  String? message;
  int? statusCode;

  LoginModel({
    this.token,
    this.rf,
    this.message,
    this.statusCode,
  });

  LoginModel.empty() {
    statusCode = 0;
    token = 'EMPTY';
    rf = 'EMPTY';
    message = 'EMPTY';
  }

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        token: json["token"],
        rf: json["rf"],
        message: json["message"],
        statusCode: json["status_code"],
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "rf": rf,
        "message": message,
        "status_code": statusCode,
      };
}
