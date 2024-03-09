import 'dart:convert';
import 'dart:io';
import 'package:buscaprodmt/src/models/login_model.dart';
import 'package:http/http.dart' as http;

class LoginService {
  final _url = 'http://api.mercotec.com.py:5000/api';

  Future<LoginModel> login(String userName, String password) async {
    final String url = '$_url/login';
    final LoginModel loginModel = LoginModel.empty();
    Map body = {'user_name': userName, 'password': password};

    try {
      final response = await http.post(Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Headers":
                "Access-Control-Allow-Origin, Accept"
          },
          body: json.encode(body));

      loginModel.statusCode = jsonDecode(response.body)['status_code'];
      loginModel.message = jsonDecode(response.body)['message'];
      loginModel.token = jsonDecode(response.body)['token'];
      loginModel.rf = jsonDecode(response.body)['rf'];

      if (response.statusCode != 200) {
        //loginModel.statusCode = jsonDecode(response.body)['status_code'];
        //loginModel.message = jsonDecode(response.body)['message'];
        return loginModel;
      }
    } catch (e) {
      if (e is SocketException) {
        return LoginModel(statusCode: 1013, message: e.toString());
      }
    }

    return loginModel;
  }
}
