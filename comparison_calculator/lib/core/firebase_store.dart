import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class FirebaseStore<T> {
  final DatabaseReference _ref;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  
  T? _currentValue;
  final _controller = StreamController<T?>.broadcast();
  StreamSubscription? _subscription;

  FirebaseStore({
    required DatabaseReference ref,
    required this.fromJson,
    required this.toJson,
  }) : _ref = ref {
    _initialize();
  }

  void _initialize() {
    _subscription = _ref.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        _currentValue = fromJson(data);
      } else {
        _currentValue = null;
      }
      _controller.add(_currentValue);
    });
  }

  Stream<T?> get stream => _controller.stream;
  T? get currentValue => _currentValue;

  Future<void> set(T value) async {
    await _ref.set(toJson(value));
  }

  Future<void> update(Map<String, dynamic> updates) async {
    await _ref.update(updates);
  }

  Future<void> delete() async {
    await _ref.remove();
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}

class FirebaseListStore<T> {
  final DatabaseReference _ref;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  final String Function(T) getId;
  
  Map<String, T> _items = {};
  final _controller = StreamController<List<T>>.broadcast();
  StreamSubscription? _subscription;

  FirebaseListStore({
    required DatabaseReference ref,
    required this.fromJson,
    required this.toJson,
    required this.getId,
  }) : _ref = ref {
    _initialize();
  }

  void _initialize() {
    _subscription = _ref.onValue.listen((event) {
      _items.clear();
      
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          final item = fromJson(Map<String, dynamic>.from(value as Map));
          _items[key] = item;
        });
      }
      
      _controller.add(_items.values.toList());
    });
  }

  Stream<List<T>> get stream => _controller.stream;
  List<T> get currentValue => _items.values.toList();

  Future<void> add(T item) async {
    final id = getId(item);
    await _ref.child(id).set(toJson(item));
  }

  Future<void> update(String id, T item) async {
    await _ref.child(id).set(toJson(item));
  }

  Future<void> delete(String id) async {
    await _ref.child(id).remove();
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}