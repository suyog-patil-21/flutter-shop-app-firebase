import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exceptions.dart';
const globalFirestoreWebApiKey ='<Firebase-Web-Api-key>';
// user Realtime Database 
class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;
  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userId.toString();
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token.toString();
    }
    return null;
  }

  Future<void> _authenicate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$globalFirestoreWebApiKey';
    try {
      var response = await http.post(Uri.parse(url),
          // headers: {"content-type": "application/json"},
          body: jsonEncode({
            "email": email,
            "password": password,
            "returnSecureToken": true
          }));
      // print(json.decode(response.body));
      var responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message'] as String);
      }
      _token = responseData['idToken'].toString();
      _userId = responseData['localId'].toString();
      _expiryDate = DateTime.now().add(
          Duration(seconds: int.parse(responseData['expiresIn'].toString())));
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
          {'token': _token, 'userId': _userId, 'expiryDate': _expiryDate!.toIso8601String()});
      prefs.setString('userData', userData);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenicate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenicate(email, password, 'signInWithPassword');
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

  void logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json
        .decode(prefs.getString('userData').toString()) as Map<String, Object>;
    final expiryDate =
        DateTime.parse(extractedUserData['expiryDate'] as String);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'] as String;
    _userId = extractedUserData['userId'] as String;
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }
}
