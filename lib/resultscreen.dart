import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:maskdetection/main.dart';

class ResultScreen extends StatelessWidget {
  final bool result;
  final CameraController cameraController;
  const ResultScreen(
      {Key? key, required this.result, required this.cameraController})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    cameraController.dispose();
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const MyHomePage(),
        ));
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Text(result ? "Mask Detected" : "Mask Not Detected"),
        ),
      ),
    );
  }
}
