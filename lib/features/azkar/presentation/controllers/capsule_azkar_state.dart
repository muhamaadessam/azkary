import 'package:equatable/equatable.dart';

import '../../../../core/data/models/capsule_zekr_model.dart';

enum CapsuleAzkarStatus { initial, loading, loaded, error }

class CapsuleAzkarState extends Equatable {
  final CapsuleAzkarStatus status;
  final List<CapsuleZekrModel> azkar;
  final String selectedCategory;
  final String searchQuery;
  final String? errorMessage;
  final String? userMessage;

  const CapsuleAzkarState({
    this.status = CapsuleAzkarStatus.initial,
    this.azkar = const [],
    this.selectedCategory = CapsuleCategories.all,
    this.searchQuery = '',
    this.errorMessage,
    this.userMessage,
  });

  CapsuleAzkarState copyWith({
    CapsuleAzkarStatus? status,
    List<CapsuleZekrModel>? azkar,
    String? selectedCategory,
    String? searchQuery,
    String? errorMessage,
    String? userMessage,
  }) {
    return CapsuleAzkarState(
      status: status ?? this.status,
      azkar: azkar ?? this.azkar,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      userMessage: userMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        azkar,
        selectedCategory,
        searchQuery,
        errorMessage,
        userMessage,
      ];
}
