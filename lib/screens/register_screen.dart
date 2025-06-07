import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _instansiController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Fungsi untuk menyimpan data pengguna
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final String username = _usernameController.text;
      final String password = _passwordController.text;
      final String instansi = _instansiController.text;

      try {
        // Panggil AuthService untuk registrasi user
        final authService = AuthService();

        // Panggil method register() dari AuthService
        await authService.register(username, instansi, password);

        // Setelah berhasil registrasi, navigasi ke halaman login
        Navigator.pushReplacementNamed(
          context,
          Routes.login,
        ); // Gunakan pushReplacementNamed untuk mengganti halaman
      } catch (e) {
        print('Error during registration: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Halaman Registrasi")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username harus diisi';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _instansiController,
                decoration: const InputDecoration(labelText: 'Instansi'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Instansi harus diisi';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _register, child: const Text('Daftar')),
            ],
          ),
        ),
      ),
    );
  }
}
