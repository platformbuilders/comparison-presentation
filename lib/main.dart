import 'package:flutter/material.dart';
import 'core/data_repository.dart';
import 'screens/home_screen.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = DataRepository.instance;
  
  try {
    await repository.initialize();
  } catch (e) {
    print('Repository initialization error: $e');
  }

  runApp(
    RepositoryProvider(
      repository: repository,
      child: const ComparisonCalculatorApp(),
    ),
  );
}

class ComparisonCalculatorApp extends StatelessWidget {
  const ComparisonCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Compra × Locação',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.blueSide,
        scaffoldBackgroundColor: AppColors.blackSide,
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      home: const HomeScreen(),
    );
  }
}