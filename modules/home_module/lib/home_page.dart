/*
 *     Copyright (C) 2021-2024  DanXi-Dev
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
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';

// 修正后的依赖导入
import 'package:tools/common/constant.dart';
import 'package:tools/generated/l10n.dart';
import 'package:tools/model/person.dart';
import 'package:tools/provider/settings_provider.dart';
import 'package:tools/provider/state_provider.dart';
import 'package:tools/repository/app/announcement_repository.dart';
import 'package:tools/repository/fdu/uis_login_tool.dart';
import 'package:tools/util/noticing.dart';
import 'package:tools/util/platform_universal.dart';
import 'package:widgets/dialogs/login_dialog.dart';
import 'package:widgets/libraries/platform_nav_bar_m3.dart';
import 'package:widgets/platform_subpage.dart';

// 其他模块依赖
import 'package:forum_module/page/subpage_forum.dart';
import 'package:timetable_module/page/subpage_timetable.dart';

// TODO: 梳理并迁移这些页面的依赖
// import 'package:dan_xi/page/subpage_danke.dart';
// import 'package:dan_xi/page/subpage_dashboard.dart';
// import 'package:dan_xi/page/subpage_settings.dart';

// --- 1. Bloc Events (事件) ---
abstract class HomePageEvent {}

class InitializeApp extends HomePageEvent {}
class UserLoginChanged extends HomePageEvent {}
class PageSwitched extends HomePageEvent {
  final int index;
  PageSwitched(this.index);
}
class TabDoubleTapped extends HomePageEvent {}


// --- 2. Bloc States (状态) ---
abstract class HomePageState {
  final int pageIndex;
  final List<PlatformSubpage<dynamic>> subpages;
  const HomePageState({this.pageIndex = 0, this.subpages = const []});
}

class HomePageLoading extends HomePageState {}

class HomePageLoginRequired extends HomePageState {}

class HomePageReady extends HomePageState {
  const HomePageReady({
    required int pageIndex,
    required List<PlatformSubpage<dynamic>> subpages,
  }) : super(pageIndex: pageIndex, subpages: subpages);
}

class HomePageFailure extends HomePageState {
  final String error;
  const HomePageFailure(this.error);
}


// --- 3. HomePage Bloc (业务逻辑核心) ---
class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  StreamSubscription? _personInfoSubscription;
  StreamSubscription? _captchaSubscription;
  StreamSubscription? _credentialsInvalidSubscription;

  HomePageBloc() : super(HomePageLoading()) {
    on<InitializeApp>(_onInitializeApp);
    on<UserLoginChanged>(_onUserLoginChanged);
    on<PageSwitched>(_onPageSwitched);
    on<TabDoubleTapped>(_onTabDoubleTapped);

    // 监听用户登录状态变化
    _personInfoSubscription = StateProvider.personInfo.addListener(() {
      add(UserLoginChanged());
    });
  }

  Future<void> _onInitializeApp(InitializeApp event, Emitter<HomePageState> emit) async {
    emit(HomePageLoading());
    try {
      // 加载本地存储的用户信息
      await _loadPersonInfoFromLocal();
      
      // 如果没有用户信息，则停留在需要登录的状态
      if (StateProvider.personInfo.value == null) {
        emit(HomePageLoginRequired());
        return;
      }

      // 初始化各种平台和服务监听器
      _initListeners();

      // 异步加载远程数据（不阻塞UI）
      _loadDataFromRemote();

      // 构建页面并进入 Ready 状态
      final subpages = _buildSubpages();
      emit(HomePageReady(pageIndex: state.pageIndex, subpages: subpages));

    } catch (e) {
      emit(HomePageFailure(e.toString()));
    }
  }

  void _onUserLoginChanged(UserLoginChanged event, Emitter<HomePageState> emit) {
    // 当用户登录或登出时，重新评估页面状态
    if (StateProvider.personInfo.value != null) {
      final subpages = _buildSubpages();
      // 如果之前是未登录状态，现在重新加载数据
      if (state is! HomePageReady) {
         _loadDataFromRemote();
      }
      emit(HomePageReady(pageIndex: state.pageIndex, subpages: subpages));
    } else {
      emit(HomePageLoginRequired());
    }
  }

  void _onPageSwitched(PageSwitched event, Emitter<HomePageState> emit) {
    if (state is HomePageReady && event.index != state.pageIndex) {
      final currentState = state as HomePageReady;
      // 派发视图状态变更事件
      for (int i = 0; i < currentState.subpages.length; i++) {
        if (event.index != i) {
          currentState.subpages[i].onViewStateChanged(SubpageViewState.INVISIBLE);
        }
      }
      currentState.subpages[event.index].onViewStateChanged(SubpageViewState.VISIBLE);
      
      emit(HomePageReady(pageIndex: event.index, subpages: currentState.subpages));
    }
  }

  void _onTabDoubleTapped(TabDoubleTapped event, Emitter<HomePageState> emit) {
    if (state is HomePageReady) {
      state.subpages[state.pageIndex].onDoubleTapOnTab();
    }
  }

  Future<void> _loadPersonInfoFromLocal() async {
    final prefs = SettingsProvider.getInstance().preferences;
    if (PersonInfo.verifySharedPreferences(prefs!)) {
      StateProvider.personInfo.value = PersonInfo.fromSharedPreferences(prefs);
    }
  }

  Future<void> _loadDataFromRemote() async {
    try {
      await AnnouncementRepository.getInstance().loadAnnouncements();
      // ... 在这里添加其他数据加载逻辑，如 _loadUpdate, _loadUserAgent 等
    } catch (e) {
      // 可以 emit 一个特定的 state 来通知 UI 数据加载失败，但不阻塞主流程
      print("Failed to load remote data: $e");
    }
  }

  void _initListeners() {
    // 初始化各种事件监听器，例如 Deep Link, Push Notification, 登录异常等
    _captchaSubscription ??= Constant.eventBus.on<CaptchaNeededException>().listen((_) {
      // TODO: emit 一个特定的 state 来显示对话框
    });
    _credentialsInvalidSubscription ??= Constant.eventBus.on<CredentialsInvalidException>().listen((_) {
      // TODO: emit 一个特定的 state 来显示对话框
    });
  }

  List<PlatformSubpage<dynamic>> _buildSubpages() {
    // 根据用户状态动态构建子页面列表
    return [
      if (StateProvider.personInfo.value?.group != UserGroup.VISITOR)
        const HomeSubpage(), // 替换为实际的 Dashboard 页面
      if (!SettingsProvider.getInstance().hideHole)
        ForumSubpage(),
      const DankeSubPage(), // 替换为实际的 Danke 页面
      if (StateProvider.personInfo.value?.group != UserGroup.VISITOR)
        TimetableSubPage(),
      const SettingsSubpage(), // 替换为实际的 Settings 页面
    ];
  }

  @override
  Future<void> close() {
    _personInfoSubscription?.cancel();
    _captchaSubscription?.cancel();
    _credentialsInvalidSubscription?.cancel();
    return super.close();
  }
}


// --- 4. HomePage View (UI视图) ---
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomePageBloc()..add(InitializeApp()),
      child: BlocConsumer<HomePageBloc, HomePageState>(
        listener: (context, state) {
          // 处理一次性事件，如显示对话框或Toast
          if (state is HomePageFailure) {
            Noticing.showErrorDialog(context, state.error);
          }
          if (state is HomePageLoginRequired && !LoginDialog.dialogShown) {
            // 延时一帧确保 BuildContext 可用
            WidgetsBinding.instance.addPostFrameCallback((_) {
              LoginDialog.showLoginDialog(
                context,
                SettingsProvider.getInstance().preferences,
                StateProvider.personInfo,
                false,
              );
            });
          }
        },
        builder: (context, state) {
          // 根据状态构建不同的UI
          return switch (state) {
            HomePageLoading() => const Scaffold(body: Center(child: CircularProgressIndicator())),
            HomePageReady() => _buildMainScaffold(context, state),
            _ => _buildLoginPromptScaffold(context), // 包含 LoginRequired 和 Failure
          };
        },
      ),
    );
  }

  Widget _buildMainScaffold(BuildContext context, HomePageReady state) {
    final s = S.of(context);
    final pageIndex = state.pageIndex;
    final subpages = state.subpages;
    final title = subpages.isEmpty ? Text(s.app_name) : subpages[pageIndex].title.call(context);

    return Scaffold(
      appBar: AppBar(title: title),
      body: LazyLoadIndexedStack(
        index: pageIndex,
        children: subpages,
      ),
      bottomNavigationBar: PlatformNavBarM3(
        items: [
          if (StateProvider.personInfo.value?.group != UserGroup.VISITOR)
            BottomNavigationBarItem(icon: const Icon(Icons.dashboard), label: s.dashboard),
          if (!SettingsProvider.getInstance().hideHole)
            BottomNavigationBarItem(icon: const Icon(Icons.forum), label: s.forum),
          BottomNavigationBarItem(icon: const Icon(Icons.egg_alt), label: s.curriculum),
          if (StateProvider.personInfo.value?.group != UserGroup.VISITOR)
            BottomNavigationBarItem(icon: const Icon(Icons.calendar_today), label: s.timetable),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: s.settings),
        ],
        currentIndex: pageIndex,
        itemChanged: (index) {
          if (index == pageIndex) {
            context.read<HomePageBloc>().add(TabDoubleTapped());
          } else {
            context.read<HomePageBloc>().add(PageSwitched(index));
          }
        },
      ),
    );
  }

  Widget _buildLoginPromptScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).app_name)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(S.of(context).login_required),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 再次触发登录对话框
                LoginDialog.showLoginDialog(
                  context,
                  SettingsProvider.getInstance().preferences,
                  StateProvider.personInfo,
                  false,
                );
              },
              child: Text(S.of(context).login),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 占位的 Subpage，您需要用实际的 Widget 替换它们 ---
class HomeSubpage extends PlatformSubpage { 
  const HomeSubpage({super.key}); 
  @override Widget build(BuildContext context) => const Center(child: Text("Dashboard Page")); 
  @override PreferredSizeWidget? buildAppBar(BuildContext context) => null; 
  @override get title => (context) => const Text("Dashboard"); 
}
class DankeSubPage extends PlatformSubpage { 
  const DankeSubPage({super.key}); 
  @override Widget build(BuildContext context) => const Center(child: Text("Curriculum Page")); 
  @override PreferredSizeWidget? buildAppBar(BuildContext context) => null; 
  @override get title => (context) => const Text("Curriculum"); 
}
class SettingsSubpage extends PlatformSubpage { 
  const SettingsSubpage({super.key}); 
  @override Widget build(BuildContext context) => const Center(child: Text("Settings Page")); 
  @override PreferredSizeWidget? buildAppBar(BuildContext context) => null; 
  @override get title => (context) => const Text("Settings"); 
}