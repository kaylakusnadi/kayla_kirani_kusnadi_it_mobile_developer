import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _imagePath;
  final String _lat = "-7.2504"; // Dummy Koordinat Surabaya
  final String _lng = "112.7508";

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  void _loadPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _imagePath = prefs.getString('profile_photo'));
  }

  void _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_photo', pickedFile.path);
      setState(() => _imagePath = pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Kandidat'), backgroundColor: const Color(0xFF222C57)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(context: context, builder: (_) => SafeArea(
                    child: Wrap(
                      children: [
                        ListTile(leading: const Icon(Icons.camera), title: const Text('Kamera'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
                        ListTile(leading: const Icon(Icons.photo_library), title: const Text('Galeri'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
                      ],
                    ),
                  ));
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF222C57),
                  backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                  child: _imagePath == null ? const Icon(Icons.camera_alt, color: Colors.white, size: 40) : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(title: const Text('Nama'), subtitle: const Text('Kayla Kirani Kusnadi'), leading: const Icon(Icons.person)),
            ListTile(title: const Text('Posisi Dilamar'), subtitle: const Text('IT Mobile Developer'), leading: const Icon(Icons.badge)),
            ListTile(title: const Text('Email'), subtitle: const Text('kayla.kusnadi@gmail.com'), leading: const Icon(Icons.email)),
            ListTile(title: const Text('Koordinat (Lat / Lng)'), subtitle: Text('$_lat / $_lng'), leading: const Icon(Icons.location_on)),
          ],
        ),
      ),
    );
  }
}