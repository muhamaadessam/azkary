part of 'azkar_cubit.dart';

enum AzkarStatus { initial, loading, loaded, error }

class AzkarState {
  final AzkarStatus status;
  final List<AzkarEntity> azkarSabahList;
  final List<AzkarEntity> azkarMassaList;
  final List<AzkarEntity> azkarSleepList;
  final List<AzkarEntity> azkarPostPrayerList;
  final int totalSabahAzkar;
  final int totalMassaAzkar;
  final int totalSleepAzkar;
  final int totalPostPrayerAzkar;
  final String error;

  AzkarState({
    required this.status,
    this.azkarSabahList = const [],
    this.azkarMassaList = const [],
    this.azkarSleepList = const [],
    this.azkarPostPrayerList = const [],
    this.totalSabahAzkar = 0,
    this.totalMassaAzkar = 0,
    this.totalSleepAzkar = 0,
    this.totalPostPrayerAzkar = 0,
    this.error = '',
  });

  AzkarState copyWith({
    AzkarStatus? status,
    List<AzkarEntity>? azkarSabahList,
    List<AzkarEntity>? azkarMassaList,
    List<AzkarEntity>? azkarSleepList,
    List<AzkarEntity>? azkarPostPrayerList,
    int? totalSabahAzkar,
    int? totalMassaAzkar,
    int? totalSleepAzkar,
    int? totalPostPrayerAzkar,
    String? error,
  }) {
    return AzkarState(
      status: status ?? this.status,
      azkarSabahList: azkarSabahList ?? this.azkarSabahList,
      azkarMassaList: azkarMassaList ?? this.azkarMassaList,
      azkarSleepList: azkarSleepList ?? this.azkarSleepList,
      azkarPostPrayerList: azkarPostPrayerList ?? this.azkarPostPrayerList,
      totalSabahAzkar: totalSabahAzkar ?? this.totalSabahAzkar,
      totalMassaAzkar: totalMassaAzkar ?? this.totalMassaAzkar,
      totalSleepAzkar: totalSleepAzkar ?? this.totalSleepAzkar,
      totalPostPrayerAzkar: totalPostPrayerAzkar ?? this.totalPostPrayerAzkar,
      error: error ?? this.error,
    );
  }
}
