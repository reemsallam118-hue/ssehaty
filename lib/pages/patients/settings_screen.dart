import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void showMessage(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> resetPassword(BuildContext context) async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (context.mounted) showMessage(context, 'تم إرسال رابط تغيير كلمة السر إلى $email');
    } on FirebaseAuthException catch (e) {
      if (context.mounted) showMessage(context, e.message ?? e.code);
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    // كلمة السر شغالة فعلاً، والباقي placeholder لحد ما تقرري تعملي فيه إيه
    final items = <(IconData, String, VoidCallback)>[
      (Icons.person, 'إعدادات الحساب', () => showMessage(context, 'قريباً')),
      (Icons.lock, 'كلمة السر', () => resetPassword(context)),
      (Icons.notifications, 'إعدادات الإشعارات', () => showMessage(context, 'قريباً')),
      (Icons.shield, 'الخصوصية', () => showMessage(context, 'قريباً')),
      (Icons.help, 'المساعدة والدعم', () => showMessage(context, 'قريباً')),
      (Icons.person_add, 'دعوة صديق', () => showMessage(context, 'قريباً')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('الاعدادات'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: items.map((item) {
                  return Card(
                    color: AppColors.offWhite,
                    elevation: 0,
                    child: ListTile(
                      leading: Icon(item.$1, color: AppColors.primary),
                      title: Text(item.$2),
                      trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
                      onTap: item.$3,
                    ),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: () => logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffFF4D67),
                foregroundColor: AppColors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('تسجيل خروج'),
            ),
          ],
        ),
      ),
    );
  }
}
