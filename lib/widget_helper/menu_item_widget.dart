import 'package:flutter/material.dart';
import 'package:stereo98/utils/custom_color.dart';
import 'package:stereo98/utils/dimsensions.dart';

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
      splashColor: CustomColor.whiteColor.withValues(alpha: 0.5),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: Dimensions.defaultPaddingSize * 0.5,
        ),
        child: Row(
          children: [
            Expanded(
              child: Icon(icon, size: 30, color: CustomColor.whiteColor),
            ),
            Expanded(
              flex: 3,
              child: Text(
                screenName,
                style: const TextStyle(
                  color: CustomColor.whiteColor,
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
