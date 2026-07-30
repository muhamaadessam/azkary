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
      emit(AzkarState(status: AzkarStatus.loaded, azkarSabahList: azkarList));
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
      emit(AzkarState(status: AzkarStatus.loaded, azkarMassaList: azkarList));
    } catch (e) {
      emit(AzkarState(status: AzkarStatus.error, error: e.toString()));
    }
  }

  void changeCounterForAzkarSabah(AzkarEntity azkarEntity) {
    // Make a mutable copy of the list
    final list = List<AzkarEntity>.from(state.azkarSabahList);

    // Find the matching azkar by its text
    final index = list.indexWhere((e) => e.zekr == azkarEntity.zekr);

    if (index == -1) return; // safety check if not found

    final item = list[index];
    final newRepeat = item.repeat - 1;

    if (newRepeat > 0) {
      list[index] = item.copyWith(repeat: newRepeat);
    } else {
      list.removeAt(index);
    }

    emit(state.copyWith(azkarSabahList: list));
  }

  changeCounterForAzkarMassa(AzkarEntity azkarEntity) {
    // Make a mutable copy of the list
    final list = List<AzkarEntity>.from(state.azkarMassaList);

    // Find the matching azkar by its text
    final index = list.indexWhere((e) => e.zekr == azkarEntity.zekr);

    if (index == -1) return; // safety check if not found

    final item = list[index];
    final newRepeat = item.repeat - 1;

    if (newRepeat > 0) {
      list[index] = item.copyWith(repeat: newRepeat);
    } else {
      list.removeAt(index);
    }

    emit(state.copyWith(azkarMassaList: list));
  }
}
