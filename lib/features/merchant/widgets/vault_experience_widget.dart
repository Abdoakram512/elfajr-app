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
/// **Closed state**: Heavy steel vault with rotating gold steering wheel,
/// hinges, digital control panel, and 6 corner rivets.
///
/// **Open state**: Door swings open with 3D perspective revealing the
/// dark interior with fan-spread receipt cards.
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

  late AnimationController _doorController;
  late AnimationController _idleController;

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
      _doorController.reverse().then((_) {
        if (mounted) {
          setState(() => _isVaultOpen = false);
          _idleController.repeat();
        }
      });
    } else {
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
        _buildHeader(),
        const Gap(8),

        // ── The Vault ──
        AnimatedBuilder(
          animation: Listenable.merge([_doorController, _idleController]),
          builder: (context, child) {
            final doorProgress = _doorSwing.value;
            final doorAngle = doorProgress * (math.pi / 2.5);

            return LayoutBuilder(
              builder: (context, constraints) {
                final vaultWidth = constraints.maxWidth;
                const vaultHeight = 380.0;

                return Container(
                  height: vaultHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emerald900.withValues(alpha: 0.4),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        // ── Layer 1: Vault Frame ──
                        Positioned.fill(
                          child: CustomPaint(painter: _VaultFramePainter()),
                        ),

                        // ── Layer 2: Hinges on the left ──
                        ..._buildHinges(vaultHeight),

                        // ── Layer 3: Interior ──
                        Positioned(
                          left: 10,
                          top: 10,
                          right: 10,
                          bottom: 10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: VaultInteriorPainter(
                                      doorOpenProgress: doorProgress,
                                    ),
                                  ),
                                ),

                                // Receipts (fan-spread inside vault)
                                if (doorProgress > 0.3)
                                  Positioned.fill(
                                    child: Opacity(
                                      opacity: ((doorProgress - 0.3) / 0.7)
                                          .clamp(0.0, 1.0),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: doorProgress * 20 + 8,
                                          top: 12,
                                          right: 8,
                                          bottom: 12,
                                        ),
                                        child: PendingReceiptsVoucherSwiperDeck(
                                          pendingReceipts:
                                              widget.pendingReceipts,
                                          confirmingReceiptId:
                                              widget.confirmingReceiptId,
                                          onConfirmReceipt:
                                              widget.onConfirmReceipt,
                                        ),
                                      ),
                                    ),
                                  ),

                                // Close button
                                if (doorProgress > 0.6)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Opacity(
                                      opacity: ((doorProgress - 0.6) / 0.4)
                                          .clamp(0.0, 1.0),
                                      child: _buildCloseButton(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // ── Layer 4: The Door (3D) ──
                        Positioned(
                          left: 10,
                          top: 10,
                          right: 10,
                          bottom: 10,
                          child: IgnorePointer(
                            ignoring: doorProgress > 0.5,
                            child: Transform(
                              alignment: Alignment.centerLeft,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.0015)
                                ..rotateY(-doorAngle),
                              child: GestureDetector(
                                onTap: _isVaultOpen ? null : _toggleVault,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
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

                                        // Shimmer
                                        if (!_isVaultOpen)
                                          Positioned.fill(
                                            child: _buildShimmer(),
                                          ),

                                        // Steering wheel (bigger: 100px)
                                        Center(
                                          child: GestureDetector(
                                            onTap: _isVaultOpen
                                                ? null
                                                : _toggleVault,
                                            child: SizedBox(
                                              width: 100,
                                              height: 100,
                                              child: CustomPaint(
                                                painter: VaultSteeringWheelPainter(
                                                  angle:
                                                      _isVaultOpen ||
                                                          _doorController
                                                              .isAnimating
                                                      ? _wheelSpin.value
                                                      : math.sin(
                                                              _idleController
                                                                      .value *
                                                                  2 *
                                                                  math.pi,
                                                            ) *
                                                            0.12,
                                                  glowIntensity: _isVaultOpen
                                                      ? 0.0
                                                      : (0.5 +
                                                            0.5 *
                                                                math.sin(
                                                                  _idleController
                                                                          .value *
                                                                      2 *
                                                                      math.pi,
                                                                )),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Open hint
                                        if (!_isVaultOpen &&
                                            !_doorController.isAnimating)
                                          Positioned(
                                            bottom: 26,
                                            left: 0,
                                            right: 0,
                                            child: Center(
                                              child: _buildOpenHint(),
                                            ),
                                          ),

                                        // Count badge
                                        if (!_isVaultOpen &&
                                            !_doorController.isAnimating)
                                          Positioned(
                                            top: 18,
                                            right: 18,
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

                        // ── Layer 5: Frame double-bevel border ──
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppColors.emerald600.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Second (inner) bevel
                        Positioned(
                          left: 3,
                          top: 3,
                          right: 3,
                          bottom: 3,
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(21),
                                border: Border.all(
                                  color: AppColors.emerald800.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 0.8,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── Layer 6: Frame rivets (6 total) ──
                        _buildFrameRivet(14, 14),
                        _buildFrameRivet(vaultWidth - 34, 14),
                        _buildFrameRivet(14, vaultHeight / 2 - 4),
                        _buildFrameRivet(vaultWidth - 34, vaultHeight / 2 - 4),
                        _buildFrameRivet(14, vaultHeight - 22),
                        _buildFrameRivet(vaultWidth - 34, vaultHeight - 22),

                        // ── Layer 7: Digital control panel (top center) ──
                        if (!_isVaultOpen && !_doorController.isAnimating)
                          Positioned(
                            top: 0,
                            left: vaultWidth * 0.3,
                            right: vaultWidth * 0.3,
                            child: _buildDigitalPanel(),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),

        // Swipe hint
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

  // ── Sub-builders ──

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
                const Icon(
                  Icons.pending_actions_rounded,
                  size: 14,
                  color: Color(0xFFD97706),
                ),
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

  List<Widget> _buildHinges(double height) {
    return [
      _buildSingleHinge(height * 0.18),
      _buildSingleHinge(height * 0.48),
      _buildSingleHinge(height * 0.78),
    ];
  }

  Widget _buildSingleHinge(double top) {
    return Positioned(
      left: 0,
      top: top,
      child: IgnorePointer(
        child: Container(
          width: 12,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(4),
            ),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFDE68A),
                Color(0xFFD97706),
                Color(0xFF92400E),
                Color(0xFFD97706),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 3,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF78350F),
                border: Border.all(color: const Color(0xFFFDE68A), width: 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleVault,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.emerald600.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.lock_rounded, size: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    final pos = _idleController.value;
    return FractionallySizedBox(
      widthFactor: 0.25,
      alignment: Alignment(pos * 4 - 2, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppColors.accentLight.withValues(alpha: 0.04),
              Colors.white.withValues(alpha: 0.08),
              AppColors.accentLight.withValues(alpha: 0.04),
              Colors.transparent,
            ],
            transform: const GradientRotation(0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildOpenHint() {
    final pulse = 0.6 + 0.4 * math.sin(_idleController.value * 2 * math.pi);
    return Opacity(
      opacity: pulse,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
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
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
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

  Widget _buildDigitalPanel() {
    return IgnorePointer(
      child: Container(
        height: 16,
        decoration: BoxDecoration(
          color: const Color(0xFF030F0A),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
          border: Border.all(
            color: AppColors.emerald600.withValues(alpha: 0.3),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const Gap(6),
            const Text(
              'ARMED',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontSize: 7,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                letterSpacing: 2,
              ),
            ),
          ],
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
              colors: [Color(0xFF6EE7B7), Color(0xFF10B981), Color(0xFF064E3B)],
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
// 🖼️ _VaultFramePainter: The outer heavy frame
// ─────────────────────────────────────────────────────────────────────────────

class _VaultFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));

    // Heavy dark emerald steel
    canvas.drawRRect(
      rrect,
      Paint()
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
        ).createShader(rect),
    );

    // Brushed texture
    final texPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.018)
      ..strokeWidth = 0.5;
    for (double y = 0; y < size.height; y += 2.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), texPaint);
    }

    // Radial highlight (subtle top-left shine)
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.7, -0.7),
          radius: 1.2,
          colors: [Colors.white.withValues(alpha: 0.04), Colors.transparent],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _VaultFramePainter oldDelegate) => false;
}
