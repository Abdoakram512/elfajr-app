import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import '../../constants/app_colors.dart';

/// A custom, premium pull-to-refresh indicator tailored to Qout's identity (قُوت).
/// Featuring a prominent animated glowing wheat/sprout seal, dynamic pull physics, and haptic feedback.
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
  static const double _kTriggerThreshold = 105.0;
  static const double _kMaxDragOffset = 155.0;

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

    _resetController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 320),
        )..addListener(() {
          setState(() {
            _dragOffset = _resetAnimation.value;
          });
        });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _pulseScale = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseGlow = Tween<double>(begin: 8.0, end: 28.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
        final delta = (notification.scrollDelta ?? 0).abs() * 0.60;
        setState(() {
          _dragOffset = math.min(_kMaxDragOffset, _dragOffset + delta);
          _canRefresh = _dragOffset >= _kTriggerThreshold;
        });
        return false;
      }
    } else if (notification is OverscrollNotification) {
      if (notification.overscroll < 0) {
        final delta = notification.overscroll.abs() * 0.60;
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
    _resetAnimation = Tween<double>(begin: _dragOffset, end: target).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOutBack),
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

          // 2. Custom Qout Pull-to-Refresh Header (immune to overflow)
          if (_dragOffset > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _dragOffset,
              child: ClipRect(
                child: OverflowBox(
                  minHeight: 0.0,
                  maxHeight: 180.0,
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: math.min(1.0, math.max(0.0, progress * 1.1)),
                    child: _buildHeaderContent(progress),
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
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Prominent Glowing Animated Qout Seal (Wheat & Emerald Emblem)
        AnimatedBuilder(
          animation: Listenable.merge([_pulseController, _spinController]),
          builder: (context, child) {
            final scale = _isRefreshing
                ? _pulseScale.value
                : 0.85 + (progress * 0.25);
            final glow = _isRefreshing ? _pulseGlow.value : (progress * 14);
            final rotationAngle = _isRefreshing
                ? _spinController.value * 2 * math.pi
                : (progress * math.pi * 1.5);

            return Transform.scale(
              scale: scale,
              child: Container(
                width: 58,
                height: 58,
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
                    width: 2.6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: _isRefreshing ? 0.50 : 0.30,
                      ),
                      blurRadius: glow,
                      spreadRadius: _isRefreshing ? 3.0 : 1.0,
                    ),
                    if (_isRefreshing)
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.40),
                        blurRadius: glow * 1.4,
                        spreadRadius: 1.8,
                      ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating shimmer dash ring
                    Transform.rotate(
                      angle: rotationAngle,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.40),
                            width: 1.8,
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
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const Gap(8),

        // Status caption with bold clear feedback
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isRefreshing) ...[
                const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                const Gap(8),
              ],
              Text(
                _isRefreshing
                    ? (widget.refreshingText ?? 'common.refreshing'.tr())
                    : (_canRefresh
                          ? 'common.release_to_refresh'.tr()
                          : 'common.pull_to_refresh'.tr()),
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: _canRefresh
                      ? AppColors.primaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
