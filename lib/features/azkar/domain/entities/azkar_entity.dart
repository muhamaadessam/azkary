class AzkarEntity {
  final String zekr;
  final int counter;
  final int repeat;
  final String bless;

  const AzkarEntity({
    required this.zekr,
    required this.counter,
    required this.bless,
    required this.repeat,
  });

  factory AzkarEntity.fromJson(Map<String, dynamic> json) => AzkarEntity(
    zekr: json["zekr"],
    counter: json["repeat"],
    repeat: json["repeat"],
    bless: json["bless"],
  );

  AzkarEntity copyWith({
    String? zekr,
    int? repeat,
    int? counter,
    String? bless,
  }) {
    return AzkarEntity(
      zekr: zekr ?? this.zekr,
      counter: counter ?? this.counter,
      repeat: repeat ?? this.repeat,
      bless: bless ?? this.bless,
    );
  }
}
