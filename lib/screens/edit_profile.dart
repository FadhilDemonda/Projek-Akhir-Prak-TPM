import 'package:flutter/material.dart';
import 'package:kai/models/user_model.dart';
import '../services/auth_service.dart';
import '../constants/colors.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _instansiController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _instansiController = TextEditingController(text: widget.user.instansi);
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _instansiController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password dan konfirmasi tidak cocok')),
      );
      return;
    }

    // Create a new UserModel with updated data
    final updatedUser = UserModel(
      id: widget.user.id ?? 'default_id', // Pastikan ada id
      username: _usernameController.text.trim(),
      instansi: _instansiController.text.trim(),
      profileImageUrl: widget.user.profileImageUrl ?? '',
      password: _passwordController.text.trim(),
    );

    // Call the AuthService to update the user data
    await AuthService().updateUser(updatedUser);

    // After updating the user, navigate back with the updated user data
    if (mounted) {
      Navigator.pop(context, updatedUser); // Pass the updated user back
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Username field
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Nama Pengguna'),
            ),
            const SizedBox(height: 16),

            // Instansi field
            TextField(
              controller: _instansiController,
              decoration: const InputDecoration(labelText: 'Instansi'),
            ),
            const SizedBox(height: 16),

            // Password field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Baru'),
            ),
            const SizedBox(height: 16),

            // Confirm Password field
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Password',
              ),
            ),
            const SizedBox(height: 32),

            // Save changes button
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }
}
