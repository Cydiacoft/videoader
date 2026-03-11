import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/download_task.dart';
import '../providers/app_provider.dart';
import '../widgets/log_viewer.dart';

class DownloadPage extends ConsumerStatefulWidget {
  const DownloadPage({super.key});

  @override
  ConsumerState<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends ConsumerState<DownloadPage> {
  final _urlController = TextEditingController();
  final _batchUrlController = TextEditingController();
  bool _showBatchInput = false;
  bool _showOptions = false;

  @override
  void dispose() {
    _urlController.dispose();
    _batchUrlController.dispose();
    super.dispose();
  }

  String _parseUrl(String input) {
    // 从文本中提取第一个 URL
    // 支持 http/https 开头的任意链接
    final urlMatch = RegExp(r'https?://[^\s<>"{}|\\^`\[\]]+').firstMatch(input.trim());
    
    if (urlMatch != null) {
      var url = urlMatch.group(0)!;
      // 移除 URL 末尾可能存在的标点符号
      url = url.replaceAll(RegExp(r'[.,;:)\]}>]+$'), '');
      return url;
    }
    
    // 如果没有提取到 URL，返回原文本
    return input.trim();
  }

  void _startDownload(String url) {
    final parsedUrl = _parseUrl(url);
    ref.read(downloadProvider.notifier).startDownload(parsedUrl);
    _urlController.clear();
  }

  void _startBatchDownload() {
    final lines = _batchUrlController.text
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    for (final line in lines) {
      final url = _parseUrl(line);
      if (url.isNotEmpty) {
        ref.read(downloadProvider.notifier).startDownload(url);
      }
    }

    _batchUrlController.clear();
    setState(() => _showBatchInput = false);
  }

  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.single.path;
      if (path != null) {
        final file = File(path);
        try {
          final lines = await file.readAsLines();
          for (final line in lines) {
            if (line.trim().isNotEmpty) {
              final url = _parseUrl(line);
              if (url.isNotEmpty) {
                ref.read(downloadProvider.notifier).startDownload(url);
              }
            }
          }
        } catch (e) {
          ref.read(appLogsProvider.notifier).add("读取文件失败: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDownloading = ref.watch(isDownloadingProvider);
    final history = ref.watch(downloadHistoryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('视频下载'),
        actions: [
          IconButton(
            icon: const Icon(Icons.content_paste),
            tooltip: '从剪贴板粘贴',
            onPressed: () async {
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              if (data?.text != null && data!.text!.isNotEmpty) {
                final parsed = _parseUrl(data.text!);
                _urlController.text = parsed;
                setState(() {});
                if (context.mounted) {
                  final isParsed = parsed != data.text!.trim();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isParsed ? '已粘贴并解析链接' : '已从剪贴板粘贴'),
                      behavior: SnackBarBehavior.floating,
                      width: 200,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('剪贴板为空'),
                    behavior: SnackBarBehavior.floating,
                    width: 200,
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(_showBatchInput ? Icons.link : Icons.playlist_add),
            tooltip: _showBatchInput ? '单链接模式' : '批量下载模式',
            onPressed: () => setState(() => _showBatchInput = !_showBatchInput),
          ),
          IconButton(
            icon: Icon(_showOptions ? Icons.tune : Icons.tune_outlined),
            tooltip: '下载选项',
            onPressed: () => setState(() => _showOptions = !_showOptions),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'file') {
                _selectFile();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'file',
                child: ListTile(
                  leading: Icon(Icons.file_open, color: colorScheme.primary),
                  title: const Text('从文件导入'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.link, color: colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "视频链接",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_showBatchInput) ...[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: TextField(
                          controller: _batchUrlController,
                          decoration: InputDecoration(
                            hintText: "每行一个URL...\n支持批量粘贴视频链接",
                            prefixIcon: const Icon(Icons.playlist_play),
                            helperText: '每行一个URL，系统将按顺序下载',
                            helperMaxLines: 2,
                          ),
                          maxLines: 5,
                          minLines: 3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: isDownloading ? null : _startBatchDownload,
                          icon: isDownloading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                              : const Icon(Icons.download),
                          label: Text(isDownloading ? "下载中..." : "开始批量下载 (${_batchUrlController.text.split('\n').where((u) => u.trim().isNotEmpty).length}个)"),
                        ),
                      ),
                    ] else ...[
                      TextField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          hintText: "粘贴 YouTube, Bilibili、抖音等链接...",
                          prefixIcon: const Icon(Icons.link),
                          suffixIcon: _urlController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _urlController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) => setState(() {}),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) _startDownload(value);
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: isDownloading || _urlController.text.isEmpty
                              ? null
                              : () => _startDownload(_urlController.text),
                          icon: isDownloading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                              : const Icon(Icons.download),
                          label: Text(isDownloading ? "下载中..." : "开始下载"),
                        ),
                      ),
                    ],
                    if (_showOptions) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      _buildDownloadOptions(context),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(
              context,
              "任务日志",
              Icons.article_outlined,
              actions: [
                TextButton.icon(
                  onPressed: () => ref.read(appLogsProvider.notifier).clear(),
                  icon: const Icon(Icons.clear_all, size: 20),
                  label: const Text("清空"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Card(
              child: SizedBox(
                height: 200,
                child: LogViewer(),
              ),
            ),
            if (history.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionHeader(
                context,
                "下载历史",
                Icons.history,
                actions: [
                  TextButton.icon(
                    onPressed: () =>
                        ref.read(downloadProvider.notifier).clearHistory(),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: const Text("清空"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  itemBuilder: (context, index) {
                    final task = history[history.length - 1 - index];
                    return _buildHistoryTile(context, task);
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon, {
    List<Widget>? actions,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        if (actions != null) ...actions,
      ],
    );
  }

  Widget _buildHistoryTile(BuildContext context, DownloadTask task) {
    final colorScheme = Theme.of(context).colorScheme;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (task.status) {
      case DownloadStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = "完成";
        break;
      case DownloadStatus.failed:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = "失败";
        break;
      case DownloadStatus.downloading:
        statusColor = colorScheme.primary;
        statusIcon = Icons.downloading;
        statusText = "下载中";
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.pending;
        statusText = "等待中";
    }

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(statusIcon, color: statusColor, size: 22),
      ),
      title: Text(
        task.url,
        style: const TextStyle(fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _formatDate(task.createdAt),
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.outline,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (task.status == DownloadStatus.failed) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.refresh, color: colorScheme.primary, size: 20),
              tooltip: '重新下载',
              onPressed: () => ref.read(downloadProvider.notifier).startDownload(task.url),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDownloadOptions(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "下载选项",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "格式",
                    style: TextStyle(fontSize: 12, color: colorScheme.outline),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<DownloadFormat>(
                    value: settings.format,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: DownloadFormat.video, child: Text("视频")),
                      DropdownMenuItem(value: DownloadFormat.audio, child: Text("音频 (MP3)")),
                      DropdownMenuItem(value: DownloadFormat.thumbnail, child: Text("封面")),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(appSettingsProvider.notifier).setFormat(value);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "画质",
                    style: TextStyle(fontSize: 12, color: colorScheme.outline),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<VideoQuality>(
                    value: settings.quality,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: VideoQuality.best, child: Text("最佳")),
                      DropdownMenuItem(value: VideoQuality.p1080, child: Text("1080p")),
                      DropdownMenuItem(value: VideoQuality.p720, child: Text("720p")),
                      DropdownMenuItem(value: VideoQuality.p480, child: Text("480p")),
                      DropdownMenuItem(value: VideoQuality.p360, child: Text("360p")),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(appSettingsProvider.notifier).setQuality(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        if (settings.cookiePath != null && settings.cookiePath!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.cookie, size: 16, color: colorScheme.outline),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  settings.cookiePath!,
                  style: TextStyle(fontSize: 12, color: colorScheme.outline),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
