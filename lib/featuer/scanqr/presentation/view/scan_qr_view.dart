import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:qr/core/helper/heder.dart';
import 'package:qr/core/helper/text_scan.dart';
import 'package:qr/core/utlis/assets.dart';
import 'package:qr/core/utlis/router.dart' show AppRouter;
import 'package:qr/core/utlis/style.dart';
import 'package:qr/featuer/scanqr/presentation/widgets/heder_scan.dart';
import 'package:qr/featuer/scanqr/presentation/widgets/icon_widget.dart';
import 'package:qr/featuer/scanqr/presentation/widgets/scan_my.dart';

class ScanQr extends StatefulWidget {
  const ScanQr({super.key});

  @override
  State<ScanQr> createState() => _ScanQrState();
}

class _ScanQrState extends State<ScanQr> {
  String? _userName;
  bool _loadingName = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        if (mounted) {
          setState(() {
            _userName = doc.data()?['name'] as String?;
            _loadingName = false;
          });
        }
      } else {
        if (mounted) setState(() => _loadingName = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingName = false);
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) context.go(AppRouter.kLoginView);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Heder(
        image: AssetsData.p2,
        topContent: _UserGreeting(
          userName: _userName,
          loading: _loadingName,
          onLogout: _logout,
        ),
        body: Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const TextScan(
                  text1: 'مسح رمز الـ QR',
                  text2:
                      'ضع رمز الاستجابة السريعة (QR) داخل الإطار للمسح، وتجنب اهتزاز الهاتف للحصول على النتيجة سريعاً',
                ),
                SizedBox(height: 50.h),
                const HederScan(),
                SizedBox(height: 16.h),
                Text(
                  'جاري قراءة الرمز...',
                  style: Styles.textStyle12.copyWith(color: Colors.white70),
                ),
                SizedBox(height: 24.h),
                const IconWidget(),
                SizedBox(height: 24.h),
                const ScanMy(),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserGreeting extends StatelessWidget {
  final String? userName;
  final bool loading;
  final VoidCallback onLogout;

  const _UserGreeting({
    required this.userName,
    required this.loading,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final String initial = (userName != null && userName!.isNotEmpty)
        ? userName![0]
        : '؟';
    final String greeting = loading
        ? ''
        : userName != null
        ? 'أهلاً، $userName 👋'
        : 'أهلاً بك!';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Styles.kPrimaryColor,
              boxShadow: [
                BoxShadow(
                  color: Styles.kPrimaryColor.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: loading
                ? Padding(
                    padding: EdgeInsets.all(12.r),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          SizedBox(width: 12.w),
          // Greeting text
          Expanded(
            child: loading
                ? const SizedBox()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'مرحباً بعودتك ✨',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
          ),
          // Logout button
          GestureDetector(
            onTap: onLogout,
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Colors.white70,
                size: 20.r,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
