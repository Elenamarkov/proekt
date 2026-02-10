import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(253, 177, 224, 1.0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'DreamScape',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          // Small airplane image
          Positioned(
            top: -20,
            right: 0,
            child: Image.asset(
              'lib/assets/images/airplane_icon.png',
              width: 45,
              height: 45,
            ),
          ),
          // Big airplane image
          Positioned(
            bottom: 10,
            left: -30,
            child: Image.asset(
              'lib/assets/images/airplane_icon.png',
              width: 80,
              height: 80,
            ),
          ),
        ],
      ),
    );
  }
}
