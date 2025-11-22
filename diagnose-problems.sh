#!/bin/bash

# Problems 面板诊断脚本

echo "🔍 诊断 Problems 面板错误..."
echo ""

# 1. 检查 TypeScript 错误
echo "1️⃣  检查 TypeScript 编译错误"
echo "----------------------------"
TS_ERRORS=$(npx tsc --noEmit 2>&1 | grep -c "error TS" || echo "0")
if [ "$TS_ERRORS" -eq 0 ]; then
    echo "✅ TypeScript: 无错误"
else
    echo "❌ TypeScript: $TS_ERRORS 个错误"
    npx tsc --noEmit 2>&1 | grep "error TS" | head -5
fi
echo ""

# 2. 检查 Go 模块文件
echo "2️⃣  检查 Go 模块文件"
echo "-------------------"
if [ -f "src/generated/grpc-go/go.mod" ]; then
    echo "✅ go.mod 存在"
else
    echo "❌ go.mod 不存在"
fi

if [ -f "src/generated/grpc-go/go.sum" ]; then
    echo "✅ go.sum 存在"
else
    echo "❌ go.sum 不存在"
fi
echo ""

# 3. 检查 Go 编译
echo "3️⃣  检查 Go CLI 编译"
echo "-------------------"
export PATH="$PATH:$HOME/go/bin"
cd cli
if go build -o /tmp/cline-test ./cmd/cline 2>&1 | grep -q "error"; then
    echo "❌ Go CLI 编译失败："
    go build -o /tmp/cline-test ./cmd/cline 2>&1 | grep "error" | head -5
else
    echo "✅ Go CLI 编译成功"
    rm -f /tmp/cline-test
fi
cd ..
echo ""

# 4. 检查 gopls 状态
echo "4️⃣  检查 gopls 进程"
echo "-------------------"
if pgrep -f gopls > /dev/null; then
    GOPLS_PID=$(pgrep -f gopls | head -1)
    echo "✅ gopls 运行中 (PID: $GOPLS_PID)"
else
    echo "⚠️  gopls 未运行"
fi
echo ""

# 5. 检查构建产物
echo "5️⃣  检查构建产物"
echo "-----------------"
[ -f "dist/extension.js" ] && echo "✅ dist/extension.js" || echo "❌ dist/extension.js"
[ -d "webview-ui/build" ] && echo "✅ webview-ui/build/" || echo "❌ webview-ui/build/"
[ -f "cli/cline" ] && echo "✅ cli/cline" || echo "❌ cli/cline"
echo ""

# 6. 检查生成的文件数量
echo "6️⃣  生成文件统计"
echo "-----------------"
GRPC_GO_FILES=$(find src/generated/grpc-go -name "*.go" 2>/dev/null | wc -l)
TS_PROTO_FILES=$(find src/generated/hosts -name "*.ts" 2>/dev/null | wc -l)
echo "Go proto 文件: $GRPC_GO_FILES 个"
echo "TS proto 文件: $TS_PROTO_FILES 个"
echo ""

# 7. 建议
echo "💡 建议操作"
echo "----------"
if [ "$TS_ERRORS" -gt 0 ] || [ ! -f "src/generated/grpc-go/go.mod" ]; then
    echo "❌ 发现问题，建议执行："
    echo "   ./dev-setup.sh"
    echo "   然后在 VS Code 中重新加载窗口"
elif ! pgrep -f gopls > /dev/null; then
    echo "⚠️  gopls 未运行，VS Code Go 扩展可能需要重启"
else
    echo "✅ 一切正常！"
    echo ""
    echo "如果 Problems 面板仍有错误："
    echo "  1. 在 VS Code 中: Cmd+Shift+P"
    echo "  2. 输入: Reload Window"
    echo "  3. 回车重新加载"
fi
