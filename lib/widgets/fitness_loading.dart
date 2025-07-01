import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class FitnessLoading extends StatefulWidget {
  final double size;
  final Color? color;

  const FitnessLoading({
    Key? key,
    this.size = 50.0,
    this.color,
  }) : super(key: key);

  @override
  State<FitnessLoading> createState() => _FitnessLoadingState();
}

class _FitnessLoadingState extends State<FitnessLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.scale(
              scale: _pulseAnimation.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: widget.size,
                    color: widget.color ?? AppTheme.accentColor,
                  ),
                  Container(
                    width: widget.size * 1.5,
                    height: widget.size * 1.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (widget.color ?? AppTheme.accentColor).withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                  ),
                  Container(
                    width: widget.size * 2,
                    height: widget.size * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (widget.color ?? AppTheme.accentColor).withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 