import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../constants/colors.dart';
import '../constants/string.dart';
import '../routes.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Fungsi untuk login
  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      try {
        // Membuka box Hive untuk verifikasi data pengguna
        final userBox = await Hive.openBox('userBox');

        // Ambil data pengguna berdasarkan username (key unik)
        final storedUserMap = userBox.get(username) as Map<String, dynamic>?;

        if (storedUserMap != null) {
          final storedUser = UserModel.fromMap(storedUserMap);

          if (storedUser.password == password) {
            // Login berhasil, simpan status login di SharedPreferences
            final authService = AuthService();
            await authService.login(username, storedUser.instansi, password);

            // Arahkan ke halaman dashboard
            Navigator.pushReplacementNamed(context, Routes.dashboard);
          } else {
            // Tampilkan pesan error jika login gagal
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Username atau password salah. Silakan coba lagi.',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        } else {
          // Tampilkan pesan error jika username tidak ditemukan
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Username tidak ditemukan. Silakan coba lagi.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        print('Error logging in: $e');
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/feedlog.jpg',
                      height: 200,
                      width: 200,
                    ),
                    SizedBox(height: 24),
                    Text(
                      AppStrings.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Login sebagai tamu",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 48),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: AppStrings.username,
                        hintText: AppStrings.enterUsername,
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.required;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: AppStrings.password,
                        hintText: AppStrings.enterPassword,
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.required;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2A6B),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                'MASUK',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                    SizedBox(height: 32),
                    TextButton(
                      onPressed: () {
                        // Arahkan ke halaman register
                        Navigator.pushNamed(context, Routes.register);
                      },
                      child: const Text('Belum punya akun? Daftar di sini'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
