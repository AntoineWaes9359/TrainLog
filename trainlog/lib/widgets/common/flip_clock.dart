import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trainlog/theme/colors.dart';
import 'package:trainlog/theme/typography.dart';

class FlipClock extends StatefulWidget {
  final DateTime time;
  final TextStyle? style;
  final Duration animationDuration;

  const FlipClock({
    super.key,
    required this.time,
    this.style,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<FlipClock> createState() => _FlipClockState();
}

class _FlipClockState extends State<FlipClock> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  String _currentTime = '';
  String _nextTime = '';
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _currentTime = DateFormat('HH:mm').format(widget.time);

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));
  }

  @override
  void didUpdateWidget(FlipClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.time != widget.time) {
      _nextTime = DateFormat('HH:mm').format(widget.time);
      if (_nextTime != _currentTime) {
        _startAnimation();
      }
    }
  }

  void _startAnimation() {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    _controller.forward().then((_) {
      setState(() {
        _currentTime = _nextTime;
        _isAnimating = false;
      });
      _controller.reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = AppTypography.displaySmall.copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.bold,
    );

    final textStyle = widget.style ?? defaultStyle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Texte actuel qui glisse vers le bas
              Transform.translate(
                offset: Offset(0, _slideAnimation.value * 20),
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Text(
                    _currentTime,
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Nouveau texte qui arrive par le haut
              Transform.translate(
                offset: Offset(0, (_slideAnimation.value - 1) * 20),
                child: Opacity(
                  opacity: 1 - _opacityAnimation.value,
                  child: Text(
                    _nextTime.isNotEmpty ? _nextTime : _currentTime,
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
