import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/payment_receipt_model.dart';
import 'cash_voucher_card.dart';

/// Internal receipt swiper that lives inside the vault interior.
/// Handles horizontal drag gestures to cycle through receipt cards.
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
    _angleAnimation = Tween<double>(
      begin: (startX / 240) * 0.22,
      end: targetX > 0 ? 0.35 : -0.35,
    ).animate(
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
    _angleAnimation = Tween<double>(
      begin: (startX / 240) * 0.22,
      end: 0.0,
    ).animate(
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

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) return const SizedBox.shrink();

    final visibleCount = math.min(3, _cards.length);

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final currentX =
            _animController.isAnimating ? _offsetXAnimation.value : _dragX;
        final currentAngle = _animController.isAnimating
            ? _angleAnimation.value
            : ((_dragX / 240) * 0.22);
        final dragProgress = (_dragX.abs() / 350).clamp(0.0, 1.0);

        return SizedBox(
          height: 280,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: List.generate(visibleCount, (i) {
              final indexInDeck = visibleCount - 1 - i;
              final receipt = _cards[indexInDeck];
              final isTop = indexInDeck == 0;

              final scale = isTop
                  ? 1.0
                  : (1.0 - (indexInDeck * 0.04) + (dragProgress * 0.04))
                      .clamp(0.88, 1.0);
              final offsetY = isTop
                  ? 0.0
                  : (indexInDeck * 10.0 - (dragProgress * 10.0));
              final opacity =
                  isTop ? 1.0 : (1.0 - (indexInDeck * 0.12)).clamp(0.0, 1.0);

              Widget card = CashVoucherCard(
                receipt: receipt,
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
                top: 4 + offsetY,
                child: Transform.translate(
                  offset: isTop ? Offset(currentX, 0) : Offset.zero,
                  child: Transform.rotate(
                    angle: isTop ? currentAngle : 0.0,
                    child: Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.82,
                          child: card,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
