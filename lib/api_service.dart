import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String _apiUrl = dotenv.get('API_URL');

  // Obtener todas las tareas
  static Future<List<Map<String, dynamic>>> getTasks() async {
    final response = await http.get(Uri.parse('$_apiUrl/tareas'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Error al cargar las tareas');
    }
  }

  // Obtener una tarea por ID
  static Future<Map<String, dynamic>> getTaskById(int id) async {
    final response = await http.get(Uri.parse('$_apiUrl/tareas/$id'));
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Error al cargar la tarea');
    }
  }

  // Crear una nueva tarea
  static Future<Map<String, dynamic>> createTask(
      Map<String, dynamic> task) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/tareas'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task),
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Error al crear la tarea');
    }
  }

  // Actualizar una tarea
  static Future<Map<String, dynamic>> updateTask(int id,
      Map<String, dynamic> task) async {
    final response = await http.put(
      Uri.parse('$_apiUrl/tareas/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task),
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar la tarea');
    }
  }

  // Marcar una tarea como completada
  static Future<Map<String, dynamic>> toggleTaskCompletion(int id,
      bool completed) async {
    final response = await http.patch(
      Uri.parse('$_apiUrl/tareas/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'completada': completed}),
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar la tarea');
    }
  }

  // Eliminar una tarea
  static Future<void> deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$_apiUrl/tareas/$id'));
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar la tarea');
    }
  }
}
