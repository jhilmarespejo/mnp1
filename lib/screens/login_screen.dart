// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mnp1/screens/sync_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('https://test-mnp.defensoria.gob.bo/api/api_iniciar'),
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // print(responseData);

        if (responseData['success'] == true) {
          FocusScope.of(context).unfocus();
         // Almacenar token y userId en SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('token', responseData['token']);
          prefs.setInt('userId', responseData['USER_id']);
         
        //  Navigator.pop(context); // Cerrar la pantalla de inicio de sesión
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SyncScreen()),
        );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Validación exitosa!.'),
            ),
          );
        } else {
          // Si el campo 'success' no es true, consideramos que las credenciales son incorrectas.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Credenciales incorrectas. Inténtalo de nuevo.'),
            ),
          );
        }
      } else {
        // Si la respuesta no es exitosa, mostrar un mensaje de error.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error en la solicitud. Inténtalo de nuevo.'),
          ),
        );
      }
    } catch (error) {
      // En caso de errores durante la solicitud, también puedes mostrar un mensaje de error.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al intentar iniciar sesión. Inténtalo de nuevo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo-defensor.png',
              height: 70,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Nombre de usuario',
                hintText: 'Ingresa tu nombre de usuario',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Ingrese el password',
                prefixIcon: const Icon(Icons.security),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Iniciar Sesión'),
            )
          ],
        ),
      ),
    );
  }
}
