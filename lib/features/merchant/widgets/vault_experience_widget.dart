import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/payment_receipt_model.dart';
import 'pending_receipts_voucher_swiper_deck.dart';
import 'vault_door_painter.dart';
import 'vault_interior_painter.dart';

/// A fully interactive 3D bank vault experience.
///
/// **Closed state**: Heavy steel vault with a rotating gold steering wheel.
/// Tap the wheel → it spins 720° → locking pins retract → door swings open
/// with perspective 3D.
///
/// **Open state**: Interior is revealed with stacked receipt cards (swiper).
/// Tap close button → door swings shut in reverse.
class VaultExperienceWidget extends StatefulWidget {
  final List<PaymentReceiptModel> pendingReceipts;
  final String? confirmingReceiptId;
  final void Function(PaymentReceiptModel) onConfirmReceipt;

  const VaultExperienceWidget({
    super.key,
    required this.pendingReceipts,
    this.confirmingReceiptId,
    required this.onConfirmReceipt,
  });

  @override
  State<VaultExperienceWidget> createState() => _VaultExperienceWidgetState();
}

class _VaultExperienceWidgetState extends State<VaultExperienceWidget>
    with TickerProviderStateMixin {
  bool _isVaultOpen = false;

  // Door open/close animation (0.0 = closed, 1.0 = open)
  late AnimationController _doorController;

  // Idle animations for closed state (wheel wobble + shimmer)
  late AnimationController _idleController;

  // Derived animations from _doorController
  late Animation<double> _wheelSpin;
  late Animation<double> _lockPinRetract;
  late Animation<double> _doorSwing;

  @override
  void initState() {
    super.initState();
    _doorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _wheelSpin = Tween<double>(begin: 0.0, end: 4 * math.pi).animate(
      CurvedAnimation(
        parent: _doorController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeInOut),
      ),
    );

    _lockPinRetract = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _doorController,
        curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
      ),
    );

    _doorSwing = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _doorController,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  void dispose() {
    _doorController.dispose();
    _idleController.dispose();
    super.dispose();
  }

  void _toggleVault() {
    if (_doorController.isAnimating) return;

    HapticFeedback.mediumImpact();

    if (_isVaultOpen) {
      // Close
      _doorController.reverse().then((_) {
        if (mounted) {
          setState(() => _isVaultOpen = false);
          _idleController.repeat();
        }
      });
    } else {
      // Open
      _idleController.stop();
      setState(() => _isVaultOpen = true);
      _doorController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pendingReceipts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ──
        _buildHeader(),
        const Gap(8),

        // ── The Vault ──
        AnimatedBuilder(
          animation: Listenable.merge([_doorController, _idleController]),
          builder: (context, child) {
            final doorProgress = _doorSwing.value;
            // Max Y-rotation angle for the door (≈72°)
            final doorAngle = doorProgress * (math.pi / 2.5);

            return Container(
              height: 370,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emerald900.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // ── Layer 1: Vault Outer Frame (always visible) ──
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _VaultFramePainter(),
                      ),
                    ),

                    // ── Layer 2: Vault Interior (revealed as door opens) ──
                    Positioned(
                      left: 8,
                      top: 8,
                      right: 8,
                      bottom: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            // Interior background
                            Positioned.fill(
                              child: CustomPaint(
                                painter: VaultInteriorPainter(
                                  doorOpenProgress: doorProgress,
                                ),
                              ),
                            ),

                            // Receipts inside the vault (fade in as door opens)
                            if (doorProgress > 0.3)
                              Positioned.fill(
                                child: Opacity(
                                  opacity: ((doorProgress - 0.3) / 0.7)
                                      .clamp(0.0, 1.0),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: doorProgress * 30,
                                      top: 8,
                                      right: 8,
                                      bottom: 8,
                                    ),
                                    child: PendingReceiptsVoucherSwiperDeck(
                                      pendingReceipts: widget.pendingReceipts,
                                      confirmingReceiptId:
                                          widget.confirmingReceiptId,
                                      onConfirmReceipt:
                                          widget.onConfirmReceipt,
                                    ),
                                  ),
                                ),
                              ),

                            // Close button (visible when open)
                            if (doorProgress > 0.6)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Opacity(
                                  opacity: ((doorProgress - 0.6) / 0.4)
                                      .clamp(0.0, 1.0),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _toggleVault,
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.5),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.emerald600
                                                .withValues(alpha: 0.5),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.lock_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // ── Layer 3: The Door (3D perspective rotation) ──
                    Positioned(
                      left: 8,
                      top: 8,
                      right: 8,
                      bottom: 8,
                      child: IgnorePointer(
                        ignoring: doorProgress > 0.5,
                        child: Transform(
                          alignment: Alignment.centerLeft,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0015)
                            ..rotateY(-doorAngle),
                          child: GestureDetector(
                            onTap:
                                _isVaultOpen ? null : _toggleVault,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox.expand(
                                child: Stack(
                                  children: [
                                    // Door surface
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: VaultDoorPainter(
                                          lockPinRetract:
                                              _lockPinRetract.value,
                                        ),
                                      ),
                                    ),

                                    // Shimmer sweep (idle)
                                    if (!_isVaultOpen)
                                      Positioned.fill(
                                        child: _buildShimmer(),
                                      ),

                                    // Steering wheel (centered on door)
                                    Center(
                                      child: GestureDetector(
                                        onTap: _isVaultOpen
                                            ? null
                                            : _toggleVault,
                                        child: SizedBox(
                                          width: 90,
                                          height: 90,
                                          child: CustomPaint(
                                            painter:
                                                VaultSteeringWheelPainter(
                                              angle: _isVaultOpen ||
                                                      _doorController
                                                          .isAnimating
                                                  ? _wheelSpin.value
                                                  : math.sin(
                                                          _idleController
                                                                  .value *
                                                              2 *
                                                              math.pi) *
                                                      0.12,
                                              glowIntensity: _isVaultOpen
                                                  ? 0.0
                                                  : (0.5 +
                                                      0.5 *
                                                          math.sin(
                                                              _idleController
                                                                      .value *
                                                                  2 *
                                                                  math.pi)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // "Tap to open" hint (closed state only)
                                    if (!_isVaultOpen &&
                                        !_doorController.isAnimating)
                                      Positioned(
                                        bottom: 24,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: _buildOpenHint(),
                                        ),
                                      ),

                                    // Pending count badge on door
                                    if (!_isVaultOpen &&
                                        !_doorController.isAnimating)
                                      Positioned(
                                        top: 20,
                                        right: 20,
                                        child: _buildCountBadge(),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Layer 4: Frame beveled border (on top) ──
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.emerald600
                                  .withValues(alpha: 0.35),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Corner rivets on the frame ──
                    _buildFrameRivet(14, 14),
                    _buildFrameRivet(
                        MediaQuery.of(context).size.width * 0.9 - 34, 14),
                    _buildFrameRivet(14, 348),
                    _buildFrameRivet(
                        MediaQuery.of(context).size.width * 0.9 - 34, 348),
                  ],
                ),
              ),
            );
          },
        ),

        // ── Swipe Hint (when open) ──
        if (_isVaultOpen && widget.pendingReceipts.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                '↔ اسحب لعرض الوصل التالي',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMutedLight,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(8),
              const Text(
                'وصولات بانتظار تأكيد الاستلام',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pending_actions_rounded,
                    size: 14, color: Color(0xFFD97706)),
                const Gap(5),
                Text(
                  '${widget.pendingReceipts.length} معلقة',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    final shimmerPos = _idleController.value;
    return FractionallySizedBox(
      widthFactor: 0.3,
      alignment: Alignment(shimmerPos * 4 - 2, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white.withValues(alpha: 0.0),
              AppColors.accentLight.withValues(alpha: 0.06),
              Colors.white.withValues(alpha: 0.10),
              Colors.transparent,
            ],
            transform: const GradientRotation(0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildOpenHint() {
    final pulseOpacity =
        0.6 + 0.4 * math.sin(_idleController.value * 2 * math.pi);
    return Opacity(
      opacity: pulseOpacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.35),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_rounded, size: 16, color: Color(0xFFFDE68A)),
            Gap(6),
            Text(
              'اضغط لفتح الخزنة',
              style: TextStyle(
                color: Color(0xFFFDE68A),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.15),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        '${widget.pendingReceipts.length}',
        style: const TextStyle(
          color: Color(0xFFFDE68A),
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildFrameRivet(double left, double top) {
    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [
                Color(0xFF6EE7B7),
                Color(0xFF10B981),
                Color(0xFF064E3B),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 3.5,
              height: 3.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🖼️ _VaultFramePainter: The outer heavy frame (always visible)
// ─────────────────────────────────────────────────────────────────────────────

class _VaultFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));

    // Heavy dark emerald steel gradient
    final framePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF0D3B2B),
          Color(0xFF072A1D),
          Color(0xFF041A11),
          Color(0xFF030F0A),
        ],
        stops: [0.0, 0.35, 0.7, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    canvas.drawRRect(rrect, framePaint);

    // Brushed texture
    final texturePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 0.5;
    for (double y = 0; y < size.height; y += 2.5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), texturePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VaultFramePainter oldDelegate) => false;
}
