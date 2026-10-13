import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr/core/helper/custom_button.dart';
import 'package:qr/featuer/result/reselt_scan.dart';
import 'package:qr/featuer/scanqr/presentation/widgets/scan_camera.dart';

class ScanMy extends StatelessWidget {
  const ScanMy({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomButton(
            text: 'فتح الكاميرا للمسح',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const ScanPage()),
              );
            },
          ),
          SizedBox(height: 16.h),
          CustomButton(
            text: 'سجل المسح والنتائج',
            color: Colors.white,
            textColor: Colors.black87,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const ResultScanView()),
              );
            },
          ),
        ],
      ),
    );
  }
}
