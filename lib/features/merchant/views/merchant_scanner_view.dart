import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/service_locator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_feedback_helper.dart';
import '../view_models/redemption_cubit.dart';
import '../view_models/redemption_state.dart';
import '../widgets/manual_search_sheet.dart';
import '../widgets/redemption_confirmation_sheet.dart';

class MerchantScannerView extends StatelessWidget {
  const MerchantScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RedemptionCubit>(),
      child: const _MerchantScannerBody(),
    );
  }
}

class _MerchantScannerBody extends StatefulWidget {
  const _MerchantScannerBody();

  @override
  State<_MerchantScannerBody> createState() => _MerchantScannerBodyState();
}

class _MerchantScannerBodyState extends State<_MerchantScannerBody> {
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
      HapticHelper.medium();
      setState(() => _isProcessing = true);
      context.read<RedemptionCubit>().onQrCodeScanned(code);
    }
  }

  void _showRedemptionSheet(BuildContext context, RedemptionCardLoaded state) {
    final cubit = context.read<RedemptionCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: RedemptionConfirmationSheet(card: state.card),
      ),
    ).whenComplete(() {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
      cubit.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RedemptionCubit, RedemptionState>(
      listener: (context, state) {
        if (state is RedemptionCardLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              _showRedemptionSheet(context, state);
            }
          });
        } else if (state is RedemptionSuccess) {
          HapticHelper.success();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const Gap(10),
                  Expanded(
                    child: Text(
                      'merchant.redemption_success'.tr(args: [
                        '${state.transaction.amountDeducted.toStringAsFixed(0)} ${'common.currency'.tr()}'
                      ]),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (state is RedemptionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white),
                  const Gap(10),
                  Expanded(
                    child: Text(
                      state.errorMessage.tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
          if (mounted) {
            setState(() => _isProcessing = false);
          }
        }
      },
      builder: (context, state) {
        final cubit = context.read<RedemptionCubit>();

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

                    // Instruction Card with Emerald Focus Icon
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
