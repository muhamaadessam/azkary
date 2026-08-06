import 'package:flutter_test/flutter_test.dart';

import 'package:azkary/core/data/capsule_azkar.dart';

void main() {
  test('capsule has a large pool of non-empty adhkar', () {
    expect(CapsuleAzkar.values.length, greaterThanOrEqualTo(40));
    expect(CapsuleAzkar.values.every((zekr) => zekr.trim().isNotEmpty), isTrue);
    expect(CapsuleAzkar.random(), isNotEmpty);
  });

  test('capsule keeps complete verified forms', () {
    final values = CapsuleAzkar.values;

    expect(
      values,
      contains(
        'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      ),
    );
    expect(
      values,
      contains(
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى',
      ),
    );
    expect(
      values.any((zekr) => zekr.contains('أَعُوذُ بِكَ مِنَ الْهُدَى')),
      isFalse,
    );
    expect(
      values,
      contains(
        'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ، وَهُوَ السَّمِيعُ الْعَلِيمُ',
      ),
    );
  });
}
