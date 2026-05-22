// lib/shared/mixins/refresh_mixin.dart
import 'package:flutter/material.dart';

mixin RefreshMixin<T extends StatefulWidget> on State<T> {
  bool _isRefreshing = false;
  
  Future<void> refreshData();
  
  Widget buildRefreshableContent({
    required Widget child,
    Color? color,
    Color? backgroundColor,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isRefreshing = true);
        await refreshData();
        setState(() => _isRefreshing = false);
      },
      color: color ?? Colors.blue,
      backgroundColor: backgroundColor ?? Colors.white,
      child: child,
    );
  }
  
  bool get isRefreshing => _isRefreshing;
}