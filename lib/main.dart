import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/sample_data_helper.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    await SampleDataHelper.addSampleRecipes(); 
  } catch (e) {
    debugPrint('Error updating sample data: $e');
  }

  runApp(const RecipeGoApp());
}

class RecipeGoApp extends StatelessWidget {
  const RecipeGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RecipeGO',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF2E7D32),
        
       
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32), 
          secondary: const Color(0xFF66BB6A), 
          surface: const Color(0xFFF1F8E9), 
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),

        cardTheme: const CardThemeData(
          color: Color(0xFFC8E6C9),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          margin: EdgeInsets.all(8),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF66BB6A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF66BB6A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFA5D6A7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
          ),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

