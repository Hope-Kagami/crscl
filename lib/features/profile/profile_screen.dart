import 'package:flutter/material.dart';
import '../../core/database/profile_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileRepository = ProfileRepository();
  late Map<String, dynamic> _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final data = await _profileRepository.getProfile();
    setState(() => _profileData = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              initialValue: _profileData['full_name'],
              decoration: const InputDecoration(labelText: 'Full Name'),
              onChanged: (value) => _profileData['full_name'] = value,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _profileRepository.updateProfile(_profileData),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
