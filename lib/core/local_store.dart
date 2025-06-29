
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStore<T> {
  final String key;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  T? _currentValue;
  final _controller = StreamController<T?>.broadcast();

  LocalStore({
    required this.key,
    required this.fromJson,
    required this.toJson,
  });

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      _currentValue = fromJson(json.decode(jsonString));
    }
    _controller.add(_currentValue);
  }

  Stream<T?> get stream => _controller.stream;
  T? get currentValue => _currentValue;

  Future<void> set(T value) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(toJson(value));
    await prefs.setString(key, jsonString);
    _currentValue = value;
    _controller.add(_currentValue);
  }

  Future<void> update(Map<String, dynamic> updates) async {
    if (_currentValue == null) return;

    final currentJson = toJson(_currentValue!);
    currentJson.addAll(updates);
    
    final newValue = fromJson(currentJson);
    await set(newValue);
  }

  Future<void> delete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    _currentValue = null;
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}
