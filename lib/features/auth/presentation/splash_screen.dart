import 'package:flutter/material.dart';

import '../../../core/widgets/lesen_mark.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: LesenMark(size: 72)));
}
