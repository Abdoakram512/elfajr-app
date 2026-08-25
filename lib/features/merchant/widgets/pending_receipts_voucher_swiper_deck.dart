import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/payment_receipt_model.dart';
import 'cash_voucher_card.dart';

class PendingReceiptsVoucherSwiperDeck extends StatefulWidget {
  final List<PaymentReceiptModel> pendingReceipts;
  final String? confirmingReceiptId;
  final void Function(PaymentReceiptModel) onConfirmReceipt;

  const PendingReceiptsVoucherSwiperDeck({
    super.key,
    required this.pendingReceipts,
    this.confirmingReceiptId,
    required this.onConfirmReceipt,
  });

  @override
  State<PendingReceiptsVoucherSwiperDeck> createState() =>
      _PendingReceiptsVoucherSwiperDeckState();
}

class _PendingReceiptsVoucherSwiperDeckState
    extends State<PendingReceiptsVoucherSwiperDeck>
    with SingleTickerProviderStateMixin {
  late List<PaymentReceiptModel> _cards;
  double _dragX = 0.0;
  bool _isDragging = false;

  late AnimationController _animController;
  late Animation<double> _offsetXAnimation;
  late Animation<double> _angleAnimation;

  @override
  void initState() {
    super.initState();
    _cards = List.from(widget.pendingReceipts);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _offsetXAnimation = const AlwaysStoppedAnimation(0.0);
    _angleAnimation = const AlwaysStoppedAnimation(0.0);
  }

  @override
  void didUpdateWidget(covariant PendingReceiptsVoucherSwiperDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIds = oldWidget.pendingReceipts.map((r) => r.id).toSet();
    final newIds = widget.pendingReceipts.map((r) => r.id).toSet();
    if (oldIds.length != newIds.length || !oldIds.containsAll(newIds)) {
      setState(() {
        _cards.removeWhere((c) => !newIds.contains(c.id));
        for (final r in widget.pendingReceipts) {
          if (!_cards.any((c) => c.id == r.id)) {
            _cards.add(r);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (_cards.isEmpty || _animController.isAnimating) return;
    setState(() => _isDragging = true);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_cards.isEmpty || _animController.isAnimating) return;
    setState(() => _dragX += details.delta.dx);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_cards.isEmpty || _animController.isAnimating) return;
    setState(() => _isDragging = false);

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.18;
    final velocityX = details.primaryVelocity ?? 0;

    if (_dragX.abs() > threshold || velocityX.abs() > 250) {
      final isRight = velocityX.abs() > 250 ? velocityX > 0 : _dragX > 0;
      _cycleTopCardToBack(isRight ? screenWidth * 1.3 : -screenWidth * 1.3);
    } else {
      _springBackToCenter();
    }
  }

  void _onHorizontalDragCancel() {
    if (_isDragging) {
      setState(() => _isDragging = false);
      _springBackToCenter();
    }
  }

  void _cycleTopCardToBack(double targetX) {
    if (_cards.length <= 1) {
      _springBackToCenter();
      return;
    }

    final startX = _dragX;
    _offsetXAnimation = Tween<double>(begin: startX, end: targetX).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _angleAnimation = Tween<double>(begin: (startX / 240) * 0.22, end: targetX > 0 ? 0.35 : -0.35).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() {
        _cards.add(_cards.removeAt(0));
        _dragX = 0;
        _offsetXAnimation = const AlwaysStoppedAnimation(0.0);
        _angleAnimation = const AlwaysStoppedAnimation(0.0);
      });
      _animController.value = 0;
    });
  }

  void _springBackToCenter() {
    final startX = _dragX;
    _offsetXAnimation = Tween<double>(begin: startX, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _angleAnimation = Tween<double>(begin: (startX / 240) * 0.22, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() {
        _dragX = 0;
        _offsetXAnimation = const AlwaysStoppedAnimation(0.0);
        _angleAnimation = const AlwaysStoppedAnimation(0.0);
      });
      _animController.value = 0;
    });
  }

  void _nextCard() {
    if (_cards.length <= 1 || _animController.isAnimating) return;
    _cycleTopCardToBack(-MediaQuery.of(context).size.width * 1.3);
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) return const SizedBox.shrink();

    final visibleCount = math.min(3, _cards.length);

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final currentX = _animController.isAnimating ? _offsetXAnimation.value : _dragX;
        final currentAngle = _animController.isAnimating
            ? _angleAnimation.value
            : ((_dragX / 240) * 0.22);
        final dragProgress = (_dragX.abs() / 350).clamp(0.0, 1.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const Gap(6),

            // 3D Deck Stack
            SizedBox(
              height: 385,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: List.generate(visibleCount, (i) {
                  final indexInDeck = visibleCount - 1 - i;
                  final receipt = _cards[indexInDeck];
                  final isTop = indexInDeck == 0;
                  final palette = CashVoucherPalette.forReceipt(receipt);

                  final scale = isTop
                      ? 1.0
                      : (1.0 - (indexInDeck * 0.05) + (dragProgress * 0.05)).clamp(0.85, 1.0);
                  final offsetY = isTop ? 0.0 : (indexInDeck * 14.0 - (dragProgress * 14.0));
                  final opacity = isTop ? 1.0 : (1.0 - (indexInDeck * 0.15)).clamp(0.0, 1.0);

                  Widget card = CashVoucherCard(
                    receipt: receipt,
                    palette: palette,
                    isTopCard: isTop,
                    isConfirming: widget.confirmingReceiptId == receipt.id,
                    onConfirm: () => widget.onConfirmReceipt(receipt),
                  );

                  if (isTop) {
                    card = GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: _onHorizontalDragStart,
                      onHorizontalDragUpdate: _onHorizontalDragUpdate,
                      onHorizontalDragEnd: _onHorizontalDragEnd,
                      onHorizontalDragCancel: _onHorizontalDragCancel,
                      child: card,
                    );
                  }

                  return Positioned(
                    key: ValueKey(receipt.id),
                    top: 8 + offsetY,
                    child: Transform.translate(
                      offset: isTop ? Offset(currentX, 0) : Offset.zero,
                      child: Transform.rotate(
                        angle: isTop ? currentAngle : 0.0,
                        child: Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.90,
                              child: card,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Next Voucher CTA
            if (_cards.length > 1) _buildNextButton(),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(color: const Color(0xFFD97706), borderRadius: BorderRadius.circular(2)),
              ),
              const Gap(8),
              const Text(
                'وصولات بانتظار تأكيد الاستلام',
                style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight),
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
                const Icon(Icons.pending_actions_rounded, size: 14, color: Color(0xFFD97706)),
                const Gap(5),
                Text(
                  '${_cards.length} معلقة',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFFD97706)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: _nextCard,
            icon: const Icon(Icons.swipe_rounded, size: 16),
            label: const Text('اسحب أو اضغط لعرض الوصل التالي', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              backgroundColor: const Color(0xFFF1F5F9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }
}
