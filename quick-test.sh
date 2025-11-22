#!/bin/bash

# Cline 快速功能测试脚本
# 用于验证项目构建和基础功能

set -e  # 遇到错误立即退出

echo "🧪 Cline 项目快速测试开始..."
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试计数
PASSED=0
FAILED=0

# 测试函数
test_command() {
    local test_name="$1"
    local command="$2"
    
    echo -n "Testing: $test_name ... "
    
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((FAILED++))
        return 1
    fi
}

# 确保在项目根目录
cd "$(dirname "$0")"
PROJECT_ROOT=$(pwd)

echo "📂 项目路径: $PROJECT_ROOT"
echo ""

# ============= 环境检查 =============
echo "1️⃣  环境检查"
echo "-------------------"

test_command "Node.js 已安装" "node --version"
test_command "npm 已安装" "npm --version"
test_command "Go 已安装" "go version"
test_command "Git 已安装" "git --version"

echo ""

# ============= TypeScript 编译检查 =============
echo "2️⃣  TypeScript 编译检查"
echo "-------------------"

echo -n "检查 TypeScript 错误 ... "
TS_ERRORS=$(npx tsc --noEmit 2>&1 | grep -c "error TS" || true)
if [ "$TS_ERRORS" -eq 0 ]; then
    echo -e "${GREEN}✓ 无错误 (0 errors)${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗ 发现 $TS_ERRORS 个错误${NC}"
    ((FAILED++))
fi

echo ""

# ============= 构建产物检查 =============
echo "3️⃣  构建产物检查"
echo "-------------------"

test_command "dist/extension.js 存在" "[ -f dist/extension.js ]"
test_command "webview-ui/build 存在" "[ -d webview-ui/build ]"
test_command "src/generated 存在" "[ -d src/generated ]"

echo ""

# ============= Go 编译检查 =============
echo "4️⃣  Go CLI 编译检查"
echo "-------------------"

# 设置 Go PATH
export PATH="$PATH:$HOME/go/bin"

echo -n "编译 Go CLI ... "
cd "$PROJECT_ROOT/cli"
if go build -v ./cmd/cline > /dev/null 2>&1; then
    echo -e "${GREEN}✓ 编译成功${NC}"
    ((PASSED++))
    
    # 测试 CLI 可执行
    if [ -f "./cline" ]; then
        echo -n "测试 CLI 可执行性 ... "
        if ./cline --help > /dev/null 2>&1; then
            echo -e "${GREEN}✓ 可执行${NC}"
            ((PASSED++))
        else
            echo -e "${RED}✗ 无法执行${NC}"
            ((FAILED++))
        fi
    fi
else
    echo -e "${RED}✗ 编译失败${NC}"
    ((FAILED++))
fi

cd "$PROJECT_ROOT"

echo ""

# ============= Proto 文件检查 =============
echo "5️⃣  Protobuf 生成文件检查"
echo "-------------------"

test_command "TypeScript proto 文件存在" "[ -d src/generated/hosts ]"
test_command "Go proto 文件存在" "[ -d src/generated/grpc-go ]"
test_command "Go proto go.mod 存在" "[ -f src/generated/grpc-go/go.mod ]"

echo ""

# ============= 依赖检查 =============
echo "6️⃣  依赖完整性检查"
echo "-------------------"

echo -n "检查 node_modules ... "
if [ -d "node_modules" ] && [ -f "node_modules/.package-lock.json" ]; then
    echo -e "${GREEN}✓ 存在${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗ 缺失或不完整${NC}"
    ((FAILED++))
fi

echo -n "检查 webview-ui/node_modules ... "
if [ -d "webview-ui/node_modules" ]; then
    echo -e "${GREEN}✓ 存在${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗ 缺失${NC}"
    ((FAILED++))
fi

echo ""

# ============= Watch 进程检查 =============
echo "7️⃣  开发进程检查"
echo "-------------------"

check_process() {
    local process_name="$1"
    local search_pattern="$2"
    
    echo -n "检查 $process_name ... "
    if pgrep -f "$search_pattern" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ 运行中${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ 未运行${NC}"
        return 1
    fi
}

check_process "watch:tsc" "npm run watch:tsc"
check_process "watch:esbuild" "npm run watch:esbuild"
check_process "dev:webview" "npm run dev:webview"

echo ""
echo -e "${YELLOW}提示: 如果 watch 进程未运行，请执行: npm run watch${NC}"
echo ""

# ============= 文件结构检查 =============
echo "8️⃣  关键文件结构检查"
echo "-------------------"

REQUIRED_FILES=(
    "package.json"
    "tsconfig.json"
    "esbuild.mjs"
    "src/extension.ts"
    "src/core/task/index.ts"
    "src/core/task/ToolExecutor.ts"
    "cli/go.mod"
    "cli/cmd/cline/main.go"
)

for file in "${REQUIRED_FILES[@]}"; do
    test_command "$file" "[ -f $file ]"
done

echo ""

# ============= Git 状态检查 =============
echo "9️⃣  Git 状态"
echo "-------------------"

if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current)
    MODIFIED=$(git status --porcelain | wc -l)
    echo -e "当前分支: ${GREEN}$BRANCH${NC}"
    echo "修改文件数: $MODIFIED"
    ((PASSED++))
else
    echo -e "${RED}✗ 不是 Git 仓库${NC}"
    ((FAILED++))
fi

echo ""

# ============= 测试总结 =============
echo "=========================================="
echo "📊 测试总结"
echo "=========================================="
echo -e "通过: ${GREEN}$PASSED${NC}"
echo -e "失败: ${RED}$FAILED${NC}"
TOTAL=$((PASSED + FAILED))
echo "总计: $TOTAL"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ 所有测试通过！项目状态良好。${NC}"
    echo ""
    echo "下一步："
    echo "  1. 按 F5 启动扩展开发"
    echo "  2. 在新窗口中打开 Cline 侧边栏"
    echo "  3. 开始测试功能"
    echo ""
    echo "详细测试用例请查看: TEST_CASES.md"
    exit 0
else
    echo -e "${RED}❌ 部分测试失败，请检查上述错误。${NC}"
    exit 1
fi
