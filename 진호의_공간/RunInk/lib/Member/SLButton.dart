import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onPressed;

  const SocialButton({
    Key? key,
    required this.imagePath,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 24),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}