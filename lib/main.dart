import 'package:flutter/material.dart';
import 'package:produccionapp/data/models/user.dart';
import 'package:produccionapp/features/produccion/screens/screen_produccion.dart';
import 'package:provider/provider.dart';
import 'package:produccionapp/features/auth/providers/user_provider.dart';
import 'package:produccionapp/features/produccion/providers/registro_produccion_provider.dart';
import 'package:produccionapp/features/auth/screens/login_screen.dart';

import 'features/produccion/providers/imagen_provider.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializamos el provider de registro
  final registroProvider = RegistroProduccionProvider();
  await registroProvider.initialize();

  // Creamos el UserProvider
  final userProvider = UserProvider();

  // Si hay un registro activo, restauramos los datos del usuario y turno
  if (registroProvider.registroActivo) {
    final nombre = registroProvider.nombreUsuario ?? '';
    final turno = int.tryParse(registroProvider.turno ?? '1') ?? 1;

    userProvider.setUser(
      User(id: -1, name: nombre, id_area: 2),
    );
    userProvider.setTurno(turno);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => userProvider),
        ChangeNotifierProvider(create: (_) => registroProvider),
        ChangeNotifierProvider(create: (_) => ImagenProvider()),
      ],
      child: MyApp(registroActivo: registroProvider.registroActivo),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool registroActivo;

  const MyApp({super.key, required this.registroActivo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Producción App',
      home: registroActivo ? const ScreenProduccion() : LoginScreen(),
    );
  }
}
