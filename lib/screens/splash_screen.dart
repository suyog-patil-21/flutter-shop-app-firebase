import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: SizedBox(height :250,width: 200,child: FlutterLogo()))
    );
  }
}
