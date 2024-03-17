import 'dart:io';

import 'package:buscaprodmt/src/pages/search_page.dart';
import 'package:buscaprodmt/src/services/login_service.dart';
import 'package:flutter/material.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formState = GlobalKey<FormState>();
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  bool showPass = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          MoveToBackground.moveTaskToBack();
        }
        return false;
      },
      child: Scaffold(
          body: Center(
              child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
              left: 25.0, right: 25.0, top: 60.0, bottom: 60.0),
          child: Form(
              key: _formState,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text('Buscaprod MT',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 33,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  Image.asset('assets/buscador.png', height: 80, width: 80),
                  const SizedBox(height: 20),
                  _userTextForm(),
                  const SizedBox(height: 20),
                  _passwordTextForm(),
                  const SizedBox(
                    height: 20,
                  ),
                  _loginButton(),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              )),
        ),
      ))),
    );
  }

  void togglePass() {
    setState(() {
      showPass = !showPass;
    });
  }

  Widget _userTextForm() {
    return TextFormField(
      keyboardType: TextInputType.text,
      controller: userController,
      decoration: InputDecoration(
          floatingLabelStyle: const TextStyle(color: Colors.blue),
          fillColor: Colors.grey.shade100,
          filled: true,
          labelText: 'Usuario',
          prefixIcon: const Icon(Icons.person_outlined),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      validator: (value) {
        if (value!.isEmpty) {
          return "Ingrese usuario";
        }
        return null;
      },
    );
  }

  Widget _passwordTextForm() {
    return TextFormField(
      obscureText: !showPass,
      keyboardType: TextInputType.text,
      controller: passwordController,
      decoration: InputDecoration(
          floatingLabelStyle: const TextStyle(color: Colors.blue),
          fillColor: Colors.grey.shade100,
          filled: true,
          labelText: 'Constraseña',
          prefixIcon: const Icon(Icons.lock_outlined),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          suffixIcon: IconButton(
            onPressed: togglePass,
            icon: showPass
                ? const Icon(Icons.visibility)
                : const Icon(
                    Icons.visibility_off,
                  ),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      validator: (value) {
        if (value!.isEmpty) {
          return "Ingrese contraseña";
        } else if (passwordController.text.length < 6) {
          return "Su contraseña debe tener al menos 6 caracteres";
        }
        return null;
      },
    );
  }

  Widget _loginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          // The width will be 100% of the parent widget
          // The height will be 60
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.blue,
          textStyle: const TextStyle(fontSize: 18),
          minimumSize: const Size.fromHeight(60)),
      onPressed: () {
        if (_formState.currentState!.validate()) {
          final LoginService loginService = LoginService();
          loginService
              .login(userController.text, passwordController.text)
              .then((response) {
            if (response.statusCode == 1000) {
              _saveText(response.token.toString()).then((_) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchPage()));
              });
            } else {
              if (response.statusCode == 1009) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    'El usuario o la contraseña son incorrectos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                  duration: Duration(seconds: 1),
                  backgroundColor: Colors.blue,
                ));
              }

              if (response.statusCode == 1013) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    'Sin Conexión a Internet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                  duration: Duration(seconds: 1),
                  backgroundColor: Colors.blue,
                ));
              }
            }
          });
        }
      },
      child:
          const Text('Iniciar Sesion', style: TextStyle(color: Colors.white)),
    );
  }

  Future<void> _saveText(String text) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tkn', text);
  }
}
