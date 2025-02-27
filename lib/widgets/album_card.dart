import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/album.dart';
import '../utils/constants.dart';

class AlbumCard extends StatelessWidget {
  final Album album;
  final VoidCallback onTap;
  final double size;

  const AlbumCard({
    Key? key,
    required this.album,
    required this.onTap,
    this.size = 160.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album cover
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            child: album.coverUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: album.coverUrl,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: size,
                      height: size,
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.album, size: 50, color: Colors.white30),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: size,
                      height: size,
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.album, size: 50, color: Colors.white30),
                      ),
                    ),
                  )
                : Container(
                    width: size,
                    height: size,
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(Icons.album, size: 50, color: Colors.white30),
                    ),
                  ),
          ),
          
          const SizedBox(height: 8),
          
          // Album title
          SizedBox(
            width: size,
            child: Text(
              album.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          
          // Track count
          SizedBox(
            width: size,
            child: Text(
              '${album.songs.length} tracks',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}