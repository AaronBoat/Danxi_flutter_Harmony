#!/bin/bash

# HarmonyOS SDK 配置脚本
# 用于配置Flutter使用HarmonyOS SDK

echo "🔧 配置HarmonyOS SDK..."

# 检查SDK是否存在
SDK_PATH="/Users/aaron/Library/OpenHarmony/Sdk"
if [ ! -d "$SDK_PATH" ]; then
    echo "❌ HarmonyOS SDK 未找到在: $SDK_PATH"
    echo "请确保已在DevEco Studio中安装HarmonyOS SDK"
    exit 1
fi

echo "✅ 找到HarmonyOS SDK: $SDK_PATH"

# 进入项目目录
cd /Users/aaron/codes/DanXi-1.4.4/apps/app_ohos

# 配置Flutter SDK路径
echo "🔧 配置Flutter SDK路径..."
fvm flutter config --ohos-sdk "$SDK_PATH"

# 清理并重新获取依赖
echo "🔧 清理项目..."
fvm flutter clean

echo "🔧 获取依赖包..."
fvm flutter packages get

# 检查关键文件
echo "🔍 验证配置文件..."

if [ -f "ohos/local.properties" ]; then
    echo "✅ local.properties 已生成"
    cat ohos/local.properties
else
    echo "❌ local.properties 未生成"
fi

if [ -f "ohos/package.json" ]; then
    echo "✅ package.json 已生成"
    cat ohos/package.json
else
    echo "❌ package.json 未生成"
fi

echo ""
echo "🎯 下一步操作:"
echo "1. 打开DevEco Studio"
echo "2. 选择 File → Open"
echo "3. 选择目录: $(pwd)/ohos"
echo "4. 等待项目同步完成"
echo ""
echo "✅ SDK配置完成！"
