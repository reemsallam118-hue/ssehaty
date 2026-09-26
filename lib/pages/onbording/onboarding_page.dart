import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:ssehaty/pages/choice_screen.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IntroductionScreen(
          pages: [
            PageViewModel(
              title: "ابحث عن دكتور متخصص",
              body: "ابحث عن اطباء متخصصين خبراء .",
              image: Center(
                child: SvgPicture.asset("assets/on1.svg", height: 250),
              ),

              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: "سهولة الحجز",
              body: "احجز المواعيد ب ضغطة زر",
              image: Center(
                child: SvgPicture.asset("assets/on2.svg", height: 250),
              ),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: "امن و سري",
              body: "كن مطمئن لخصوصيتك",
              image: Center(
                child: SvgPicture.asset("assets/on3.svg", height: 250),
              ),
              decoration: getPageDecoration(),
            ),
          ],

          // 2. التحكم بأزرار التنقل والإنهاء
          showSkipButton: true,
          skip: const Text(
            "تخطي",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          next: const Icon(Icons.arrow_forward),
          done: const Text(
            "هيا بنا",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),

          // 3. الإجراء المتخذ عند الضغط على زر الإنهاء أو التخطي
          onDone: () => _onIntroEnd(context),
          onSkip: () => _onIntroEnd(context),

          // 4. تخصيص مؤشر النقاط السفلي (Dots)
          dotsDecorator: DotsDecorator(
            size: const Size.square(10.0),
            activeSize: const Size(20.0, 10.0),
            activeColor: Theme.of(context).primaryColor,
            color: Colors.black26,
            spacing: const EdgeInsets.symmetric(horizontal: 3.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
        ),
      ),
    );
  }

  // الدالة المسؤولة عن الانتقال للشاشة الرئيسية بعد انتهاء المقدمة
  void _onIntroEnd(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const ChoiceScreen()));
  }

  // تخصيص تنسيقات النصوص والصفحات
  PageDecoration getPageDecoration() => const PageDecoration(
    footerFlex: 1,
    titleTextStyle: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
    bodyTextStyle: TextStyle(fontSize: 16.0, color: Colors.grey),
    imagePadding: EdgeInsets.all(24.0),
    pageColor: Colors.white,
  );
}
