import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/data_repository.dart';
import 'screens/home_screen.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
    print('Running in demo mode without Firebase');
  }

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