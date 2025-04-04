import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final String _apiUrl = dotenv.get('API_URL');

  // Obtener el token almacenado en SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Obtener todas las tareas
  static Future<List<Map<String, dynamic>>> getTasks() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_apiUrl/tareas'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Error al cargar las tareas');
    }
  }

  // Crear una nueva tarea
  static Future<Map<String, dynamic>> createTask(Map<String, dynamic> task) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$_apiUrl/tareas'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(task),
    );

    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Error al crear la tarea');
    }
  }

  // Actualizar una tarea
  static Future<Map<String, dynamic>> updateTask(int id, Map<String, dynamic> task) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$_apiUrl/tareas/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(task),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar la tarea');
    }
  }

  // Marcar tarea como completada
  static Future<Map<String, dynamic>> toggleTaskCompletion(int id, bool completed) async {
    final token = await _getToken();
    final response = await http.patch(
      Uri.parse('$_apiUrl/tareas/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({'completada': completed}),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar la tarea');
    }
  }

  // Eliminar tarea
  static Future<void> deleteTask(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$_apiUrl/tareas/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar la tarea');
    }
  }

// Registro de usuario
  static Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async {
    print("Datos a enviar: $userData"); // Imprimir los datos que estás enviando
    final response = await http.post(
      Uri.parse('$_apiUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );
    if (response.statusCode == 201) { // 201: Creado
      return json.decode(response.body);
    } else {
      print('Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Error al registrar el usuario');
    }
  }


  // Login de usuario
  static Future<String> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token']; // Devuelve el token de sesión
    } else {
      throw Exception('Usuario o contraseña incorrectos');
    }
  }

  // Obtener información de usuario autenticado
  static Future<Map<String, dynamic>> getUserById(int id) async {
    final response = await http.get(
      Uri.parse('$_apiUrl/usuarios/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener la información del usuario');
    }
  }

  // Obtener información del usuario autenticado
  static Future<Map<String, dynamic>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('No autenticado');

    final response = await http.get(
      Uri.parse('$_apiUrl/usuarios/perfil'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Enviar JWT en la cabecera
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener usuario');
    }
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

}
