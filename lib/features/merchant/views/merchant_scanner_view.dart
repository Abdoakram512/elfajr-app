import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/app_colors.dart';
import '../view_models/merchant_cubit.dart';
import '../view_models/merchant_state.dart';
import '../widgets/redemption_confirmation_sheet.dart';

class MerchantScannerView extends StatefulWidget {
  const MerchantScannerView({super.key});

  @override
  State<MerchantScannerView> createState() => _MerchantScannerViewState();
}

class _MerchantScannerViewState extends State<MerchantScannerView> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final code = barcodes.first.rawValue!;
      setState(() => _isProcessing = true);
      context.read<MerchantCubit>().onQrCodeScanned(code);
    }
  }

  void _showRedemptionSheet(BuildContext context, MerchantState state) {
    if (state.scannedCard == null) return;
    final cubit = context.read<MerchantCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return RedemptionConfirmationSheet(
          card: state.scannedCard!,
          onConfirm: (amount, baskets, notes) {
            Navigator.pop(sheetContext);
            cubit.redeemAid(
              amount: amount,
              foodBaskets: baskets,
              notes: notes,
            );
          },
        );
      },
    ).whenComplete(() {
      setState(() => _isProcessing = false);
      cubit.clearScannedCard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MerchantCubit, MerchantState>(
      listener: (context, state) {
        if (state.scannedCard != null) {
          _showRedemptionSheet(context, state);
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'merchant.redemption_success'.tr(args: [state.successMessage!]),
              ),
              backgroundColor: AppColors.success,
            ),
          );
          context.read<MerchantCubit>().clearMessages();
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!.tr()),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() => _isProcessing = false);
          context.read<MerchantCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text('merchant.scan_title'.tr()),
            actions: [
              IconButton(
                icon: ValueListenableBuilder(
                  valueListenable: _scannerController,
                  builder: (context, state, child) {
                    final torchState = state.torchState;
                    return Icon(
                      torchState == TorchState.on
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      color: Colors.white,
                    );
                  },
                ),
                onPressed: () => _scannerController.toggleTorch(),
              ),
            ],
          ),
          body: Stack(
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: _onDetect,
              ),

              // Overlay viewfinder
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),

              // Bottom instruction text
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'merchant.scan_instruction'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
