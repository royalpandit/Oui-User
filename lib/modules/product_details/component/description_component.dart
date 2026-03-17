import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class DescriptionComponent extends StatelessWidget {
  const DescriptionComponent(this.description, {super.key});

  final String description;

  @override
  Widget build(BuildContext context) {
    // print('description $description');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Html(
            data: description,
            style: {
              '*': Style(
                color: Colors.grey.shade600,
                textAlign: TextAlign.justify,
                fontFeatureSettings: [
                  const FontFeature('kern'),
                  const FontFeature('liga'),
                ],
              ),
            },
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}
