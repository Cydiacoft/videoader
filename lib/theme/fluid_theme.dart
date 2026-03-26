import 'package:flutter/material.dart';

class FluidColors {
  static const Color primary = Color(0xFF4d5e8b);
  static const Color primaryDim = Color(0xFF41527f);
  static const Color tertiary = Color(0xFF6b567f);

  static const Color surface = Color(0xFFfaf8fe);
  static const Color surfaceContainerLow = Color(0xFFf4f3fa);
  static const Color surfaceContainerHighest = Color(0xFFe1e2ed);
  static const Color surfaceContainerLowest = Color(0xFFffffff);

  static const Color onSurface = Color(0xFF30323b);
  static const Color onSurfaceVariant = Color(0xFF5d5f68);
  static const Color onPrimary = Color(0xFFf9f8ff);

  static const Color secondaryContainer = Color(0xFFdce2f9);
  static const Color onSecondaryContainer = Color(0xFF4b5164);

  static const Color tertiaryContainer = Color(0xFFe2c8f8);
  static const Color onTertiaryContainer = Color(0xFF533f66);

  static const Color error = Color(0xFFa83836);
  static const Color errorContainer = Color(0xFFfa746f);
  static const Color onErrorContainer = Color(0xFF6e0a12);

  static const Color outlineVariant = Color(0xFFb0b1bc);

  static const Color primaryContainer = Color(0xFFb4c5f9);
  static const Color onPrimaryContainer = Color(0xFF2d3f6a);

  static const Color surfaceDim = Color(0xFFd8d9e4);
}

class FluidRadius {
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 28.0;
  static const double xl = 48.0;

  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
}

class FluidSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class FluidShadows {
  static List<BoxShadow> get ambient => [
        BoxShadow(
          offset: const Offset(0, 8),
          blurRadius: 24,
          color: FluidColors.onSurface.withValues(alpha: 0.06),
        ),
      ];

  static List<BoxShadow> get elevated => [
        BoxShadow(
          offset: const Offset(0, 12),
          blurRadius: 32,
          color: FluidColors.onSurface.withValues(alpha: 0.12),
        ),
      ];
}

class FluidGradients {
  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [FluidColors.primary, FluidColors.primaryDim],
  );
}
