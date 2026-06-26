import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FloatingNotchedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double cornerRadius = 24.0;
    double notchRadius = 54.0;
    double startNotchX = (size.width / 2) - notchRadius;
    double endNotchX = (size.width / 2) + notchRadius;
    double centerX = size.width / 2;
    double depth = 42.0;
    double controlPointX = notchRadius * 0.55;

    final path = Path();
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    path.lineTo(startNotchX, 0);

    path.cubicTo(
      centerX - controlPointX, 0,
      centerX - controlPointX, depth,
      centerX, depth,
    );
    path.cubicTo(
      centerX + controlPointX, depth,
      centerX + controlPointX, 0,
      endNotchX, 0,
    );

    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(size.width, size.height, size.width - cornerRadius, size.height);
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
    path.close();

    canvas.drawShadow(
      path,
      const Color(0xFF000000),
      12.0,
      true,
    );

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final borderPath = Path();
    borderPath.moveTo(0, cornerRadius);
    borderPath.quadraticBezierTo(0, 0, cornerRadius, 0);
    borderPath.lineTo(startNotchX, 0);
    borderPath.cubicTo(
      centerX - controlPointX, 0,
      centerX - controlPointX, depth,
      centerX, depth,
    );
    borderPath.cubicTo(
      centerX + controlPointX, depth,
      centerX + controlPointX, 0,
      endNotchX, 0,
    );
    borderPath.lineTo(size.width - cornerRadius, 0);
    borderPath.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    final borderPaint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DoughnutChartPainter extends CustomPainter {
  final double calorieProgress;
  final double carbPct;
  final double proteinPct;
  final double fatPct;
  final double otherPct;

  DoughnutChartPainter({
    required this.calorieProgress,
    required this.carbPct,
    required this.proteinPct,
    required this.fatPct,
    required this.otherPct,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);

    double outerRadius = size.width / 2 - 2;
    double innerRadius = outerRadius - 14;

    Paint outerTrackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = const Color(0xFFF1F5F9);
    canvas.drawCircle(center, outerRadius, outerTrackPaint);

    Paint outerProgressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    outerProgressPaint.color = const Color(0xFF108967);
    double outerStartAngle = -3.141592653589793 / 2;
    double outerSweepAngle = (calorieProgress.clamp(0.0, 1.0)) * 2 * 3.141592653589793;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      outerStartAngle,
      outerSweepAngle,
      false,
      outerProgressPaint,
    );

    double innerStrokeWidth = 11;
    Rect innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    Paint innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = innerStrokeWidth
      ..strokeCap = StrokeCap.butt;

    double innerStartAngle = -3.141592653589793 / 2;
    double gap = 0.05;

    innerPaint.color = const Color(0xFFFFA500);
    double sweepAngleCarb = carbPct * 2 * 3.141592653589793;
    if (sweepAngleCarb > gap) {
      canvas.drawArc(innerRect, innerStartAngle + gap / 2, sweepAngleCarb - gap, false, innerPaint);
    } else {
      canvas.drawArc(innerRect, innerStartAngle, sweepAngleCarb, false, innerPaint);
    }
    innerStartAngle += sweepAngleCarb;

    innerPaint.color = const Color(0xFF8B5CF6);
    double sweepAngleProtein = proteinPct * 2 * 3.141592653589793;
    if (sweepAngleProtein > gap) {
      canvas.drawArc(innerRect, innerStartAngle + gap / 2, sweepAngleProtein - gap, false, innerPaint);
    } else {
      canvas.drawArc(innerRect, innerStartAngle, sweepAngleProtein, false, innerPaint);
    }
    innerStartAngle += sweepAngleProtein;

    innerPaint.color = Colors.redAccent;
    double sweepAngleFat = fatPct * 2 * 3.141592653589793;
    if (sweepAngleFat > gap) {
      canvas.drawArc(innerRect, innerStartAngle + gap / 2, sweepAngleFat - gap, false, innerPaint);
    } else {
      canvas.drawArc(innerRect, innerStartAngle, sweepAngleFat, false, innerPaint);
    }
    innerStartAngle += sweepAngleFat;

    innerPaint.color = const Color(0xFFE2E8F0);
    double sweepAngleOther = otherPct * 2 * 3.141592653589793;
    if (sweepAngleOther > gap) {
      canvas.drawArc(innerRect, innerStartAngle + gap / 2, sweepAngleOther - gap, false, innerPaint);
    } else {
      canvas.drawArc(innerRect, innerStartAngle, sweepAngleOther, false, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
