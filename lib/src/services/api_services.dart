import 'dart:io';
import 'package:buscaprodmt/src/models/item_model.dart';
import 'package:buscaprodmt/src/models/materialsv2_model.dart';
import 'package:buscaprodmt/src/models/verify_token_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FetchItem {
  ItemModel data = ItemModel.empty();
  late int statusCode;
  late String message;

  Future<ItemModel> getItem({String? item}) async {
    String endpointUrl =
        //   'http://s4des.mercotec.com.py:8000/sap/bc/rest/api/imagen?sap-client=110';
        'http://s4prd-app.mercotec.com.py:8002/sap/bc/rest/api/imagen?sap-client=300';
    Map<String, String> header = {
      "Access-Control-Allow-Methods": "GET,POST",
      "Access-Control-Allow-Headers": "X-Requested-With",
      //"Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept",
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json; charset=utf-8',
      'X-CSRF-Token': 'Fetch',
      'Accept': '*/*',
      "MATNR": item!.toUpperCase(),
      'authorization':
          //   'Basic ${base64.encode(utf8.encode('mbecchi:2010Merco'))}'
          'Basic ${base64.encode(utf8.encode('API_PRD:C68nE7uDhVFzQ/S-Hg,>?t=K'))}'
    };

    http.Response response =
        await http.get(Uri.parse(endpointUrl), headers: header);

    if (response.statusCode == 200) {
      data.image = jsonDecode(response.body)[0]['IMAGE'].toString();
      data.created = jsonDecode(response.body)[0]['CREATED'].toString();
      data.matnr = jsonDecode(response.body)[0]['MATNR'].toString();
      data.modified = jsonDecode(response.body)[0]['MODIFIED'].toString();
    }
    return data;
  }

  Future<Materialsv2Model> getMaterialsDescriptionCodePerPage(
      int page, String input, String option, String token) async {
    const String url = 'http://api.mercotec.com.py:5000/api';
    String endpoint = '';
    String msg = '';
    int status = 0;
    List posts = [];

    Materialsv2 materialsv2 = Materialsv2.empty();
    Materialsv2Model materialsv2model = Materialsv2Model.empty();

    if (option == 'Descripción') {
      endpoint = '$url/materials_description/$page';
    } else {
      if (option == 'Código') {
        endpoint = '$url/materials_code/$page';
      }
    }

    try {
      final response = await http.get(Uri.parse(endpoint), headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": token,
        "input": Uri.encodeComponent(input)
      });

      status = jsonDecode(response.body)['status_code'];
      msg = jsonDecode(response.body)['message'];

      if (response.statusCode != 200) {
        // internal server error
        return Materialsv2Model(
            statusCode: 1003, message: msg, materialsv2: []);
      }

      if (status != 1000) {
        return Materialsv2Model(
            statusCode: status, message: msg, materialsv2: []);
      }

      posts.addAll(jsonDecode(response.body)['materialsv2']);
    } catch (e) {
      if (e is SocketException) {
        return Materialsv2Model(
            statusCode: 1013, message: e.toString(), materialsv2: []);
      }
    }
    for (var i = 0; i < posts.length; i++) {
      if (!posts[i]['cod_material'].contains('Ñ') &&
          !posts[i]['cod_material'].contains('ñ')) {
        final ItemModel data = await getItem(item: posts[i]['cod_material']);
        materialsv2 = Materialsv2(
            codMaterial: posts[i]['cod_material'],
            descripcion: posts[i]['descripcion'],
            image: data.image);
        materialsv2model.materialsv2?.add(materialsv2);
      }
    }
    return materialsv2model;
  }

  Future<VerifyTokenModel> verifyToken(String token) async {
    const String url = 'http://api.mercotec.com.py:5000/api';
    const String endpoint = '$url/verify_token';
    String msg = '';
    int status = 0;

    try {
      final response = await http.get(Uri.parse(endpoint), headers: {
        "Content-Type": "application/json",
        "Authorization": token
      });

      status = jsonDecode(response.body)['status_code'];
      msg = jsonDecode(response.body)['message'];

      if (response.statusCode != 200) {
        return VerifyTokenModel(statusCode: 1003, message: msg);
      }
    } catch (e) {
      if (e is SocketException) {
        return VerifyTokenModel(statusCode: 1013, message: e.toString());
      }
    }

    return VerifyTokenModel(statusCode: status, message: msg);
  }
}
