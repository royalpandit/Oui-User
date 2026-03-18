import 'package:flutter/material.dart';

import '../../../widgets/custom_radio_button.dart';

class SinglePaymentCardComponent extends StatelessWidget {
  const SinglePaymentCardComponent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
      child: const ListTile(
        horizontalTitleGap: 0,
        leading: CustomRadioButton(isSelected: true),
        title: Row(
          children: [
            Icon(Icons.paypal_outlined),
            SizedBox(width: 10),
            Flexible(
              child: Text("MasterCard", maxLines: 1),
            ),
          ],
        ),
        subtitle: Text('874 ****** 8372'),
        trailing: CircleAvatar(
          backgroundColor: const Color(0xFFE0E0E0),
          radius: 13,
          child: const Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: Colors.black),
        ),
      ),
    );
  }
}
