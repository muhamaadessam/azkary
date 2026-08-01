class AzkarEntity {
  final String zekr;
  final int counter;
  final int repeat;
  final String bless;
  final bool isQuran;
  final String? surah;

  const AzkarEntity({
    required this.zekr,
    required this.counter,
    required this.bless,
    required this.repeat,
    this.isQuran = false,
    this.surah,
  });

  factory AzkarEntity.fromJson(Map<String, dynamic> json) {
    final zekrText = json["zekr"] as String? ?? "";
    final isQuranVal = json["isQuran"] as bool?;
    return AzkarEntity(
      zekr: zekrText,
      counter: json["repeat"] as int? ?? 1,
      repeat: json["repeat"] as int? ?? 1,
      bless: json["bless"] as String? ?? "",
      isQuran: isQuranVal ?? _checkIfQuran(zekrText),
      surah: json["surah"] as String?,
    );
  }

  static bool _checkIfQuran(String text) {
    if (text.contains('الله لا إلـه إلا هو الحي القيوم') ||
        text.contains('الله لا إله إلا هو الحي القيوم') ||
        text.contains('قُلْ هُوَ ٱللَّهُ أَحَدٌ') ||
        text.contains('قُلْ أَعُوذُ بِرَبِّ ٱلْفَلَقِ') ||
        text.contains('قُلْ أَعُوذُ بِرَبِّ ٱلنَّاسِ') ||
        text.contains('آمَنَ الرَّسُولُ بِمَا أُنْزِلَ إِلَيْهِ') ||
        text.contains('آية الكرسي') ||
        text.contains('البقرة')) {
      return true;
    }
    return false;
  }

  AzkarEntity copyWith({
    String? zekr,
    int? repeat,
    int? counter,
    String? bless,
    bool? isQuran,
    String? surah,
  }) {
    return AzkarEntity(
      zekr: zekr ?? this.zekr,
      counter: counter ?? this.counter,
      repeat: repeat ?? this.repeat,
      bless: bless ?? this.bless,
      isQuran: isQuran ?? this.isQuran,
      surah: surah ?? this.surah,
    );
  }
}
