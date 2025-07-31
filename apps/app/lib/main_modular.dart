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

// 导入各个模块
import 'package:home_module/home_module.dart';

void main() {
  runApp(const DanXiApp());
}

/// 主应用壳工程
/// 
/// 该壳工程只负责：
/// 1. 应用的基础配置（主题、本地化等）
/// 2. 模块间的路由管理
/// 3. 全局状态管理
/// 
/// 具体的业务逻辑和三方库依赖都下沉到各个模块中
class DanXiApp extends StatelessWidget {
  const DanXiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DanXi - 模块化架构',
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
      
      // 主题配置
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      
      // 使用封装的首页组件
      home: const MainNavigationPage(),
    );
  }
}

/// 主导航页面
/// 
/// 该页面负责在不同模块间切换，展示模块化架构的效果
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  
  // 各个模块的页面
  late final List<Widget> _pages;
  
  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(), // 来自 home_module
      const DashboardPage(), // 来自 dashboard_module
      const ForumPage(), // 来自 forum_module  
      const CoursePage(), // 来自 course_module
      const TimetablePage(), // 来自 timetable_module
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
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '校园',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: '论坛',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: '课程',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: '课表',
          ),
        ],
      ),
    );
  }
}

/// Dashboard 页面占位符
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Dashboard Module',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('来自 dashboard_module 的页面'),
          ],
        ),
      ),
    );
  }
}

/// Forum 页面占位符
class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Forum Module',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('来自 forum_module 的页面'),
          ],
        ),
      ),
    );
  }
}

/// Course 页面占位符  
class CoursePage extends StatelessWidget {
  const CoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Course Module',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('来自 course_module 的页面'),
          ],
        ),
      ),
    );
  }
}

/// Timetable 页面占位符
class TimetablePage extends StatelessWidget {
  const TimetablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: Colors.purple),
            SizedBox(height: 16),
            Text(
              'Timetable Module',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('来自 timetable_module 的页面'),
          ],
        ),
      ),
    );
  }
}
