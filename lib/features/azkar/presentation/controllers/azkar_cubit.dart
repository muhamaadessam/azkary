import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../res/assets.dart';
import '../../domain/entities/azkar_entity.dart';

part 'azkar_state.dart';

class AzkarCubit extends Cubit<AzkarState> {
  AzkarCubit() : super(AzkarState(status: AzkarStatus.initial));

  Future<void> getAzkarSabah() async {
    emit(AzkarState(status: AzkarStatus.loading));
    try {
      final String response = await rootBundle.loadString(Assets.azkarSabah);
      final data = await json.decode(response);
      final azkarList = List<AzkarEntity>.from(
        (data['content'] as List).map((e) => AzkarEntity.fromJson(e)),
      );
      emit(AzkarState(
        status: AzkarStatus.loaded,
        azkarSabahList: azkarList,
        totalSabahAzkar: azkarList.length,
      ));
    } catch (e) {
      emit(AzkarState(status: AzkarStatus.error, error: e.toString()));
    }
  }

  Future<void> getAzkarMassa() async {
    emit(AzkarState(status: AzkarStatus.loading));
    try {
      final String response = await rootBundle.loadString(Assets.azkarMassa);
      final data = await json.decode(response);
      final azkarList = List<AzkarEntity>.from(
        (data['content'] as List).map((e) => AzkarEntity.fromJson(e)),
      );
      emit(AzkarState(
        status: AzkarStatus.loaded,
        azkarMassaList: azkarList,
        totalMassaAzkar: azkarList.length,
      ));
    } catch (e) {
      emit(AzkarState(status: AzkarStatus.error, error: e.toString()));
    }
  }

  void changeCounterForAzkarSabah(AzkarEntity azkarEntity) {
    final list = List<AzkarEntity>.from(state.azkarSabahList);
    final index = list.indexWhere((e) => e.zekr == azkarEntity.zekr);
    if (index == -1) return;

    final item = list[index];
    if (item.repeat > 0) {
      list[index] = item.copyWith(repeat: item.repeat - 1);
      emit(state.copyWith(azkarSabahList: list));
    }
  }

  void changeCounterForAzkarMassa(AzkarEntity azkarEntity) {
    final list = List<AzkarEntity>.from(state.azkarMassaList);
    final index = list.indexWhere((e) => e.zekr == azkarEntity.zekr);
    if (index == -1) return;

    final item = list[index];
    if (item.repeat > 0) {
      list[index] = item.copyWith(repeat: item.repeat - 1);
      emit(state.copyWith(azkarMassaList: list));
    }
  }

  Future<void> getAzkarSleep() async {
    emit(state.copyWith(status: AzkarStatus.loading));
    try {
      final String response = await rootBundle.loadString(Assets.azkarSleep);
      final data = await json.decode(response);
      final azkarList = List<AzkarEntity>.from(
        (data['content'] as List).map((e) => AzkarEntity.fromJson(e)),
      );
      emit(state.copyWith(
        status: AzkarStatus.loaded,
        azkarSleepList: azkarList,
        totalSleepAzkar: azkarList.length,
      ));
    } catch (e) {
      emit(state.copyWith(status: AzkarStatus.error, error: e.toString()));
    }
  }

  Future<void> getAzkarPostPrayer() async {
    emit(state.copyWith(status: AzkarStatus.loading));
    try {
      final String response = await rootBundle.loadString(Assets.azkarPostPrayer);
      final data = await json.decode(response);
      final azkarList = List<AzkarEntity>.from(
        (data['content'] as List).map((e) => AzkarEntity.fromJson(e)),
      );
      emit(state.copyWith(
        status: AzkarStatus.loaded,
        azkarPostPrayerList: azkarList,
        totalPostPrayerAzkar: azkarList.length,
      ));
    } catch (e) {
      emit(state.copyWith(status: AzkarStatus.error, error: e.toString()));
    }
  }

  void changeCounterForAzkarSleep(AzkarEntity azkarEntity) {
    final list = List<AzkarEntity>.from(state.azkarSleepList);
    final index = list.indexWhere((e) => e.zekr == azkarEntity.zekr);
    if (index == -1) return;

    final item = list[index];
    if (item.repeat > 0) {
      list[index] = item.copyWith(repeat: item.repeat - 1);
      emit(state.copyWith(azkarSleepList: list));
    }
  }

  void changeCounterForAzkarPostPrayer(AzkarEntity azkarEntity) {
    final list = List<AzkarEntity>.from(state.azkarPostPrayerList);
    final index = list.indexWhere((e) => e.zekr == azkarEntity.zekr);
    if (index == -1) return;

    final item = list[index];
    if (item.repeat > 0) {
      list[index] = item.copyWith(repeat: item.repeat - 1);
      emit(state.copyWith(azkarPostPrayerList: list));
    }
  }
}
