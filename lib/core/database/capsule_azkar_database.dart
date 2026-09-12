import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../data/capsule_azkar.dart';
import '../data/models/capsule_zekr_model.dart';

class CapsuleAzkarDatabase {
  static final CapsuleAzkarDatabase instance = CapsuleAzkarDatabase._internal();

  CapsuleAzkarDatabase._internal();

  Database? _db;
  bool _useInMemoryFallback = false;
  List<CapsuleZekrModel> _inMemoryAzkar = [];

  /// يُتيح تعيين قاعدة بيانات مخصصة (مفيد للاختبارات الآلية)
  void setDatabaseForTesting(Database db) {
    _db = db;
    _useInMemoryFallback = false;
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database?> _getDatabaseOrFallback() async {
    if (_useInMemoryFallback) return null;
    if (_db != null) return _db;
    try {
      _db = await _initDatabase();
      return _db;
    } on MissingPluginException {
      _useInMemoryFallback = true;
      if (_inMemoryAzkar.isEmpty) {
        _inMemoryAzkar = List.from(CapsuleAzkar.defaultSeedAzkar);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    SqflitePlugin.registerWith();
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, 'azkary_capsule.db');

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );

    // التأكد من ملء الأذكار الافتراضية إذا كانت القاعدة فارغة
    try {
      final count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM capsule_azkar'),
          ) ??
          0;
      if (count == 0) {
        final batch = db.batch();
        for (final zekr in CapsuleAzkar.defaultSeedAzkar) {
          batch.insert('capsule_azkar', zekr.toMap());
        }
        await batch.commit(noResult: true);
      }
    } catch (_) {}

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
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

    // إدراج الأذكار الافتراضية المعتمدة
    final batch = db.batch();
    for (final zekr in CapsuleAzkar.defaultSeedAzkar) {
      batch.insert('capsule_azkar', zekr.toMap());
    }
    await batch.commit(noResult: true);
  }

  List<CapsuleZekrModel> _filterInMemory({
    String? searchQuery,
    String? category,
  }) {
    if (_inMemoryAzkar.isEmpty) {
      _inMemoryAzkar = List.from(CapsuleAzkar.defaultSeedAzkar);
    }

    return _inMemoryAzkar.where((item) {
      if (category != null &&
          category.isNotEmpty &&
          category != CapsuleCategories.all) {
        if (item.category != category) return false;
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim();
        final normalized = ArabicSearchHelper.normalize(query);
        final normalizedItemText = ArabicSearchHelper.normalize(item.text);
        final hasMatch = normalizedItemText.contains(normalized) ||
            item.text.contains(query) ||
            item.virtue.contains(query) ||
            item.source.contains(query);
        if (!hasMatch) return false;
      }
      return true;
    }).toList();
  }

  /// جلب كل الأذكار مع دعم البحث بالكلمات والفلترة بالفئة
  Future<List<CapsuleZekrModel>> getAllAzkar({
    String? searchQuery,
    String? category,
  }) async {
    final db = await _getDatabaseOrFallback();
    if (db == null) {
      return _filterInMemory(searchQuery: searchQuery, category: category);
    }

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (category != null &&
        category.isNotEmpty &&
        category != CapsuleCategories.all) {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final normalized = ArabicSearchHelper.normalize(searchQuery);
      whereClauses.add('(search_text LIKE ? OR text LIKE ?)');
      whereArgs.addAll(['%$normalized%', '%${searchQuery.trim()}%']);
    }

    final where = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final result = await db.query(
      'capsule_azkar',
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'is_custom DESC, id ASC',
    );

    return result.map((map) => CapsuleZekrModel.fromMap(map)).toList();
  }

  /// جلب ذكر عشوائي من الأذكار المفعّلة للظهور في الكبسولة
  Future<CapsuleZekrModel?> getRandomEnabledZekr() async {
    final db = await _getDatabaseOrFallback();
    if (db == null) {
      if (_inMemoryAzkar.isEmpty) {
        _inMemoryAzkar = List.from(CapsuleAzkar.defaultSeedAzkar);
      }
      final enabled = _inMemoryAzkar.where((e) => e.isEnabled).toList();
      if (enabled.isEmpty) return null;
      return enabled[Random().nextInt(enabled.length)];
    }

    final result = await db.rawQuery('''
      SELECT * FROM capsule_azkar
      WHERE is_enabled = 1
      ORDER BY RANDOM()
      LIMIT 1
    ''');

    if (result.isNotEmpty) {
      return CapsuleZekrModel.fromMap(result.first);
    }
    return null;
  }

  /// جلب كافة الأذكار المفعّلة
  Future<List<CapsuleZekrModel>> getEnabledAzkar() async {
    final db = await _getDatabaseOrFallback();
    if (db == null) {
      if (_inMemoryAzkar.isEmpty) {
        _inMemoryAzkar = List.from(CapsuleAzkar.defaultSeedAzkar);
      }
      return _inMemoryAzkar.where((e) => e.isEnabled).toList();
    }

    final result = await db.query(
      'capsule_azkar',
      where: 'is_enabled = 1',
      orderBy: 'id ASC',
    );
    return result.map((map) => CapsuleZekrModel.fromMap(map)).toList();
  }

  /// إضافة ذكر جديد
  Future<int> insertZekr(CapsuleZekrModel zekr) async {
    final db = await _getDatabaseOrFallback();
    if (db == null) {
      if (_inMemoryAzkar.isEmpty) {
        _inMemoryAzkar = List.from(CapsuleAzkar.defaultSeedAzkar);
      }
      final newId = (_inMemoryAzkar.isEmpty
              ? 0
              : _inMemoryAzkar.map((e) => e.id ?? 0).reduce(max)) +
          1;
      final newItem = zekr.copyWith(id: newId, isCustom: true);
      _inMemoryAzkar.insert(0, newItem);
      return newId;
    }

    return await db.insert(
      'capsule_azkar',
      zekr.copyWith(isCustom: true).toMap(),
    );
  }

  /// تعديل ذكر موجود
  Future<int> updateZekr(CapsuleZekrModel zekr) async {
    if (zekr.id == null) return 0;
    final db = await _getDatabaseOrFallback();
    if (db == null) {
      final index = _inMemoryAzkar.indexWhere((e) => e.id == zekr.id);
      if (index != -1) {
        _inMemoryAzkar[index] = zekr;
        return 1;
      }
      return 0;
    }

    return await db.update(
      'capsule_azkar',
      zekr.toMap(),
      where: 'id = ?',
      whereArgs: [zekr.id],
    );
  }

  /// حذف ذكر
  Future<int> deleteZekr(int id) async {
    final db = await _getDatabaseOrFallback();
    if (db == null) {
      _inMemoryAzkar.removeWhere((e) => e.id == id);
      return 1;
    }

    return await db.delete(
      'capsule_azkar',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// تفعيل أو تعطيل ظهور الذكر في الكبسولة
  Future<int> toggleZekrEnabled(int id, bool isEnabled) async {
    final db = await _getDatabaseOrFallback();
    if (db == null) {
      final index = _inMemoryAzkar.indexWhere((e) => e.id == id);
      if (index != -1) {
        _inMemoryAzkar[index] =
            _inMemoryAzkar[index].copyWith(isEnabled: isEnabled);
        return 1;
      }
      return 0;
    }

    return await db.update(
      'capsule_azkar',
      {'is_enabled': isEnabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// إعادة تعيين قاعدة البيانات إلى الأذكار الافتراضية
  Future<void> resetToDefaults() async {
    final db = await _getDatabaseOrFallback();
    if (db == null) {
      _inMemoryAzkar = List.from(CapsuleAzkar.defaultSeedAzkar);
      return;
    }

    await db.transaction((txn) async {
      await txn.delete('capsule_azkar');
      final batch = txn.batch();
      for (final zekr in CapsuleAzkar.defaultSeedAzkar) {
        batch.insert('capsule_azkar', zekr.toMap());
      }
      await batch.commit(noResult: true);
    });
  }

  /// عدد الأذكار الإجمالي
  Future<int> getCount() async {
    final db = await _getDatabaseOrFallback();
    if (db == null) {
      return _inMemoryAzkar.length;
    }

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM capsule_azkar'),
    );
    return count ?? 0;
  }
}
