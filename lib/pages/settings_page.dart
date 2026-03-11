import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/app_provider.dart';
import '../widgets/path_config_card.dart';
import 'cookie_login_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  Map<String, dynamic>? _versions;
  bool _checkingVersions = false;

  bool get isAndroid => Platform.isAndroid;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, "环境配置", Icons.tune),
          const SizedBox(height: 12),
          Card(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '提示: 请选择 yt-dlp 和 ffmpeg 可执行文件',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          PathConfigCard(
            title: "yt-dlp 执行文件",
            description: "选择 yt-dlp 可执行文件",
            currentPath: settings.ytDlpPath,
            icon: Icons.play_arrow_rounded,
            onTap: () => _selectFile(ref, 'yt-dlp'),
          ),
          if (settings.ytDlpPath == null || settings.ytDlpPath!.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton.icon(
                onPressed: () => _downloadTool('yt-dlp', context),
                icon: const Icon(Icons.download, size: 18),
                label: const Text("下载 yt-dlp"),
              ),
            ),
          if (_versions != null && _versions!.containsKey('yt-dlp')) ...[
            const SizedBox(height: 8),
            _buildVersionInfo(context, 'yt-dlp', _versions!['yt-dlp']),
          ],
          const SizedBox(height: 12),
          PathConfigCard(
            title: "ffmpeg 执行文件",
            description: "用于合并视频流和音频流",
            currentPath: settings.ffmpegPath,
            icon: Icons.movie_creation_outlined,
            onTap: () => _selectFile(ref, 'ffmpeg'),
          ),
          if (settings.ffmpegPath == null || settings.ffmpegPath!.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton.icon(
                onPressed: () => _downloadTool('ffmpeg', context),
                icon: const Icon(Icons.download, size: 18),
                label: const Text("下载 ffmpeg"),
              ),
            ),
          if (_versions != null && _versions!.containsKey('ffmpeg')) ...[
            const SizedBox(height: 8),
            _buildVersionInfo(context, 'ffmpeg', _versions!['ffmpeg']),
          ],
          const SizedBox(height: 12),
          Card(
            child: InkWell(
              onTap: _checkingVersions ? null : () => _checkVersions(ref),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _checkingVersions
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              Icons.system_update,
                              color: colorScheme.onSecondaryContainer,
                              size: 22,
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "检查更新",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _checkingVersions 
                                ? "正在检查..." 
                                : "检查 yt-dlp 和 ffmpeg 是否有新版本",
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: colorScheme.outline,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          PathConfigCard(
            title: "下载保存目录",
            description: "视频下载后的存储位置",
            currentPath: settings.downloadPath,
            icon: Icons.folder_open_rounded,
            onTap: () => _selectDirectory(context, ref),
            isDirectory: true,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, "Cookie 配置 (可选)", Icons.cookie),
          const SizedBox(height: 12),
          Card(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '用于登录后才能访问的视频，支持 Netscape 格式的 cookie 文件',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          PathConfigCard(
            title: "Cookie 文件",
            description: "浏览器导出的 cookie 文件 (cookies.txt)",
            currentPath: settings.cookiePath,
            icon: Icons.cookie_outlined,
            onTap: () => _selectCookieFile(ref),
            onClear: settings.cookiePath != null 
                ? () => ref.read(appSettingsProvider.notifier).setCookiePath('')
                : null,
          ),
          const SizedBox(height: 12),
          Card(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.content_paste, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '或手动粘贴 Cookie 文本',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showPasteCookieDialog(context, ref),
                    child: const Text("粘贴"),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: InkWell(
              onTap: () => _openCookieLogin(context),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.login,
                        color: colorScheme.onSecondaryContainer,
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
                                "在线登录",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.open_in_new,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Platform.isAndroid || Platform.isIOS 
                                ? "使用内置浏览器登录并导出 Cookie"
                                : "仅移动端支持在线登录",
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () => _openCookieLogin(context),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(Platform.isAndroid || Platform.isIOS ? "登录" : "查看"),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildStatusCard(context, settings),
          const SizedBox(height: 24),
          _buildSectionHeader(context, "关于", Icons.info_outline),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.download,
                          color: colorScheme.onPrimaryContainer,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Videoader",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "跨平台视频下载工具",
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    "支持从 YouTube、Bilibili、抖音等平台下载视频",
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectFile(WidgetRef ref, String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.single.path;
      if (path != null) {
        switch (type) {
          case 'yt-dlp':
            await ref.read(appSettingsProvider.notifier).setYtDlpPath(path);
            break;
          case 'ffmpeg':
            await ref.read(appSettingsProvider.notifier).setFfmpegPath(path);
            break;
        }
      }
    }
  }

  Future<void> _selectDirectory(BuildContext context, WidgetRef ref) async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      await ref.read(appSettingsProvider.notifier).setDownloadPath(selectedDirectory);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('下载目录已设置为: $selectedDirectory'),
            behavior: SnackBarBehavior.floating,
            width: 300,
          ),
        );
      }
    }
  }

  Future<void> _selectCookieFile(WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.single.path;
      if (path != null) {
        await ref.read(appSettingsProvider.notifier).setCookiePath(path);
      }
    }
  }

  Future<void> _checkVersions(WidgetRef ref) async {
    setState(() => _checkingVersions = true);
    try {
      final versions = await ref.read(appSettingsProvider.notifier).checkVersions();
      setState(() {
        _versions = versions;
        _checkingVersions = false;
      });
      
      if (mounted) {
        final ytDlpInfo = versions['yt-dlp'];
        final daysOld = ytDlpInfo is Map ? ytDlpInfo['daysOld'] as int? : null;
        final hasUpdate = daysOld != null && daysOld > 90;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasUpdate 
                ? "检测到 yt-dlp 已过期 $daysOld 天，建议更新！" 
                : "版本检查完成"),
            backgroundColor: hasUpdate ? Colors.orange : null,
          ),
        );
      }
    } catch (e) {
      setState(() => _checkingVersions = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("检查失败: $e")),
        );
      }
    }
  }

  Future<void> _downloadTool(String tool, BuildContext context) async {
    String url;
    String name;
    
    switch (tool) {
      case 'yt-dlp':
        url = 'https://github.com/yt-dlp/yt-dlp/releases';
        name = 'yt-dlp';
        break;
      case 'ffmpeg':
        url = 'https://github.com/BtbN/FFmpeg-Builds/releases';
        name = 'ffmpeg';
        break;
      default:
        return;
    }
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("下载 $name"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("将打开 $name 的官方下载页面。"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "下载后请解压并将可执行文件路径配置到本应用中",
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "注意: 本软件不包含 $name，仅提供下载链接。",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("取消"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("打开下载页面"),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  Future<void> _updateYtDlp(WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("更新 yt-dlp"),
        content: const Text("确定要更新 yt-dlp 吗？更新过程可能需要一些时间。"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("取消"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("更新"),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text("正在更新 yt-dlp..."),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );
    
    try {
      final result = await ref.read(appSettingsProvider.notifier).updateYtDlp();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      if (result['status'] == 'success') {
        final versions = await ref.read(appSettingsProvider.notifier).checkVersions();
        setState(() => _versions = versions);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("更新成功！新版本: ${result['newVersion']}"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("更新失败: ${result['message'] ?? result['output']}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("更新出错: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
    
  Widget _buildVersionInfo(BuildContext context, String name, dynamic info) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (info is Map && info.containsKey('error')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 16, color: colorScheme.error),
            const SizedBox(width: 8),
            Text(
              "$name: 获取版本失败",
              style: TextStyle(fontSize: 12, color: colorScheme.error),
            ),
          ],
        ),
      );
    }
    
    final version = info is Map ? info['version'] : 'unknown';
    final daysOld = info is Map ? info['daysOld'] as int? : null;
    final hasUpdate = info is Map && info['updateAvailable'] == true;
    final isYtDlp = name == 'yt-dlp';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: hasUpdate 
            ? Colors.orange.withValues(alpha: 0.15) 
            : colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            hasUpdate ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            size: 16,
            color: hasUpdate ? Colors.orange : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$name: $version",
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                ),
                if (hasUpdate && daysOld != null)
                  Text(
                    "已过期 $daysOld 天，建议更新！",
                    style: TextStyle(fontSize: 11, color: Colors.orange),
                  ),
                if (!hasUpdate && daysOld != null)
                  Text(
                    "版本较新 ($daysOld 天前发布)",
                    style: TextStyle(fontSize: 11, color: Colors.green),
                  ),
              ],
            ),
          ),
          if (isYtDlp)
            TextButton.icon(
              onPressed: () => _updateYtDlp(ref),
              icon: const Icon(Icons.system_update, size: 16),
              label: const Text("更新", style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }

  void _openCookieLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CookieLoginPage(),
      ),
    );
  }

  Future<void> _showPasteCookieDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final settings = ref.read(appSettingsProvider);
    
    await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("粘贴 Cookie"),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "请从浏览器开发者工具 -> Application -> Cookies 中复制 Cookie 文本",
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "粘贴 Cookie 文本...",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("请粘贴 Cookie")),
                );
                return;
              }
              
              try {
                final cookieFile = File('${settings.downloadPath}/cookies.txt');
                await cookieFile.writeAsString(controller.text);
                await ref.read(appSettingsProvider.notifier).setCookiePath(cookieFile.path);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cookie 已保存到: ${cookieFile.path}')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('保存失败: $e')),
                  );
                }
              }
            },
            child: const Text("保存"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, AppSettings settings) {
    final isConfigured = settings.isConfigured;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isConfigured 
                    ? const Color(0xFFE8F5E9) 
                    : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isConfigured ? Icons.check_circle : Icons.warning_amber_rounded,
                color: isConfigured ? Colors.green : Colors.orange,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isConfigured ? "配置完成" : "配置未完成",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isConfigured
                        ? "所有必要的工具已配置，可以开始下载视频"
                        : "请完成 yt-dlp 和 ffmpeg 配置后才能下载视频",
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
