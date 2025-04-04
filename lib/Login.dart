import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart'; // Asegúrate de tener tu pantalla principal (MyHomePage o similar)
import "Register.dart"; // Asegúrate de tener tu pantalla de registro (RegisterScreen)
import 'api_service.dart'; // Asegúrate de tener tu servicio de API

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginScreen(), // LoginScreen como pantalla principal
      routes: {
        '/home': (context) => const MyHomePage(title: 'Home'), // Reemplaza MyHomePage con tu pantalla principal
        '/register': (context) => const RegisterScreen(), // Reemplaza RegisterScreen con tu pantalla de registro
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false; // Estado de carga

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, introduce correo y contraseña")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String username = _emailController.text;
    final String password = _passwordController.text;

    try {
      final token = await ApiService.loginUser(username, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      Navigator.pushReplacementNamed(context, '/home'); // Navega a la ruta '/home'
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario o Contraseña incorrectas")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Fondo gris claro
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 300, // Ancho del contenedor
            height: 370, // Alto del contenedor (ajustado para el indicador de carga)
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0), // Bordes redondeados
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email address',
                    hintText: 'Introduce tu correo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Introduce tu contraseña',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),
                Align(
                  alignment: Alignment.centerRight,
                ),
                const SizedBox(height: 24.0),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Iniciar Sesion', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register'); // Navega a la ruta '/register'
                  },
                  child: const Text('¿No tienes una cuenta? Regístrate', style: TextStyle(color: Colors.blue)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}