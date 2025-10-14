import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ivideo/core/constants/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static bool _isInitialized = false;
  static String? _initializationError;

  static Future<void> initialize() async {
    try {
      // 防止重复初始化
      if (_isInitialized) return;

      // 确保环境变量已加载
      await dotenv.load(fileName: '.env');
      
      // 验证配置
      _validateConfiguration();

      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
      
      _isInitialized = true;
      _initializationError = null;
      print('✅ Supabase初始化成功');
    } catch (e) {
      _initializationError = e.toString();
      print('❌ Supabase初始化失败: $e');
      rethrow;
    }
  }

  static void _validateConfiguration() {
    if (AppConstants.supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL未配置，请检查.env文件');
    }
    if (AppConstants.supabaseAnonKey.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY未配置，请检查.env文件');
    }
    if (!AppConstants.supabaseUrl.startsWith('https://')) {
      throw Exception('SUPABASE_URL格式不正确，应以https://开头');
    }
  }

  static SupabaseClient get client {
    _checkInitialization();
    return Supabase.instance.client;
  }

  static void _checkInitialization() {
    if (!_isInitialized) {
      throw Exception(
        'Supabase尚未初始化。请在main()函数中调用: await SupabaseService.initialize()'
      );
    }
  }

  // 辅助方法：检查初始化状态
  static bool get isInitialized => _isInitialized;
  static String? get initializationError => _initializationError;
}