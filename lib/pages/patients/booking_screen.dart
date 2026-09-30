import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.doctorId, required this.doctor});

  final String doctorId;
  final Map<String, dynamic> doctor;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final descController = TextEditingController();

  final times = const ['14:00', '15:00', '16:00', '17:00', '18:00', '19:00'];
  DateTime? date;
  String? time;
  bool isLoading = false;

  String get dateText => date == null
      ? ''
      : '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    // نملا الاسم والهاتف تلقائي من بيانات المريض
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((doc) {
      final data = doc.data();
      if (data == null || !mounted) return;
      nameController.text = data['name'] ?? '';
      phoneController.text = data['phone'] ?? '';
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => date = picked);
  }

  void showMessage(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> book() async {
    if (!formKey.currentState!.validate()) return;
    if (date == null || time == null) {
      showMessage('اختر التاريخ والوقت');
      return;
    }

    setState(() => isLoading = true);
    try {
      final col = FirebaseFirestore.instance.collection('appointments');

      // نتأكد إن الموعد مش محجوز قبل كده عند نفس الدكتور
      final sameDay = await col
          .where('doctorId', isEqualTo: widget.doctorId)
          .where('date', isEqualTo: dateText)
          .get();
      if (sameDay.docs.any((d) => d['time'] == time)) {
        showMessage('الموعد ده محجوز، اختر وقت تاني');
        return;
      }

      await col.add({
        'doctorId': widget.doctorId,
        'patientId': FirebaseAuth.instance.currentUser!.uid,
        'doctorName': widget.doctor['name'] ?? '',
        'speciality': widget.doctor['speciality'] ?? '',
        'patientName': nameController.text.trim(),
        'patientPhone': phoneController.text.trim(),
        'description': descController.text.trim(),
        'date': dateText,
        'time': time,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.popUntil(context, (route) => route.isFirst);
      messenger.showSnackBar(const SnackBar(content: Text('تم الحجز بنجاح')));
    } on FirebaseException catch (e) {
      showMessage('${e.code}: ${e.message}');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  InputDecoration decoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: AppColors.offWhite,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('احجز مع دكتور'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: AppColors.offWhite,
              elevation: 0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: AppColors.white),
                ),
                title: Text('د. ${widget.doctor['name'] ?? ''}'),
                subtitle: Text('${widget.doctor['speciality'] ?? ''}'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('اسم المريض'),
            const SizedBox(height: 6),
            TextFormField(
              controller: nameController,
              decoration: decoration('الاسم'),
              validator: (v) => v == null || v.trim().isEmpty ? 'ادخل الاسم' : null,
            ),
            const SizedBox(height: 16),
            const Text('رقم الهاتف'),
            const SizedBox(height: 6),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: decoration('رقم الهاتف'),
              validator: (v) => v == null || v.trim().length < 10 ? 'ادخل رقم صحيح' : null,
            ),
            const SizedBox(height: 16),
            const Text('وصف الحالة'),
            const SizedBox(height: 6),
            TextFormField(
              controller: descController,
              maxLines: 4,
              decoration: decoration('اكتب وصف مختصر للحالة'),
            ),
            const SizedBox(height: 16),
            const Text('تاريخ الحجز'),
            const SizedBox(height: 6),
            InkWell(
              onTap: pickDate,
              child: InputDecorator(
                decoration: decoration('').copyWith(
                  prefixIcon: Icon(Icons.calendar_month, color: AppColors.primary),
                ),
                child: Text(date == null ? 'ادخل تاريخ الحجز' : dateText),
              ),
            ),
            const SizedBox(height: 16),
            const Text('وقت الحجز'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: times.map((t) {
                return ChoiceChip(
                  label: Text(t),
                  selected: time == t,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: time == t ? AppColors.white : AppColors.black,
                  ),
                  onSelected: (_) => setState(() => time = t),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : book,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? CircularProgressIndicator(color: AppColors.white)
                  : const Text('تأكيد الحجز'),
            ),
          ],
        ),
      ),
    );
  }
}
