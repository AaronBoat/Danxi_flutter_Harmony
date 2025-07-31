#!/bin/bash

# HarmonyOS项目配置检查脚本

echo "🔍 HarmonyOS项目配置检查"
echo "================================"

OHOS_PROJECT_PATH="/Users/aaron/codes/DanXi-1.4.4/apps/app_ohos/ohos"

# 检查项目目录
if [ ! -d "$OHOS_PROJECT_PATH" ]; then
    echo "❌ HarmonyOS项目目录不存在: $OHOS_PROJECT_PATH"
    exit 1
fi

echo "✅ HarmonyOS项目目录存在"
cd "$OHOS_PROJECT_PATH"

echo ""
echo "📁 项目结构检查:"
echo "--------------------------------"

# 检查关键文件
key_files=(
    "build-profile.json5"
    "oh-package.json5"
    "hvigorfile.ts"
    "entry/src/main/module.json5"
    "AppScope/app.json5"
)

for file in "${key_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file (缺失)"
    fi
done

echo ""
echo "📋 配置信息:"
echo "--------------------------------"

# 检查应用配置
if [ -f "oh-package.json5" ]; then
    echo "📦 应用名称: $(grep '"name"' oh-package.json5 | cut -d'"' -f4)"
    echo "📦 应用版本: $(grep '"version"' oh-package.json5 | cut -d'"' -f4)"
fi

# 检查构建配置
if [ -f "build-profile.json5" ]; then
    echo "🔧 兼容SDK版本: $(grep 'compatibleSdkVersion' build-profile.json5 | cut -d'"' -f4)"
    echo "🔧 运行时OS: $(grep 'runtimeOS' build-profile.json5 | cut -d'"' -f4)"
fi

# 检查模块配置
if [ -f "entry/src/main/module.json5" ]; then
    echo "📱 模块名称: $(grep '"name"' entry/src/main/module.json5 | head -1 | cut -d'"' -f4)"
    echo "📱 模块类型: $(grep '"type"' entry/src/main/module.json5 | head -1 | cut -d'"' -f4)"
fi

echo ""
echo "🎯 DevEco Studio 操作指南:"
echo "--------------------------------"
echo "1. 在DevEco Studio中选择 'Open Project'"
echo "2. 导航到以下路径:"
echo "   $OHOS_PROJECT_PATH"
echo "3. 选择此目录并点击 'Open'"
echo ""
echo "⚠️  重要提醒:"
echo "   - 必须打开 'ohos' 目录，不是上级目录"
echo "   - 确保已安装HarmonyOS SDK 5.1.0或更高版本"
echo "   - 首次打开可能需要下载依赖，请耐心等待"

echo ""
echo "🔗 项目路径 (复制此路径到DevEco Studio):"
echo "$OHOS_PROJECT_PATH"

echo ""
echo "✨ 检查完成!"
