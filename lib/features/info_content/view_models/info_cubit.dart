import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/service_locator.dart';
import '../repositories/info_repository.dart';
import 'info_state.dart';

class InfoCubit extends Cubit<InfoState> {
  final InfoRepository _repository;

  InfoCubit({InfoRepository? repository})
    : _repository = repository ?? getIt<InfoRepository>(),
      super(const InfoState(isLoading: true)) {
    loadAllInfo();
  }

  Future<void> loadAllInfo() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final results = await Future.wait([
        _repository.getAboutUs(),
        _repository.getFaqs(),
        _repository.getTermsPrivacy(),
        _repository.getContactSupport(),
      ]);

      emit(
        state.copyWith(
          aboutUs: results[0] as dynamic,
          faqs: results[1] as dynamic,
          termsPrivacy: results[2] as dynamic,
          contactSupport: results[3] as dynamic,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'فشل في تحميل البيانات من قاعدة البيانات: $e',
        ),
      );
    }
  }

  void selectFaqCategory(String category) {
    emit(state.copyWith(selectedFaqCategory: category));
  }
}
