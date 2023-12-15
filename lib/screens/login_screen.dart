import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _login() {
    // Lógica para manejar el inicio de sesión aquí
    String username = _usernameController.text;
    String password = _passwordController.text;

    // ... Tu lógica de autenticación aquí ...

    if (username == 'nombre.apellido' && password == 'contrasena') {
      // Las credenciales son válidas, puedes navegar a la siguiente pantalla o realizar acciones adicionales.
      // Por ejemplo, aquí cerramos la pantalla actual y mostramos un SnackBar.
      Navigator.pop(context); // Cerrar la pantalla de inicio de sesión
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inicio de sesión exitoso.'),
        ),
      );
    } else {
      // Las credenciales no son válidas, puedes mostrar un mensaje de error.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciales incorrectas. Inténtalo de nuevo.'),
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
            // Inserta tu logotipo aquí
            Image.asset(
              'assets/logo-defensor.png',
              height: 70, // Ajusta la altura según tus necesidades
            ),
            const SizedBox(height: 20),
            TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de usuario',
                  hintText: 'Ingresa tu nombre de usuario',
                  prefixIcon: const Icon(Icons.person), // Icono antes del campo de texto
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0), // Bordes redondeados
                  ),
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor, // Color de fondo
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
              // decoration: const InputDecoration(labelText: 'Contraseña'),
              // obscureText: true,
            ),
            const SizedBox(height: 20),
            
            FilledButton.icon(
              icon: const Icon(Icons.key_outlined),
              label: const Text('Iniciar Sesión'),
              onPressed: _login,
            )
          ],
        ),
      ),
    );
  }
}