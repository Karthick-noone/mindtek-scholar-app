// lib/features/scholar/presentation/pages/full_image_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullImageView extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final String? heroTag;

  const FullImageView({
    super.key, 
    this.imageFile, 
    this.imageUrl,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
    
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                // child: IconButton(
                //   icon: const Icon(Icons.share, color: Colors.white),
                //   onPressed: () {
                //     // Add share functionality
                //   },
                // ),
              ),
            //   Container(
            //     margin: const EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       color: Colors.black.withOpacity(0.5),
            //       shape: BoxShape.circle,
            //     ),
            //  child: IconButton(
            //     icon: const Icon(Icons.close, color: Colors.white),
            //     onPressed: () => Navigator.pop(context),
            //   ),
            //   ),
            ],
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Main Image with Zoom
          Center(
            child: Hero(
              tag: heroTag ?? 'profile_image',
              child: _buildZoomableImage(context),
            ),
          ),
          
          // Bottom Info Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
              // child: Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     const Text(
              //       'Profile Image',
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontSize: 14,
              //         fontWeight: FontWeight.w500,
              //       ),
              //     ),
              //     Container(
              //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              //       decoration: BoxDecoration(
              //         color: Colors.white.withOpacity(0.2),
              //         borderRadius: BorderRadius.circular(20),
              //       ),
              //       child: Row(
              //         mainAxisSize: MainAxisSize.min,
              //         children: const [
              //           Icon(Icons.zoom_in, size: 14, color: Colors.white),
              //           SizedBox(width: 4),
              //           Text(
              //             'Pinch to zoom',
              //             style: TextStyle(color: Colors.white, fontSize: 10),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
            ),
          ),
          
         
        ],
      ),
    );
  }

  Widget _buildZoomableImage(BuildContext context) {
    if (imageFile != null) {
      return PhotoView(
        imageProvider: FileImage(imageFile!),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        loadingBuilder: (context, event) => Center(
          child: Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return PhotoView(
        imageProvider: NetworkImage(imageUrl!),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        loadingBuilder: (context, event) => Center(
          child: Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
        errorBuilder: (context, error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image, size: 64, color: Colors.white54),
              const SizedBox(height: 16),
              const Text(
                'Failed to load image',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_not_supported, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            const Text(
              'No image available',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }
  }
}