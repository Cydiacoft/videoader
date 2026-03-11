import 'dart:io';

import 'package:flutter/material.dart';

class PathConfigCard extends StatelessWidget {
  final String title;
  final String description;
  final String? currentPath;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDirectory;
  final VoidCallback? onClear;

  const PathConfigCard({
    super.key,
    required this.title,
    required this.description,
    required this.currentPath,
    required this.icon,
    required this.onTap,
    this.isDirectory = false,
    this.onClear,
  });

  Future<void> _openFolder(BuildContext context) async {
    if (currentPath == null || currentPath!.isEmpty) return;
    
    try {
      if (Platform.isWindows) {
        await Process.run('explorer', [currentPath!]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [currentPath!]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [currentPath!]);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('无法打开: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSet = currentPath != null && currentPath!.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSet 
                      ? colorScheme.primaryContainer 
                      : colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: isSet 
                      ? colorScheme.onPrimaryContainer 
                      : colorScheme.error,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (isSet) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green.shade600,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentPath ?? description,
                      style: TextStyle(
                        color: isSet 
                            ? colorScheme.onSurfaceVariant 
                            : colorScheme.outline,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isSet && isDirectory)
                IconButton(
                  icon: const Icon(Icons.folder_open, size: 20),
                  tooltip: '打开文件夹',
                  onPressed: () => _openFolder(context),
                ),
              if (isSet && onClear != null)
                IconButton(
                  icon: Icon(Icons.clear, size: 20, color: colorScheme.error),
                  tooltip: '清除',
                  onPressed: onClear,
                ),
              FilledButton.tonal(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(isSet ? "更改" : "选择"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
