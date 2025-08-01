library home_module;

// 导出封装的 HomePage 组件（推荐使用）
export 'home_page_wrapper.dart';

// 导出原始的 home_page（兼容性保留），但隐藏其中的 HomePage 类以避免冲突
export 'home_page.dart' hide HomePage;
