import 'package:flutter/material.dart';
import 'package:produccionapp/features/produccion/database/database_helper.dart';

class TodosLosRegistrosScreen extends StatefulWidget {
  const TodosLosRegistrosScreen({super.key});

  @override
  State<TodosLosRegistrosScreen> createState() => _TodosLosRegistrosScreenState();
}

class _TodosLosRegistrosScreenState extends State<TodosLosRegistrosScreen> {
  List<Map<String, dynamic>> _registrosCompletos = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _cargarRegistros();
  }

  Future<void> _cargarRegistros() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final registros = await DatabaseHelper().getTodosLosRegistrosCompletos();
      
      debugPrint('📊 Registros recibidos:');
      for (final registro in registros) {
        debugPrint('🔹 Registro ID: ${registro['registro']['id']}');
        debugPrint('   - Formulario General: ${registro['formulario_general'] != null ? "EXISTE" : "NO EXISTE"}');
        debugPrint('   - Resistencias: ${registro['resistencias'] != null ? "EXISTE" : "NO EXISTE"}');
        debugPrint('   - Temperaturas: ${registro['temperaturas'] != null ? "EXISTE" : "NO EXISTE"}');
      }

      setState(() {
        _registrosCompletos = registros;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error al cargar registros: $e');
      setState(() {
        _errorMessage = 'Error al cargar registros: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos los Registros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarRegistros,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    if (_registrosCompletos.isEmpty) {
      return const Center(child: Text('No se encontraron registros'));
    }

    return ListView.builder(
      itemCount: _registrosCompletos.length,
      itemBuilder: (context, index) {
        final registroCompleto = _registrosCompletos[index];
        final registro = registroCompleto['registro'] as Map<String, dynamic>;
        final formularioGeneral = registroCompleto['formulario_general'] as Map<String, dynamic>?;
        final resistencias = registroCompleto['resistencias'] as Map<String, dynamic>?;
        final temperaturas = registroCompleto['temperaturas'] as Map<String, dynamic>?;

        return _buildRegistroCard(
          registro,
          formularioGeneral,
          resistencias,
          temperaturas,
        );
      },
    );
  }

  Widget _buildRegistroCard(
    Map<String, dynamic> registro,
    Map<String, dynamic>? formularioGeneral,
    Map<String, dynamic>? resistencias,
    Map<String, dynamic>? temperaturas,
  ) {
    final estaCerrado = registro['cerrado'] == 1;

    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        title: Text('Registro ID: ${registro['id']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID Sistema: ${registro['idRegistro']}'),
            Text(
              'Estado: ${estaCerrado ? 'CERRADO' : 'ABIERTO'}',
              style: TextStyle(
                color: estaCerrado ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        children: [
          _buildInfoRow('Fecha', registro['fecha']?.toString() ?? 'No especificada'),
          _buildInfoRow('Usuario', registro['nombreUsuario']?.toString() ?? 'No especificado'),
          _buildInfoRow('Turno', registro['turno']?.toString() ?? 'No especificado'),

          _buildSectionTitle('Formulario General'),
          if (formularioGeneral != null) ...[
            _buildInfoRow('Estado', formularioGeneral['cerrado'] == 1 ? 'CERRADO' : 'ABIERTO'),
            _buildInfoRow('Presión Entrada', formularioGeneral['presion_entrada_agua_molde']?.toString() ?? 'No registrada'),
            _buildInfoRow('Última Actualización', formularioGeneral['fecha_actualizacion']?.toString() ?? 'No especificada'),
          ] else 
            _buildInfoRow('Estado', 'NO EXISTE'),

          // ... (similar para resistencias y temperaturas)
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.blue[50],
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}