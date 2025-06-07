import 'package:flutter/material.dart';
import 'package:kai/models/user_model.dart';
import 'package:kai/screens/edit_profile.dart';
import '../services/auth_service.dart';
import '../constants/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, String>> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _getUserInfo();
  }

  Future<Map<String, String>> _getUserInfo() async {
    final user = await AuthService().getCurrentUser();
    if (user == null) {
      return {
        'username': 'Tidak tersedia',
        'instansi': 'Tidak diketahui',
        'id': '',
        'profileImageUrl': '',
      };
    }

    return {
      'id': user.id,
      'username': user.username,
      'instansi': user.instansi,
      'profileImageUrl': user.profileImageUrl ?? '',
    };
  }

  void _reloadUser() {
    setState(() {
      _userFuture = _getUserInfo();
    });
  }

  // Function to show the confirmation dialog
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Hapus Akun"),
            content: const Text("Apakah Anda yakin ingin menghapus akun ini?"),
            actions: <Widget>[
              TextButton(
                child: const Text("Batal"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Hapus"),
                onPressed: () async {
                  Navigator.of(context).pop(); // Close dialog

                  // Call AuthService to delete the user
                  final success = await AuthService().deleteUser();
                  if (success) {
                    // Show success and log out the user
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Akun berhasil dihapus")),
                    );
                    Navigator.pushReplacementNamed(
                      context,
                      '/login',
                    ); // Navigate to login screen
                  } else {
                    // Show error if deletion failed
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Gagal menghapus akun")),
                    );
                  }
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed:
                _showDeleteConfirmation, // Trigger delete confirmation modal
          ),
        ],
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data!;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage:
                    user['profileImageUrl']!.isNotEmpty
                        ? NetworkImage(user['profileImageUrl']!)
                        : const AssetImage('assets/images/avatar.png')
                            as ImageProvider,
              ),
              const SizedBox(height: 16),
              Text(
                user['username'] ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.settings, color: Colors.indigo),
                  label: const Text('Edit Profile'),
                  onPressed: () async {
                    final updatedUser = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => EditProfileScreen(
                              user: UserModel(
                                id: user['id'] ?? '', // Pastikan id tidak null
                                username:
                                    user['username'] ??
                                    'Username tidak tersedia',
                                instansi:
                                    user['instansi'] ??
                                    'Instansi tidak tersedia',
                                profileImageUrl:
                                    user['profileImageUrl'] ??
                                    '', // Menangani null
                                password:
                                    user['password'] ?? '', // Menangani null
                              ),
                            ),
                      ),
                    );

                    if (updatedUser != null) {
                      _reloadUser(); // ini akan memicu setState
                      Navigator.pop(context, 'updated'); // <- ini penting
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('LOGOUT'),
                  onPressed: () async {
                    final success = await AuthService().logout();
                    if (success && context.mounted) {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/login', (route) => false);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logout gagal. Silakan coba lagi.'),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.grey),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.orange),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
