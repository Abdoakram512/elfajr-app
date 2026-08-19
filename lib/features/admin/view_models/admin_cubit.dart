import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit() : super(const AdminState()) {
    loadInitialData();
  }

  void setTab(int index) {
    emit(state.copyWith(currentTabIndex: index));
  }

  void loadInitialData() {
    final mockMerchants = [
      const AdminMerchantItem(
        id: 'usr_merch_nokhba',
        name: 'أسواق النخبة المركزية',
        storeType: 'هايبر ماركت وتموينات',
        city: 'الرياض',
        commercialReg: '1010293847',
        totalTransactions: 142,
        totalDisbursed: 48500.0,
        isActive: true,
      ),
      const AdminMerchantItem(
        id: 'usr_merch_shefa',
        name: 'صيدليات الشفاء التخصصية',
        storeType: 'صيدلية ومستلزمات علاجية',
        city: 'جدة',
        commercialReg: '1010887722',
        totalTransactions: 98,
        totalDisbursed: 24200.0,
        isActive: true,
      ),
      const AdminMerchantItem(
        id: 'usr_merch_baraka',
        name: 'تموينات ومخابز البركة',
        storeType: 'تموينات إغاثية ومخبز',
        city: 'الدمام',
        commercialReg: '1010993344',
        totalTransactions: 115,
        totalDisbursed: 31000.0,
        isActive: true,
      ),
    ];

    final mockRedemptions = [
      AdminRedemptionItem(
        id: 'TXN-RED-481920',
        beneficiaryName: 'أحمد سعيد الغامدي',
        cardId: 'QOUT-CARD-784920',
        merchantName: 'أسواق النخبة المركزية',
        amount: 250.0,
        foodBaskets: 1,
        city: 'الرياض',
        timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
      ),
      AdminRedemptionItem(
        id: 'TXN-RED-481912',
        beneficiaryName: 'فاطمة مسفر العتيبي',
        cardId: 'QOUT-CARD-554210',
        merchantName: 'صيدليات الشفاء التخصصية',
        amount: 180.0,
        foodBaskets: 0,
        city: 'جدة',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
      ),
      AdminRedemptionItem(
        id: 'TXN-RED-481890',
        beneficiaryName: 'إبراهيم سالم الدوسري',
        cardId: 'QOUT-CARD-992140',
        merchantName: 'تموينات ومخابز البركة',
        amount: 400.0,
        foodBaskets: 1,
        city: 'الدمام',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];

    emit(state.copyWith(
      merchants: mockMerchants,
      recentRedemptions: mockRedemptions,
    ));
  }

  void toggleMerchantStatus(String merchantId) {
    final updatedList = state.merchants.map((m) {
      if (m.id == merchantId) {
        return AdminMerchantItem(
          id: m.id,
          name: m.name,
          storeType: m.storeType,
          city: m.city,
          commercialReg: m.commercialReg,
          totalTransactions: m.totalTransactions,
          totalDisbursed: m.totalDisbursed,
          isActive: !m.isActive,
        );
      }
      return m;
    }).toList();

    emit(state.copyWith(merchants: updatedList));
  }

  void clearNotification() {
    emit(state.copyWith(notificationMessage: null));
  }
}
