import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import '../../constants/app_colors.dart';

/// A custom, premium pull-to-refresh indicator tailored to Qout's identity (قُوت).
/// Featuring an animated glowing wheat/sprout seal, dynamic pull physics, and haptic feedback.
class QoutRefreshIndicator extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final String? refreshingText;

  const QoutRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.refreshingText,
  });

  @override
  State<QoutRefreshIndicator> createState() => _QoutRefreshIndicatorState();
}

class _QoutRefreshIndicatorState extends State<QoutRefreshIndicator>
    with TickerProviderStateMixin {
  static const double _kTriggerThreshold = 75.0;
  static const double _kMaxDragOffset = 110.0;

  double _dragOffset = 0.0;
  bool _isRefreshing = false;
  bool _canRefresh = false;

  late final AnimationController _resetController;
  late final AnimationController _pulseController;
  late final AnimationController _spinController;

  late Animation<double> _resetAnimation;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseGlow;

  @override
  void initState() {
    super.initState();

    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        setState(() {
          _dragOffset = _resetAnimation.value;
        });
      });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pulseScale = Tween<double>(begin: 0.95, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseGlow = Tween<double>(begin: 6.0, end: 20.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    _pulseController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;

    if (_isRefreshing) return false;

    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.extentBefore == 0 &&
          (notification.scrollDelta ?? 0) < 0) {
        // Dragging down at the top of scroll
        final delta = (notification.scrollDelta ?? 0).abs() * 0.55;
        setState(() {
          _dragOffset = math.min(_kMaxDragOffset, _dragOffset + delta);
          _canRefresh = _dragOffset >= _kTriggerThreshold;
        });
        return false;
      }
    } else if (notification is OverscrollNotification) {
      if (notification.overscroll < 0) {
        final delta = notification.overscroll.abs() * 0.55;
        setState(() {
          final oldCanRefresh = _canRefresh;
          _dragOffset = math.min(_kMaxDragOffset, _dragOffset + delta);
          _canRefresh = _dragOffset >= _kTriggerThreshold;

          if (!oldCanRefresh && _canRefresh) {
            HapticFeedback.mediumImpact();
          }
        });
        return false;
      }
    } else if (notification is ScrollEndNotification ||
        (notification is UserScrollNotification &&
            notification.direction == ScrollDirection.idle)) {
      if (_dragOffset > 0 && !_isRefreshing) {
        if (_canRefresh) {
          _startRefresh();
        } else {
          _animateToOffset(0.0);
        }
      }
    }

    return false;
  }

  void _startRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    _animateToOffset(_kTriggerThreshold);

    _pulseController.repeat(reverse: true);
    _spinController.repeat();
    HapticFeedback.lightImpact();

    try {
      await widget.onRefresh();
    } catch (_) {
      // Ignore errors so the UI smoothly closes
    } finally {
      if (mounted) {
        _pulseController.stop();
        _spinController.stop();
        setState(() {
          _isRefreshing = false;
          _canRefresh = false;
        });
        _animateToOffset(0.0);
      }
    }
  }

  void _animateToOffset(double target) {
    _resetAnimation = Tween<double>(
      begin: _dragOffset,
      end: target,
    ).animate(
      CurvedAnimation(
        parent: _resetController,
        curve: Curves.easeOutBack,
      ),
    );
    _resetController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final progress = math.min(1.0, _dragOffset / _kTriggerThreshold);

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        children: [
          // 1. Scrollable child shifted down when pulled
          Transform.translate(
            offset: Offset(0, _dragOffset),
            child: widget.child,
          ),

          // 2. Custom Qout Pull-to-Refresh Header
          if (_dragOffset > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _dragOffset,
              child: ClipRect(
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Opacity(
                      opacity: math.min(1.0, progress * 1.2),
                      child: _buildHeaderContent(progress),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderContent(double progress) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Glowing Animated Qout Seal (Wheat & Emerald Emblem)
        AnimatedBuilder(
          animation: Listenable.merge([_pulseController, _spinController]),
          builder: (context, child) {
            final scale = _isRefreshing ? _pulseScale.value : 0.8 + (progress * 0.25);
            final glow = _isRefreshing ? _pulseGlow.value : (progress * 10);
            final rotationAngle = _isRefreshing
                ? _spinController.value * 2 * math.pi
                : (progress * math.pi * 1.5);

            return Transform.scale(
              scale: scale,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                      AppColors.accentDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _canRefresh ? AppColors.accent : Colors.white,
                    width: 2.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: _isRefreshing ? 0.45 : 0.25,
                      ),
                      blurRadius: glow,
                      spreadRadius: _isRefreshing ? 2.5 : 0.5,
                    ),
                    if (_isRefreshing)
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.35),
                        blurRadius: glow * 1.4,
                        spreadRadius: 1.5,
                      ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating shimmer dash
                    Transform.rotate(
                      angle: rotationAngle,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1.5,
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                        ),
                      ),
                    ),
                    // Center Wheat Sprout / Qout Emblem
                    Transform.rotate(
                      angle: _isRefreshing ? 0 : (1.0 - progress) * -0.4,
                      child: Icon(
                        _isRefreshing
                            ? Icons.eco_rounded
                            : (_canRefresh
                                ? Icons.spa_rounded
                                : Icons.volunteer_activism_rounded),
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const Gap(6),

        // Status caption with animated feedback
        Text(
          _isRefreshing
              ? (widget.refreshingText ?? 'جاري تحديث بيانات قُوت...')
              : (_canRefresh ? 'اترك لتحديث البيانات' : 'اسحب لتحديث بيانات قُوت'),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: _canRefresh ? AppColors.primaryDark : AppColors.textSecondaryLight,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
