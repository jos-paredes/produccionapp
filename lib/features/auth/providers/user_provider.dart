import 'package:flutter/material.dart';
import 'package:produccionapp/data/models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  int? _turno;

  User? get user => _user;
  int? get turno => _turno;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void setTurno(int turno) {
    _turno = turno;
    notifyListeners();
  }

  void clear() {
    _user = null;
    _turno = null;
    notifyListeners();
  }
}
