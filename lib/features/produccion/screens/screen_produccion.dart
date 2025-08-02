import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:produccionapp/features/auth/providers/user_provider.dart';
import 'package:produccionapp/features/auth/screens/login_screen.dart';
import 'package:produccionapp/features/produccion/providers/registro_produccion_provider.dart';
import 'package:provider/provider.dart';
import 'package:produccionapp/features/produccion/screens/screen_formulario_general.dart';
import 'package:produccionapp/features/produccion/screens/screen_formulario_resistencias.dart';
import 'package:produccionapp/features/produccion/screens/screen_formulario_temperaturas.dart';

class ScreenProduccion extends StatefulWidget {
  const ScreenProduccion({super.key});

  @override
  State<ScreenProduccion> createState() => _ScreenProduccionState();
}

class _ScreenProduccionState extends State<ScreenProduccion> {
  final PersistentTabController _controller =
  PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() =>
      const [
        FormularioGeneralScreen(),
        FormularioResistenciasScreen(idRegistro: '',),
        FormularioTemperaturasScreen(),
      ];

  List<PersistentBottomNavBarItem> _navBarsItems() =>
      [
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final registroProvider = Provider.of<RegistroProduccionProvider>(
        context, listen: false);


    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: const Text('Inyectora IPS - 400')),
        backgroundColor: Colors.green,
        actions: [
          if (_controller.index != 0)
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: () {
                print("Botón de cámara presionado");
              },
            ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              print("Botón de perfil presionado");
              _mostrarDialogoInicio(context, registroProvider);
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
  void _mostrarDialogoInicio(BuildContext context, RegistroProduccionProvider provider) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool registroCreado = provider.registroActivo;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Center(child: Text(registroCreado ? 'Registro Activo' : 'Iniciar Registro')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Información del usuario
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

                  // Información del registro (solo si hay registro activo)
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
                          Text('Fecha: ${DateFormat('dd/MM/yyyy').format(provider.fecha!)}'),
                          Text('Hora: ${DateFormat('HH:mm').format(provider.fecha!)}'),
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
                      Navigator.of(context).pop(); // Cierra el diálogo
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
                        const SnackBar(content: Text('Registro cerrado y guardado')),
                      );
                    } else {
                      if (userProvider.user?.name != null && userProvider.turno != null) {
                        await provider.crearRegistro(
                          nombre: userProvider.user!.name!,
                          turno: userProvider.turno.toString(),
                        );

                        setState(() {
                          registroCreado = true;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Registro creado y guardado')),
                        );
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