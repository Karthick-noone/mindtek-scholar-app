// lib/shared/widgets/base_refreshable_page.dart
import 'package:flutter/material.dart';
import 'custom_refresh_indicator.dart';

abstract class RefreshablePage extends StatefulWidget {
  const RefreshablePage({super.key});
}

abstract class RefreshablePageState<T extends RefreshablePage> extends State<T> {
  bool _isRefreshing = false;
  
  // Override this method to implement refresh logic
  Future<void> onRefresh();
  
  // Override this to provide the scrollable widget
  Widget buildScrollableContent(BuildContext context);
  
  // Optional: Override to add custom loading widget
  Widget buildLoadingWidget() {
    return const Center(child: CircularProgressIndicator());
  }
  
  // Optional: Override to add custom error widget
  Widget buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Error loading data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: () async {
        setState(() => _isRefreshing = true);
        await onRefresh();
        setState(() => _isRefreshing = false);
      },
      child: _isRefreshing
          ? buildLoadingWidget()
          : buildScrollableContent(context),
    );
  }
}