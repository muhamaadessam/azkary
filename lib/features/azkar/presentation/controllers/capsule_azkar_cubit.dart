import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/models/capsule_zekr_model.dart';
import '../../../../core/database/capsule_azkar_database.dart';
import 'capsule_azkar_state.dart';

class CapsuleAzkarCubit extends Cubit<CapsuleAzkarState> {
  final CapsuleAzkarDatabase database;

  CapsuleAzkarCubit({CapsuleAzkarDatabase? database})
      : database = database ?? CapsuleAzkarDatabase.instance,
        super(const CapsuleAzkarState()) {
    loadAzkar();
  }

  Future<void> loadAzkar() async {
    emit(state.copyWith(status: CapsuleAzkarStatus.loading));
    try {
      final list = await database.getAllAzkar(
        searchQuery: state.searchQuery,
        category: state.selectedCategory,
      );
      emit(state.copyWith(
        status: CapsuleAzkarStatus.loaded,
        azkar: list,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CapsuleAzkarStatus.error,
        errorMessage: 'حدث خطأ أثناء تحميل الأذكار: $e',
      ));
    }
  }

  Future<void> filterByCategory(String category) async {
    emit(state.copyWith(
      selectedCategory: category,
      status: CapsuleAzkarStatus.loading,
    ));
    try {
      final list = await database.getAllAzkar(
        searchQuery: state.searchQuery,
        category: category,
      );
      emit(state.copyWith(
        status: CapsuleAzkarStatus.loaded,
        azkar: list,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CapsuleAzkarStatus.error,
        errorMessage: 'تعذر التصفية: $e',
      ));
    }
  }

  Future<void> search(String query) async {
    emit(state.copyWith(
      searchQuery: query,
      status: CapsuleAzkarStatus.loading,
    ));
    try {
      final list = await database.getAllAzkar(
        searchQuery: query,
        category: state.selectedCategory,
      );
      emit(state.copyWith(
        status: CapsuleAzkarStatus.loaded,
        azkar: list,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CapsuleAzkarStatus.error,
        errorMessage: 'تعذر البحث: $e',
      ));
    }
  }

  Future<bool> addZekr({
    required String text,
    required String category,
    required String virtue,
    required String source,
  }) async {
    try {
      final newZekr = CapsuleZekrModel(
        text: text.trim(),
        category: category,
        virtue: virtue.trim(),
        source: source.trim().isEmpty ? 'دعاء مخصص' : source.trim(),
        isCustom: true,
        isEnabled: true,
      );
      await database.insertZekr(newZekr);
      await loadAzkar();
      emit(state.copyWith(userMessage: 'تمت إضافة الذكر بنجاح'));
      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: 'فشل إضافة الذكر: $e'));
      return false;
    }
  }

  Future<bool> updateZekr(CapsuleZekrModel zekr) async {
    try {
      await database.updateZekr(zekr);
      await loadAzkar();
      emit(state.copyWith(userMessage: 'تم تعديل الذكر بنجاح'));
      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: 'فشل تعديل الذكر: $e'));
      return false;
    }
  }

  Future<void> deleteZekr(int id) async {
    try {
      await database.deleteZekr(id);
      await loadAzkar();
      emit(state.copyWith(userMessage: 'تم حذف الذكر'));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'فشل حذف الذكر: $e'));
    }
  }

  Future<void> toggleZekrEnabled(int id, bool isEnabled) async {
    try {
      await database.toggleZekrEnabled(id, isEnabled);
      // تحديث فوري محلي للقائمة دون إعادة التحميل بالكامل
      final updatedList = state.azkar.map((item) {
        if (item.id == id) {
          return item.copyWith(isEnabled: isEnabled);
        }
        return item;
      }).toList();

      emit(state.copyWith(azkar: updatedList));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'تعذر تغيير حالة التفعيل: $e'));
    }
  }

  Future<void> resetToDefaults() async {
    emit(state.copyWith(status: CapsuleAzkarStatus.loading));
    try {
      await database.resetToDefaults();
      emit(state.copyWith(
        selectedCategory: CapsuleCategories.all,
        searchQuery: '',
      ));
      await loadAzkar();
      emit(state.copyWith(userMessage: 'تمت استعادة الأذكار الافتراضية بنجاح'));
    } catch (e) {
      emit(state.copyWith(
        status: CapsuleAzkarStatus.error,
        errorMessage: 'تعذر استعادة الأذكار: $e',
      ));
    }
  }
}
