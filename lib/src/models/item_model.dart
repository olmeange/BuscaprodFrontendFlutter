import 'dart:convert';

List<ItemModel> itemModelFromJson(String str) =>
    List<ItemModel>.from(json.decode(str).map((x) => ItemModel.fromJson(x)));

String itemModelToJson(List<ItemModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ItemModel {
  String? matnr;
  String? created;
  String? modified;
  String? image;

  ItemModel({
    this.matnr,
    this.created,
    this.modified,
    this.image,
  });

  ItemModel.empty() {
    matnr = 'EMPTY';
    created = 'EMPTY';
    modified = 'EMPTY';
    image = 'EMPTY';
  }

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
        matnr: json["MATNR"],
        created: json["CREATED"],
        modified: json["MODIFIED"],
        image: json["IMAGE"],
      );

  Map<String, dynamic> toJson() => {
        "MATNR": matnr,
        "CREATED": created,
        "MODIFIED": modified,
        "IMAGE": image,
      };
}
