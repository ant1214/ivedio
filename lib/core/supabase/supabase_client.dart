import 'dart:developer' as developer;  // 添加这行导入
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static Future<void> initialize() async {
    try {
      String supabaseUrl;
      String supabaseAnonKey;

      if (kIsWeb) {
        // Web 环境使用硬编码配置
        supabaseUrl = 'https://trbiuadvichcmfgxhocb.supabase.co';
        supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRyYml1YWR2aWNoY21mZ3hob2NiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzOTQ0OTYsImV4cCI6MjA3NTk3MDQ5Nn0.T7jdF4cDeQMVbJETboEwrlZDgF1tTKUKa2EkqL9IBE8';
        developer.log('Web环境: 使用硬编码配置', name: 'Supabase');
      } else {
        // 移动端使用 .env 文件
        await dotenv.load(fileName: '.env');
        supabaseUrl = dotenv.get('SUPABASE_URL', fallback: '');
        supabaseAnonKey = dotenv.get('SUPABASE_ANON_KEY', fallback: '');
        developer.log('移动端环境: 使用.env配置', name: 'Supabase');
      }
      
      _validateConfiguration(supabaseUrl, supabaseAnonKey);
      
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      
      developer.log('Supabase初始化成功!', name: 'Supabase');
    } catch (e) {
      developer.log('Supabase初始化失败: $e', name: 'Supabase', error: e);
      rethrow;
    }
  }

  static void _validateConfiguration(String url, String anonKey) {
    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception('SUPABASE_URL 或 SUPABASE_ANON_KEY 未配置，请检查.env文件');
    }
    
    // 验证 URL 格式
    if (!url.startsWith('https://')) {
      throw Exception('SUPABASE_URL 格式不正确，应以 https:// 开头');
    }
    
    // 验证 key 长度（基本验证）
    if (anonKey.length < 10) {
      throw Exception('SUPABASE_ANON_KEY 格式不正确');
    }
  }
}