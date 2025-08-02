Future<List<Map<String, dynamic>>> getFormularioGeneralByIdRegistroResistencias(String idRegistro) async {
  final db = await database;
  return await db.query(
    'resistencias',
    where: 'id_registro = ? AND cerrado = 0',
    whereArgs: [idRegistro],
  );
}
