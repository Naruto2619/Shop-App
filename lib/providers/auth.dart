import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../Models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authtimer;
  bool get isAuth {
    if (token != null) {
      return true;
    }
    return false;
  }

  String get userid {
    return _userId;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(
      String email, String password, String urlseg) async {
    var url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/$urlseg?key=AIzaSyBo-k0dBkxDze0NM9X_bRNJAb45NKpJ1gs');
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final responsedata = json.decode(response.body);
      if (responsedata['error'] != null) {
        throw HttpException(responsedata['error']['message']);
      }
      _token = responsedata['idToken'];
      _userId = responsedata['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responsedata['expiresIn'])));
      _autologout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userdata = json.encode({
        'token': _token,
        'userid': _userId,
        'expirydate': _expiryDate.toIso8601String()
      });
      prefs.setString('userdata', userdata);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'accounts:signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'accounts:signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userdata')) {
      return false;
    }
    final extracted =
        json.decode(prefs.getString('userdata')) as Map<String, dynamic>;
    final expirydate = DateTime.parse(extracted['expirydate']);
    if (expirydate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extracted['token'];
    _userId = extracted['userid'];
    _expiryDate = expirydate;
    notifyListeners();
    _autologout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    if (_authtimer != null) {
      _authtimer.cancel();
      _authtimer = null;
    }
    _expiryDate = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autologout() {
    if (_authtimer != null) {
      _authtimer.cancel();
    }
    final timeToexp = _expiryDate.difference(DateTime.now()).inSeconds;
    _authtimer = Timer(Duration(seconds: timeToexp), logout);
  }
}
