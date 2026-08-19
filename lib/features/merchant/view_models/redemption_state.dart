import 'package:equatable/equatable.dart';
import '../../beneficiary/models/aid_card_model.dart';
import '../models/redemption_transaction_model.dart';

abstract class RedemptionState extends Equatable {
  const RedemptionState();

  @override
  List<Object?> get props => [];
}

/// Initial idle state (waiting for camera scan or manual search input)
class RedemptionInitial extends RedemptionState {
  const RedemptionInitial();
}

/// Active search in progress
class RedemptionSearching extends RedemptionState {
  const RedemptionSearching();
}

/// Card loaded and displayed to cashier (ready for amount & PIN entry)
class RedemptionCardLoaded extends RedemptionState {
  final AidCardModel card;
  final String? pinError;
  final String? amountError;

  const RedemptionCardLoaded({
    required this.card,
    this.pinError,
    this.amountError,
  });

  RedemptionCardLoaded copyWith({
    AidCardModel? card,
    String? pinError,
    bool clearPinError = false,
    String? amountError,
    bool clearAmountError = false,
  }) {
    return RedemptionCardLoaded(
      card: card ?? this.card,
      pinError: clearPinError ? null : (pinError ?? this.pinError),
      amountError: clearAmountError ? null : (amountError ?? this.amountError),
    );
  }

  @override
  List<Object?> get props => [card, pinError, amountError];
}

/// Active redemption transaction submission to Firestore
class RedemptionSubmitting extends RedemptionState {
  final AidCardModel card;

  const RedemptionSubmitting(this.card);

  @override
  List<Object?> get props => [card];
}

/// Redemption successfully committed and receipt generated
class RedemptionSuccess extends RedemptionState {
  final RedemptionTransactionModel transaction;
  final AidCardModel card;

  const RedemptionSuccess({
    required this.transaction,
    required this.card,
  });

  @override
  List<Object?> get props => [transaction, card];
}

/// Redemption or search error state
class RedemptionFailure extends RedemptionState {
  final String errorMessage;
  final AidCardModel? card;

  const RedemptionFailure(this.errorMessage, {this.card});

  @override
  List<Object?> get props => [errorMessage, card];
}
