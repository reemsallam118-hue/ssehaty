import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../doctors/home.dart';
import 'appointments_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class PatientHome extends StatefulWidget {
  const PatientHome({super.key});

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  int currentIndex = 0;

  final pages = const [
    Home(),
    SearchScreen(),
    AppointmentsScreen(),
    ProfileScreen(),
  ];

  final titles = const ['صحتي', 'ابحث عن دكتور', 'مواعيد الحجز', 'الحساب الشخصي'];

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
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.offWhite,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.blueGrey,
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'البحث'),
          BottomNavigationBarItem(icon: Icon(Icons.date_range), label: 'المواعيد'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الحساب'),
        ],
      ),
    );
  }
}
