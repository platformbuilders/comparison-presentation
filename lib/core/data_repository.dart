import 'package:flutter/material.dart';
import 'local_store.dart';
import '../models/calc_params.dart';

class DataRepository {
  static DataRepository? _instance;
  
  late final LocalStore<CalcParams> calcParams;
  
  DataRepository._();
  
  static DataRepository get instance {
    _instance ??= DataRepository._();
    return _instance!;
  }
  
  Future<void> initialize() async {
    calcParams = LocalStore<CalcParams>(
      key: 'calcParams',
      fromJson: CalcParams.fromJson,
      toJson: (params) => params.toJson(),
    );
    await calcParams.initialize();
    
    if (calcParams.currentValue == null) {
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