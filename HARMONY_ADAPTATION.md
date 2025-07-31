# DanXi 鸿蒙版本适配指南

## 项目结构

```
DanXi-1.4.4/
├── apps/
│   ├── app/           # 通用Flutter应用（Android、iOS、Windows等）
│   └── app_ohos/      # 鸿蒙专用应用
├── modules/           # 业务模块（通用）
└── common/           # 公共模块（通用）
```

## 鸿蒙适配策略

### 1. 壳工程分离
- `apps/app`: 使用标准 Flutter SDK
- `apps/app_ohos`: 使用鸿蒙化 Flutter SDK (3.22.1-ohos-1.0.3)

### 2. 模块复用
所有业务模块和公共模块在两个平台间完全复用：
- ✅ `modules/home_module`
- ✅ `modules/dashboard_module`  
- ✅ `modules/forum_module`
- ✅ `modules/course_module`
- ✅ `modules/timetable_module`
- ✅ `common/network`
- ✅ `common/tools`
- ✅ `common/widgets`

### 3. 依赖适配策略

#### 🟢 无需适配（纯Dart实现）
这些库在两个平台使用相同版本：
```yaml
flutter_bloc: ^8.1.3      # 状态管理
dio: ^5.4.3+1             # 网络请求
fl_chart: ^0.68.0         # 图表组件
go_router: ^14.0.0        # 路由管理
intl: ^0.19.0            # 国际化
data_table_2: ^2.5.9      # 表格组件
flutter_rating_bar: ^4.0.1 # 评分组件
table_calendar: ^3.0.9    # 日历组件
```

#### 🟡 需要鸿蒙适配（平台依赖）
这些库在鸿蒙版本中通过 `dependency_overrides` 替换：

| 库名 | 功能 | 鸿蒙适配源 |
|-----|------|----------|
| fluttertoast | Toast提示 | gitee.com/openharmony-sig/flutter_fluttertoast |
| image_picker | 图片选择 | gitee.com/openharmony-sig/flutter_image_picker |
| permission_handler | 权限管理 | gitee.com/openharmony-sig/flutter_permission_handler |
| shared_preferences | 本地存储 | gitee.com/openharmony-sig/flutter_shared_preferences |
| file_picker | 文件选择 | gitee.com/openharmony-sig/flutter_file_picker |

## 配置文件对比

### 通用版本 (apps/app/pubspec.yaml)
```yaml
dependencies:
  # 模块依赖
  home_module:
    path: ../../modules/home_module
  # ... 其他模块

  # 平台特定依赖
  flutter_phoenix: ^1.0.0
  app_links: ^6.1.3
  provider: ^6.0.5
```

### 鸿蒙版本 (apps/app_ohos/pubspec.yaml)  
```yaml
dependencies:
  # 相同的模块依赖
  home_module:
    path: ../../modules/home_module
  # ... 其他模块

  # 鸿蒙平台特定依赖
  flutter_phoenix: ^1.0.0
  provider: ^6.0.5

# 鸿蒙化适配
dependency_overrides:
  fluttertoast:
    git:
      url: "https://gitee.com/openharmony-sig/flutter_fluttertoast.git"
      ref: "master"
  # ... 其他适配库
```

## 开发流程

### 1. 通用功能开发
在 `modules/` 中开发业务功能，两个平台自动共享：
```bash
# 开发新功能
cd modules/dashboard_module
# 添加功能代码
# 两个应用都会获得更新
```

### 2. 平台特定功能
如需平台特定功能，在对应的壳工程中添加：
```bash
# Android/iOS 特定功能
cd apps/app
# 添加平台代码

# 鸿蒙特定功能  
cd apps/app_ohos
# 添加鸿蒙代码
```

### 3. 三方库适配
当模块中使用新的平台依赖库时：

1. 在模块的 `pubspec.yaml` 中添加库
2. 检查该库是否需要鸿蒙适配
3. 如需适配，在 `apps/app_ohos/pubspec.yaml` 的 `dependency_overrides` 中添加鸿蒙版本

## 构建和运行

### 通用版本
```bash
cd apps/app
fvm flutter run         # 默认平台
fvm flutter run -d android
fvm flutter run -d ios
```

### 鸿蒙版本
```bash
cd apps/app_ohos
fvm flutter run         # 鸿蒙平台
fvm flutter run lib/main_harmony.dart  # 使用鸿蒙专用入口
```

## 权限配置

### 鸿蒙应用权限 (ohos/entry/src/main/module.json5)
```json
{
  "requestPermissions": [
    {
      "name": "ohos.permission.INTERNET",
      "reason": "网络访问"
    },
    {
      "name": "ohos.permission.CAMERA",
      "reason": "拍照功能"
    },
    {
      "name": "ohos.permission.READ_MEDIA",
      "reason": "读取媒体文件"
    },
    {
      "name": "ohos.permission.WRITE_MEDIA",
      "reason": "写入媒体文件"
    }
  ]
}
```

## 维护策略

### 1. 版本同步
- 两个应用保持相同的版本号
- 模块更新时，两个应用同时受益

### 2. 测试策略
- 模块级测试：在模块目录下运行测试
- 应用级测试：分别在两个应用中测试
- 自动化测试：CI 中同时测试两个平台

### 3. 发布策略
- 通用版本：发布到 App Store、Google Play 等
- 鸿蒙版本：发布到华为应用市场

## 优势总结

✅ **代码复用最大化**：90%+ 代码在两个平台间共享  
✅ **维护成本最小化**：只需维护一套业务逻辑  
✅ **适配工作量最小化**：只需适配少数平台依赖库  
✅ **开发效率最高化**：模块化开发，并行协作  
✅ **质量保证最优化**：统一的代码质量和测试覆盖

这种架构使得 DanXi 可以高效地支持鸿蒙平台，同时保持与其他平台的一致性和可维护性。
