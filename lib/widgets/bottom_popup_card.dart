import 'package:flutter/material.dart';
import '../utils/app_style.dart';

class BottomPopupCard extends StatelessWidget {
  final String message;
  final bool success;
  const BottomPopupCard({super.key, required this.message, this.success = true});

  @override
  Widget build(BuildContext context) {
    final borderColor = success ? AppStyle.accentColor : Colors.grey.shade700;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppStyle.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor.withOpacity(0.9), width: 1.2),
            boxShadow: AppStyle.softShadow,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: borderColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
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
