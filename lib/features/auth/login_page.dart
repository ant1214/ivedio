import 'package:flutter/material.dart';
import 'package:ivideo/core/services/auth_service.dart';
import 'package:ivideo/features/auth/register_page.dart';


class LoginPage extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  
  const LoginPage({super.key, this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await AuthService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
      }
      
      Navigator.pop(context); // 关闭登录页面
    } catch (e) {
      setState(() {
        _errorMessage = '登录失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
  }

  void _continueAsGuest() {
    Navigator.pop(context); // 关闭登录页面，继续匿名浏览
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Logo 或标题
              const SizedBox(height: 40),
              const Icon(Icons.video_library, size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'iVideo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '登录以享受个性化体验',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),
              
              // 错误信息
              if (_errorMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              
              if (_errorMessage.isNotEmpty) const SizedBox(height: 16),
              
              // 邮箱输入
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '邮箱',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入邮箱';
                  }
                  if (!value.contains('@')) {
                    return '请输入有效的邮箱地址';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 密码输入
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '密码',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入密码';
                  }
                  if (value.length < 6) {
                    return '密码至少6位字符';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // 登录按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('登录', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              
              // 注册链接
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('还没有账号？'),
                  TextButton(
                    onPressed: _navigateToRegister,
                    child: const Text('立即注册'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // 分隔线
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '或',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 20),
              
              // 匿名浏览按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _continueAsGuest,
                  child: const Text('匿名浏览'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}