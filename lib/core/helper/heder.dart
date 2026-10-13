import 'package:flutter/material.dart';

class Heder extends StatelessWidget {
  final Widget? body;
  final Widget? topContent;
  final dynamic image;
  final IconData? icon;

  const Heder({
    super.key,
    this.body,
    this.image,
    this.icon,
    this.topContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Top black area — greeting or back icon
          SafeArea(
            bottom: false,
            child: topContent ??
                (icon != null
                    ? Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 20, right: 20, left: 20),
                          child: GestureDetector(
                            onTap: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            },
                            child: Icon(
                              icon,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(height: 40)),
          ),

          // White rounded content area
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  // Image top-right
                  if (image != null)
                    Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Image.asset(image),
                      ),
                    ),
                  const SizedBox(height: 50),
                  body!,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
