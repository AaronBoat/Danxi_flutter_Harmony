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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:go_router/go_router.dart';

// 导入原有的 home_page 组件
import 'home_page.dart' as original;

/// 封装的首页组件，提供给壳工程使用
/// 该组件封装了所有必要的依赖和状态管理
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _initializeModule();
  }

  /// 初始化模块
  Future<void> _initializeModule() async {
    try {
      // 初始化本地存储
      //final prefs = await SharedPreferences.getInstance();
      
      // 显示模块加载完成提示
      _showToast('Home module loaded successfully');
    } catch (e) {
      _showToast('Failed to initialize home module: $e');
    }
  }

  /// 显示 Toast 提示
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('DanXi - 模块化架构'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              actions: [
                IconButton(
                  onPressed: () => _showModuleInfo(),
                  icon: const Icon(Icons.info_outline),
                ),
              ],
            ),
            body: const Column(
              children: [
                // 模块化架构信息卡片
                _ModuleInfoCard(),
                // 原有的首页内容
                Expanded(
                  child: original.HomePage(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 显示模块信息
  void _showModuleInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('模块化架构信息'),
        content: const Text(
          '当前页面由 home_module 模块提供\n\n'
          '已集成的三方库：\n'
          '• flutter_bloc (状态管理)\n'
          '• dio (网络请求)\n'
          '• fluttertoast (提示框)\n'
          '• shared_preferences (本地存储)\n'
          '• go_router (路由管理)\n\n'
          '所有依赖都封装在模块内部，壳工程无需关心具体实现。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/// 模块信息卡片
class _ModuleInfoCard extends StatelessWidget {
  const _ModuleInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.widgets,
            color: Colors.blue.shade600,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '模块化架构',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '该页面由 home_module 独立提供，所有依赖已封装',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 首页状态管理
class HomeBloc extends Cubit<HomeState> {
  HomeBloc() : super(const HomeState.initial());

  void loadData() {
    emit(const HomeState.loading());
    // 模拟数据加载
    Future.delayed(const Duration(seconds: 1), () {
      emit(const HomeState.loaded());
    });
  }
}

/// 首页状态
abstract class HomeState {
  const HomeState();

  const factory HomeState.initial() = _Initial;
  const factory HomeState.loading() = _Loading;
  const factory HomeState.loaded() = _Loaded;
  const factory HomeState.error(String message) = _Error;
}

class _Initial extends HomeState {
  const _Initial();
}

class _Loading extends HomeState {
  const _Loading();
}

class _Loaded extends HomeState {
  const _Loaded();
}

class _Error extends HomeState {
  final String message;
  const _Error(this.message);
}
