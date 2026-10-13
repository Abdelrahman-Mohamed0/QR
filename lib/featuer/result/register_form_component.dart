import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr/core/helper/result_card.dart';
import 'package:qr/core/utlis/assets.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultComponents extends StatelessWidget {
  const ResultComponents({super.key});

  // 🔹 نعتبر أي نص فيه نقطة على الأقل كأنه رابط
  bool _isURL(String text) {
    final regex = RegExp(r'^(?:https?:\/\/)?(?:www\.)?[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}');
    return regex.hasMatch(text);
  }

  // 🔹 محاولة فتح الرابط مهما كان شكله
  Future<void> _openURL(String text) async {
    String fixedUrl = text.trim();

    // لو الرابط مش بيبدأ بـ http نضيفه تلقائيًا
    if (!fixedUrl.startsWith('http://') && !fixedUrl.startsWith('https://')) {
      fixedUrl = 'https://$fixedUrl';
    }

    final uri = Uri.tryParse(fixedUrl);

    if (uri == null) {
      debugPrint('❌ Invalid URI: $fixedUrl');
      return;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('❌ Could not launch $fixedUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("scans")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("لا توجد نتائج مسح سابقة"));
        }

        final docs = snapshot.data!.docs;

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final result = data["result"] ?? "";
              final isLink = _isURL(result);
          
              return GestureDetector(
                onTap: () async {
                  if (isLink) {
                    await _openURL(result);
                  } else {
                    await Clipboard.setData(ClipboardData(text: result));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم نسخ النص إلى الحافظة بنجاح'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                child: ResultCard(
                  resulttext: result,
                  image: AssetsData.p32,
                  isLink: isLink,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
