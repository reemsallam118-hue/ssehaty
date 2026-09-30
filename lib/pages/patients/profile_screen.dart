import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final bioController = TextEditingController();
  final cityController = TextEditingController();
  final specialityController = TextEditingController();

  final userRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    bioController.dispose();
    cityController.dispose();
    specialityController.dispose();
    super.dispose();
  }

  Future<void> edit(Map<String, dynamic> data) async {
    nameController.text = data['name'] ?? '';
    phoneController.text = data['phone'] ?? '';
    bioController.text = data['bio'] ?? '';
    cityController.text = data['city'] ?? '';
    specialityController.text = data['speciality'] ?? '';
    final isDoctor = data['role'] == 'doctor';

    final save = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تعديل الحساب'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'الاسم')),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
              ),
              TextField(
                controller: bioController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'نبذه تعريفيه'),
              ),
              if (isDoctor) ...[
                TextField(
                  controller: specialityController,
                  decoration: const InputDecoration(labelText: 'التخصص'),
                ),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'المدينة'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حفظ')),
        ],
      ),
    );

    if (save == true) {
      await userRef.update({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'bio': bioController.text.trim(),
        if (isDoctor) 'speciality': specialityController.text.trim(),
        if (isDoctor) 'city': cityController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userRef.snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        if (data == null) return const Center(child: CircularProgressIndicator());

        final bio = (data['bio'] ?? '').toString();
        final phone = (data['phone'] ?? '').toString();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: IconButton(
                icon: Icon(Icons.settings, color: AppColors.primary),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, size: 40, color: AppColors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data['name'] ?? ''}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (data['role'] == 'doctor') Text('${data['speciality'] ?? ''}'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => edit(data),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                        ),
                        child: const Text('تعديل الحساب'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('نبذه تعريفيه', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(bio.isEmpty ? 'لم تضاف' : bio),
            const Divider(height: 32),
            const Text('معلومات التواصل', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(children: [
                    Icon(Icons.email, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text('${data['email'] ?? ''}')),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.phone, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(phone.isEmpty ? 'لم تضاف' : phone)),
                  ]),
                  if (data['role'] == 'doctor') ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      Icon(Icons.location_on, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${data['city'] ?? 'لم تضاف'}')),
                    ]),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
