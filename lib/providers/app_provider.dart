import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/download_task.dart';

enum DownloadFormat {
  video,
  audio,
  thumbnail,
}

enum VideoQuality {
  best,
  p1080,
  p720,
  p480,
  p360,
}

enum DownloadMode {
  defaultMode,
  aria2,
}

enum CookiePlatform {
  youtube,
  bilibili,
  twitter,
  tiktok,
  custom,
}

class CustomCookie {
  final String id;
  final String name;
  final String domain;
  final String? remark;
  final String cookie;
  final DateTime createdAt;

  const CustomCookie({
    required this.id,
    required this.name,
    required this.domain,
    this.remark,
    required this.cookie,
    required this.createdAt,
  });

  CustomCookie copyWith({
    String? id,
    String? name,
    String? domain,
    String? remark,
    String? cookie,
    DateTime? createdAt,
  }) {
    return CustomCookie(
      id: id ?? this.id,
      name: name ?? this.name,
      domain: domain ?? this.domain,
      remark: remark ?? this.remark,
      cookie: cookie ?? this.cookie,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'domain': domain,
    'remark': remark,
    'cookie': cookie,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CustomCookie.fromJson(Map<String, dynamic> json) => CustomCookie(
    id: json['id'] as String,
    name: json['name'] as String,
    domain: json['domain'] as String,
    remark: json['remark'] as String?,
    cookie: json['cookie'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

extension CookiePlatformExtension on CookiePlatform {
  String get displayName {
    switch (this) {
      case CookiePlatform.youtube:
        return 'YouTube';
      case CookiePlatform.bilibili:
        return 'Bilibili';
      case CookiePlatform.twitter:
        return 'X (Twitter)';
      case CookiePlatform.tiktok:
        return 'TikTok';
      case CookiePlatform.custom:
        return '自定义';
    }
  }

  String get domain {
    switch (this) {
      case CookiePlatform.youtube:
        return 'youtube.com';
      case CookiePlatform.bilibili:
        return 'bilibili.com';
      case CookiePlatform.twitter:
        return 'twitter.com';
      case CookiePlatform.tiktok:
        return 'tiktok.com';
      case CookiePlatform.custom:
        return '';
    }
  }

  String get cookieFileName {
    switch (this) {
      case CookiePlatform.youtube:
        return 'cookies_youtube.txt';
      case CookiePlatform.bilibili:
        return 'cookies_bilibili.txt';
      case CookiePlatform.twitter:
        return 'cookies_twitter.txt';
      case CookiePlatform.tiktok:
        return 'cookies_tiktok.txt';
      case CookiePlatform.custom:
        return 'cookies_custom.txt';
    }
  }
}

extension DownloadModeExtension on DownloadMode {
  String get displayName {
    switch (this) {
      case DownloadMode.defaultMode:
        return '默认 (yt-dlp)';
      case DownloadMode.aria2:
        return 'Aria2 (多线程)';
    }
  }

  String get description {
    switch (this) {
      case DownloadMode.defaultMode:
        return '使用 yt-dlp 原生下载，速度较慢但稳定';
      case DownloadMode.aria2:
        return '使用 Aria2 多线程下载，速度更快';
    }
  }
}

class AppSettings {
  final String? ytDlpPath;
  final String? ffmpegPath;
  final String? aria2Path;
  final String? downloadPath;
  final DownloadFormat format;
  final VideoQuality quality;
  final DownloadMode downloadMode;
  final List<CustomCookie> customCookies;
  final int cookieVersion;

  const AppSettings({
    this.ytDlpPath,
    this.ffmpegPath,
    this.aria2Path,
    this.downloadPath,
    this.format = DownloadFormat.video,
    this.quality = VideoQuality.best,
    this.downloadMode = DownloadMode.defaultMode,
    this.customCookies = const [],
    this.cookieVersion = 0,
  });

  bool get isConfigured =>
      ytDlpPath != null &&
      ytDlpPath!.isNotEmpty &&
      ffmpegPath != null &&
      ffmpegPath!.isNotEmpty &&
      downloadPath != null &&
      downloadPath!.isNotEmpty;

  bool get isAria2Configured => aria2Path != null && aria2Path!.isNotEmpty;

  bool get isAndroid => Platform.isAndroid;

  AppSettings copyWith({
    String? ytDlpPath,
    String? ffmpegPath,
    String? aria2Path,
    String? downloadPath,
    DownloadFormat? format,
    VideoQuality? quality,
    DownloadMode? downloadMode,
    List<CustomCookie>? customCookies,
    int? cookieVersion,
  }) {
    return AppSettings(
      ytDlpPath: ytDlpPath ?? this.ytDlpPath,
      ffmpegPath: ffmpegPath ?? this.ffmpegPath,
      aria2Path: aria2Path ?? this.aria2Path,
      downloadPath: downloadPath ?? this.downloadPath,
      format: format ?? this.format,
      quality: quality ?? this.quality,
      downloadMode: downloadMode ?? this.downloadMode,
      customCookies: customCookies ?? this.customCookies,
      cookieVersion: cookieVersion ?? this.cookieVersion,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  static const String _netscapeHeader = '# Netscape HTTP Cookie File';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String? downloadPath = prefs.getString('download_path');
    
    if (downloadPath == null && Platform.isAndroid) {
      downloadPath = '/storage/emulated/0/Download/Videoader';
    }
    
    final formatIndex = prefs.getInt('download_format') ?? 0;
    final qualityIndex = prefs.getInt('video_quality') ?? 0;
    final downloadModeIndex = prefs.getInt('download_mode') ?? 0;
    
    final customCookiesJson = prefs.getString('custom_cookies');
    List<CustomCookie> customCookies = [];
    if (customCookiesJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(customCookiesJson);
        customCookies = decoded.map((e) => CustomCookie.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    
    state = AppSettings(
      ytDlpPath: prefs.getString('yt_dlp_path'),
      ffmpegPath: prefs.getString('ffmpeg_path'),
      aria2Path: prefs.getString('aria2_path'),
      downloadPath: downloadPath,
      format: DownloadFormat.values[formatIndex.clamp(0, DownloadFormat.values.length - 1)],
      quality: VideoQuality.values[qualityIndex.clamp(0, VideoQuality.values.length - 1)],
      downloadMode: DownloadMode.values[downloadModeIndex.clamp(0, DownloadMode.values.length - 1)],
      customCookies: customCookies,
      cookieVersion: 0,
    );

    _autoDetectAria2();
  }

  Future<void> _autoDetectAria2() async {
    if (state.aria2Path != null && state.aria2Path!.isNotEmpty) return;

    final List<String> searchPaths = [];
    
    if (Platform.isWindows) {
      searchPaths.addAll([
        p.join(Platform.environment['LOCALAPPDATA'] ?? '', 'Programs', 'aria2', 'aria2c.exe'),
        p.join(Platform.environment['ProgramFiles'] ?? '', 'aria2', 'aria2c.exe'),
        p.join(Platform.environment['ProgramFiles(x86)'] ?? '', 'aria2', 'aria2c.exe'),
        'C:\\aria2\\aria2c.exe',
        'C:\\Program Files\\aria2\\aria2c.exe',
      ]);
    } else if (Platform.isMacOS) {
      searchPaths.addAll([
        '/usr/local/bin/aria2c',
        '/usr/bin/aria2c',
        '/opt/homebrew/bin/aria2c',
        '${Platform.environment['HOME']}/.local/bin/aria2c',
      ]);
    } else if (Platform.isLinux) {
      searchPaths.addAll([
        '/usr/bin/aria2c',
        '/usr/local/bin/aria2c',
        '${Platform.environment['HOME']}/.local/bin/aria2c',
      ]);
    }

    for (final path in searchPaths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          final result = await Process.run(path, ['--version']);
          if (result.exitCode == 0) {
            await setAria2Path(path);
            break;
          }
        }
      } catch (_) {
        continue;
      }
    }
  }

  Future<String> getAppDataDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final cookieDir = Directory(p.join(dir.path, 'cookies'));
    if (!await cookieDir.exists()) {
      await cookieDir.create(recursive: true);
    }
    return cookieDir.path;
  }

  Future<String> getCookiePath(CookiePlatform platform) async {
    final appDir = await getAppDataDir();
    return p.join(appDir, platform.cookieFileName);
  }

  Future<bool> hasCookieFile(CookiePlatform platform) async {
    final path = await getCookiePath(platform);
    final file = File(path);
    return file.exists();
  }

  Future<void> setYtDlpPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('yt_dlp_path', path);
    state = state.copyWith(ytDlpPath: path);
  }

  Future<void> setFfmpegPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ffmpeg_path', path);
    state = state.copyWith(ffmpegPath: path);
  }

  Future<void> setAria2Path(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('aria2_path', path);
    state = state.copyWith(aria2Path: path);
  }

  Future<void> clearAria2Path() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('aria2_path');
    state = state.copyWith(aria2Path: null);
  }

  Future<void> setDownloadPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('download_path', path);
    state = state.copyWith(downloadPath: path);
  }

  Future<void> setDownloadMode(DownloadMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('download_mode', mode.index);
    state = state.copyWith(downloadMode: mode);
  }

  Future<void> addCookie(CookiePlatform platform, String url, String remark, String cookieContent) async {
    final cookiePath = await getCookiePath(platform);
    final file = File(cookiePath);

    final normalizedContent = _buildCookieFileContent(
      cookieContent,
      defaultDomain: platform.domain,
      remark: remark,
    );

    await file.writeAsString(normalizedContent);
    state = state.copyWith(cookieVersion: state.cookieVersion + 1);
  }

  Future<void> clearCookie(CookiePlatform platform) async {
    final cookiePath = await getCookiePath(platform);
    final file = File(cookiePath);
    if (await file.exists()) {
      await file.delete();
    }
    state = state.copyWith(cookieVersion: state.cookieVersion + 1);
  }

  Future<void> addCustomCookie(String name, String domain, String remark, String cookieContent) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final normalizedDomain = _normalizeCookieDomain(domain);
    final customCookie = CustomCookie(
      id: id,
      name: name,
      domain: normalizedDomain,
      remark: remark,
      cookie: cookieContent,
      createdAt: DateTime.now(),
    );
    
    final cookiePath = await _getCustomCookiePath(id);
    final file = File(cookiePath);

    final normalizedContent = _buildCookieFileContent(
      cookieContent,
      defaultDomain: normalizedDomain,
      remark: remark.isEmpty ? name : '$remark - $normalizedDomain',
    );

    await file.writeAsString(normalizedContent);
    
    final prefs = await SharedPreferences.getInstance();
    final updatedList = [...state.customCookies, customCookie];
    final jsonList = updatedList.map((e) => e.toJson()).toList();
    await prefs.setString('custom_cookies', jsonEncode(jsonList));
    
    state = state.copyWith(
      customCookies: updatedList,
      cookieVersion: state.cookieVersion + 1,
    );
  }

  Future<void> removeCustomCookie(String id) async {
    final cookiePath = await _getCustomCookiePath(id);
    final file = File(cookiePath);
    if (await file.exists()) {
      await file.delete();
    }
    
    final prefs = await SharedPreferences.getInstance();
    final updatedList = state.customCookies.where((c) => c.id != id).toList();
    final jsonList = updatedList.map((e) => e.toJson()).toList();
    await prefs.setString('custom_cookies', jsonEncode(jsonList));
    
    state = state.copyWith(
      customCookies: updatedList,
      cookieVersion: state.cookieVersion + 1,
    );
  }

  Future<void> updateCustomCookie(String id, String name, String domain, String remark, String cookieContent) async {
    final existingCookie = state.customCookies.firstWhere((c) => c.id == id);
    final normalizedDomain = _normalizeCookieDomain(domain);
    
    final cookiePath = await _getCustomCookiePath(id);
    final file = File(cookiePath);

    final normalizedContent = _buildCookieFileContent(
      cookieContent,
      defaultDomain: normalizedDomain,
      remark: remark.isEmpty ? name : '$remark - $normalizedDomain',
    );

    await file.writeAsString(normalizedContent);
    
    final updatedCookie = existingCookie.copyWith(
      name: name,
      domain: normalizedDomain,
      remark: remark,
      cookie: cookieContent,
    );
    
    final prefs = await SharedPreferences.getInstance();
    final updatedList = state.customCookies.map((c) => c.id == id ? updatedCookie : c).toList();
    final jsonList = updatedList.map((e) => e.toJson()).toList();
    await prefs.setString('custom_cookies', jsonEncode(jsonList));
    
    state = state.copyWith(
      customCookies: updatedList,
      cookieVersion: state.cookieVersion + 1,
    );
  }

  Future<String> _getCustomCookiePath(String id) async {
    final appDir = await getAppDataDir();
    return p.join(appDir, 'cookie_custom_$id.txt');
  }

  Future<String> getCustomCookiePath(String id) async {
    return _getCustomCookiePath(id);
  }

  Future<bool> hasCustomCookieFile(String id) async {
    final path = await _getCustomCookiePath(id);
    return File(path).exists();
  }

  Future<String?> resolveCookiePathForUrl(String url) async {
    final platform = detectPlatform(url);
    if (platform != null && await hasCookieFile(platform)) {
      return getCookiePath(platform);
    }

    final uri = Uri.tryParse(url);
    final host = uri?.host.toLowerCase();
    if (host == null || host.isEmpty) {
      return null;
    }

    final matchedCookies = state.customCookies.where((cookie) {
      final domain = _normalizeCookieDomain(cookie.domain);
      return host == domain || host.endsWith('.$domain');
    }).toList()
      ..sort((a, b) => b.domain.length.compareTo(a.domain.length));

    for (final cookie in matchedCookies) {
      final path = await _getCustomCookiePath(cookie.id);
      if (await File(path).exists()) {
        return path;
      }
    }

    return null;
  }

  CookiePlatform? detectPlatform(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('youtube.com') || 
        lowerUrl.contains('youtu.be') ||
        lowerUrl.contains('m.youtube.com')) {
      return CookiePlatform.youtube;
    }
    if (lowerUrl.contains('bilibili.com') || lowerUrl.contains('b23.tv')) {
      return CookiePlatform.bilibili;
    }
    if (lowerUrl.contains('twitter.com') || lowerUrl.contains('x.com')) {
      return CookiePlatform.twitter;
    }
    if (lowerUrl.contains('tiktok.com') || lowerUrl.contains('douyin.com')) {
      return CookiePlatform.tiktok;
    }
    return null;
  }

  String _buildCookieFileContent(
    String rawInput, {
    required String defaultDomain,
    String? remark,
  }) {
    final entries = _parseCookieEntries(rawInput, defaultDomain: defaultDomain);
    final lines = <String>[
      _netscapeHeader,
      '# This file was generated by Videoader',
      if (remark != null && remark.trim().isNotEmpty) '# ${remark.trim()}',
      '',
      ...entries,
    ];
    return lines.join('\n');
  }

  List<String> _parseCookieEntries(String rawInput, {required String defaultDomain}) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final netscapeEntries = _tryParseNetscapeEntries(trimmed);
    if (netscapeEntries.isNotEmpty) {
      return netscapeEntries;
    }

    final normalizedDomain = _normalizeCookieDomain(defaultDomain);
    final cookieDomain = normalizedDomain.startsWith('.') ? normalizedDomain : '.$normalizedDomain';
    final segments = trimmed
        .replaceAll('\r', '\n')
        .split(RegExp(r'[;\n]+'))
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty && !segment.startsWith('#'));

    final entries = <String>[];
    for (final segment in segments) {
      final separatorIndex = segment.indexOf('=');
      if (separatorIndex <= 0) {
        continue;
      }
      final name = segment.substring(0, separatorIndex).trim();
      final value = segment.substring(separatorIndex + 1).trim();
      if (name.isEmpty) {
        continue;
      }
      entries.add('$cookieDomain\tTRUE\t/\tFALSE\t0\t$name\t$value');
    }
    return entries;
  }

  List<String> _tryParseNetscapeEntries(String content) {
    final lines = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
    final entries = <String>[];

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) {
        continue;
      }

      final fields = line.split('\t');
      if (fields.length < 7) {
        continue;
      }

      final domain = fields[0].trim();
      final includeSubdomains = fields[1].trim().toUpperCase();
      final path = fields[2].trim().isEmpty ? '/' : fields[2].trim();
      final secure = fields[3].trim().toUpperCase();
      final expires = fields[4].trim().isEmpty ? '0' : fields[4].trim();
      final name = fields[5].trim();
      final value = fields.sublist(6).join('\t').trim();

      if (domain.isEmpty || name.isEmpty) {
        continue;
      }

      entries.add([
        domain,
        includeSubdomains == 'TRUE' ? 'TRUE' : 'FALSE',
        path,
        secure == 'TRUE' ? 'TRUE' : 'FALSE',
        expires,
        name,
        value,
      ].join('\t'));
    }

    return entries;
  }

  String _normalizeCookieDomain(String value) {
    var normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return normalized;
    }

    if (!normalized.contains('://') && normalized.contains('/')) {
      normalized = normalized.split('/').first;
    }

    if (normalized.contains('://')) {
      normalized = Uri.tryParse(normalized)?.host.toLowerCase() ?? normalized;
    }

    normalized = normalized.replaceFirst(RegExp(r'^\.+'), '');
    normalized = normalized.replaceFirst(RegExp(r':\d+$'), '');
    return normalized;
  }

  Future<void> setFormat(DownloadFormat format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('download_format', format.index);
    state = state.copyWith(format: format);
  }

  Future<void> setQuality(VideoQuality quality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('video_quality', quality.index);
    state = state.copyWith(quality: quality);
  }

  Future<Map<String, dynamic>> checkVersions() async {
    final results = <String, dynamic>{};
    
    if (state.ytDlpPath != null && state.ytDlpPath!.isNotEmpty) {
      try {
        final result = await Process.run(
          state.ytDlpPath!,
          ['--version'],
          runInShell: true,
        );
        final output = result.stdout.toString().trim();
        if (output.isNotEmpty) {
          final versionStr = output.trim();
          results['yt-dlp'] = {'version': versionStr};
          
          final dateMatch = RegExp(r'(\d{4})\.(\d{2})\.(\d{2})').firstMatch(versionStr);
          if (dateMatch != null) {
            final year = int.parse(dateMatch.group(1)!);
            final month = int.parse(dateMatch.group(2)!);
            final day = int.parse(dateMatch.group(3)!);
            final versionDate = DateTime(year, month, day);
            final daysOld = DateTime.now().difference(versionDate).inDays;
            results['yt-dlp'] = {
              'version': versionStr,
              'daysOld': daysOld,
              'updateAvailable': daysOld > 90,
            };
          }
        }
      } catch (e) {
        results['yt-dlp'] = {'error': e.toString()};
      }
    }
    
    if (state.ffmpegPath != null && state.ffmpegPath!.isNotEmpty) {
      try {
        String ffmpegExe = state.ffmpegPath!;
        if (ffmpegExe.toLowerCase().endsWith('.exe')) {
          ffmpegExe = p.dirname(ffmpegExe);
        }
        
        final ffprobePath = p.join(ffmpegExe, 'ffprobe.exe');
        final execPath = await File(ffprobePath).exists() ? ffprobePath : state.ffmpegPath!;
        
        final result = await Process.run(execPath, ['-version'], runInShell: true);
        final output = result.stdout.toString().trim();
        if (output.isNotEmpty) {
          final match = RegExp(r'ff(?:mpeg|probe) version (\S+)').firstMatch(output);
          results['ffmpeg'] = {'version': match?.group(1) ?? 'unknown'};
        }
      } catch (e) {
        results['ffmpeg'] = {'error': e.toString()};
      }
    }

    if (state.aria2Path != null && state.aria2Path!.isNotEmpty) {
      try {
        final result = await Process.run(state.aria2Path!, ['--version'], runInShell: true);
        final output = result.stdout.toString().trim();
        if (output.isNotEmpty) {
          final match = RegExp(r'aria2 version (\S+)').firstMatch(output);
          results['aria2'] = {'version': match?.group(1) ?? 'unknown'};
        }
      } catch (e) {
        results['aria2'] = {'error': e.toString()};
      }
    }
    
    return results;
  }

  Future<Map<String, dynamic>> updateYtDlp() async {
    final result = <String, dynamic>{};
    
    if (state.ytDlpPath != null && state.ytDlpPath!.isNotEmpty) {
      try {
        result['status'] = 'updating';
        result['message'] = '正在更新 yt-dlp...';
        
        final process = await Process.start(
          state.ytDlpPath!,
          ['-U'],
          runInShell: true,
        );
        
        final output = StringBuffer();
        await for (final data in process.stdout.transform(utf8.decoder)) {
          output.write(data);
        }
        await for (final data in process.stderr.transform(utf8.decoder)) {
          output.write(data);
        }
        
        final exitCode = await process.exitCode;
        result['status'] = exitCode == 0 ? 'success' : 'failed';
        result['output'] = output.toString();
        
        final versions = await checkVersions();
        result['newVersion'] = versions['yt-dlp'];
      } catch (e) {
        result['status'] = 'error';
        result['message'] = e.toString();
      }
    } else {
      result['status'] = 'error';
      result['message'] = 'yt-dlp 未配置';
    }
    
    return result;
  }
}

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});

class AppLogsNotifier extends StateNotifier<List<String>> {
  static const int maxLogs = 500;
  
  AppLogsNotifier() : super([]);

  void clear() {
    state = [];
  }

  void add(String message) {
    if (state.length >= maxLogs) {
      state = [...state.sublist(1), message];
    } else {
      state = [...state, message];
    }
  }

  void addError(String message) => add('❌ $message');
  void addSuccess(String message) => add('✅ $message');
  void addWarning(String message) => add('⚠️ $message');
  void addInfo(String message) => add('ℹ️ $message');
}

final appLogsProvider = StateNotifierProvider<AppLogsNotifier, List<String>>((ref) {
  return AppLogsNotifier();
});

class DownloadState {
  final bool isDownloading;
  final List<DownloadTask> tasks;
  final int? currentTaskIndex;

  const DownloadState({
    this.isDownloading = false,
    this.tasks = const [],
    this.currentTaskIndex,
  });

  DownloadState copyWith({
    bool? isDownloading,
    List<DownloadTask>? tasks,
    int? currentTaskIndex,
  }) {
    return DownloadState(
      isDownloading: isDownloading ?? this.isDownloading,
      tasks: tasks ?? this.tasks,
      currentTaskIndex: currentTaskIndex,
    );
  }
}

class DownloadNotifier extends StateNotifier<DownloadState> {
  final Ref _ref;

  DownloadNotifier(this._ref) : super(const DownloadState());

  Future<void> startDownload(String url) async {
    final settings = _ref.read(appSettingsProvider);
    final logs = _ref.read(appLogsProvider.notifier);

    if (!settings.isConfigured) {
      logs.addError('请先在设置中配置 yt-dlp、ffmpeg 路径和下载目录');
      return;
    }

    if (url.isEmpty) {
      logs.addError('URL 不能为空');
      return;
    }

    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    final task = DownloadTask(
      id: taskId,
      url: url,
      createdAt: DateTime.now(),
      status: DownloadStatus.downloading,
    );

    state = state.copyWith(
      isDownloading: true,
      tasks: [...state.tasks, task],
      currentTaskIndex: state.tasks.length,
    );

    logs.add('🚀 开始下载: $url');

    try {
      final args = await _buildArgs(settings, url, logs);

      final process = await Process.start(
        settings.ytDlpPath!,
        args,
        runInShell: true,
      );

      final stdoutBuffer = StringBuffer();
      final stderrBuffer = StringBuffer();

      process.stdout.transform(utf8.decoder).listen((data) {
        stdoutBuffer.write(data);
        if (data.trim().isNotEmpty) {
          logs.add(data.trim());
        }
      });

      process.stderr.transform(utf8.decoder).listen((data) {
        stderrBuffer.write(data);
        if (data.trim().isNotEmpty) {
          logs.addWarning(data.trim());
        }
      });

      final exitCode = await process.exitCode;

      final fullOutput = stdoutBuffer.toString() + stderrBuffer.toString();

      if (exitCode != 0) {
        final errorMatch = RegExp(r'ERROR?\s*[:\-]?\s*(.+)', caseSensitive: false).firstMatch(fullOutput);
        if (errorMatch != null) {
          logs.addError('错误: ${errorMatch.group(1)}');
        }
      }

      bool downloadSucceeded = exitCode == 0;
      String? errorMessage;

      if (exitCode != 0) {
        final hasError = fullOutput.contains('error') || fullOutput.contains('Error') || fullOutput.contains('ERROR');
        if (hasError) {
          errorMessage = 'Exit code: $exitCode';
        } else {
          downloadSucceeded = true;
        }
      }

      final updatedTasks = state.tasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(
            status: downloadSucceeded
                ? DownloadStatus.completed
                : DownloadStatus.failed,
            errorMessage: errorMessage,
          );
        }
        return t;
      }).toList();

      if (downloadSucceeded) {
        logs.addSuccess('下载完成！');
      } else {
        logs.addError('下载失败，退出代码: $exitCode');
      }

      state = state.copyWith(
        isDownloading: false,
        tasks: updatedTasks,
        currentTaskIndex: null,
      );
    } catch (e) {
      logs.addError('发生异常: $e');

      final updatedTasks = state.tasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(
            status: DownloadStatus.failed,
            errorMessage: e.toString(),
          );
        }
        return t;
      }).toList();

      state = state.copyWith(
        isDownloading: false,
        tasks: updatedTasks,
        currentTaskIndex: null,
      );
    }
  }

  Future<List<String>> _buildArgs(AppSettings settings, String url, AppLogsNotifier logs) async {
    String ffmpegDir = settings.ffmpegPath!;
    if (ffmpegDir.toLowerCase().endsWith('.exe')) {
      ffmpegDir = p.dirname(ffmpegDir);
    }

    final List<String> args = [
      '--ffmpeg-location',
      settings.ffmpegPath!,
      '-o',
      p.join(settings.downloadPath!, '%(title)s.%(ext)s'),
      '--newline',
    ];

    if (settings.downloadMode == DownloadMode.aria2 && settings.isAria2Configured) {
      args.addAll(['--downloader', 'aria2c', '--downloader-args', 'aria2c:-x 16 -s 16 -k 1M']);
      logs.addInfo('使用 Aria2 多线程下载模式');
    }

    final cookieNotifier = _ref.read(appSettingsProvider.notifier);
    final cookiePath = await cookieNotifier.resolveCookiePathForUrl(url);
    if (cookiePath != null) {
      args.addAll(['--cookies', cookiePath]);
      logs.addInfo('已应用 Cookie: $cookiePath');
    }

    switch (settings.format) {
      case DownloadFormat.audio:
        args.addAll(['-x', '--audio-format', 'mp3', '--audio-quality', '0']);
        break;
      case DownloadFormat.thumbnail:
        args.addAll(['--skip-download', '--write-thumbnail']);
        break;
      case DownloadFormat.video:
        _addVideoQualityArgs(args, settings.quality);
        break;
    }

    args.add(url);
    logs.addInfo('格式: ${settings.format.name}, 画质: ${settings.quality.name}, 模式: ${settings.downloadMode.displayName}');

    return args;
  }

  void _addVideoQualityArgs(List<String> args, VideoQuality quality) {
    switch (quality) {
      case VideoQuality.p1080:
        args.addAll(['-f', 'bestvideo[height<=1080]+bestaudio/best[height<=1080]']);
        break;
      case VideoQuality.p720:
        args.addAll(['-f', 'bestvideo[height<=720]+bestaudio/best[height<=720]']);
        break;
      case VideoQuality.p480:
        args.addAll(['-f', 'bestvideo[height<=480]+bestaudio/best[height<=480]']);
        break;
      case VideoQuality.p360:
        args.addAll(['-f', 'bestvideo[height<=360]+bestaudio/best[height<=360]']);
        break;
      case VideoQuality.best:
        break;
    }
  }

  void removeHistory(String taskId) {
    final updatedTasks = state.tasks.where((t) => t.id != taskId).toList();
    state = state.copyWith(tasks: updatedTasks);
  }

  void clearHistory() {
    state = state.copyWith(tasks: []);
  }
}

final downloadProvider = StateNotifierProvider<DownloadNotifier, DownloadState>((ref) {
  return DownloadNotifier(ref);
});

final isDownloadingProvider = Provider<bool>((ref) {
  return ref.watch(downloadProvider).isDownloading;
});

final downloadHistoryProvider = Provider<List<DownloadTask>>((ref) {
  return ref.watch(downloadProvider).tasks;
});
