// To parse this JSON data, do
//
//     final materialsv2Model = materialsv2ModelFromJson(jsonString);

import 'dart:convert';

Materialsv2Model materialsv2ModelFromJson(String str) =>
    Materialsv2Model.fromJson(json.decode(str));

String materialsv2ModelToJson(Materialsv2Model data) =>
    json.encode(data.toJson());

class Materialsv2Model {
  String? message;
  List<Materialsv2>? materialsv2;
  int? statusCode;

  Materialsv2Model({this.message, this.materialsv2, this.statusCode});

  Materialsv2Model.empty() {
    message = 'EMPTY';
    statusCode = 0;
    materialsv2 = [];
  }

  factory Materialsv2Model.fromJson(Map<String, dynamic> json) =>
      Materialsv2Model(
          message: json["message"],
          materialsv2: List<Materialsv2>.from(
              json["materialsv2"].map((x) => Materialsv2.fromJson(x))),
          statusCode: json["status_code"]);

  Map<String, dynamic> toJson() => {
        "message": message,
        "materialsv2": List<dynamic>.from(materialsv2!.map((x) => x.toJson())),
        "status_code": statusCode
      };
}

class Materialsv2 {
  String? codMaterial;
  String? descripcion;
  String? image;

  Materialsv2({
    this.codMaterial,
    this.descripcion,
    this.image,
  });

  Materialsv2.empty() {
    codMaterial = 'EMPTY';
    descripcion = 'EMPTY';
    image = 'EMPTY';
  }

  factory Materialsv2.fromJson(Map<String, dynamic> json) => Materialsv2(
      codMaterial: json["cod_material"],
      descripcion: json["descripcion"],
      image: json["image"]);

  Map<String, dynamic> toJson() =>
      {"cod_material": codMaterial, "descripcion": descripcion, "image": image};
}
