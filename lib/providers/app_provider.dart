import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
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

class AppSettings {
  final String? ytDlpPath;
  final String? ffmpegPath;
  final String? downloadPath;
  final String? cookiePath;
  final DownloadFormat format;
  final VideoQuality quality;

  const AppSettings({
    this.ytDlpPath,
    this.ffmpegPath,
    this.downloadPath,
    this.cookiePath,
    this.format = DownloadFormat.video,
    this.quality = VideoQuality.best,
  });

  bool get isConfigured => ytDlpPath != null && ffmpegPath != null && downloadPath != null;

  bool get isAndroid => Platform.isAndroid;

  AppSettings copyWith({
    String? ytDlpPath,
    String? ffmpegPath,
    String? downloadPath,
    String? cookiePath,
    DownloadFormat? format,
    VideoQuality? quality,
  }) {
    return AppSettings(
      ytDlpPath: ytDlpPath ?? this.ytDlpPath,
      ffmpegPath: ffmpegPath ?? this.ffmpegPath,
      downloadPath: downloadPath ?? this.downloadPath,
      cookiePath: cookiePath ?? this.cookiePath,
      format: format ?? this.format,
      quality: quality ?? this.quality,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String? downloadPath = prefs.getString('download_path');
    
    if (downloadPath == null && Platform.isAndroid) {
      downloadPath = '/storage/emulated/0/Download/Videoader';
    }
    
    final formatIndex = prefs.getInt('download_format') ?? 0;
    final qualityIndex = prefs.getInt('video_quality') ?? 0;
    
    state = AppSettings(
      ytDlpPath: prefs.getString('yt_dlp_path'),
      ffmpegPath: prefs.getString('ffmpeg_path'),
      downloadPath: downloadPath,
      cookiePath: prefs.getString('cookie_path'),
      format: DownloadFormat.values[formatIndex],
      quality: VideoQuality.values[qualityIndex],
    );
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

  Future<void> setDownloadPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('download_path', path);
    state = state.copyWith(downloadPath: path);
  }

  Future<void> setCookiePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cookie_path', path);
    state = state.copyWith(cookiePath: path);
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
          results['yt-dlp'] = {
            'version': versionStr,
          };
          
          try {
            final dateMatch = RegExp(r'(\d{4})\.(\d{2})\.(\d{2})').firstMatch(versionStr);
            if (dateMatch != null) {
              final year = int.parse(dateMatch.group(1)!);
              final month = int.parse(dateMatch.group(2)!);
              final day = int.parse(dateMatch.group(3)!);
              final versionDate = DateTime(year, month, day);
              final now = DateTime.now();
              final daysOld = now.difference(versionDate).inDays;
              results['yt-dlp'] = {
                'version': versionStr,
                'daysOld': daysOld,
                'updateAvailable': daysOld > 90,
              };
            }
          } catch (e) {
            // 解析失败，忽略
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
        
        // 尝试查找 ffprobe 或直接用 ffmpeg
        final ffprobePath = p.join(ffmpegExe, 'ffprobe.exe');
        final execPath = await File(ffprobePath).exists() ? ffprobePath : state.ffmpegPath!;
        
        final result = await Process.run(
          execPath,
          ['-version'],
          runInShell: true,
        );
        final output = result.stdout.toString().trim();
        if (output.isNotEmpty) {
          final match = RegExp(r'ffmpeg version (\S+)').firstMatch(output);
          results['ffmpeg'] = {
            'version': match?.group(1) ?? 'unknown',
          };
        }
      } catch (e) {
        results['ffmpeg'] = {'error': e.toString()};
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
        await for (final data in process.stdout.transform(const SystemEncoding().decoder)) {
          output.write(data);
        }
        await for (final data in process.stderr.transform(const SystemEncoding().decoder)) {
          output.write(data);
        }
        
        final exitCode = await process.exitCode;
        result['status'] = exitCode == 0 ? 'success' : 'failed';
        result['output'] = output.toString();
        
        // 重新检查版本
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

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});

class AppLogsNotifier extends StateNotifier<List<String>> {
  AppLogsNotifier() : super([]);

  void clear() {
    state = [];
  }

  void add(String message) {
    state = [...state, message];
  }
}

final appLogsProvider =
    StateNotifierProvider<AppLogsNotifier, List<String>>((ref) {
  return AppLogsNotifier();
});

class DownloadState {
  final bool isDownloading;
  final List<DownloadTask> tasks;

  const DownloadState({
    this.isDownloading = false,
    this.tasks = const [],
  });

  DownloadState copyWith({
    bool? isDownloading,
    List<DownloadTask>? tasks,
  }) {
    return DownloadState(
      isDownloading: isDownloading ?? this.isDownloading,
      tasks: tasks ?? this.tasks,
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
      logs.add("错误: 请先在设置中配置 yt-dlp、ffmpeg 路径和下载目录");
      return;
    }

    if (url.isEmpty) {
      logs.add("错误: URL 不能为空");
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
    );

    logs.add("🚀 开始下载: $url");

    try {
      String ffmpegDir = settings.ffmpegPath!;
      if (ffmpegDir.toLowerCase().endsWith('.exe')) {
        ffmpegDir = p.dirname(ffmpegDir);
      }

      final List<String> args = [
        '--ffmpeg-location',
        ffmpegDir,
        '-o',
        p.join(settings.downloadPath!, '%(title)s.%(ext)s'),
        '--newline',
      ];

      if (settings.cookiePath != null && settings.cookiePath!.isNotEmpty) {
        args.addAll(['--cookies', settings.cookiePath!]);
      }

      switch (settings.format) {
        case DownloadFormat.audio:
          args.addAll(['-x', '--audio-format', 'mp3', '--audio-quality', '0']);
          break;
        case DownloadFormat.thumbnail:
          args.addAll(['--skip-download', '--write-thumbnail']);
          break;
        case DownloadFormat.video:
          switch (settings.quality) {
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
            default:
              break;
          }
          break;
      }

      args.add(url);

      logs.add("执行命令: ${settings.ytDlpPath} ${args.join(' ')}");
      logs.add("格式: ${settings.format.name}, 画质: ${settings.quality.name}");

      final process = await Process.start(
        settings.ytDlpPath!,
        args,
        runInShell: true,
      );

      process.stdout.transform(const SystemEncoding().decoder).listen((data) {
        if (data.trim().isNotEmpty) {
          logs.add(data.trim());
        }
      });

      process.stderr.transform(const SystemEncoding().decoder).listen((data) {
        if (data.trim().isNotEmpty) {
          logs.add("⚠️ $data");
        }
      });

      final exitCode = await process.exitCode;

      final updatedTasks = state.tasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(
            status: exitCode == 0
                ? DownloadStatus.completed
                : DownloadStatus.failed,
            errorMessage: exitCode != 0 ? "Exit code: $exitCode" : null,
          );
        }
        return t;
      }).toList();

      if (exitCode == 0) {
        logs.add("✅ 下载完成！");
      } else {
        logs.add("❌ 下载失败，退出代码: $exitCode");
      }

      state = state.copyWith(
        isDownloading: false,
        tasks: updatedTasks,
      );
    } catch (e) {
      logs.add("❌ 发生异常: $e");

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
      );
    }
  }

  void clearHistory() {
    state = state.copyWith(tasks: []);
  }
}

final downloadProvider =
    StateNotifierProvider<DownloadNotifier, DownloadState>((ref) {
  return DownloadNotifier(ref);
});

final isDownloadingProvider = Provider<bool>((ref) {
  return ref.watch(downloadProvider).isDownloading;
});

final downloadHistoryProvider = Provider<List<DownloadTask>>((ref) {
  return ref.watch(downloadProvider).tasks;
});
