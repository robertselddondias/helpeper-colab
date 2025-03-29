import 'package:flutter/material.dart';

class ColorConstants {
  // Cores do branding
  static const Color primaryColor = Color(0xFF5D5FEF);
  static const Color accentColor = Color(0xFF00C6A2);
  static const Color tertiaryColor = Color(0xFFF1651C);

  // Cores de fundo
  static const Color backgroundColor = Color(0xFFF8F9FC);
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;
  static const Color modalColor = Colors.white;

  // Cores de texto
  static const Color textPrimaryColor = Color(0xFF1A1D1F);
  static const Color textSecondaryColor = Color(0xFF6F767E);
  static const Color textHintColor = Color(0xFFA7A7A7);
  static const Color textInvertedColor = Colors.white;

  // Cores de utilidade
  static const Color successColor = Color(0xFF00C566);
  static const Color errorColor = Color(0xFFFF4747);
  static const Color warningColor = Color(0xFFFFAD0F);
  static const Color infoColor = Color(0xFF3E7BFA);

  // Cores de interface
  static const Color borderColor = Color(0xFFEFEFF4);
  static const Color dividerColor = Color(0xFFEFEFF4);
  static const Color inputFillColor = Color(0xFFF4F4F8);
  static const Color disabledColor = Color(0xFFE8E8E8);
  static const Color chipBackgroundColor = Color(0xFFF4F4F8);
  static const Color shimmerBaseColor = Color(0xFFE0E0E0);
  static const Color shimmerHighlightColor = Color(0xFFF5F5F5);

  // Cores de status
  static const Color onlineColor = Color(0xFF00C566);
  static const Color offlineColor = Color(0xFFFF4747);
  static const Color busyColor = Color(0xFFFFAD0F);

  // Cores de avaliação
  static const Color starColor = Color(0xFFFFB800);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, Color(0xFF4C4DDC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, Color(0xFF00A189)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
