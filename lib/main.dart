import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/download_page.dart';
import 'pages/settings_page.dart';
import 'theme/fluid_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: VideoaderApp(),
    ),
  );
}

class VideoaderApp extends StatefulWidget {
  const VideoaderApp({super.key});

  @override
  State<VideoaderApp> createState() => _VideoaderAppState();
}

class _VideoaderAppState extends State<VideoaderApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Videoader',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _themeMode,
      home: MainLayout(
        themeMode: _themeMode,
        onThemeChanged: _setThemeMode,
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: FluidColors.primary,
        onPrimary: FluidColors.onPrimary,
        primaryContainer: FluidColors.primaryContainer,
        onPrimaryContainer: FluidColors.onPrimaryContainer,
        secondary: FluidColors.secondaryContainer,
        onSecondary: FluidColors.onSecondaryContainer,
        secondaryContainer: FluidColors.secondaryContainer,
        onSecondaryContainer: FluidColors.onSecondaryContainer,
        tertiary: FluidColors.tertiary,
        tertiaryContainer: FluidColors.tertiaryContainer,
        onTertiaryContainer: FluidColors.onTertiaryContainer,
        error: FluidColors.error,
        errorContainer: FluidColors.errorContainer,
        onErrorContainer: FluidColors.onErrorContainer,
        surface: FluidColors.surface,
        onSurface: FluidColors.onSurface,
        onSurfaceVariant: FluidColors.onSurfaceVariant,
        outlineVariant: FluidColors.outlineVariant,
        surfaceContainerLowest: FluidColors.surfaceContainerLowest,
        surfaceContainerLow: FluidColors.surfaceContainerLow,
        surfaceContainerHighest: FluidColors.surfaceContainerHighest,
      ),
      scaffoldBackgroundColor: FluidColors.surface,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: FluidColors.surfaceContainerLow,
        foregroundColor: FluidColors.onSurface,
        titleTextStyle: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: -0.5,
          color: FluidColors.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: FluidColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: FluidRadius.lgRadius,
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FluidColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: FluidRadius.smRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: FluidRadius.smRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: FluidRadius.smRadius,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          color: FluidColors.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: FluidRadius.lgRadius,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: FluidRadius.lgRadius,
          ),
          backgroundColor: FluidColors.primary,
          foregroundColor: FluidColors.onPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: FluidRadius.lgRadius,
          ),
          side: BorderSide(
            color: FluidColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: FluidColors.surface,
        indicatorColor: FluidColors.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: FluidColors.surfaceContainerLow,
        indicatorColor: FluidColors.secondaryContainer,
        labelType: NavigationRailLabelType.all,
      ),
      dividerTheme: DividerThemeData(
        color: FluidColors.outlineVariant.withValues(alpha: 0.15),
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: FluidRadius.mdRadius,
        ),
        backgroundColor: FluidColors.onSurface,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const darkPrimary = Color(0xFFb4c5f9);
    const darkOnSurface = Color(0xFFe3e2e8);
    const darkSurface = Color(0xFF1a1b1f);
    const darkSurfaceContainerLow = Color(0xFF232428);
    const darkSurfaceContainerHighest = Color(0xFF3d3e44);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        onPrimary: Color(0xFF182a55),
        primaryContainer: Color(0xFF374874),
        onPrimaryContainer: Color(0xFFd4e0ff),
        secondary: Color(0xFFc4c9e0),
        onSecondary: Color(0xFF2f3147),
        tertiary: Color(0xFFd3bae9),
        tertiaryContainer: Color(0xFF5c4870),
        onTertiaryContainer: Color(0xFFf4dcff),
        error: Color(0xFFffb4ab),
        errorContainer: Color(0xFF93000a),
        onErrorContainer: Color(0xFFffdad6),
        surface: darkSurface,
        onSurface: darkOnSurface,
        surfaceContainerLowest: Color(0xFF0f0f12),
        surfaceContainerLow: darkSurfaceContainerLow,
        surfaceContainerHighest: darkSurfaceContainerHighest,
      ),
      scaffoldBackgroundColor: darkSurface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: darkSurfaceContainerLow,
        foregroundColor: darkOnSurface,
        titleTextStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: -0.5,
          color: darkOnSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkSurfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: FluidRadius.lgRadius,
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: FluidRadius.smRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: FluidRadius.smRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: FluidRadius.smRadius,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: FluidRadius.lgRadius,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: FluidRadius.lgRadius,
          ),
          backgroundColor: darkPrimary,
          foregroundColor: const Color(0xFF182a55),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: darkSurface,
        indicatorColor: const Color(0xFF3d3e44),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.5,
            );
          }
          return TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            letterSpacing: 0.5,
            color: darkOnSurface.withValues(alpha: 0.7),
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: darkSurfaceContainerLow,
        indicatorColor: darkSurfaceContainerHighest,
        labelType: NavigationRailLabelType.all,
      ),
    );
  }
}

class MainLayout extends StatefulWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeChanged;

  const MainLayout({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DownloadPage(),
    SettingsPage(),
  ];

  void _toggleTheme() {
    final newMode = widget.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : widget.themeMode == ThemeMode.dark
            ? ThemeMode.system
            : ThemeMode.light;
    widget.onThemeChanged(newMode);
  }

  IconData _getThemeIcon() {
    switch (widget.themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      default:
        return Icons.brightness_auto;
    }
  }

  String _getThemeLabel() {
    switch (widget.themeMode) {
      case ThemeMode.light:
        return '浅色';
      case ThemeMode.dark:
        return '深色';
      default:
        return '跟随系统';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 800;
    final colorScheme = Theme.of(context).colorScheme;

    if (isWideScreen) {
      return Scaffold(
        body: Row(
          children: [
            Container(
              width: 80,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                border: Border(
                  right: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 8),
                  const Text(
                    'Videoader',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildNavItem(
                    index: 0,
                    icon: Icons.download_outlined,
                    selectedIcon: Icons.download,
                    label: '下载',
                  ),
                  const SizedBox(height: 8),
                  _buildNavItem(
                    index: 1,
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                    label: '设置',
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(_getThemeIcon()),
                    tooltip: '主题: ${_getThemeLabel()}',
                    onPressed: _toggleTheme,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: colorScheme.surface,
                child: _pages[_selectedIndex],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -8),
              blurRadius: 24,
              color: FluidColors.onSurface.withValues(alpha: 0.06),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(
                  index: 0,
                  icon: Icons.download_outlined,
                  selectedIcon: Icons.download,
                  label: '下载',
                ),
                _buildBottomNavItem(
                  index: 1,
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: '设置',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.secondaryContainer : Colors.transparent,
          borderRadius: FluidRadius.mdRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected
                  ? colorScheme.onSecondaryContainer
                  : colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 11,
                color: isSelected
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.secondaryContainer
                : Colors.transparent,
            borderRadius: FluidRadius.lgRadius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12,
                  letterSpacing: 0.5,
                  color: isSelected
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
