import 'dart:async';

import 'package:flutter/material.dart';
import '../calendar/cale.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return const MyTable();
        },
      ));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/bc.jpg');
  }
}
