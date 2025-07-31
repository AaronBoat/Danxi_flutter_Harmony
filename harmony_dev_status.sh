#!/bin/bash

# DanXi HarmonyOS 项目状态检查和问题诊断脚本
echo "🔍 DanXi HarmonyOS 项目完整状态检查"
echo "=================================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_ROOT="/Users/aaron/codes/DanXi-1.4.4"
APP_OHOS_PATH="$PROJECT_ROOT/apps/app_ohos"
OHOS_PATH="$APP_OHOS_PATH/ohos"

echo -e "${BLUE}📍 检查项目路径...${NC}"
echo "项目根目录: $PROJECT_ROOT"
echo "HarmonyOS应用: $APP_OHOS_PATH"
echo "原生项目: $OHOS_PATH"

# 1. 检查DevEco Studio项目路径
echo -e "\n${BLUE}1. DevEco Studio 项目检查${NC}"
if [ -d "$OHOS_PATH" ]; then
    echo -e "${GREEN}✅ HarmonyOS原生项目目录存在${NC}"
    echo "  📂 正确的DevEco Studio打开路径: $OHOS_PATH"
else
    echo -e "${RED}❌ HarmonyOS原生项目目录不存在${NC}"
fi

# 2. 检查关键配置文件
echo -e "\n${BLUE}2. 关键配置文件检查${NC}"
files_to_check=(
    "$OHOS_PATH/build-profile.json5"
    "$OHOS_PATH/oh-package.json5"
    "$OHOS_PATH/hvigorfile.ts"
    "$OHOS_PATH/hvigorconfig.ts"
    "$OHOS_PATH/AppScope/app.json5"
    "$OHOS_PATH/entry/src/main/module.json5"
)

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ $(basename "$file")${NC}"
    else
        echo -e "${RED}❌ $(basename "$file")${NC}"
    fi
done

# 3. 检查Flutter配置
echo -e "\n${BLUE}3. Flutter HarmonyOS 配置检查${NC}"
cd "$APP_OHOS_PATH"

# 检查Flutter配置
echo "Flutter配置状态:"
fvm flutter config --list | grep -E "(ohos-sdk|enable-ohos)" || echo "未找到HarmonyOS配置"

# 检查HarmonyOS SDK
SDK_PATH="/Users/aaron/Library/OpenHarmony/Sdk"
if [ -d "$SDK_PATH" ]; then
    echo -e "${GREEN}✅ HarmonyOS SDK存在: $SDK_PATH${NC}"
    if [ -d "$SDK_PATH/18" ]; then
        echo -e "${GREEN}✅ API 18 (5.1.0) SDK已安装${NC}"
    else
        echo -e "${YELLOW}⚠️ API 18 SDK可能未安装${NC}"
    fi
else
    echo -e "${RED}❌ HarmonyOS SDK未找到${NC}"
fi

# 4. 检查Flutter Assets
echo -e "\n${BLUE}4. Flutter Assets 检查${NC}"
ASSETS_PATH="$APP_OHOS_PATH/build/ohos/intermediates/flutter/defaultDebug/flutter_assets"
if [ -d "$ASSETS_PATH" ]; then
    asset_count=$(ls -1 "$ASSETS_PATH" 2>/dev/null | wc -l)
    if [ "$asset_count" -gt 0 ]; then
        echo -e "${GREEN}✅ Flutter assets已生成 ($asset_count 个文件)${NC}"
        ls -la "$ASSETS_PATH" | head -5
    else
        echo -e "${YELLOW}⚠️ Flutter assets目录为空${NC}"
        echo "  💡 需要运行: flutter packages get"
    fi
else
    echo -e "${RED}❌ Flutter assets目录不存在${NC}"
fi

# 5. 检查权限配置
echo -e "\n${BLUE}5. 权限配置检查${NC}"
MODULE_JSON="$OHOS_PATH/entry/src/main/module.json5"
if [ -f "$MODULE_JSON" ]; then
    # 检查是否有usedScene配置
    if grep -q "usedScene" "$MODULE_JSON"; then
        echo -e "${GREEN}✅ 权限配置包含usedScene${NC}"
    else
        echo -e "${YELLOW}⚠️ 某些权限可能缺少usedScene配置${NC}"
    fi
    
    # 统计权限数量
    permission_count=$(grep -c '"name": "ohos.permission.' "$MODULE_JSON" || echo "0")
    echo "  📋 配置的权限数量: $permission_count"
else
    echo -e "${RED}❌ module.json5文件不存在${NC}"
fi

# 6. 检查全局hvigor配置
echo -e "\n${BLUE}6. Hvigor 配置检查${NC}"
GLOBAL_HVIGOR="/Users/aaron/hvigor/hvigor-config.json5"
if [ -f "$GLOBAL_HVIGOR" ]; then
    echo -e "${GREEN}✅ 全局hvigor配置存在${NC}"
else
    echo -e "${RED}❌ 全局hvigor配置缺失${NC}"
    echo "  💡 需要创建: mkdir -p /Users/aaron/hvigor && 创建配置文件"
fi

# 7. 检查构建产物
echo -e "\n${BLUE}7. 构建产物检查${NC}"
if [ -f "$APP_OHOS_PATH/ohos/local.properties" ]; then
    echo -e "${GREEN}✅ local.properties已生成${NC}"
    echo "  SDK路径配置:"
    cat "$APP_OHOS_PATH/ohos/local.properties" | head -3
else
    echo -e "${RED}❌ local.properties未生成${NC}"
fi

if [ -f "$APP_OHOS_PATH/ohos/package.json" ]; then
    echo -e "${GREEN}✅ package.json已生成${NC}"
    if grep -q "flutter-hvigor-plugin" "$APP_OHOS_PATH/ohos/package.json"; then
        echo -e "${GREEN}✅ flutter-hvigor-plugin配置正确${NC}"
    else
        echo -e "${YELLOW}⚠️ flutter-hvigor-plugin可能配置有问题${NC}"
    fi
else
    echo -e "${RED}❌ package.json未生成${NC}"
fi

# 8. 版本兼容性检查
echo -e "\n${BLUE}8. 版本兼容性检查${NC}"
BUILD_PROFILE="$OHOS_PATH/build-profile.json5"
if [ -f "$BUILD_PROFILE" ]; then
    if grep -q '"compatibleSdkVersion": "5.1.0(18)"' "$BUILD_PROFILE"; then
        echo -e "${GREEN}✅ SDK版本配置正确 (5.1.0/API 18)${NC}"
    else
        echo -e "${YELLOW}⚠️ SDK版本配置需要检查${NC}"
        grep "compatibleSdkVersion" "$BUILD_PROFILE" || echo "未找到SDK版本配置"
    fi
fi

# 9. 常见问题快速诊断
echo -e "\n${BLUE}9. 常见问题诊断${NC}"
issues_found=0

# 检查flutter-hvigor-plugin问题
if ! grep -q "flutter-hvigor-plugin" "$APP_OHOS_PATH/ohos/package.json" 2>/dev/null; then
    echo -e "${RED}🐛 问题: flutter-hvigor-plugin未配置${NC}"
    echo "   💡 解决: 运行 fvm flutter packages get"
    ((issues_found++))
fi

# 检查assets问题
if [ ! -d "$ASSETS_PATH" ] || [ -z "$(ls -A "$ASSETS_PATH" 2>/dev/null)" ]; then
    echo -e "${RED}🐛 问题: Flutter assets为空${NC}"
    echo "   💡 解决: 检查pubspec.yaml assets配置并重新运行 flutter packages get"
    ((issues_found++))
fi

# 检查权限问题
if [ -f "$MODULE_JSON" ] && ! grep -q "usedScene" "$MODULE_JSON"; then
    echo -e "${RED}🐛 问题: 用户权限缺少usedScene配置${NC}"
    echo "   💡 解决: 为user_grant权限添加usedScene属性"
    ((issues_found++))
fi

if [ $issues_found -eq 0 ]; then
    echo -e "${GREEN}🎉 未发现常见问题！${NC}"
fi

# 10. 总结和建议
echo -e "\n${BLUE}10. 总结和下一步建议${NC}"
echo "=================================================="

if [ $issues_found -eq 0 ]; then
    echo -e "${GREEN}✅ 项目配置良好，可以在DevEco Studio中打开${NC}"
    echo ""
    echo "📱 建议的操作步骤:"
    echo "1. 打开DevEco Studio"
    echo "2. 选择 File → Open"
    echo "3. 导航到: $OHOS_PATH"
    echo "4. 等待项目同步完成"
    echo "5. 连接HarmonyOS设备或启动模拟器"
    echo "6. 点击Run按钮构建和运行应用"
else
    echo -e "${YELLOW}⚠️ 发现 $issues_found 个问题需要解决${NC}"
    echo ""
    echo "🔧 建议的修复步骤:"
    echo "1. 运行配置脚本: ./configure_harmony_sdk.sh"
    echo "2. 检查并修复上述问题"
    echo "3. 重新运行此检查脚本验证"
    echo "4. 然后在DevEco Studio中打开项目"
fi

echo ""
echo -e "${BLUE}📚 完整文档: DEVECO_STUDIO_GUIDE.md${NC}"
echo -e "${BLUE}🛠️ 配置脚本: configure_harmony_sdk.sh${NC}"
