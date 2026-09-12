import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/models/capsule_zekr_model.dart';
import '../controllers/capsule_azkar_cubit.dart';
import '../controllers/capsule_azkar_state.dart';

class CapsuleAzkarManagerScreen extends StatefulWidget {
  const CapsuleAzkarManagerScreen({super.key});

  @override
  State<CapsuleAzkarManagerScreen> createState() =>
      _CapsuleAzkarManagerScreenState();
}

class _CapsuleAzkarManagerScreenState extends State<CapsuleAzkarManagerScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => CapsuleAzkarCubit(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'أذكار الكبسولة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  tooltip: 'استعادة الأذكار الافتراضية',
                  icon: const Icon(Icons.restart_alt_rounded),
                  onPressed: () => _confirmReset(context),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'إضافة ذكر',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => _showAddZekrDialog(context),
            ),
            body: BlocConsumer<CapsuleAzkarCubit, CapsuleAzkarState>(
              listener: (context, state) {
                if (state.userMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.userMessage!),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  children: [
                    _buildSearchBar(context),
                    _buildCategoryChips(context, state),
                    Expanded(
                      child: _buildBody(context, state),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'ابحث في نصوص الأذكار، الفضائل، أو المصادر...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    context.read<CapsuleAzkarCubit>().search('');
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1.8,
            ),
          ),
        ),
        onChanged: (value) {
          context.read<CapsuleAzkarCubit>().search(value);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, CapsuleAzkarState state) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: CapsuleCategories.list.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = CapsuleCategories.list[index];
          final isSelected = state.selectedCategory == category;

          return ChoiceChip(
            label: Text(
              category,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
            selected: isSelected,
            selectedColor: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : theme.colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
            onSelected: (selected) {
              if (selected) {
                context.read<CapsuleAzkarCubit>().filterByCategory(category);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CapsuleAzkarState state) {
    if (state.status == CapsuleAzkarStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.azkar.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_stories_outlined,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              const Text(
                'لا توجد أذكار مطابقة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'جرّب تغيير كلمات البحث أو اختر فئة أخرى، أو أضف ذكراً جديداً.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: state.azkar.length,
      itemBuilder: (context, index) {
        final zekr = state.azkar[index];
        return _buildZekrCard(context, zekr);
      },
    );
  }

  Widget _buildZekrCard(BuildContext context, CapsuleZekrModel zekr) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shadowColor: const Color(0x220F3D34),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: zekr.isEnabled
              ? const Color(0xFFC08A28).withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Category & Source Tags + Enable Switch
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    zekr.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (zekr.isCustom)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'مخصص',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                const Spacer(),
                Switch(
                  value: zekr.isEnabled,
                  activeThumbColor: theme.colorScheme.secondary,
                  onChanged: (value) {
                    if (zekr.id != null) {
                      context
                          .read<CapsuleAzkarCubit>()
                          .toggleZekrEnabled(zekr.id!, value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Zekr Text
            Text(
              zekr.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Traditional',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: zekr.isEnabled
                    ? (theme.brightness == Brightness.dark
                        ? const Color(0xFFE8DFCD)
                        : const Color(0xFF0F6B55))
                    : Colors.grey,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 12),

            // Virtue Box (if available)
            if (zekr.virtue.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFC08A28).withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: Color(0xFFC08A28),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        zekr.virtue,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4A4031),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Footer: Source and Action Buttons
            Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 15,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    zekr.source,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'تعديل',
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _showEditZekrDialog(context, zekr),
                ),
                IconButton(
                  tooltip: 'حذف',
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.red.shade400,
                  ),
                  onPressed: () => _confirmDelete(context, zekr),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddZekrDialog(BuildContext context) {
    final cubit = context.read<CapsuleAzkarCubit>();
    final formKey = GlobalKey<FormState>();
    final textController = TextEditingController();
    final virtueController = TextEditingController();
    final sourceController = TextEditingController();
    String selectedCategory = CapsuleCategories.relief;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'إضافة ذكر أو دعاء جديد',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: textController,
                        textDirection: TextDirection.rtl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'نص الذكر / الدعاء *',
                          hintText: 'اكتب نص الذكر بالتشكيل...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'يرجى كتابة نص الذكر'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'فئة الذكر',
                          border: OutlineInputBorder(),
                        ),
                        items: CapsuleCategories.formOptions
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: virtueController,
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'فضل الذكر وثوابه (اختياري)',
                          hintText: 'ما ورد في فضله وأجره من السنة...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: sourceController,
                        textDirection: TextDirection.rtl,
                        decoration: const InputDecoration(
                          labelText: 'المصدر (اختياري)',
                          hintText: 'مثال: صحيح مسلم / القرآن الكريم',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      final ok = await cubit.addZekr(
                        text: textController.text,
                        category: selectedCategory,
                        virtue: virtueController.text,
                        source: sourceController.text,
                      );
                      if (ok && dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    }
                  },
                  child: const Text('إضافة'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditZekrDialog(BuildContext context, CapsuleZekrModel zekr) {
    final cubit = context.read<CapsuleAzkarCubit>();
    final formKey = GlobalKey<FormState>();
    final textController = TextEditingController(text: zekr.text);
    final virtueController = TextEditingController(text: zekr.virtue);
    final sourceController = TextEditingController(text: zekr.source);
    String selectedCategory =
        CapsuleCategories.formOptions.contains(zekr.category)
            ? zekr.category
            : CapsuleCategories.relief;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'تعديل الذكر',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: textController,
                        textDirection: TextDirection.rtl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'نص الذكر *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'يرجى كتابة نص الذكر'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'الفئة',
                          border: OutlineInputBorder(),
                        ),
                        items: CapsuleCategories.formOptions
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: virtueController,
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'الفضل والثواب',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: sourceController,
                        textDirection: TextDirection.rtl,
                        decoration: const InputDecoration(
                          labelText: 'المصدر',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      final updated = zekr.copyWith(
                        text: textController.text.trim(),
                        category: selectedCategory,
                        virtue: virtueController.text.trim(),
                        source: sourceController.text.trim(),
                      );
                      final ok = await cubit.updateZekr(updated);
                      if (ok && dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    }
                  },
                  child: const Text('حفظ التعديلات'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, CapsuleZekrModel zekr) {
    if (zekr.id == null) return;
    final cubit = context.read<CapsuleAzkarCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'حذف الذكر',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'هل أنت متأكد من حذف هذا الذكر من قائمة الكبسولة؟',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                cubit.deleteZekr(zekr.id!);
                Navigator.pop(dialogContext);
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  void _confirmReset(BuildContext context) {
    final cubit = context.read<CapsuleAzkarCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'استعادة الأذكار الأصلية',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'سيتم استرجاع قائمة الأذكار الافتراضية المعتمدة بجميع فئاتها وفضائلها وحذف الأذكار المخصصة. هل تود المتابعة؟',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                cubit.resetToDefaults();
                Navigator.pop(dialogContext);
              },
              child: const Text('استعادة الآن'),
            ),
          ],
        );
      },
    );
  }
}
