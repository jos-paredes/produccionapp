import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:produccionapp/core/constants/api_routes.dart';
import 'package:produccionapp/data/models/user.dart';

class ApiService {
  static Future<List<User>> fetchUsers() async {
    // 1. Hacer la petición a Laravel
    final response = await http.get(Uri.parse(ApiRoutes.users));
    // 2. Verificar si la respuesta es exitosa (código 200)
    if (response.statusCode == 200) {
      // 3. Decodificar el JSON (ej: [{"id":1, "name":"José"}, {"id":2, "name":"María"}])
      List jsonResponse = json.decode(response.body);

      // 4. Mapear cada JSON a un objeto User usando el modelo
      return jsonResponse.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('¡Ups! Falló la conexión con la API');
    }
  }
}