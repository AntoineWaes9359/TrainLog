import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ScanLoading extends StatefulWidget {
  final XFile image;
  final String status;

  const ScanLoading({
    super.key,
    required this.image,
    required this.status,
  });

  @override
  State<ScanLoading> createState() => _ScanLoadingState();
}

class _ScanLoadingState extends State<ScanLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image du billet
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    Image.file(
                      File(widget.image.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 500))
                        .blurXY(
                            begin: 10,
                            end: 0,
                            duration: const Duration(milliseconds: 500)),
                    // Overlay avec effet de scan
                    AnimatedBuilder(
                      animation: _scanAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(
                            MediaQuery.of(context).size.width * 0.8,
                            MediaQuery.of(context).size.height * 0.6,
                          ),
                          painter: ScanPainter(
                            scanPosition: _scanAnimation.value,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 500))
                .scale(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 500),
                    begin: const Offset(0.8, 0.8)),
          ),
          // Texte de statut
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                widget.status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              )
                  .animate()
                  .fadeIn(
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(milliseconds: 500))
                  .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: const Duration(milliseconds: 500)),
            ),
          ),
        ],
      ),
    );
  }
}

class ScanPainter extends CustomPainter {
  final double scanPosition;

  ScanPainter({required this.scanPosition});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Créer un dégradé pour l'effet de scan
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withValues(alpha: 0),
        Colors.white.withValues(alpha: 0.5),
        Colors.white.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final scanRect = Rect.fromLTWH(
      0,
      size.height * scanPosition - 50,
      size.width,
      100,
    );

    // Dessiner l'overlay sombre
    canvas.drawRect(rect, paint);

    // Dessiner la barre de scan
    final scanPaint = Paint()
      ..shader = gradient.createShader(scanRect)
      ..style = PaintingStyle.fill;

    canvas.drawRect(scanRect, scanPaint);
  }

  @override
  bool shouldRepaint(ScanPainter oldDelegate) => true;
}
