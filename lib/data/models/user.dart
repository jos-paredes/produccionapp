class User {
  final int id;     // Campo para el ID (ej: 1)
  final String name; // Campo para el nombre (ej: "José")
  final int id_area;

  // Constructor (como una receta para crear un usuario)
  User({required this.id, required this.name, required this.id_area});

  // Factory (convierte el JSON de Laravel a un objeto Dart)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],     // Extrae el valor de la clave 'id' del JSON
      name: json['name'], // Extrae el valor de la clave 'name'
      id_area: json['id_area'],
    );
  }
}