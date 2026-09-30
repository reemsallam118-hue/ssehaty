import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'doctor_details_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  String query = '';
  String? selectedSpeciality;

  // التخصصات ثابتة في الكود (مش في Firestore)
  final specialities = const ['قلب', 'جراحة عامة', 'عظام', 'أطفال', 'جلدية', 'أسنان'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ---------- الترحيب ----------
        FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: firestore.collection('users').doc(auth.currentUser!.uid).get(),
          builder: (context, snapshot) {
            final name = snapshot.data?.data()?['name'] ?? '';
            return Text('مرحبا، $name', style: TextStyle(color: AppColors.primary));
          },
        ),
        const SizedBox(height: 8),
        const Text(
          'احجز الآن وكن جزءًا من رحلتك الصحية.',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // ---------- البحث ----------
        TextField(
          onChanged: (value) => setState(() => query = value.trim()),
          decoration: InputDecoration(
            hintText: 'ابحث عن دكتور',
            prefixIcon: Icon(Icons.search, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.offWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ---------- التخصصات ----------
        Text('التخصصات', style: TextStyle(color: AppColors.primary, fontSize: 16)),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: specialities.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final speciality = specialities[index];
              final selected = selectedSpeciality == speciality;
              return GestureDetector(
                // الضغط مرة تانية بيلغي الفلتر
                onTap: () => setState(
                      () => selectedSpeciality = selected ? null : speciality,
                ),
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.offWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services,
                        size: 32,
                        color: selected ? AppColors.white : AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        speciality,
                        style: TextStyle(
                          color: selected ? AppColors.white : AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // ---------- الأعلى تقييما ----------
        Text('الأعلى تقييما', style: TextStyle(color: AppColors.primary, fontSize: 16)),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: firestore
              .collection('users')
              .where('role', isEqualTo: 'doctor')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('حصل خطأ في تحميل الدكاترة'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            // الفلترة والترتيب في الكود عشان منحتاجش index في Firestore
            final doctors = snapshot.data!.docs.where((doc) {
              final data = doc.data();
              final name = (data['name'] ?? '').toString();
              final speciality = (data['speciality'] ?? '').toString();
              final matchesQuery = name.contains(query) || speciality.contains(query);
              final matchesSpeciality = selectedSpeciality == null ||
                  speciality.contains(selectedSpeciality!);
              return matchesQuery && matchesSpeciality;
            }).toList()
              ..sort((a, b) {
                final ra = (a.data()['rating'] ?? 0) as num;
                final rb = (b.data()['rating'] ?? 0) as num;
                return rb.compareTo(ra);
              });

            if (doctors.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('لا يوجد دكاترة')),
              );
            }

            return Column(
              children: doctors.map((doc) {
                final data = doc.data();
                return _doctorCard(doc.id, data);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _doctorCard(String doctorId, Map<String, dynamic> data) {
    return Card(
      color: AppColors.offWhite,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorDetailsScreen(doctorId: doctorId, data: data),
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.person, color: AppColors.white),
        ),
        title: Text('د. ${data['name'] ?? ''}'),
        subtitle: Text('${data['speciality'] ?? ''}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.orange, size: 18),
            Text('${data['rating'] ?? 0}'),
          ],
        ),
      ),
    );
  }
}
