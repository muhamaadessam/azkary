import 'package:flutter_test/flutter_test.dart';

import 'package:azkary/core/data/capsule_azkar.dart';

void main() {
  test('capsule has a large pool of non-empty adhkar', () {
    expect(CapsuleAzkar.values.length, greaterThanOrEqualTo(40));
    expect(CapsuleAzkar.values.every((zekr) => zekr.trim().isNotEmpty), isTrue);
    expect(CapsuleAzkar.random(), isNotEmpty);
  });
}
