import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ssehaty/pages/choice_screen.dart';
import 'package:ssehaty/pages/doctors/doctor_home.dart';
import 'package:ssehaty/pages/patients/patient_home.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final user = authSnapshot.data;

          if (user == null) {
            return ChoiceScreen();
          }

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasError ||
                  !userSnapshot.hasData ||
                  !userSnapshot.data!.exists) {
                return ChoiceScreen();
              }

              final data = userSnapshot.data!.data() as Map<String, dynamic>;

              final role = data["role"];

              if (role == "doctor") {
                return DoctorHome();
              }

              if (role == "patient") {
                return PatientHome();
              }

              return ChoiceScreen();
            },
          );
        },
      ),
    );
  }
}
