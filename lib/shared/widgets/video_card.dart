
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ivideo/features/video/video_player_page.dart';
import 'package:ivideo/shared/models/video_model.dart';

class VideoCard extends StatelessWidget {
  final Video video;
  
  const VideoCard({super.key, required this.video});

  // CORS 代理方法 - 解决跨域图片加载问题
  String _getProxiedImageUrl(String originalUrl) {
    if (originalUrl.isEmpty) {
      return _getPlaceholderImage();
    }
    
    // 对 B 站图片和其他可能跨域的图片使用代理
    if (originalUrl.contains('hdslb.com') || 
        originalUrl.contains('bilibili') ||
        originalUrl.contains('googleapis')) {
      return 'https://corsproxy.io/?${Uri.encodeComponent(originalUrl)}';
    }
    
    return originalUrl;
  }

  // 备用图片URL
  String _getPlaceholderImage() {
    return 'https://corsproxy.io/?https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg';
  }

  // 格式化视频时长（秒 -> 分:秒）
  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0:00';
    
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    
    if (minutes < 60) {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      final int hours = minutes ~/ 60;
      final int remainingMinutes = minutes % 60;
      return '$hours:${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // TODO: 跳转到视频播放页面
          print('点击视频: ${video.title}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerPage(video: video),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 视频缩略图区域
            Stack(
              children: [
                // 视频缩略图
                CachedNetworkImage(
                  imageUrl: _getProxiedImageUrl(video.thumbnailUrl),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, color: Colors.grey, size: 48),
                        SizedBox(height: 8),
                        Text(
                          '图片加载失败',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 视频时长标签
                if (video.duration > 0)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(video.duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                
                // 推荐标签
                if (video.isFeatured)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '推荐',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // 视频信息区域
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 视频标题
                  Text(
                    video.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 视频描述（如果有）
                  if (video.description.isNotEmpty)
                    Column(
                      children: [
                        Text(
                          video.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  
                  // 视频元信息
                  Row(
                    children: [
                      // 观看次数
                      Text(
                        '${video.viewsCount} 次观看',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // 视频类型标签
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.blue[100]!,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          video.videoType,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 视频元信息 - 美化版本
                  // Row(
                  //   children: [
                  //     // 观看次数和类型
                  //     Expanded(
                  //       child: Row(
                  //         children: [
                  //           // 观看次数图标
                  //           Icon(
                  //             Icons.remove_red_eye_outlined,
                  //             size: 14,
                  //             color: Colors.grey[500],
                  //           ),
                  //           const SizedBox(width: 4),
                  //           Text(
                  //             '${video.viewsCount}',
                  //             style: TextStyle(
                  //               fontSize: 12,
                  //               color: Colors.grey[500],
                  //               fontWeight: FontWeight.w500,
                  //             ),
                  //           ),
                  //           const SizedBox(width: 12),
                  //           // 视频类型标签
                  //           Container(
                  //             padding: const EdgeInsets.symmetric(
                  //               horizontal: 6,
                  //               vertical: 2,
                  //             ),
                  //             decoration: BoxDecoration(
                  //               gradient: LinearGradient(
                  //                 colors: [
                  //                   Colors.blue.shade100,
                  //                   Colors.blue.shade200,
                  //                 ],
                  //               ),
                  //               borderRadius: BorderRadius.circular(6),
                  //               boxShadow: [
                  //                 BoxShadow(
                  //                   color: Colors.blue.shade100,
                  //                   blurRadius: 2,
                  //                   offset: const Offset(0, 1),
                  //                 ),
                  //               ],
                  //             ),
                  //             child: Text(
                  //               video.videoType,
                  //               style: TextStyle(
                  //                 fontSize: 10,
                  //                 color: Colors.blue.shade800,
                  //                 fontWeight: FontWeight.w600,
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                      
                  //     // 收藏按钮
                  //     IconButton(
                  //       icon: Icon(
                  //         Icons.favorite_border,
                  //         size: 18,
                  //         color: Colors.grey[600],
                  //       ),
                  //       onPressed: () {
                  //         // TODO: 实现收藏功能
                  //         print('收藏视频: ${video.title}');
                  //       },
                  //       padding: EdgeInsets.zero,
                  //       constraints: const BoxConstraints(
                  //         minWidth: 36,
                  //         minHeight: 36,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}