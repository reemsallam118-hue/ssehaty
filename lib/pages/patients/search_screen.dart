import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_colors.dart';
import '../doctors/doctor_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => query = value.trim()),
            decoration: InputDecoration(
              hintText: 'البحث بالاسم أو التخصص',
              prefixIcon: Icon(Icons.search, color: AppColors.primary),
              filled: true,
              fillColor: AppColors.offWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'doctor')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final doctors = query.isEmpty
                    ? <QueryDocumentSnapshot<Map<String, dynamic>>>[]
                    : snapshot.data!.docs.where((doc) {
                  final data = doc.data();
                  return '${data['name']}'.contains(query) ||
                      '${data['speciality']}'.contains(query);
                }).toList();

                if (doctors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset('assets/no-search.svg', height: 180),
                        const SizedBox(height: 12),
                        Text(query.isEmpty ? 'ابحث عن دكتور' : 'لا توجد نتائج'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doc = doctors[index];
                    final data = doc.data();
                    return Card(
                      color: AppColors.offWhite,
                      elevation: 0,
                      child: ListTile(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DoctorDetailsScreen(doctorId: doc.id, data: data),
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
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
