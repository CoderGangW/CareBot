import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // child: LoadingAnimationWidget.discreteCircle(
        child: LoadingAnimationWidget.stretchedDots(
          // thirdRingColor: Color.fromARGB(255, 212, 157, 255),
          // secondRingColor: Color.fromARGB(255, 186, 95, 255),
          color: Color.fromARGB(255, 144, 0, 255),
          size: 100,
        ),
      ),
    );
  }
}
