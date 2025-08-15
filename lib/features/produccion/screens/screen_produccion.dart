import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:produccionapp/core/constants/api_routes.dart';
import 'package:produccionapp/features/auth/providers/user_provider.dart';
import 'package:produccionapp/features/auth/screens/login_screen.dart';
import 'package:produccionapp/features/produccion/providers/registro_produccion_provider.dart';
import 'package:produccionapp/registros_bd.dart';
import 'package:provider/provider.dart';
import 'package:produccionapp/features/produccion/screens/screen_formulario_general.dart';
import 'package:produccionapp/features/produccion/screens/screen_formulario_resistencias.dart';
import 'package:produccionapp/features/produccion/screens/screen_formulario_temperaturas.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScreenProduccion extends StatefulWidget {
  const ScreenProduccion({super.key});

  @override
  State<ScreenProduccion> createState() => _ScreenProduccionState();
}

class _ScreenProduccionState extends State<ScreenProduccion> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() => const [
        FormularioGeneralScreen(),
        FormularioResistenciasScreen(),
        FormularioTemperaturasScreen(),
      ];

  List<PersistentBottomNavBarItem> _navBarsItems() => [
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.list_alt),
          title: "General",
          activeColorPrimary: Colors.green,
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.bolt),
          title: "Resistencias",
          activeColorPrimary: Colors.orange,
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.thermostat),
          title: "Temperaturas",
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
        ),
      ];

  Future<void> _guardarRegistroEnBackend({
    required String idRegistro,
    required String nombreUsuario,
    required String turno,
    required DateTime fecha,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiRoutes.registroProduccion),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_registro': idRegistro,
          'nombre_usuario': nombreUsuario,
          'turno': turno,
          'fecha': fecha.toIso8601String(),
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al guardar en backend: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserProvider>(context, listen: false);
    final registroProvider =
        Provider.of<RegistroProduccionProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(child: Text('Inyectora IPS - 400')),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              _mostrarDialogoInicio(context, registroProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TodosLosRegistrosScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        onItemSelected: (index) {
          setState(() {});
        },
        navBarStyle: NavBarStyle.style1,
        decoration: const NavBarDecoration(colorBehindNavBar: Colors.white),
        backgroundColor: Colors.white,
        confineToSafeArea: true,
        handleAndroidBackButtonPress: true,
        stateManagement: true,
      ),
    );
  }

  void _mostrarDialogoInicio(
      BuildContext context, RegistroProduccionProvider provider) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool registroCreado = provider.registroActivo;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Center(
                  child: Text(registroCreado ? 'Registro Activo' : 'Iniciar Registro')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (userProvider.user != null || userProvider.turno != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        children: [
                          if (userProvider.user != null)
                            Text(
                              'Usuario: ${userProvider.user!.name}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (userProvider.turno != null)
                            Text(
                              'Turno: ${userProvider.turno}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  if (registroCreado) ...[
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        children: [
                          Text(
                            'Detalles del Registro',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('ID: ${provider.idRegistro}'),
                          Text(
                              'Fecha: ${DateFormat('dd/MM/yyyy').format(provider.fecha!)}'),
                          Text(
                              'Hora: ${DateFormat('HH:mm').format(provider.fecha!)}'),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                if (!registroCreado)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: const Text('Volver al login'),
                  ),
                ElevatedButton(
                  onPressed: () async {
                    if (registroCreado) {
                      await provider.cerrarRegistro();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Registro cerrado y guardado')),
                      );
                    } else {
                      if (userProvider.user?.name != null &&
                          userProvider.turno != null) {
                        try {
                          // Crear registro local
                          await provider.crearRegistro(
                            nombre: userProvider.user!.name!,
                            turno: userProvider.turno.toString(),
                          );

                          // Guardar en el backend
                          await _guardarRegistroEnBackend(
                            idRegistro: provider.idRegistro.toString(),
                            nombreUsuario: userProvider.user!.name!,
                            turno: userProvider.turno.toString(),
                            fecha: provider.fecha!,
                          );

                          setState(() {
                            registroCreado = true;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Registro creado y guardado correctamente')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Error al guardar registro: ${e.toString()}')),
                          );
                        }
                      }
                    }
                  },
                  child: Text(registroCreado ? 'Cerrar Registro' : 'Iniciar Registro'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}