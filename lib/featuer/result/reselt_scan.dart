import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr/core/helper/custom_button.dart';
import 'package:qr/core/helper/heder.dart';
import 'package:qr/core/helper/text_scan.dart';
import 'package:qr/core/utlis/assets.dart';
import 'package:qr/featuer/result/register_form_component.dart';

class ResultScanView extends StatelessWidget {
  const ResultScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Heder(
        image: AssetsData.p3,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const TextScan(
                text1: 'سجل نتائج المسح',
                text2:
                    'يتم حفظ سجلات الأكواد التي تم مسحها هنا تلقائياً لسهولة الرجوع إليها.',
              ),
              const ResultComponents(),
              SizedBox(height: 20.h),
              CustomButton(
                text: 'العودة',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
