part of 'azkar_cubit.dart';

enum AzkarStatus { initial, loading, loaded, error }

class AzkarState {
  final AzkarStatus status;
  final List<AzkarEntity> azkarSabahList;
  final List<AzkarEntity> azkarMassaList;
  final String error;

  AzkarState({
    required this.status,
    this.azkarSabahList = const [],
    this.azkarMassaList = const [],
    this.error = '',
  });

  AzkarState copyWith({
    AzkarStatus? status,
    List<AzkarEntity>? azkarSabahList,
    List<AzkarEntity>? azkarMassaList,
    String? error,
  }) {
    return AzkarState(
      status: status ?? this.status,
      azkarSabahList: azkarSabahList ?? this.azkarSabahList,
      azkarMassaList: azkarMassaList ?? this.azkarMassaList,
      error: error ?? this.error,
    );
  }
}
