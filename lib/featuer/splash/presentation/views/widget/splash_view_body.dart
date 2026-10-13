import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:qr/core/utlis/router.dart';
import 'package:qr/core/utlis/style.dart';

import '../../../../../core/utlis/assets.dart';

class SplashViewbody extends StatefulWidget {
  const SplashViewbody({super.key});

  @override
  State<SplashViewbody> createState() => _SplashViewbodyState();
}

class _SplashViewbodyState extends State<SplashViewbody>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Offset> slidingAnimation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();
    initAnimations();
    navigateToHome();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slidingAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(AssetsData.qr, width: 150, height: 150),
                const SizedBox(height: 16),
                const Text(
                  "ماسح الرمز QR",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Styles.kPrimaryColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void initAnimations() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    slidingAnimation =
        Tween<Offset>(begin: const Offset(0, 2), end: Offset.zero).animate(
          CurvedAnimation(parent: animationController, curve: Curves.easeOut),
        );

    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    animationController.forward();
  }

  void navigateToHome() {
    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          try {
            await user.reload();
            user = FirebaseAuth.instance.currentUser;
          } catch (_) {}
          if (user != null && user.emailVerified && mounted) {
            context.go(AppRouter.kScanqr);
            return;
          }
        }
        if (mounted) {
          context.go(AppRouter.kLoginView);
        }
      }
    });
  }
}
