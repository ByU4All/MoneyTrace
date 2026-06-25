import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Horizontal scrollable strip of bill photo thumbnails with an add button.
class BillPhotoStrip extends StatelessWidget {
  final List<String> paths;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  const BillPhotoStrip({
    super.key,
    required this.paths,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...paths.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _Thumbnail(
                  path: entry.value,
                  onRemove: () => onRemove(entry.key),
                ),
              )),
          _AddButton(onTap: onAdd),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;

  const _Thumbnail({required this.path, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(path),
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.broken_image, color: AppColors.textMuted),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: AppColors.textMuted, size: 22),
            SizedBox(height: 4),
            Text(
              'Add photo',
              style: TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
