import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _instansiController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _instansiController = TextEditingController(text: widget.user.instansi);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _instansiController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final updatedUser = widget.user.copyWith(
      username: _usernameController.text.trim(),
      instansi: _instansiController.text.trim(),
    );

    await AuthService().updateUser(updatedUser);

    if (mounted) {
      Navigator.pop(context, updatedUser); // kirim kembali ke ProfileScreen
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
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Nama Pengguna'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _instansiController,
              decoration: const InputDecoration(labelText: 'Instansi'),
            ),
            const SizedBox(height: 32),
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
