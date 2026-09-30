import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../patients/booking_screen.dart';

class DoctorDetailsScreen extends StatelessWidget {
  const DoctorDetailsScreen({
    super.key,
    required this.doctorId,
    required this.data,
  });

  final String doctorId;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final bio = (data['bio'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('بيانات الدكتور'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------- الرأس ----------
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
                      'د. ${data['name'] ?? ''}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('${data['speciality'] ?? ''}'),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 18),
                        Text('${data['rating'] ?? 0}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ---------- نبذة ----------
          const Text('نبذه تعريفيه', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(bio.isEmpty ? 'لم تضاف' : bio),
          const SizedBox(height: 16),

          // ---------- العنوان ----------
          if (data['city'] != null)
            _infoTile(Icons.location_on, data['city'].toString()),

          const Divider(height: 32),

          // ---------- معلومات الاتصال ----------
          const Text('معلومات الاتصال', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _infoTile(Icons.email, (data['email'] ?? 'لم يضاف').toString()),
                _infoTile(Icons.phone, (data['phone'] ?? 'لم يضاف').toString()),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ---------- زر الحجز ----------
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingScreen(doctorId: doctorId, doctor: data),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('احجز موعدك الان'),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
