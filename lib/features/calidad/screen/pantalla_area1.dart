import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/user_provider.dart';

class ScreenCalidad extends StatelessWidget {
  const ScreenCalidad({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final turno = userProvider.turno;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Área de Calidad'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user, size: 64, color: Colors.blueAccent),
                const SizedBox(height: 16),
                Text(
                  'Bienvenido ${user?.name ?? 'Usuario'}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Turno seleccionado: ${turno ?? '-'}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
