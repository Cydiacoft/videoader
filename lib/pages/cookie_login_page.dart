import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../providers/app_provider.dart';

class CookieLoginPage extends ConsumerStatefulWidget {
  const CookieLoginPage({super.key});

  @override
  ConsumerState<CookieLoginPage> createState() => _CookieLoginPageState();
}

class _CookieLoginPageState extends ConsumerState<CookieLoginPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _currentUrl = '';
  
  static const _allowedDomains = [
    'youtube.com',
    'www.youtube.com',
    'm.youtube.com',
    'bilibili.com',
    'www.bilibili.com',
    'twitter.com',
    'x.com',
    'www.twitter.com',
    'tiktok.com',
    'www.tiktok.com',
  ];

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
              _currentUrl = url;
            });
          },
          onNavigationRequest: (request) {
            final url = request.url;
            if (!_isAllowedUrl(url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
  }

  bool _isAllowedUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();
      return _allowedDomains.any((domain) => host == domain || host.endsWith('.$domain'));
    } catch (e) {
      return false;
    }
  }

  Future<void> _exportCookies() async {
    try {
      final result = await _controller.runJavaScriptReturningResult(
        '(function() { var cookies = document.cookie; return cookies; })();'
      ) as String;
      
      if (result.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('未获取到 Cookie，请先登录')),
          );
        }
        return;
      }

      final settings = ref.read(appSettingsProvider);
      
      final cookieFile = File('${settings.downloadPath}/cookies.txt');
      await cookieFile.writeAsString(result);
      
      await ref.read(appSettingsProvider.notifier).setCookiePath(cookieFile.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cookie 已保存到: ${cookieFile.path}')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出 Cookie 失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('在线登录获取 Cookie'),
        actions: [
          if (_currentUrl.isNotEmpty)
            TextButton.icon(
              onPressed: _exportCookies,
              icon: const Icon(Icons.save),
              label: const Text('保存'),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '请登录需要下载视频的网站，登录完成后点击"保存"按钮',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(),
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }
}
