import 'package:flutter/material.dart';

import '../utils/math_utils.dart';

class CustButton extends StatelessWidget {
  final Function()? onPressed;
  final Widget child;
  final bool isOutlined;
  final bool? isRounded;
  final Color? color;
  final BorderSide? bordercolor;
  final Widget? icon;

  const CustButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isRounded = false,
    this.color,
    this.isOutlined = false,
    this.bordercolor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = isRounded == true ? 50 : 5;
    return isOutlined
        ? OutlinedButton.icon(
            icon: icon,
            onPressed: onPressed,
            style: ButtonStyle(
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              minimumSize: WidgetStatePropertyAll(
                  Size(double.minPositive, getSize(context, 50))),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius.toDouble()),
                ),
              ),
            ),
            label: child,
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: icon,
            label: child,
            style: ButtonStyle(
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              backgroundColor: WidgetStateProperty.all(
                color ?? Theme.of(context).colorScheme.primary,
              ),
              foregroundColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.onPrimary,
              ),
              minimumSize:
                  const WidgetStatePropertyAll(Size(double.minPositive, 50)),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  //side: BorderSide(color: Colors.black,width: 4),
                  side: bordercolor ?? BorderSide.none,
                  borderRadius: BorderRadius.circular(borderRadius.toDouble()),
                ),
              ),
            ),
          );
  }
}
