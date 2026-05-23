import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/store_bloc.dart';
import '../bloc/store_event.dart';
import '../bloc/store_state.dart';
import 'main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Menggunakan kredensial alternatif Platzi agar bypass kendala server utama
  final _userController = TextEditingController(text: "john@mail.com");
  final _passController = TextEditingController(text: "changeme");

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<StoreBloc, StoreState>(
        listener: (context, state) async {
          if (state is LoginSuccess) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('session_token', state.token);
            if (mounted) {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (_) => const MainNavigation())
              );
            }
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Render Logo Borwita Resmi dari folder aset lokal
                Image.asset(
                  'assets/logo_borwita.png',
                  width: 240,
                  height: 240,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.cloud, size: 80, color: Color(0xFF222C57));
                  },
                ),
                const SizedBox(height: 40),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sign In', 
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF010101))
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _userController,
                  decoration: const InputDecoration(
                    labelText: 'Username / Email', 
                    labelStyle: TextStyle(color: Color(0xFFF24134))
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password', 
                    labelStyle: TextStyle(color: Color(0xFFF24134))
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<StoreBloc, StoreState>(
                  builder: (context, state) {
                    if (state is StoreLoading) return const CircularProgressIndicator();
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF24134),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          context.read<StoreBloc>().add(
                            LoginAction(_userController.text, _passController.text)
                          );
                        },
                        child: const Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
                BlocBuilder<StoreBloc, StoreState>(
                  builder: (context, state) {
                    if (state is AuthError) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(state.msg, style: const TextStyle(color: Color(0xFFF24134), fontWeight: FontWeight.w500)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}