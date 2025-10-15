
// import 'package:flutter/material.dart';
// import 'package:ivideo/core/supabase/supabase_client.dart';
// import 'package:provider/provider.dart';
// import 'package:ivideo/core/providers/auth_provider.dart'; 
// import 'package:ivideo/shared/models/video_model.dart';
// import 'package:ivideo/shared/widgets/video_card.dart';
// import 'package:ivideo/features/auth/login_page.dart';
// import 'package:ivideo/features/profile/profile_page.dart';
// import 'package:ivideo/features/search/search_page.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   List<Video> _videos = [];
//   bool _isLoading = true;
//   String _errorMessage = '';
//   bool _hideWelcomeBanner = false; // 添加这个状态变量

//   @override
//   void initState() {
//     super.initState();
//     _loadVideos();
//   }

//   Future<void> _loadVideos() async {
//     try {
//       final response = await SupabaseService.client
//           .from('videos')
//           .select('*')
//           .order('created_at', ascending: false);

//       final data = response as List;
//       setState(() {
//         _videos = data.map((json) => Video.fromJson(json)).toList();
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = '加载失败: $e';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 使用 Consumer 来访问 authProvider
//     return Consumer<AuthProvider>(
//       builder: (context, authProvider, child) {
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('iVideo'),
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black,
//             elevation: 0,
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.search),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const SearchPage()),
//                   );
//                 },
//               ),
//               IconButton(
//                 icon: authProvider.isLoggedIn
//                     ? const Icon(Icons.person)
//                     : const Icon(Icons.person_outline),
//                 onPressed: () {
//                   if (authProvider.isLoggedIn) {
//                     // 跳转到个人中心
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const ProfilePage()),
//                     );
//                   } else {
//                     // 跳转到登录页面
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => LoginPage(
//                           onLoginSuccess: () {
//                             // 登录成功后刷新页面
//                             setState(() {});
//                           },
//                         ),
//                       ),
//                     );
//                   }
//                 },
//               ),
//             ],
//           ),
//           body: _buildBody(authProvider), // 传递 authProvider
//         );
//       },
//     );
//   }

//   Widget _buildBody(AuthProvider authProvider) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_errorMessage.isNotEmpty) {
//       return Center(child: Text(_errorMessage));
//     }

//     if (_videos.isEmpty) {
//       return const Center(child: Text('暂无视频'));
//     }

//     // 显示欢迎信息（如果已登录且未隐藏欢迎横幅）
//     if (authProvider.isLoggedIn && !_hideWelcomeBanner) {
//       return Column(
//         children: [
//           // 可关闭的欢迎横幅
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             color: Colors.blue.shade50,
//             child: Row(
//               children: [
//                 const Icon(Icons.check_circle, color: Colors.green, size: 20),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     '欢迎回来! ${authProvider.user?.email ?? ''}',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 // 关闭按钮
//                 IconButton(
//                   icon: const Icon(Icons.close, size: 16),
//                   onPressed: () {
//                     setState(() {
//                       _hideWelcomeBanner = true; // 现在这个变量已定义
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ),
//           // 视频列表
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(8),
//               itemCount: _videos.length,
//               itemBuilder: (context, index) {
//                 final video = _videos[index];
//                 return VideoCard(video: video);
//               },
//             ),
//           ),
//         ],
//       );
//     }

//     // 未登录状态或欢迎横幅已隐藏
//     return ListView.builder(
//       padding: const EdgeInsets.all(8),
//       itemCount: _videos.length,
//       itemBuilder: (context, index) {
//         final video = _videos[index];
//         return VideoCard(video: video);
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 新增导入
import 'package:ivideo/core/supabase/supabase_client.dart';
import 'package:provider/provider.dart';
import 'package:ivideo/core/providers/auth_provider.dart'; 
import 'package:ivideo/shared/models/video_model.dart';
import 'package:ivideo/shared/widgets/video_card.dart';
import 'package:ivideo/features/auth/login_page.dart';
import 'package:ivideo/features/profile/profile_page.dart';
import 'package:ivideo/features/search/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Video> _videos = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _hideWelcomeBanner = false;

  @override
  void initState() {
    super.initState();
    _loadVideos();
    _loadWelcomeBannerState(); // 新增：加载欢迎横幅状态
  }

  // 新增：加载欢迎横幅状态
  Future<void> _loadWelcomeBannerState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hideWelcomeBanner = prefs.getBool('hide_welcome_banner') ?? false;
    });
  }

  // 新增：保存欢迎横幅状态
  Future<void> _saveWelcomeBannerState(bool hide) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hide_welcome_banner', hide);
  }

  Future<void> _loadVideos() async {
    try {
      final response = await SupabaseService.client
          .from('videos')
          .select('*')
          .order('created_at', ascending: false);

      final data = response as List;
      setState(() {
        _videos = data.map((json) => Video.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '加载失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('iVideo'),
            backgroundColor: const Color.fromARGB(255, 177, 198, 255),
            foregroundColor: const Color.fromARGB(255, 255, 255, 255),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchPage()),
                  );
                },
              ),
              IconButton(
                icon: authProvider.isLoggedIn
                    ? const Icon(Icons.person)
                    : const Icon(Icons.person_outline),
                onPressed: () {
                  if (authProvider.isLoggedIn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(
                          onLoginSuccess: () {
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          body: _buildBody(authProvider),
        );
      },
    );
  }

  Widget _buildBody(AuthProvider authProvider) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    if (_videos.isEmpty) {
      return const Center(child: Text('暂无视频'));
    }

    // 显示欢迎信息（如果已登录且未隐藏欢迎横幅）
    if (authProvider.isLoggedIn && !_hideWelcomeBanner) {
      return Column(
        children: [
          // 可关闭的欢迎横幅
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color.fromARGB(255, 194, 215, 229),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '欢迎回来! ${authProvider.user?.email ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                // 关闭按钮
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    // 保存状态并更新UI
                    _saveWelcomeBannerState(true);
                    setState(() {
                      _hideWelcomeBanner = true;
                    });
                  },
                ),
              ],
            ),
          ),
          // 视频列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                final video = _videos[index];
                return VideoCard(video: video);
              },
            ),
          ),
        ],
      );
    }

    // 未登录状态或欢迎横幅已隐藏
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return VideoCard(video: video);
      },
    );
  }
}