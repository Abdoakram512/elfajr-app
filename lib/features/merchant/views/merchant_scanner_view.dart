import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/app_colors.dart';
import '../view_models/merchant_cubit.dart';
import '../view_models/merchant_state.dart';
import '../widgets/manual_search_sheet.dart';
import '../widgets/redemption_confirmation_sheet.dart';

class MerchantScannerView extends StatefulWidget {
  const MerchantScannerView({super.key});

  @override
  State<MerchantScannerView> createState() => _MerchantScannerViewState();
}

class _MerchantScannerViewState extends State<MerchantScannerView> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
    returnImage: false,
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
            cubit.redeemAid(amount: amount, foodBaskets: baskets, notes: notes);
          },
        );
      },
    ).whenComplete(() {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
      cubit.clearScannedCard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MerchantCubit, MerchantState>(
      listener: (context, state) {
        if (state.scannedCard != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted && state.scannedCard != null) {
              _showRedemptionSheet(context, state);
            }
          });
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
          if (mounted) {
            setState(() => _isProcessing = false);
          }
          context.read<MerchantCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        final cubit = context.read<MerchantCubit>();

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const Gap(8),
                Text(
                  'merchant.scan_title'.tr(),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'merchant.search_manual_title'.tr(),
                icon: const Icon(
                  Icons.person_search_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                onPressed: () => ManualSearchSheet.show(context, cubit),
              ),
              IconButton(
                icon: ValueListenableBuilder(
                  valueListenable: _scannerController,
                  builder: (context, state, child) {
                    final torchState = state.torchState;
                    return Icon(
                      torchState == TorchState.on
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      color: torchState == TorchState.on
                          ? AppColors.accentLight
                          : Colors.white,
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

              // Emerald Green Viewfinder box
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 3.5),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Actions & Instruction Card
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    // Manual Search Button for beneficiaries without phones
                    ElevatedButton.icon(
                      onPressed: () => ManualSearchSheet.show(context, cubit),
                      icon: const Icon(
                        Icons.dialpad_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                      label: Text(
                        'merchant.search_manual_button'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                      ),
                    ),

                    const Gap(12),

                    // Instruction Card with Emerald Focus Icon and crisp text
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.center_focus_strong_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const Gap(8),
                          Flexible(
                            child: Text(
                              'merchant.scan_instruction'.tr(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
