// Background Bubble Widget
import 'dart:math' as math;
import 'package:draze/core/constants/appColors.dart';
import 'package:flutter/material.dart';

class BackgroundBubbles extends StatefulWidget {
  const BackgroundBubbles({super.key});

  @override
  State<BackgroundBubbles> createState() => _BackgroundBubblesState();
}

class _BackgroundBubblesState extends State<BackgroundBubbles>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final List<Bubble> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _initializeBubbles();
  }

  void _initializeBubbles() {
    _controllers = [];
    _animations = [];

    for (int i = 0; i < 8; i++) {
      final controller = AnimationController(
        duration: Duration(seconds: 15 + math.Random().nextInt(10)),
        vsync: this,
      );

      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.linear));

      _controllers.add(controller);
      _animations.add(animation);

      _bubbles.add(
        Bubble(
          size: 20 + math.Random().nextDouble() * 60,
          startX: math.Random().nextDouble(),
          opacity: 0.1 + math.Random().nextDouble() * 0.3,
          color: AppColors.primary.withOpacity(
            0.1 + math.Random().nextDouble() * 0.2,
          ),
          hasIcon: i % 2 == 0, // Add home icon to every other bubble
        ),
      );

      controller.repeat();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...List.generate(_bubbles.length, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              final bubble = _bubbles[index];
              return Positioned(
                left: MediaQuery.of(context).size.width * bubble.startX,
                top:
                    MediaQuery.of(context).size.height *
                    (1 - _animations[index].value),
                child: Container(
                  width: bubble.size * 1.5,
                  height: bubble.size * 1.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bubble.color,
                  ),
                  child:
                      bubble.hasIcon
                          ? Icon(
                            Icons.home,
                            color: AppColors.primary.withOpacity(0.6),
                            size: bubble.size * 0.5,
                          )
                          : null,
                ),
              );
            },
          );
        }),
      ],
    );
  }
}

class Bubble {
  final double size;
  final double startX;
  final double opacity;
  final Color color;
  final bool hasIcon;

  Bubble({
    required this.size,
    required this.startX,
    required this.opacity,
    required this.color,
    required this.hasIcon,
  });
}
