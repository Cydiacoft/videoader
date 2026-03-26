import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/download_task.dart';
import '../providers/app_provider.dart';
import '../theme/fluid_theme.dart';
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
    final urlMatch = RegExp(r'https?://[^\s<>"{}|\\^`\[\]]+').firstMatch(input.trim());
    
    if (urlMatch != null) {
      var url = urlMatch.group(0)!;
      url = url.replaceAll(RegExp(r'[.,;:)\]}>]+$'), '');
      return url;
    }
    
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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(FluidSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(colorScheme),
                    const SizedBox(height: FluidSpacing.xl),
                    _buildHeroSection(colorScheme),
                    const SizedBox(height: FluidSpacing.lg),
                    _buildInputCard(context, isDownloading, colorScheme),
                    const SizedBox(height: FluidSpacing.xl),
                    _buildSectionHeader(
                      context,
                      "任务日志",
                      Icons.article_outlined,
                      onClear: () => ref.read(appLogsProvider.notifier).clear(),
                    ),
                    const SizedBox(height: FluidSpacing.md),
                    _buildLogCard(colorScheme),
                    if (history.isNotEmpty) ...[
                      const SizedBox(height: FluidSpacing.xl),
                      _buildSectionHeader(
                        context,
                        "下载历史",
                        Icons.history,
                        onClear: () => _showClearHistoryDialog(context, ref),
                      ),
                      const SizedBox(height: FluidSpacing.md),
                      ...history.reversed.map((task) => _buildHistoryItem(context, task, colorScheme)),
                    ],
                    const SizedBox(height: FluidSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: FluidGradients.primaryButton,
            borderRadius: FluidRadius.mdRadius,
          ),
          child: const Icon(
            Icons.download_rounded,
            color: FluidColors.onPrimary,
            size: 24,
          ),
        ),
        const SizedBox(width: FluidSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Videoader',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  letterSpacing: -1,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '视频下载工具',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.content_paste, color: colorScheme.onSurfaceVariant),
          tooltip: '从剪贴板粘贴',
          onPressed: () async {
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            final data = await Clipboard.getData(Clipboard.kTextPlain);
            if (data?.text != null && data!.text!.isNotEmpty) {
              final parsed = _parseUrl(data.text!);
              _urlController.text = parsed;
              setState(() {});
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(parsed != data.text!.trim() ? '已粘贴并解析链接' : '已从剪贴板粘贴'),
                  behavior: SnackBarBehavior.floating,
                  width: 200,
                  duration: const Duration(seconds: 1),
                ),
              );
            } else {
              scaffoldMessenger.showSnackBar(
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
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
          onSelected: (value) {
            if (value == 'file') {
              _selectFile();
            } else if (value == 'batch') {
              setState(() => _showBatchInput = !_showBatchInput);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'file',
              child: Row(
                children: [
                  Icon(Icons.file_open, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  const Text('从文件导入'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'batch',
              child: Row(
                children: [
                  Icon(Icons.playlist_add, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(_showBatchInput ? '单链接模式' : '批量下载模式'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(FluidSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FluidColors.primary.withValues(alpha: 0.08),
            FluidColors.tertiary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: FluidRadius.lgRadius,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '快速下载',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '支持 YouTube、Bilibili、抖音等平台',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: FluidRadius.smRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bolt,
                  size: 16,
                  color: FluidColors.tertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  'NVENC',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: FluidColors.tertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard(BuildContext context, bool isDownloading, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: FluidRadius.lgRadius,
        boxShadow: FluidShadows.ambient,
      ),
      child: Padding(
        padding: const EdgeInsets.all(FluidSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: FluidRadius.smRadius,
                  ),
                  child: Icon(
                    Icons.link,
                    color: colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: FluidSpacing.md),
                Text(
                  '视频链接',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FluidSpacing.lg),
            if (_showBatchInput) ...[
              TextField(
                controller: _batchUrlController,
                decoration: InputDecoration(
                  hintText: "每行一个URL...\n支持批量粘贴视频链接",
                  prefixIcon: Icon(Icons.playlist_play, color: colorScheme.onSurfaceVariant),
                  helperText: '每行一个URL，系统将按顺序下载',
                  helperMaxLines: 2,
                ),
                maxLines: 5,
                minLines: 3,
              ),
              const SizedBox(height: FluidSpacing.md),
              _buildPrimaryButton(
                context,
                isDownloading: isDownloading,
                onPressed: _startBatchDownload,
                label: '开始批量下载 (${_batchUrlController.text.split('\n').where((u) => u.trim().isNotEmpty).length}个)',
                icon: Icons.download,
              ),
            ] else ...[
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: "粘贴 YouTube, Bilibili、抖音等链接...",
                  prefixIcon: Icon(Icons.link, color: colorScheme.onSurfaceVariant),
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
              const SizedBox(height: FluidSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _buildPrimaryButton(
                      context,
                      isDownloading: isDownloading,
                      onPressed: _urlController.text.isEmpty ? null : () => _startDownload(_urlController.text),
                      label: '开始下载',
                      icon: Icons.download,
                    ),
                  ),
                  const SizedBox(width: FluidSpacing.sm),
                  IconButton(
                    onPressed: () => setState(() => _showOptions = !_showOptions),
                    icon: Icon(
                      _showOptions ? Icons.tune : Icons.tune_outlined,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    tooltip: '下载选项',
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: FluidRadius.lgRadius,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (_showOptions) ...[
              const SizedBox(height: FluidSpacing.lg),
              _buildDownloadOptions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context, {
    required bool isDownloading,
    required VoidCallback? onPressed,
    required String label,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: onPressed != null ? FluidGradients.primaryButton : null,
        color: onPressed == null ? FluidColors.surfaceContainerHighest : null,
        borderRadius: FluidRadius.lgRadius,
        boxShadow: onPressed != null ? FluidShadows.ambient : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: FluidRadius.lgRadius,
          child: Center(
            child: isDownloading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: FluidColors.onPrimary,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        color: onPressed != null ? FluidColors.onPrimary : FluidColors.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.5,
                          color: onPressed != null ? FluidColors.onPrimary : FluidColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon, {
    VoidCallback? onClear,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: FluidRadius.smRadius,
          ),
          child: Icon(icon, color: colorScheme.primary, size: 18),
        ),
        const SizedBox(width: FluidSpacing.md),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        if (onClear != null)
          TextButton(
            onPressed: onClear,
            child: Text(
              '清空',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLogCard(ColorScheme colorScheme) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: FluidRadius.mdRadius,
      ),
      child: const LogViewer(),
    );
  }

  Widget _buildHistoryItem(BuildContext context, DownloadTask task, ColorScheme colorScheme) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (task.status) {
      case DownloadStatus.completed:
        statusColor = FluidColors.tertiary;
        statusIcon = Icons.check_circle;
        statusText = "完成";
        break;
      case DownloadStatus.failed:
        statusColor = FluidColors.error;
        statusIcon = Icons.error;
        statusText = "失败";
        break;
      case DownloadStatus.downloading:
        statusColor = FluidColors.primary;
        statusIcon = Icons.downloading;
        statusText = "下载中";
        break;
      default:
        statusColor = FluidColors.onSurfaceVariant;
        statusIcon = Icons.pending;
        statusText = "等待中";
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: FluidSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(FluidSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: FluidRadius.mdRadius,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: FluidRadius.smRadius,
              ),
              child: Icon(statusIcon, color: statusColor, size: 22),
            ),
            const SizedBox(width: FluidSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.url,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(task.createdAt),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: FluidRadius.smRadius,
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: statusColor,
                ),
              ),
            ),
            if (task.status == DownloadStatus.failed) ...[
              const SizedBox(width: FluidSpacing.sm),
              IconButton(
                icon: Icon(Icons.refresh, color: colorScheme.primary, size: 20),
                tooltip: '重新下载',
                onPressed: () => ref.read(downloadProvider.notifier).startDownload(task.url),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: FluidRadius.smRadius,
                  ),
                ),
              ),
            ],
            const SizedBox(width: FluidSpacing.xs),
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error.withValues(alpha: 0.7), size: 18),
              tooltip: '删除记录',
              onPressed: () => _showDeleteHistoryDialog(context, ref, task),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: FluidRadius.smRadius,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteHistoryDialog(BuildContext context, WidgetRef ref, DownloadTask task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: FluidRadius.lgRadius),
        title: const Text("确认删除"),
        content: const Text("确定要删除这条下载记录吗？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("取消"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: FluidColors.error),
            child: const Text("删除"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(downloadProvider.notifier).removeHistory(task.id);
    }
  }

  Future<void> _showClearHistoryDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: FluidRadius.lgRadius),
        title: const Text("清空历史"),
        content: const Text("请选择清空方式："),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'single'),
            child: const Text("清空已完成"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'all'),
            style: FilledButton.styleFrom(backgroundColor: FluidColors.error),
            child: const Text("清空全部"),
          ),
        ],
      ),
    );

    if (result == 'all') {
      ref.read(downloadProvider.notifier).clearHistory();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('下载历史已清空')),
        );
      }
    } else if (result == 'single') {
      final history = ref.read(downloadHistoryProvider);
      final completedIds = history
          .where((t) => t.status == DownloadStatus.completed || t.status == DownloadStatus.failed)
          .map((t) => t.id)
          .toList();
      for (final id in completedIds) {
        ref.read(downloadProvider.notifier).removeHistory(id);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已完成记录已清空')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDownloadOptions(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(FluidSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: FluidRadius.smRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "下载选项",
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: FluidSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "格式",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: FluidRadius.smRadius,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<DownloadFormat>(
                          value: settings.format,
                          isExpanded: true,
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
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: FluidSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "画质",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: FluidRadius.smRadius,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<VideoQuality>(
                          value: settings.quality,
                          isExpanded: true,
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
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FluidSpacing.md),
          Container(
            padding: const EdgeInsets.all(FluidSpacing.sm),
            decoration: BoxDecoration(
              color: settings.downloadMode == DownloadMode.aria2
                  ? Colors.orange.withValues(alpha: 0.1)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: FluidRadius.smRadius,
            ),
            child: Row(
              children: [
                Icon(
                  settings.downloadMode == DownloadMode.aria2 ? Icons.speed : Icons.download,
                  size: 16,
                  color: settings.downloadMode == DownloadMode.aria2
                      ? Colors.orange.shade700
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '下载模式: ${settings.downloadMode.displayName}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: settings.downloadMode == DownloadMode.aria2
                        ? Colors.orange.shade700
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                if (settings.downloadMode == DownloadMode.aria2 && !settings.isAria2Configured) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade700,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '未配置',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                TextButton(
                  onPressed: () {
                  },
                  child: Text(
                    '在设置中修改',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
