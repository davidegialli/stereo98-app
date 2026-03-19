import 'package:flutter/material.dart';
import 'package:stereo98/utils/dimsensions.dart';
import 'package:stereo98/utils/theme_helper.dart';

class MenuItemWidget extends StatelessWidget {
  const MenuItemWidget({
    super.key,
    required this.screenName,
    required this.icon,
    required this.onPressed,
  });

  final String screenName;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      splashColor: context.s98Surface(0.5),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: Dimensions.defaultPaddingSize * 0.5,
        ),
        child: Row(
          children: [
            Expanded(
              child: Icon(icon, size: 30, color: context.s98Icon),
            ),
            Expanded(
              flex: 3,
              child: Text(
                screenName,
                style: TextStyle(
                  color: context.s98Text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
