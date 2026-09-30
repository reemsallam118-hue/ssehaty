import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_colors.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  Future<void> confirmDelete(BuildContext context, DocumentReference ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الموعد'),
        content: const Text('هل تريد حذف هذا الحجز؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok == true) await ref.delete();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('حصل خطأ في تحميل المواعيد'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        // الترتيب في الكود عشان منحتاجش index
        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) => '${a['date']} ${a['time']}'.compareTo('${b['date']} ${b['time']}'));

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset('assets/no_scheduled.svg', height: 180),
                const SizedBox(height: 12),
                const Text('لا توجد مواعيد محجوزة'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            return Card(
              color: AppColors.offWhite,
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'د. ${data['doctorName']}',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                    Text('${data['speciality']}'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_month, size: 18, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text('${data['date']}'),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, size: 18, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text('${data['time']}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('اسم المريض: ${data['patientName']}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => confirmDelete(context, doc.reference),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFF4D67),
                        foregroundColor: AppColors.white,
                        minimumSize: const Size.fromHeight(40),
                      ),
                      child: const Text('حذف الموعد'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
