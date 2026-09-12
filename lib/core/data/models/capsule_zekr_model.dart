import 'package:equatable/equatable.dart';

class CapsuleZekrModel extends Equatable {
  final int? id;
  final String text;
  final String category;
  final String virtue;
  final String source;
  final bool isEnabled;
  final bool isCustom;

  const CapsuleZekrModel({
    this.id,
    required this.text,
    required this.category,
    required this.virtue,
    required this.source,
    this.isEnabled = true,
    this.isCustom = false,
  });

  CapsuleZekrModel copyWith({
    int? id,
    String? text,
    String? category,
    String? virtue,
    String? source,
    bool? isEnabled,
    bool? isCustom,
  }) {
    return CapsuleZekrModel(
      id: id ?? this.id,
      text: text ?? this.text,
      category: category ?? this.category,
      virtue: virtue ?? this.virtue,
      source: source ?? this.source,
      isEnabled: isEnabled ?? this.isEnabled,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  String get searchableText =>
      ArabicSearchHelper.normalize('$text $category $virtue $source');

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'text': text,
      'category': category,
      'virtue': virtue,
      'source': source,
      'search_text': searchableText,
      'is_enabled': isEnabled ? 1 : 0,
      'is_custom': isCustom ? 1 : 0,
    };
  }

  factory CapsuleZekrModel.fromMap(Map<String, dynamic> map) {
    return CapsuleZekrModel(
      id: map['id'] as int?,
      text: map['text'] as String,
      category: map['category'] as String,
      virtue: (map['virtue'] as String?) ?? '',
      source: map['source'] as String,
      isEnabled: (map['is_enabled'] as int? ?? 1) == 1,
      isCustom: (map['is_custom'] as int? ?? 0) == 1,
    );
  }

  @override
  List<Object?> get props => [
        id,
        text,
        category,
        virtue,
        source,
        isEnabled,
        isCustom,
      ];
}

class CapsuleCategories {
  CapsuleCategories._();

  static const String all = 'الكل';
  static const String relief = 'فك الكرب والهم';
  static const String sustenance = 'الرزق وقضاء الدين';
  static const String forgiveness = 'المغفرة والتوبة';
  static const String praise = 'التسبيح والثناء';
  static const String protection = 'العافية والحفظ';
  static const String prophet = 'الصلاة على النبي ﷺ';
  static const String quranic = 'جوامع الدعاء';

  static const List<String> list = [
    all,
    relief,
    sustenance,
    forgiveness,
    praise,
    protection,
    prophet,
    quranic,
  ];

  static const List<String> formOptions = [
    relief,
    sustenance,
    forgiveness,
    praise,
    protection,
    prophet,
    quranic,
  ];
}

class ArabicSearchHelper {
  ArabicSearchHelper._();

  static final RegExp _diacriticsRegex =
      RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');

  static String normalize(String text) {
    return text
        .replaceAll(_diacriticsRegex, '')
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .toLowerCase()
        .trim();
  }
}
