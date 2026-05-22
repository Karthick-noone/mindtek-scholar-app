// lib/shared/widgets/custom_refresh_indicator.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CustomRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;
  final Color? backgroundColor;
  final double? strokeWidth;

  const CustomRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.backgroundColor,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? AppColors.gradientStart,
      backgroundColor: backgroundColor ?? Colors.white,
      strokeWidth: strokeWidth ?? 2.5,
      displacement: 40,
      edgeOffset: 0,
      notificationPredicate: (notification) {
        // Only trigger refresh for the main scroll view
        return notification.depth == 0;
      },
      child: child,
    );
  }
}