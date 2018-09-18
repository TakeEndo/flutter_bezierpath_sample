import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bezier/tail.dart';

final double tailLength = 200.0;
final double tailPosition = 200.0;

class TailState extends State<Tail> with SingleTickerProviderStateMixin {

  Animation<double> animation;
  AnimationController controller;

  bool under = false;
  startForward() {
    return new Timer(Duration(seconds: 4), handleTimeout);
  }
  void handleTimeout() {  // callback function
    controller.forward();
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    final Animation curve =
    CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    animation = Tween(begin: 0.0, end: 100.0).animate(curve)
      ..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      })
    ..addStatusListener((status){
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        startForward();
      }
    });
    controller.forward();
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.black12,
        child: AspectRatio(
          aspectRatio: 1.0,
          child: CustomPaint(
          painter: TailCanvas(animation.value,under),
          ),
        ),
      ),
    );
  }
}

class TailCanvas extends CustomPainter{

  final double value;
  final bool under;

  TailCanvas(this.value, this.under);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = new Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30.0;

    canvas.save();
    Path path = Path();

    // 角度（90 ~ 180）
    double angle = (value * 0.9) + 90.0;
    // 下向きの場合（0 ~ 90）
    if (under) {
      angle = (-value * 0.9) + 90.0;
    }
    // ラジアンに変換
    double rad = angle * (pi / 180.0);

    // 曲げ始めの位置
    double len = value;

    // 線の開始位置
    path.moveTo(0.0, tailPosition);

    // ベジェ曲線の終了位置と、制御位置
    path.conicTo(tailLength - len, tailPosition , tailLength - len + (len * sin(rad)), (len * cos(rad)) + tailPosition, 1.3);

    // 描画する
    canvas.drawPath(path, p);

    p.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-60.0, tailPosition - 20.0), 90.0, p);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}