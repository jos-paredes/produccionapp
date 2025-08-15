import 'package:flutter/material.dart';
import 'package:produccionapp/data/datasources/remote/user_api.dart';
import 'package:produccionapp/data/models/user.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:produccionapp/features/auth/providers/user_provider.dart';
import 'package:produccionapp/features/calidad/screen/pantalla_area1.dart';
import 'package:produccionapp/features/produccion/screens/screen_produccion.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  List<User> users = [];
  User? selectedUser;
  int? selectedNumber;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedUsers = await ApiService.fetchUsers();
      setState(() {
        users = fetchedUsers;
        if (fetchedUsers.isNotEmpty) {
          selectedUser = fetchedUsers.first;
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar usuarios: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildDropdownContainer(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const CircularProgressIndicator(),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (!isLoading && errorMessage == null)
              buildDropdownContainer(
                Material(
                  child: DropdownButton2<User>(
                    isExpanded: true,
                    value: selectedUser,
                    hint: const Text(
                      'Selecciona un usuario',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    items: users.map((user) {
                      return DropdownMenuItem<User>(
                        value: user,
                        child: Text(
                          user.name,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                    onChanged: (User? newValue) {
                      setState(() {
                        selectedUser = newValue;
                      });
                    },
                    buttonStyleData: _buttonStyle(),
                    dropdownStyleData: _dropdownStyle(),
                    iconStyleData: _iconStyle(),
                    menuItemStyleData: _menuItemStyle(),
                  ),
                ),
              ),
            buildDropdownContainer(
              Material(
                child: DropdownButton2<int>(
                  isExpanded: true,
                  value: selectedNumber,
                  hint: Text(
                    'Selecciona un turno',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  items: [1, 2, 3].map((number) {
                    return DropdownMenuItem<int>(
                      value: number,
                      child: Text(
                        'Turno $number',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedNumber = newValue;
                    });
                  },
                  buttonStyleData: _buttonStyle(),
                  dropdownStyleData: _dropdownStyle(),
                  iconStyleData: _iconStyle(),
                  menuItemStyleData: _menuItemStyle(),
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (selectedUser == null || selectedNumber == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor, selecciona usuario y turno')),
                  );
                  return;
                }
                // Guardar en Provider
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                userProvider.setUser(selectedUser!);
                userProvider.setTurno(selectedNumber!);
      
                // Redirigir según id_area
                switch (selectedUser!.id_area) {
                  case 1:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScreenCalidad()),
                    );
                    break;
                  case 2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScreenProduccion()),
                    );
                    break;
                  default:
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Área no reconocida')),
                    );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text(
                'Ingresar',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
      
          ],
        ),
      ),
    );
  }

  /// Estilo compartido para botones
  ButtonStyleData _buttonStyle() => ButtonStyleData(
    height: 50,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
      color: Colors.white,
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    elevation: 2,
  );

  /// Estilo compartido para dropdown
  DropdownStyleData _dropdownStyle() => DropdownStyleData(
    maxHeight: 300,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 6,
          offset: Offset(0, 4),
        ),
      ],
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: MaterialStateProperty.all(Colors.grey.shade400),
      radius: const Radius.circular(8),
      thickness: MaterialStateProperty.all(6),
    ),
  );

  /// Estilo compartido para ícono
  IconStyleData _iconStyle() => const IconStyleData(
    icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
    iconSize: 24,
  );

  /// Estilo compartido para ítems
  MenuItemStyleData _menuItemStyle() => const MenuItemStyleData(
    height: 48,
    padding: EdgeInsets.symmetric(horizontal: 16),
  );
}
