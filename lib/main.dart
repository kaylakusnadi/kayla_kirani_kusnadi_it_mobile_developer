import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/storemart/data/store_datasource.dart';
import 'features/storemart/presentation/bloc/store_bloc.dart';
import 'features/storemart/presentation/bloc/store_event.dart';
import 'features/storemart/presentation/screens/login_screen.dart';
import 'features/storemart/presentation/screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('session_token');

  runApp(MyApp(hasSession: token != null));
}

class MyApp extends StatelessWidget {
  final bool hasSession;
  const MyApp({super.key, required this.hasSession});

  @override
  Widget build(BuildContext context) {
    // Definisi Palet Warna Resmi Borwita Group
    const Color borwitaNavy = Color(0xFF222C57);
    const Color borwitaRed = Color(0xFFF24134);

    return BlocProvider(
      create: (context) => StoreBloc(StoreDataSource())..add(LoadProductsAndCart()),
      child: MaterialApp(
        title: 'Fake Storemart',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          // Mengganti seed color ungu default menjadi Navy Borwita secara global
          colorScheme: ColorScheme.fromSeed(
            seedColor: borwitaNavy,
            primary: borwitaNavy,
            secondary: borwitaRed,
            surface: Colors.white,
          ),
          // Pengaturan Tema AppBar untuk semua halaman
          appBarTheme: const AppBarTheme(
            backgroundColor: borwitaNavy,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
          ),
          // Pengaturan Tema Kotak Input Teks (TextField)
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: borwitaNavy),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borwitaRed, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borwitaNavy),
            ),
            prefixIconColor: borwitaNavy,
          ),
          // Pengaturan Tema Tombol Utama (ElevatedButton)
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: borwitaRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          // Pengaturan Tema Bottom Navigation Bar di bagian bawah
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: borwitaRed,
            unselectedItemColor: borwitaNavy,
            backgroundColor: Colors.white,
            elevation: 8,
          ),
        ),
        home: hasSession ? const MainNavigation() : const LoginScreen(),
      ),
    );
  }
}