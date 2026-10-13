import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr/core/helper/custom_button.dart';
import 'package:qr/core/utlis/style.dart';
import 'package:qr/featuer/result/reselt_scan.dart';
import 'package:qr/featuer/scanqr/presentation/widgets/scan_camera.dart';

class ScanMy extends StatefulWidget {
  const ScanMy({super.key});

  @override
  State<ScanMy> createState() => _ScanMyState();
}

class _ScanMyState extends State<ScanMy> {
  bool _isAnalyzing = false;

  Future<void> _pickAndScanFromGallery(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return; // المستخدم لم يختر صورة

      setState(() => _isAnalyzing = true);

      final MobileScannerController controller = MobileScannerController();
      final BarcodeCapture? capture = await controller.analyzeImage(image.path);
      await controller.dispose();

      if (mounted) setState(() => _isAnalyzing = false);

      if (capture != null && capture.barcodes.isNotEmpty) {
        final resultText = capture.barcodes.first.rawValue;
        if (resultText != null && resultText.isNotEmpty) {
          // حفظ النتيجة في حساب المستخدم
          await _saveResult(resultText);

          if (context.mounted) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ResultScanView()));
          }
          return;
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'لم يتم العثور على رمز QR في هذه الصورة. يرجى اختيار صورة واضحة.',
            ),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isAnalyzing = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء قراءة الصورة: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _saveResult(String resultText) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final collection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('scans');

      await collection.doc().set({
        "result": resultText,
        "time": DateTime.now(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. زر فتح الكاميرا
          CustomButton(
            text: 'فتح الكاميرا للمسح',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (ctx) => const ScanPage()));
            },
          ),

          SizedBox(height: 14.h),

          // 2. خيار تحميل من الجهاز (المعرض)
          CustomButton(
            text: 'تحميل من الجهاز ',
            isLoading: _isAnalyzing,
            color: const Color(0xFFFFF3ED),
            textColor: Styles.kPrimaryColor,
            onPressed: () => _pickAndScanFromGallery(context),
          ),

          SizedBox(height: 14.h),

          // 3. زر سجل النتائج
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
