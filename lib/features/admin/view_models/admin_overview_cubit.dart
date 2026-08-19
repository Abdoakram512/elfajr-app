import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/service_locator.dart';
import '../models/admin_redemption_item.dart';
import '../repositories/admin_repository.dart';
import 'admin_overview_state.dart';

class AdminOverviewCubit extends Cubit<AdminOverviewState> {
  final AdminRepository _repository;
  StreamSubscription<Map<String, dynamic>>? _statsSubscription;
  StreamSubscription<List<AdminRedemptionItem>>? _redemptionsSubscription;

  AdminOverviewCubit({AdminRepository? repository})
      : _repository = repository ?? getIt<AdminRepository>(),
        super(const AdminOverviewState()) {
    initDataStreams();
  }

  void initDataStreams() {
    // 1. Live Stats from Firestore (stats/global)
    _statsSubscription?.cancel();
    _statsSubscription = _repository.getGlobalStatsStream().listen((stats) {
      emit(
        state.copyWith(
          totalFundsDisbursed: stats['totalFundsDisbursed'] as double? ?? 0.0,
          totalBeneficiariesCount:
              stats['totalBeneficiariesCount'] as int? ?? 0,
          activeMerchantsCount: stats['activeMerchantsCount'] as int? ?? 0,
          totalRedemptionsCount: stats['totalRedemptionsCount'] as int? ?? 0,
        ),
      );
    });

    // 2. Live Redemptions Stream from Firestore
    _redemptionsSubscription?.cancel();
    _redemptionsSubscription = _repository.getLiveRedemptionsStream().listen((
      redemptions,
    ) {
      emit(state.copyWith(recentRedemptions: redemptions));
    });
  }

  Future<void> refreshData() async {
    initDataStreams();
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> close() {
    _statsSubscription?.cancel();
    _redemptionsSubscription?.cancel();
    return super.close();
  }
}
