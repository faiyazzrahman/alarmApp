import 'package:flutter/material.dart';

class LocationHeroWidget extends StatelessWidget {
  final Color? color;

  const LocationHeroWidget({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Center(
        child: Image.asset('assets/images/Hero.png', fit: BoxFit.fill),
      ),
    );
  }
}
