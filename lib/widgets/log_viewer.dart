import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(appLogsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF2B2B2B),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: logs.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.terminal,
                      color: Colors.grey[600],
                      size: 36,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "等待任务...",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "日志将显示在这里",
                      style: TextStyle(
                        color: Colors.grey[700],
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
                      Text(
                        '输出日志 (${logs.length} 条)',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.terminal,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: Colors.white12),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        Color textColor;
                        
                        if (log.contains('错误') || log.contains('失败') || log.contains('Error') || log.contains('failed') || log.contains('❌')) {
                          textColor = const Color(0xFFFF5252);
                        } else if (log.contains('完成') || log.contains('success') || log.contains('✅')) {
                          textColor = const Color(0xFF69F0AE);
                        } else if (log.contains('警告') || log.contains('Warning') || log.contains('warning') || log.contains('⚠️')) {
                          textColor = const Color(0xFFFFD740);
                        } else if (log.contains('🚀')) {
                          textColor = const Color(0xFF40C4FF);
                        } else {
                          textColor = const Color(0xFFB0BEC5);
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            log,
                            style: TextStyle(
                              color: textColor,
                              fontFamily: 'monospace',
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
