#!/bin/bash

# DanXi 鸿蒙版本开发脚本
# 使用方法: ./harmony_dev.sh [command]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目路径
PROJECT_ROOT="/Users/aaron/codes/DanXi-1.4.4"
HARMONY_APP_PATH="$PROJECT_ROOT/apps/app_ohos"

# 打印带颜色的信息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查鸿蒙Flutter环境
check_harmony_env() {
    print_info "检查鸿蒙Flutter环境..."
    
    if ! command -v fvm &> /dev/null; then
        print_error "FVM未安装，请先安装FVM"
        exit 1
    fi
    
    cd "$HARMONY_APP_PATH"
    
    # 检查Flutter版本
    FLUTTER_VERSION=$(fvm flutter --version | head -n 1)
    if [[ $FLUTTER_VERSION == *"ohos"* ]]; then
        print_success "鸿蒙Flutter环境正常: $FLUTTER_VERSION"
    else
        print_warning "当前Flutter版本可能不支持鸿蒙: $FLUTTER_VERSION"
    fi
    
    # 检查鸿蒙SDK
    if [ -z "$HOS_SDK_HOME" ]; then
        print_warning "HOS_SDK_HOME环境变量未设置，请确保已安装鸿蒙SDK"
    else
        print_success "鸿蒙SDK路径: $HOS_SDK_HOME"
    fi
}

# 获取依赖
get_dependencies() {
    print_info "获取项目依赖..."
    cd "$HARMONY_APP_PATH"
    fvm flutter pub get
    print_success "依赖获取完成"
}

# 清理项目
clean_project() {
    print_info "清理项目..."
    cd "$HARMONY_APP_PATH"
    fvm flutter clean
    print_success "项目清理完成"
}

# 构建项目
build_project() {
    print_info "构建鸿蒙应用..."
    cd "$HARMONY_APP_PATH"
    fvm flutter build ohos --release
    print_success "构建完成"
}

# 运行项目
run_project() {
    print_info "运行鸿蒙应用..."
    cd "$HARMONY_APP_PATH"
    
    # 使用鸿蒙专用入口文件
    fvm flutter run lib/main_harmony.dart
}

# 检查模块依赖
check_modules() {
    print_info "检查模块依赖状态..."
    
    MODULES=("home_module" "dashboard_module" "forum_module" "course_module" "timetable_module")
    COMMON=("network" "tools" "widgets")
    
    for module in "${MODULES[@]}"; do
        if [ -d "$PROJECT_ROOT/modules/$module" ]; then
            print_success "✓ 业务模块: $module"
        else
            print_error "✗ 缺失模块: $module"
        fi
    done
    
    for common in "${COMMON[@]}"; do
        if [ -d "$PROJECT_ROOT/common/$common" ]; then
            print_success "✓ 公共模块: $common"
        else
            print_error "✗ 缺失模块: $common"
        fi
    done
}

# 检查鸿蒙适配库
check_harmony_libs() {
    print_info "检查鸿蒙适配库状态..."
    
    cd "$HARMONY_APP_PATH"
    
    # 需要鸿蒙适配的库
    HARMONY_LIBS=("fluttertoast" "image_picker" "permission_handler" "shared_preferences" "file_picker")
    
    print_info "检查pubspec.yaml中的dependency_overrides..."
    
    for lib in "${HARMONY_LIBS[@]}"; do
        if grep -q "$lib:" pubspec.yaml; then
            if grep -A 3 "$lib:" pubspec.yaml | grep -q "gitee.com/openharmony-sig"; then
                print_success "✓ $lib - 已配置鸿蒙适配"
            else
                print_warning "⚠ $lib - 未使用鸿蒙适配版本"
            fi
        else
            print_info "○ $lib - 未使用此库"
        fi
    done
}

# 显示帮助信息
show_help() {
    echo "DanXi 鸿蒙版本开发脚本"
    echo ""
    echo "使用方法: $0 [command]"
    echo ""
    echo "可用命令:"
    echo "  check-env     检查鸿蒙开发环境"
    echo "  check-modules 检查模块依赖状态"
    echo "  check-libs    检查鸿蒙适配库状态"
    echo "  get           获取项目依赖"
    echo "  clean         清理项目"
    echo "  build         构建鸿蒙应用"
    echo "  run           运行鸿蒙应用"
    echo "  dev           开发模式（检查+获取依赖+运行）"
    echo "  help          显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 dev        # 开发模式，一键启动"
    echo "  $0 check-env  # 仅检查环境"
    echo "  $0 build      # 仅构建应用"
}

# 开发模式
dev_mode() {
    print_info "========== DanXi 鸿蒙版本开发模式 =========="
    check_harmony_env
    check_modules
    check_harmony_libs
    get_dependencies
    print_info "========== 准备完成，启动应用 =========="
    run_project
}

# 主逻辑
case "$1" in
    "check-env")
        check_harmony_env
        ;;
    "check-modules")
        check_modules
        ;;
    "check-libs")
        check_harmony_libs
        ;;
    "get")
        get_dependencies
        ;;
    "clean")
        clean_project
        ;;
    "build")
        build_project
        ;;
    "run")
        run_project
        ;;
    "dev")
        dev_mode
        ;;
    "help"|"")
        show_help
        ;;
    *)
        print_error "未知命令: $1"
        show_help
        exit 1
        ;;
esac
