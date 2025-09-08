import 'package:flutter/material.dart';

class BackgroundImageContainer extends StatelessWidget {
  final String imagePath;
  final Widget child;

  const BackgroundImageContainer({
    Key? key,
    required this.imagePath,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.fill,
        ),
      ),
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: child,
      ),
    );
  }
}
