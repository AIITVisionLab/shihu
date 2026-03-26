import 'package:flutter/material.dart';

/// 应用使用的主配色与辅助配色。
class AppPalette {
  /// 更深一层的松绿色，用于标题和强调区。
  static const Color deepPine = Color(0xFF294536);

  /// 深色文字与图标主色。
  static const Color pineInk = Color(0xFF213229);

  /// 参考图主色，作为整体识别色。
  static const Color pineGreen = Color(0xFF518463);

  /// 参考图中的浅松绿色，用于主强调辅助面。
  static const Color softPine = Color(0xFFA7D3B2);

  /// 参考图中的雾青色，用于信息卡片和冷感高亮。
  static const Color mistMint = Color(0xFFCBF2E0);

  /// 参考图中的亚麻色，用于中性强调。
  static const Color linenOlive = Color(0xFFD2C8AC);

  /// 参考图中的淡紫灰，用于辅助分层。
  static const Color softLavender = Color(0xFFCEBBD8);

  /// 冷雾纸感底色。
  static const Color paper = Color(0xFFF1F5EF);

  /// 更明亮一层的冷雾纸感底色。
  static const Color paperWarm = Color(0xFFF8FBF8);

  /// 稍深一层的纸感底色。
  static const Color paperShade = Color(0xFFE0EAE1);

  /// 带轻雾感的大面积衬底。
  static const Color paperMist = Color(0xFFEDF3EE);

  /// 更亮一层的雾白高光底色。
  static const Color paperSnow = Color(0xFFFCFEFC);

  /// 浅雾松青，用于弱化背景和高亮边框。
  static const Color fogMint = Color(0xFFE6EFE8);

  /// 统一描边色。
  static const Color outlineSoft = Color(0xFFC6D6CB);

  /// 冷雾高光，用于玻璃质感叠层。
  static const Color frost = Color(0xFFF3F8F4);

  /// 深色阴影基色。
  static const Color pineShadow = Color(0xFF16231C);

  /// 将强调色轻混到纸感底色，生成统一的浅色面。
  static Color blendOnPaper(
    Color accent, {
    double opacity = 0.14,
    Color base = paperSnow,
  }) {
    return Color.alphaBlend(accent.withValues(alpha: opacity), base);
  }
}
