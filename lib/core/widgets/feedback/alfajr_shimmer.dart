import 'package:flutter/material.dart';

/// A premium, smooth Shimmer gradient loading effect for Alfajr app.
class AlfajrShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final ShapeBorder? shapeBorder;
  final EdgeInsetsGeometry? margin;

  const AlfajrShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 16,
    this.shapeBorder,
    this.margin,
  });

  const AlfajrShimmer.circular({
    super.key,
    required double size,
    this.margin,
  })  : width = size,
        height = size,
        borderRadius = size / 2,
        shapeBorder = const CircleBorder();

  const AlfajrShimmer.card({
    super.key,
    this.width = double.infinity,
    this.height = 210,
    this.borderRadius = 24,
    this.margin,
  }) : shapeBorder = null;

  const AlfajrShimmer.listTile({
    super.key,
    this.width = double.infinity,
    this.height = 76,
    this.borderRadius = 18,
    this.margin,
  }) : shapeBorder = null;

  @override
  State<AlfajrShimmer> createState() => _AlfajrShimmerState();
}

class _AlfajrShimmerState extends State<AlfajrShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: widget.shapeBorder != null
                ? ShapeDecoration(
                    shape: widget.shapeBorder!,
                    gradient: LinearGradient(
                      begin: Alignment(-1.5 + 3.0 * _controller.value, -0.3),
                      end: Alignment(0.5 + 3.0 * _controller.value, 0.3),
                      colors: const [
                        Color(0xFFE8ECEB),
                        Color(0xFFF7F9F8),
                        Color(0xFFE8ECEB),
                      ],
                    ),
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    gradient: LinearGradient(
                      begin: Alignment(-1.5 + 3.0 * _controller.value, -0.3),
                      end: Alignment(0.5 + 3.0 * _controller.value, 0.3),
                      colors: const [
                        Color(0xFFE8ECEB),
                        Color(0xFFF7F9F8),
                        Color(0xFFE8ECEB),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
