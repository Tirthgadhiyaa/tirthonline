import 'package:flutter/material.dart';

class CustText extends StatelessWidget {
  final String? title;
  final TextStyle? style;
  final TextAlign? align;
  final Alignment? btnTextAlignment;
  final int? maxLine;
  final TextOverflow? textOverflow;
  final void Function()? onTap;

  const CustText(
    this.title, {
    Key? key,
    this.style,
    this.align = TextAlign.start,
    this.btnTextAlignment,
    this.maxLine,
    this.textOverflow,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget textWidget = Text(
      title ?? "",
      style: style,
      softWrap: true,
      textAlign: align,
      maxLines: maxLine,
      overflow: textOverflow,

    );
    return onTap == null
        ? textWidget
        : TextButton(
            onPressed: onTap,
            style: ButtonStyle(
              padding: MaterialStateProperty.all(
                const EdgeInsets.all(5),
              ),
            ),
            child: Align(
              alignment: btnTextAlignment ?? Alignment.center,
              child: textWidget,
            ),
          );
  }
}
