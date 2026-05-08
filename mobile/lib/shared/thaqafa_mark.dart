// Thaqafa brand mark — Flutter port of the web's ``ThaqafaMark`` /
// ``ThaqafaLockup`` (web/src/components/design/ThaqafaMark.tsx).
//
// The mark is an 8-point khātam (rub al-hizb / two interlocking squares)
// framing the Arabic letter ث (Thā). All colours pull from the project's
// editorial tokens so dark mode flips for free.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thaqafa/core/theme/thaqafa_tokens.dart';

/// The square brand tile — paper-hi background, hairline rule border,
/// outline 8-point star in ink, ث glyph in accent verdigris. Mirrors
/// the web ``AppIconMark`` ``style="star-light"`` + ``glyph="arabic"``.
class ThaqafaMark extends StatelessWidget {
  const ThaqafaMark({this.size = 40, super.key});

  /// Pixel side of the square tile. The internal star + glyph scale
  /// proportionally, matching the design canvas's geometry.
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: t.paperHi,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(color: t.rule, width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outline 8-point star painted at 86% of the tile.
          Center(
            child: SizedBox(
              width: size * 0.86,
              height: size * 0.86,
              child: CustomPaint(
                painter: _ThaqafaStarPainter(
                  color: t.ink,
                  strokeWidth: math.max(0.6, size / 80),
                ),
              ),
            ),
          ),
          // ث glyph centered, in accent verdigris.
          Padding(
            padding: EdgeInsets.only(bottom: size * 0.04),
            child: Text(
              'ث',
              style: GoogleFonts.amiri(
                fontSize: size * 0.42,
                fontWeight: FontWeight.w500,
                color: t.accent,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal lockup: tile + italic Cormorant "Thaqafa" + accent
/// "ثقافة". Drop the Arabic on small viewports via ``hideArabic``.
class ThaqafaLockup extends StatelessWidget {
  const ThaqafaLockup({
    this.size = 40,
    this.hideArabic = false,
    super.key,
  });

  final double size;
  final bool hideArabic;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ThaqafaMark(size: size),
        SizedBox(width: size * 0.32),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Thaqafa',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: size * 0.65,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: t.ink,
                  letterSpacing: -0.4,
                  height: 1,
                ),
              ),
              if (!hideArabic) ...[
                WidgetSpan(child: SizedBox(width: size * 0.22)),
                TextSpan(
                  text: 'ثقافة',
                  style: GoogleFonts.amiri(
                    fontSize: size * 0.45,
                    fontWeight: FontWeight.w500,
                    color: t.accent,
                    height: 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Painter for the two interlocking squares forming the 8-point star.
/// Geometry matches the design canvas: vertices at 92% of the half-
/// extent, one square axis-aligned, the other rotated 45°.
class _ThaqafaStarPainter extends CustomPainter {
  _ThaqafaStarPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.miter
      ..strokeCap = StrokeCap.butt;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final half = (size.width / 2) * 0.92;

    Path makeSquare(double rotDeg) {
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final a = math.pi / 2 * i + rotDeg * math.pi / 180;
        final x = cx + half * math.cos(a);
        final y = cy + half * math.sin(a);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      return path;
    }

    canvas.drawPath(makeSquare(0), paint);
    canvas.drawPath(makeSquare(45), paint);
  }

  @override
  bool shouldRepaint(_ThaqafaStarPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
