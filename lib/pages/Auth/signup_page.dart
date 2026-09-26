import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ssehaty/pages/patients/patient_home.dart';

import '../../core/constants/app_colors.dart';
import '../doctors/doctor_home.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key, required this.isDoctor});

  final bool isDoctor;

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final specialityController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 100),

              Image.asset("assets/logo.png", height: 200),

              Text(
                "انشا حساب الان كـ "
                "${widget.isDoctor ? "دكتور" : "مريض"}",
                style: TextStyle(
                  fontSize: 24,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "enter email";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: "email",
                  suffixIcon: Icon(Icons.email, color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "enter name";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: "name",
                ),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "enter password";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: "password",
                  suffixIcon: Icon(Icons.password, color: AppColors.primary),
                ),
              ),

              if (widget.isDoctor) ...[
                const SizedBox(height: 30),

                TextFormField(
                  controller: specialityController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "enter speciality";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "speciality",
                  ),
                ),
              ],

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  fixedSize: Size(MediaQuery.of(context).size.width, 70),
                ),
                child: Text(
                  "انشاء حساب",
                  style: TextStyle(fontSize: 30, color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> signup() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

    final user = credential.user;

    if (user == null) {
      return;
    }

    final role = widget.isDoctor ? "doctor" : "patient";

    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "role": role,
      if (widget.isDoctor) "speciality": specialityController.text.trim(),
    });

    if (!mounted) {
      return;
    }

    if (role == "doctor") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DoctorHome()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PatientHome()),
      );
    }
  }
}
