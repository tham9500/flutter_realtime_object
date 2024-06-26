import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:freewill_fx_widgets/fx.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'camera.dart';
import 'bndbox.dart';
import 'models.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomePage(this.cameras, {super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<dynamic> _recognitions = [];
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";

  @override
  void initState() {
    loadModel();
    super.initState();
  }

  Future loadModel() async {
    Tflite.close();
    String res;
    try {
      switch (_model) {
        case yolo:
          res = (await Tflite.loadModel(
            model: "assets/yolov2_tiny.tflite",
            labels: "assets/yolov2_tiny.txt",
          ))!;
          break;

        case mobilenet:
          res = (await Tflite.loadModel(
              model: "assets/mobilenet_v1_1.0_224.tflite",
              labels: "assets/mobilenet_v1_1.0_224.txt"))!;
          break;

        case posenet:
          res = (await Tflite.loadModel(
              model: "assets/posenet_mv1_075_float_from_checkpoints.tflite"))!;
          break;

        default:
          res = (await Tflite.loadModel(
              model: "assets/ssd_mobilenet.tflite",
              labels: "assets/ssd_mobilenet.txt"))!;
      }
      print(res);
    } catch (e) {
      print('Failed to load model.');
    }
  }

  onSelect(model) {
    setState(() {
      _model = model;
    });
    loadModel();
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: _model == ""
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    child: const FXText(ssd),
                    onTap: () => onSelect(ssd),
                  ),
                  InkWell(
                    child: const FXText(yolo),
                    onTap: () => onSelect(yolo),
                  ),
                  InkWell(
                    child: const FXText(mobilenet),
                    onTap: () => onSelect(mobilenet),
                  ),
                  InkWell(
                    child: const FXText(posenet),
                    onTap: () => onSelect(posenet),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                Camera(
                  widget.cameras,
                  _model,
                  setRecognitions,
                ),
                BndBox(
                    _recognitions,
                    math.max(_imageHeight, _imageWidth),
                    math.min(_imageHeight, _imageWidth),
                    screen.height,
                    screen.width,
                    _model),
              ],
            ),
    );
  }
}
