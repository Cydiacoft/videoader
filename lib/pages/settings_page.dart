import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/app_provider.dart';
import '../widgets/path_config_card.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  Map<String, dynamic>? _versions;
  bool _checkingVersions = false;
  bool _envSectionExpanded = true;
  bool _cookieSectionExpanded = true;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('璁剧疆'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsItem(
            context: context,
            colorScheme: colorScheme,
            icon: Icons.settings_input_component,
            iconColor: colorScheme.primary,
            title: '鐜閰嶇疆',
            subtitle: '閰嶇疆蹇呰鐨勫彲鎵ц鏂囦欢',
            isExpanded: _envSectionExpanded,
            onToggle: () => setState(() => _envSectionExpanded = !_envSectionExpanded),
            child: _buildEnvironmentSection(settings, colorScheme),
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            context: context,
            colorScheme: colorScheme,
            icon: Icons.cookie,
            iconColor: Colors.orange,
            title: 'Cookies 閰嶇疆',
            subtitle: '鐢ㄤ簬璁块棶闇€瑕佺櫥褰曠殑鍐呭',
            isExpanded: _cookieSectionExpanded,
            onToggle: () => setState(() => _cookieSectionExpanded = !_cookieSectionExpanded),
            child: _buildCookieSection(settings, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required ColorScheme colorScheme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: child,
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildEnvironmentSection(AppSettings settings, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    '鎻愮ず: 璇峰厛閰嶇疆 yt-dlp銆乫fmpeg 鍜屼笅杞界洰褰曪紝aria2 涓哄彲閫夊姞閫熷櫒銆?,
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
          title: 'yt-dlp 鍙墽琛屾枃浠?,
          description: '閫夋嫨 yt-dlp 鍙墽琛屾枃浠?,
          currentPath: settings.ytDlpPath,
          icon: Icons.play_arrow_rounded,
          onTap: () => _selectFile(ref, 'yt-dlp'),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: TextButton.icon(
            onPressed: () => _downloadTool('yt-dlp', context),
            icon: const Icon(Icons.download, size: 18),
            label: const Text('涓嬭浇/鏇存柊 yt-dlp'),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
            ),
          ),
        ),
        if (_versions != null && _versions!.containsKey('yt-dlp')) ...[
          const SizedBox(height: 8),
          _buildVersionInfo(context, 'yt-dlp', _versions!['yt-dlp']),
        ],
        const SizedBox(height: 12),
        PathConfigCard(
          title: 'ffmpeg 鍙墽琛屾枃浠?,
          description: '鐢ㄤ簬鍚堝苟瑙嗛娴佸拰闊抽娴?,
          currentPath: settings.ffmpegPath,
          icon: Icons.movie_creation_outlined,
          onTap: () => _selectFile(ref, 'ffmpeg'),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: TextButton.icon(
            onPressed: () => _downloadTool('ffmpeg', context),
            icon: const Icon(Icons.download, size: 18),
            label: const Text('涓嬭浇/鏇存柊 ffmpeg'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.purple,
            ),
          ),
        ),
        if (_versions != null && _versions!.containsKey('ffmpeg')) ...[
          const SizedBox(height: 8),
          _buildVersionInfo(context, 'ffmpeg', _versions!['ffmpeg']),
        ],
        const SizedBox(height: 12),
        PathConfigCard(
          title: 'aria2 鍙墽琛屾枃浠讹紙鍙€夛級',
          description: '澶氱嚎绋嬩笅杞藉姞閫熷櫒',
          currentPath: settings.aria2Path,
          icon: Icons.speed,
          onTap: () => _selectFile(ref, 'aria2'),
          onClear: settings.aria2Path != null
              ? () => ref.read(appSettingsProvider.notifier).clearAria2Path()
              : null,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: TextButton.icon(
            onPressed: () => _downloadTool('aria2', context),
            icon: const Icon(Icons.download, size: 18),
            label: const Text('涓嬭浇/鏇存柊 aria2'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.teal,
            ),
          ),
        ),
        if (_versions != null && _versions!.containsKey('aria2')) ...[
          const SizedBox(height: 8),
          _buildVersionInfo(context, 'aria2', _versions!['aria2']),
        ],
        const SizedBox(height: 12),
        PathConfigCard(
          title: '涓嬭浇鐩綍',
          description: '閫夋嫨瑙嗛淇濆瓨浣嶇疆',
          currentPath: settings.downloadPath,
          icon: Icons.folder_open,
          isDirectory: true,
          onTap: () => _selectDownloadPath(ref),
        ),
        const SizedBox(height: 12),
        Card(
          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
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
                      color: colorScheme.primaryContainer,
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
                            color: colorScheme.onPrimaryContainer,
                            size: 22,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '妫€鏌ュ伐鍏风増鏈?,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '妫€鏌?yt-dlp銆乫fmpeg銆乤ria2 鏄惁鍙敤浠ュ強鏄惁杩囨棫',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVersionInfo(BuildContext context, String tool, dynamic versionData) {
    final colorScheme = Theme.of(context).colorScheme;
    
    String displayText;
    Color iconColor;
    
    if (versionData is Map && versionData.containsKey('error')) {
      displayText = '$tool: ${versionData['error']}';
      iconColor = Colors.red;
    } else if (versionData is Map) {
      final version = versionData['version'] ?? 'unknown';
      final daysOld = versionData['daysOld'];
      displayText = '$tool: $version';
      if (daysOld != null && daysOld > 90) {
        iconColor = Colors.orange;
      } else {
        iconColor = colorScheme.tertiary;
      }
    } else {
      displayText = '$tool: $versionData';
      iconColor = colorScheme.tertiary;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: iconColor, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              displayText,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectFile(WidgetRef ref, String tool) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.single.path;
      if (path != null) {
        final notifier = ref.read(appSettingsProvider.notifier);
        if (tool == 'yt-dlp') {
          await notifier.setYtDlpPath(path);
        } else if (tool == 'ffmpeg') {
          await notifier.setFfmpegPath(path);
        } else if (tool == 'aria2') {
          await notifier.setAria2Path(path);
        }
      }
    }
  }

  Future<void> _selectDownloadPath(WidgetRef ref) async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      await ref.read(appSettingsProvider.notifier).setDownloadPath(result);
    }
  }

  Future<void> _downloadTool(String tool, BuildContext context) async {
    String url;
    String toolName;
    if (tool == 'yt-dlp') {
      url = 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe';
      toolName = 'yt-dlp';
    } else if (tool == 'ffmpeg') {
      url = 'https://www.gyan.dev/ffmpeg/release/packages/ffmpeg-release-essentials.zip';
      toolName = 'ffmpeg';
    } else {
      url = 'https://github.com/aria2/aria2/releases/latest/download/aria2-${Platform.isWindows ? 'win' : 'linux'}-64bit.zip';
      toolName = 'aria2';
    }
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final snackBar = SnackBar(
      content: Text('璇锋墜鍔ㄤ笅杞?$toolName: $url'),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: '澶嶅埗',
        onPressed: () {
          Clipboard.setData(ClipboardData(text: url));
          Future.delayed(const Duration(seconds: 3), () {
            scaffoldMessenger.hideCurrentSnackBar();
          });
        },
      ),
    );
    scaffoldMessenger.showSnackBar(snackBar);
  }

  Widget _buildCookieSection(AppSettings settings, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Colors.orange.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cookie 鐢ㄤ簬璁块棶闇€瑕佺櫥褰曠殑鍐呭锛屽浼氬憳瑙嗛',
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
        ...CookiePlatform.values
            .where((p) => p != CookiePlatform.custom)
            .map((platform) => _buildPlatformCookiePanel(context, ref, platform, colorScheme)),
        const SizedBox(height: 16),
        _buildCustomCookiesPanel(settings, colorScheme),
      ],
    );
  }

  Widget _buildPlatformCookiePanel(
    BuildContext context,
    WidgetRef ref,
    CookiePlatform platform,
    ColorScheme colorScheme,
  ) {
    final cookieVersion = ref.watch(appSettingsProvider.select((settings) => settings.cookieVersion));
    return FutureBuilder<bool>(
      key: ValueKey('platform-cookie-${platform.name}-$cookieVersion'),
      future: ref.read(appSettingsProvider.notifier).hasCookieFile(platform),
      builder: (context, snapshot) {
        final hasCookie = snapshot.data == true;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _showCookieInputDialog(context, ref, platform),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: hasCookie
                          ? Colors.orange.withValues(alpha: 0.2)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      hasCookie ? Icons.check_circle : Icons.cookie,
                      color: hasCookie ? Colors.orange : colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          platform.displayName,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasCookie ? '宸查厤缃?Cookie' : '鐐瑰嚮娣诲姞 Cookie',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasCookie)
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: colorScheme.error),
                      tooltip: '娓呴櫎 Cookie',
                      onPressed: () => _clearCookieWithFeedback(context, ref, platform),
                    ),
                  Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomCookiesPanel(AppSettings settings, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '鑷畾涔夌綉绔?,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...settings.customCookies.map(
          (cookie) => _buildCustomCookiePanel(context, ref, cookie, colorScheme),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showCustomCookieDialog(context, ref),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  '娣诲姞鑷畾涔?Cookie',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomCookiePanel(
    BuildContext context,
    WidgetRef ref,
    CustomCookie cookie,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.language, color: Colors.orange, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cookie.name,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  cookie.domain,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: colorScheme.primary, size: 20),
            tooltip: '缂栬緫',
            onPressed: () => _showCustomCookieDialog(context, ref, existing: cookie),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: colorScheme.error, size: 20),
            tooltip: '鍒犻櫎',
            onPressed: () => _deleteCustomCookieWithFeedback(context, ref, cookie),
          ),
        ],
      ),
    );
  }

  Future<void> _showCookieInputDialog(
    BuildContext context,
    WidgetRef ref,
    CookiePlatform platform,
  ) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('娣诲姞 ${platform.displayName} Cookie'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '鏀寔绮樿创 document.cookie 鎴?Netscape cookies.txt 鍐呭銆?,
                  style: Theme.of(dialogContext).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: '渚嬪: session=xxx; uid=123',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final content = await _pickCookieFileContent();
                    if (content == null || content.isEmpty) return;
                    setDialogState(() => controller.text = content);
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('浠庢枃浠跺鍏?),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('鍙栨秷'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
              child: const Text('淇濆瓨'),
            ),
          ],
        ),
      ),
    );

    if (result == null || result.isEmpty) return;

    await ref.read(appSettingsProvider.notifier).addCookie(
          platform,
          '',
          '鎵嬪姩娣诲姞',
          result,
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${platform.displayName} Cookie 宸蹭繚瀛?)),
      );
    }
  }

  Future<void> _showCustomCookieDialog(
    BuildContext context,
    WidgetRef ref, {
    CustomCookie? existing,
  }) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final domainController = TextEditingController(text: existing?.domain ?? '');
    final cookieController = TextEditingController(text: existing?.cookie ?? '');
    String? errorText;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(existing == null ? '娣诲姞鑷畾涔?Cookie' : '缂栬緫鑷畾涔?Cookie'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: '缃戠珯鍚嶇О',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: domainController,
                  decoration: InputDecoration(
                    labelText: '缃戠珯鍩熷悕鎴?URL',
                    hintText: '渚嬪: example.com 鎴?https://example.com',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    errorText: errorText,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cookieController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Cookie 鍐呭',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final content = await _pickCookieFileContent();
                      if (content == null || content.isEmpty) return;
                      setDialogState(() => cookieController.text = content);
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('浠庢枃浠跺鍏?),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('鍙栨秷'),
            ),
            FilledButton(
              onPressed: () {
                final normalizedDomain = _normalizeDomainInput(domainController.text);
                if (nameController.text.trim().isEmpty ||
                    normalizedDomain == null ||
                    cookieController.text.trim().isEmpty) {
                  setDialogState(() {
                    errorText = normalizedDomain == null ? '璇疯緭鍏ュ悎娉曠殑鍩熷悕鎴?URL' : null;
                  });
                  return;
                }

                Navigator.pop(dialogContext, {
                  'name': nameController.text.trim(),
                  'domain': normalizedDomain,
                  'cookie': cookieController.text.trim(),
                });
              },
              child: const Text('淇濆瓨'),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;

    final notifier = ref.read(appSettingsProvider.notifier);
    if (existing == null) {
      await notifier.addCustomCookie(result['name']!, result['domain']!, '', result['cookie']!);
    } else {
      await notifier.updateCustomCookie(
        existing.id,
        result['name']!,
        result['domain']!,
        '',
        result['cookie']!,
      );
    }

    if (context.mounted) {
      final label = existing == null ? '宸蹭繚瀛? : '宸叉洿鏂?;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${result['name']} Cookie $label')),
      );
    }
  }

  Future<void> _clearCookieWithFeedback(
    BuildContext context,
    WidgetRef ref,
    CookiePlatform platform,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('纭娓呴櫎'),
        content: Text('纭畾瑕佹竻闄?${platform.displayName} 鐨?Cookie 鍚楋紵'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('鍙栨秷'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('娓呴櫎'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await ref.read(appSettingsProvider.notifier).clearCookie(platform);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${platform.displayName} Cookie 宸叉竻闄?)),
      );
    }
  }

  Future<void> _deleteCustomCookieWithFeedback(
    BuildContext context,
    WidgetRef ref,
    CustomCookie cookie,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('纭鍒犻櫎'),
        content: Text('纭畾瑕佸垹闄?${cookie.name} 鐨?Cookie 鍚楋紵'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('鍙栨秷'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('鍒犻櫎'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await ref.read(appSettingsProvider.notifier).removeCustomCookie(cookie.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${cookie.name} Cookie 宸插垹闄?)),
      );
    }
  }

  Future<String?> _pickCookieFileContent() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['txt', 'cookies'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final path = result.files.single.path;
    if (path == null) {
      return null;
    }

    final file = File(path);
    if (!await file.exists()) {
      return null;
    }

    return file.readAsString();
  }

  String? _normalizeDomainInput(String input) {
    var value = input.trim().toLowerCase();
    if (value.isEmpty) {
      return null;
    }

    if (value.contains('://')) {
      value = Uri.tryParse(value)?.host.toLowerCase() ?? '';
    } else if (value.contains('/')) {
      value = value.split('/').first;
    }

    value = value.replaceFirst(RegExp(r'^\.+'), '');
    value = value.replaceFirst(RegExp(r':\d+$'), '');

    if (value.isEmpty || !value.contains('.') || value.contains(' ')) {
      return null;
    }

    return value;
  }

  Future<void> _checkVersions(WidgetRef ref) async {
    if (!mounted) return;
    setState(() => _checkingVersions = true);
    try {
      final versions = await ref.read(appSettingsProvider.notifier).checkVersions().timeout(
        const Duration(seconds: 10),
        onTimeout: () => <String, dynamic>{'error': 'timeout'},
      );
      if (!mounted) return;
      setState(() {
        _versions = versions;
        _checkingVersions = false;
      });
      if (versions.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('鐗堟湰妫€鏌ュけ璐ワ紝璇锋鏌ラ厤缃矾寰?)),
        );
        return;
      }
      final ytDlpInfo = versions['yt-dlp'];
      final daysOld = ytDlpInfo is Map ? ytDlpInfo['daysOld'] as int? : null;
      final hasUpdate = daysOld != null && daysOld > 90;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasUpdate
                ? "妫€娴嬪埌 yt-dlp 宸茶繃鏈?$daysOld 澶╋紝寤鸿鏇存柊锛?
                : "鐗堟湰妫€鏌ュ畬鎴?),
            backgroundColor: hasUpdate ? Colors.orange : null,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _checkingVersions = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('鐗堟湰妫€鏌ュけ璐? $e')),
      );
    }
  }

}
