#!/bin/bash

echo "🔍 验证HarmonyOS项目配置..."
echo

# 检查项目路径
OHOS_PROJECT_PATH="/Users/aaron/codes/DanXi-1.4.4/apps/app_ohos/ohos"

if [ ! -d "$OHOS_PROJECT_PATH" ]; then
    echo "❌ HarmonyOS项目目录不存在: $OHOS_PROJECT_PATH"
    exit 1
fi

echo "✅ HarmonyOS项目目录存在"

# 检查关键文件
FILES_TO_CHECK=(
    "build-profile.json5"
    "oh-package.json5"
    "hvigorfile.ts"
    "hvigorconfig.ts"
    "AppScope/app.json5"
    "entry/build-profile.json5"
)

cd "$OHOS_PROJECT_PATH"

for file in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file 存在"
    else
        echo "❌ $file 缺失"
    fi
done

# 检查oh-package.json5配置
echo
echo "📋 检查oh-package.json5配置:"
if grep -q '"dependencies": {}' oh-package.json5; then
    echo "✅ dependencies配置正确 (为空)"
else
    echo "⚠️  dependencies配置可能有问题"
    echo "当前配置:"
    grep -A 3 '"dependencies"' oh-package.json5
fi

# 检查全局hvigor配置
GLOBAL_HVIGOR_CONFIG="/Users/aaron/hvigor/hvigor-config.json5"
if [ -f "$GLOBAL_HVIGOR_CONFIG" ]; then
    echo "✅ 全局hvigor配置文件存在"
else
    echo "⚠️  全局hvigor配置文件不存在，建议创建:"
    echo "mkdir -p /Users/aaron/hvigor"
    echo "cat > /Users/aaron/hvigor/hvigor-config.json5 << 'EOF'"
    echo "{"
    echo '  "modelVersion": "5.1.0",'
    echo '  "dependencies": {}'
    echo "}"
    echo "EOF"
fi

echo
echo "📱 下一步操作:"
echo "1. 打开DevEco Studio"
echo "2. 选择 File → Open"
echo "3. 选择目录: $OHOS_PROJECT_PATH"
echo "4. 等待项目同步完成"
echo "5. 如果提示安装SDK，点击同意"

echo
echo "🎯 DevEco Studio应该显示:"
echo "- 项目名称: app_ohos"
echo "- 底部状态栏显示 'HarmonyOS'"
echo "- 可以看到entry模块"
echo "- 构建工具栏有HarmonyOS选项"
