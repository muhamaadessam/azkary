import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:azkary/core/data/capsule_azkar.dart';
import 'package:azkary/core/data/models/capsule_zekr_model.dart';
import 'package:azkary/core/database/capsule_azkar_database.dart';
import 'package:azkary/features/azkar/presentation/controllers/capsule_azkar_cubit.dart';
import 'package:azkary/features/azkar/presentation/controllers/capsule_azkar_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database db;
  late CapsuleAzkarDatabase azkarDb;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('''
      CREATE TABLE capsule_azkar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        category TEXT NOT NULL,
        virtue TEXT NOT NULL,
        source TEXT NOT NULL,
        search_text TEXT NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        is_custom INTEGER NOT NULL DEFAULT 0
      )
    ''');

    final batch = db.batch();
    for (final zekr in CapsuleAzkar.defaultSeedAzkar) {
      batch.insert('capsule_azkar', zekr.toMap());
    }
    await batch.commit(noResult: true);

    azkarDb = CapsuleAzkarDatabase.instance;
    azkarDb.setDatabaseForTesting(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Database is seeded with all verified azkar', () async {
    final count = await azkarDb.getCount();
    expect(count, equals(CapsuleAzkar.defaultSeedAzkar.length));
    expect(count, greaterThanOrEqualTo(30));
  });

  test('Can filter azkar by category', () async {
    final reliefAzkar = await azkarDb.getAllAzkar(
      category: CapsuleCategories.relief,
    );
    expect(reliefAzkar.isNotEmpty, isTrue);
    expect(
      reliefAzkar.every((z) => z.category == CapsuleCategories.relief),
      isTrue,
    );

    final sustenanceAzkar = await azkarDb.getAllAzkar(
      category: CapsuleCategories.sustenance,
    );
    expect(sustenanceAzkar.isNotEmpty, isTrue);
    expect(
      sustenanceAzkar.every((z) => z.category == CapsuleCategories.sustenance),
      isTrue,
    );
  });

  test('Can search azkar by text and virtue keywords', () async {
    final searchByText = await azkarDb.getAllAzkar(searchQuery: 'ذي النون');
    expect(searchByText.isNotEmpty, isTrue);
    expect(searchByText.first.text, contains('سُبْحَانَكَ إِنِّي كُنْتُ'));

    final searchByVirtue = await azkarDb.getAllAzkar(searchQuery: 'مائة حسنة');
    expect(searchByVirtue.isNotEmpty, isTrue);
  });

  test('CRUD operations work properly (Insert, Update, Delete, Toggle)',
      () async {
    // 1. Insert
    const newZekr = CapsuleZekrModel(
      text: 'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ',
      category: CapsuleCategories.prophet,
      virtue: 'فضل عظيم',
      source: 'مخصص',
    );
    final newId = await azkarDb.insertZekr(newZekr);
    expect(newId, greaterThan(0));

    var all = await azkarDb.getAllAzkar();
    final inserted = all.firstWhere((z) => z.id == newId);
    expect(inserted.text, equals(newZekr.text));
    expect(inserted.isCustom, isTrue);

    // 2. Update
    final updatedZekr = inserted.copyWith(virtue: 'فضل معدل ومحدث');
    await azkarDb.updateZekr(updatedZekr);
    all = await azkarDb.getAllAzkar();
    final afterUpdate = all.firstWhere((z) => z.id == newId);
    expect(afterUpdate.virtue, equals('فضل معدل ومحدث'));

    // 3. Toggle
    await azkarDb.toggleZekrEnabled(newId, false);
    all = await azkarDb.getAllAzkar();
    final afterToggle = all.firstWhere((z) => z.id == newId);
    expect(afterToggle.isEnabled, isFalse);

    // 4. Delete
    await azkarDb.deleteZekr(newId);
    all = await azkarDb.getAllAzkar();
    expect(all.any((z) => z.id == newId), isFalse);
  });

  test('getRandomEnabledZekr only returns enabled azkar', () async {
    // Disable all azkar except one
    await db.update('capsule_azkar', {'is_enabled': 0});
    final all = await azkarDb.getAllAzkar();
    final targetId = all.first.id!;
    await azkarDb.toggleZekrEnabled(targetId, true);

    for (int i = 0; i < 5; i++) {
      final randomZekr = await azkarDb.getRandomEnabledZekr();
      expect(randomZekr, isNotNull);
      expect(randomZekr!.id, equals(targetId));
      expect(randomZekr.isEnabled, isTrue);
    }
  });

  test('resetToDefaults restores initial state', () async {
    // Add custom
    await azkarDb.insertZekr(const CapsuleZekrModel(
      text: 'ذكر تجريبي',
      category: CapsuleCategories.relief,
      virtue: 'تجربة',
      source: 'تجربة',
    ));
    // Delete one default
    final all = await azkarDb.getAllAzkar();
    await azkarDb.deleteZekr(all.first.id!);

    // Reset
    await azkarDb.resetToDefaults();
    final restored = await azkarDb.getAllAzkar();
    expect(restored.length, equals(CapsuleAzkar.defaultSeedAzkar.length));
    expect(restored.any((z) => z.isCustom), isFalse);
  });

  test('CapsuleAzkarCubit handles lifecycle, search, and operations', () async {
    final cubit = CapsuleAzkarCubit(database: azkarDb);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(cubit.state.status, equals(CapsuleAzkarStatus.loaded));
    expect(cubit.state.azkar.isNotEmpty, isTrue);

    // Test filter
    await cubit.filterByCategory(CapsuleCategories.relief);
    expect(
      cubit.state.azkar.every((z) => z.category == CapsuleCategories.relief),
      isTrue,
    );

    // Test search
    await cubit.search('العرش');
    expect(
      cubit.state.azkar.any((z) => z.text.contains('الْعَرْشِ')),
      isTrue,
    );

    // Test add
    final ok = await cubit.addZekr(
      text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ مائة مرة',
      category: CapsuleCategories.praise,
      virtue: 'حطت خطاياه',
      source: 'صحيح',
    );
    expect(ok, isTrue);

    await cubit.close();
  });
}
