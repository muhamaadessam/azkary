import 'package:flutter/material.dart';

import '../../domain/entities/azkar_entity.dart';

class ZekrWidget extends StatelessWidget {
  const ZekrWidget({super.key, required this.azkar, this.onTap});

  final AzkarEntity azkar;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 10,
        shadowColor: const Color(0x330F3D34),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: theme.colorScheme.secondary,
                  size: 28,
                ),
                const SizedBox(height: 12),
                Text(
                  azkar.zekr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF173F35),
                    fontSize: 28,
                    height: 1.7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (azkar.bless.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    azkar.bless,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF5A6B62),
                      fontSize: 20,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                Container(
                  width: 124,
                  height: 124,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.secondary,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x330F3D34),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${azkar.repeat}/${azkar.counter}',
                      style: const TextStyle(
                        color: Color(0xFFFFFBF0),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'اضغط للتسبيح',
                  style: TextStyle(
                    color: Color(0xFF5A6B62),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
