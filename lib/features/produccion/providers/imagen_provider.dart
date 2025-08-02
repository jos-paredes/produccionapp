import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagenProvider with ChangeNotifier {
  final List<XFile> _imagenes = [];
  XFile? _imagenSeleccionada;

  List<XFile> get imagenes => _imagenes;
  XFile? get imagenSeleccionada => _imagenSeleccionada;

  // Método para agregar una nueva imagen
  Future<void> agregarImagen(XFile imagen) async {
    _imagenes.add(imagen);
    _imagenSeleccionada = imagen;
    notifyListeners();
  }

  // Método para eliminar una imagen por índice
  void eliminarImagen(int index) {
    if (index >= 0 && index < _imagenes.length) {
      final imagenEliminada = _imagenes.removeAt(index);
      if (_imagenSeleccionada == imagenEliminada) {
        _imagenSeleccionada = null;
      }
      notifyListeners();
    }
  }

  // Método para limpiar todas las imágenes
  void limpiarImagenes() {
    _imagenes.clear();
    _imagenSeleccionada = null;
    notifyListeners();
  }

  // Método para seleccionar una imagen específica
  void seleccionarImagen(XFile imagen) {
    _imagenSeleccionada = imagen;
    notifyListeners();
  }

  // Método para capturar imagen desde la cámara
  Future<void> capturarDesdeCamara() async {
    try {
      final imagen = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 90,
      );
      if (imagen != null) {
        await agregarImagen(imagen);
      }
    } catch (e) {
      debugPrint('Error al capturar imagen: $e');
    }
  }

  // Método para seleccionar imagen de la galería
  Future<void> seleccionarDeGaleria() async {
    try {
      final imagen = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 90,
      );
      if (imagen != null) {
        await agregarImagen(imagen);
      }
    } catch (e) {
      debugPrint('Error al seleccionar imagen: $e');
    }
  }
}