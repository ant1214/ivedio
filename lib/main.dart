import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ivideo/core/providers/auth_provider.dart';
import 'package:ivideo/core/supabase/supabase_client.dart';
import 'package:ivideo/features/home/home_page.dart' show HomePage;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 加载环境变量
  await dotenv.load(fileName: '.env');
  
  // 初始化Supabase
 await SupabaseService.initialize(); 
  developer.log('iVideo项目启动成功!', name: 'iVideo');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
  return ChangeNotifierProvider(
    create: (context) => AuthProvider(), 
    child: MaterialApp(
      title: 'iVideo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, 
       home: HomePage(), 
    ),
    );
  }
}