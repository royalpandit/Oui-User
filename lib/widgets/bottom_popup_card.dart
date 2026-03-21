import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomPopupCard extends StatelessWidget {
  final String message;
  final bool success;
  const BottomPopupCard({super.key, required this.message, this.success = true});

  @override
  Widget build(BuildContext context) {
    final borderColor = success ? const Color(0xFFE5E2E1) : const Color(0xFF5E5E5E);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1B1B1B),
            border: Border.all(color: borderColor.withValues(alpha: 0.6), width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                color: borderColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.manrope(fontSize: 14, color: const Color(0xFFE5E2E1)),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                success ? Icons.check_circle : Icons.error_outline,
                color: borderColor,
                size: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
