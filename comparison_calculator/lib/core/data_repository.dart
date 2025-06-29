import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'firebase_store.dart';
import '../models/calc_params.dart';

class DataRepository {
  static DataRepository? _instance;
  
  late final FirebaseStore<CalcParams> calcParams;
  
  DataRepository._();
  
  static DataRepository get instance {
    _instance ??= DataRepository._();
    return _instance!;
  }
  
  Future<void> initialize() async {
    final database = FirebaseDatabase.instance;
    
    calcParams = FirebaseStore<CalcParams>(
      ref: database.ref('calcParams'),
      fromJson: CalcParams.fromJson,
      toJson: (params) => params.toJson(),
    );
    
    final snapshot = await database.ref('calcParams').get();
    if (!snapshot.exists) {
      await calcParams.set(const CalcParams());
    }
  }
  
  void dispose() {
    calcParams.dispose();
  }
}

class RepositoryProvider extends InheritedWidget {
  final DataRepository repository;
  
  const RepositoryProvider({
    super.key,
    required this.repository,
    required super.child,
  });
  
  static DataRepository of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<RepositoryProvider>();
    if (provider == null) {
      throw FlutterError('RepositoryProvider not found in context');
    }
    return provider.repository;
  }
  
  @override
  bool updateShouldNotify(RepositoryProvider oldWidget) {
    return repository != oldWidget.repository;
  }
}