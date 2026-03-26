import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_provider.dart';
import '../theme/fluid_theme.dart';

class LogViewer extends ConsumerStatefulWidget {
  const LogViewer({super.key});

  @override
  ConsumerState<LogViewer> createState() => _LogViewerState();
}

class _LogViewerState extends ConsumerState<LogViewer> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _copyLogs(List<String> logs) {
    final text = logs.join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('日志已复制到剪贴板'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        width: 200,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(appLogsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FluidSpacing.md),
      child: logs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.terminal,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "等待任务...",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "日志将显示在这里",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.expand_less,
                          color: colorScheme.onSurfaceVariant,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '输出日志 (${logs.length} 条)',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.copy,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            size: 16,
                          ),
                          onPressed: () => _copyLogs(logs),
                          tooltip: '复制日志',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.terminal,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: FluidSpacing.sm),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      Color textColor;

                      if (log.contains('错误') ||
                          log.contains('失败') ||
                          log.contains('Error') ||
                          log.contains('failed') ||
                          log.contains('❌')) {
                        textColor = FluidColors.error;
                      } else if (log.contains('完成') ||
                          log.contains('success') ||
                          log.contains('✅')) {
                        textColor = FluidColors.tertiary;
                      } else if (log.contains('警告') ||
                          log.contains('Warning') ||
                          log.contains('warning') ||
                          log.contains('⚠️')) {
                        textColor = Colors.orange;
                      } else if (log.contains('🚀')) {
                        textColor = FluidColors.primary;
                      } else {
                        textColor = colorScheme.onSurfaceVariant;
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          log,
                          style: TextStyle(
                            color: textColor,
                            fontFamily: 'JetBrains Mono',
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        );
                      },
                    ),
                ),
              ],
            ),
    );
  }
}