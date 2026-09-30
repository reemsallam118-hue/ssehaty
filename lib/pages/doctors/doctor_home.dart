import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_colors.dart';
import '../patients/profile_screen.dart';

class DoctorHome extends StatefulWidget {
  const DoctorHome({super.key});

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  int currentIndex = 0;

  final pages = const [DoctorAppointments(), ProfileScreen()];
  final titles = const ['حجوزات المرضى', 'الحساب الشخصي'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        centerTitle: true,
        title: Text(titles[currentIndex]),
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.offWhite,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.blueGrey,
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.date_range), label: 'الحجوزات'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الحساب'),
        ],
      ),
    );
  }
}

// الحجوزات اللي المرضى عملوها عند الدكتور الحالي
class DoctorAppointments extends StatelessWidget {
  const DoctorAppointments({super.key});

  Future<void> cancel(BuildContext context, DocumentReference ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إلغاء الحجز'),
        content: const Text('هل تريد إلغاء هذا الحجز؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('رجوع')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('إلغاء الحجز')),
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
          .where('doctorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('حصل خطأ في تحميل الحجوزات'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) => '${a['date']} ${a['time']}'.compareTo('${b['date']} ${b['time']}'));

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset('assets/no_scheduled.svg', height: 180),
                const SizedBox(height: 12),
                const Text('لا توجد حجوزات'),
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
            final description = (data['description'] ?? '').toString();
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
                      '${data['patientName']}',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.phone, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text('${data['patientPhone']}'),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.calendar_month, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text('${data['date']}'),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text('${data['time']}'),
                    ]),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('الحالة: $description'),
                    ],
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => cancel(context, doc.reference),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFF4D67),
                        foregroundColor: AppColors.white,
                        minimumSize: const Size.fromHeight(40),
                      ),
                      child: const Text('إلغاء الحجز'),
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

