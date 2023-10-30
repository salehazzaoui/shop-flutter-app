import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> signup(String email, String password) async {
    const url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyDN9tVIwt2DZI_Fb2NMIixCoGwt_3EZW18';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final result = json.decode(response.body);
      if (result['error'] != null) {
        throw HttpException(result['error']['message']);
      }
      _token = result['idToken'];
      _userId = result['localId'];
      _expiryDate =
          DateTime.now().add(Duration(seconds: int.parse(result['expiresIn'])));
      _autoLogout();
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> signin(String email, String password) async {
    const url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyDN9tVIwt2DZI_Fb2NMIixCoGwt_3EZW18';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final result = json.decode(response.body);
      if (result['error'] != null) {
        throw HttpException(result['error']['message']);
      }
      _token = result['idToken'];
      _userId = result['localId'];
      _expiryDate =
          DateTime.now().add(Duration(seconds: int.parse(result['expiresIn'])));
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'expiryDate': _expiryDate.toString(),
        'userId': _userId
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;
    final extractedUserData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isAfter(DateTime.now())) return false;
    _token = extractedUserData['token'] as String;
    _userId = extractedUserData['userId'] as String;
    _expiryDate = expiryDate;
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _expiryDate = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer?.cancel();
    }
    final timeToExpiry = _expiryDate?.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry!), logout);
  }
}
