import 'dart:math';
import 'package:flutter/material.dart';
import '../models/aid_card_model.dart';
import 'digital_card_back.dart';
import 'digital_card_front.dart';

class DigitalAidCardWidget extends StatefulWidget {
  final AidCardModel card;

  const DigitalAidCardWidget({super.key, required this.card});

  @override
  State<DigitalAidCardWidget> createState() => _DigitalAidCardWidgetState();
}

class _DigitalAidCardWidgetState extends State<DigitalAidCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    )..addListener(() {
        if (_flipAnimation.value >= 0.5 && _showFront) {
          setState(() {
            _showFront = false;
          });
        } else if (_flipAnimation.value < 0.5 && !_showFront) {
          setState(() {
            _showFront = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_flipController.isAnimating) return;
    if (_showFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * pi;
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(angle),
          alignment: Alignment.center,
          child: _showFront
              ? DigitalCardFront(
                  card: widget.card,
                  onFlip: _toggleFlip,
                )
              : Transform(
                  transform: Matrix4.identity()..rotateY(pi),
                  alignment: Alignment.center,
                  child: DigitalCardBack(
                    card: widget.card,
                    onFlip: _toggleFlip,
                  ),
                ),
        );
      },
    );
  }
}
