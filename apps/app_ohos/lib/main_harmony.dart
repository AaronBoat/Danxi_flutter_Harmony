/*
 *     Copyright (C) 2021  DanXi-Dev
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// 导入各个模块 - 使用封装的组件
import 'package:home_module/home_module.dart';

void main() {
  runApp(const DanXiHarmonyOSApp());
}

/// DanXi 鸿蒙应用
/// 
/// 该应用使用模块化架构，所有三方库依赖都下沉到各个模块中
/// 鸿蒙特有的库通过 dependency_overrides 进行适配
class DanXiHarmonyOSApp extends StatelessWidget {
  const DanXiHarmonyOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DanXi - HarmonyOS',
      debugShowCheckedModeBanner: false,
      
      // 本地化配置
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      
      // 鸿蒙主题配置
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        // 鸿蒙特色配色
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      
      // 使用封装的模块化首页
      home: const HarmonyOSMainPage(),
    );
  }
}

/// 鸿蒙主页面
/// 
/// 展示模块化架构在鸿蒙平台的应用效果
class HarmonyOSMainPage extends StatefulWidget {
  const HarmonyOSMainPage({super.key});

  @override
  State<HarmonyOSMainPage> createState() => _HarmonyOSMainPageState();
}

class _HarmonyOSMainPageState extends State<HarmonyOSMainPage> {
  int _currentIndex = 0;
  
  // 各个模块的页面
  late final List<Widget> _pages;
  
  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(), // 来自 home_module，内部使用鸿蒙化的三方库
      const HarmonyOSInfoPage(), // 鸿蒙平台信息页面
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: '鸿蒙信息',
          ),
        ],
      ),
    );
  }
}

/// 鸿蒙平台信息页面
class HarmonyOSInfoPage extends StatelessWidget {
  const HarmonyOSInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DanXi - HarmonyOS版'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 鸿蒙平台信息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.phone_android,
                          color: Colors.blue.shade600,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '鸿蒙平台适配',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '✅ 使用 Flutter 3.22.1-ohos-1.0.3 鸿蒙化版本\n'
                      '✅ 模块化架构支持鸿蒙平台\n'
                      '✅ 三方库通过 dependency_overrides 适配\n'
                      '✅ 保持与其他平台的代码一致性',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 适配库信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '鸿蒙化适配库',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• fluttertoast - Toast提示\n'
                      '• image_picker - 图片选择\n'
                      '• permission_handler - 权限管理\n'
                      '• shared_preferences - 本地存储\n'
                      '• file_picker - 文件选择器',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 纯Dart库信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '无需适配库（纯Dart实现）',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• flutter_bloc - 状态管理\n'
                      '• dio - 网络请求\n'
                      '• fl_chart - 图表组件\n'
                      '• go_router - 路由管理\n'
                      '• intl - 国际化',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
