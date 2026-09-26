import 'package:flutter/material.dart';
import 'package:ssehaty/core/constants/app_colors.dart';

import 'Auth/login_page.dart';

class ChoiceScreen extends StatelessWidget {
  const ChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/welcome-bg.png', fit: BoxFit.cover),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(right: 20, bottom: 100, left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: 100),
                  Text(
                    "اهلا بيك",
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    "سجل و احجز عند دكتورك وانت في البيت",
                    style: TextStyle(fontSize: 18, color: AppColors.black),
                  ),
                  Spacer(),
                  Container(
                    width: 400,
                    height: 250,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            "سجل دلوقتي كــ",
                            style: TextStyle(
                              fontSize: 30,
                              color: AppColors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      LoginPage(isDoctor: false),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.offWhite.withValues(
                                alpha: 0.7,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              fixedSize: Size(
                                MediaQuery.of(context).size.width,
                                70,
                              ),
                            ),
                            child: Text(
                              "مريض",
                              style: TextStyle(
                                fontSize: 30,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      LoginPage(isDoctor: true),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.offWhite.withValues(
                                alpha: 0.7,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              fixedSize: Size(
                                MediaQuery.of(context).size.width,
                                70,
                              ),
                            ),
                            child: Text(
                              "دكتور",
                              style: TextStyle(
                                fontSize: 30,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
