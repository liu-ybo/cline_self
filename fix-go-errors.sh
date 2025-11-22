#!/bin/bash
set -e

echo "🔧 彻底修复 Go 错误（151个）"
echo "================================"

# 1. 确保 Go bin 在 PATH 中
echo ""
echo "步骤 1: 设置 Go PATH..."
export PATH="$PATH:$HOME/go/bin"
echo "✓ PATH 已更新"

# 2. 重新生成 Go protobuf 代码
echo ""
echo "步骤 2: 重新生成 Go protobuf 代码..."
node scripts/build-go-proto.mjs
echo "✓ Go protobuf 代码已生成"

# 3. 更新 Go 模块依赖
echo ""
echo "步骤 3: 更新 Go 模块依赖..."
echo "  - 更新 src/generated/grpc-go/go.mod..."
cd src/generated/grpc-go && go mod tidy && cd ../../..
echo "  - 更新 cli/go.mod..."
cd cli && go mod tidy && cd ..
echo "✓ Go 依赖已更新"

# 4. 杀掉所有 gopls 进程（强制重启）
echo ""
echo "步骤 4: 重启 gopls 语言服务器..."
pkill -9 gopls 2>/dev/null || echo "  (没有运行的 gopls 进程)"
echo "✓ gopls 将在 VS Code 中自动重启"

# 5. 验证文件存在
echo ""
echo "步骤 5: 验证生成的文件..."
if [ -f "src/generated/grpc-go/go.mod" ]; then
    echo "✓ src/generated/grpc-go/go.mod 存在"
else
    echo "✗ src/generated/grpc-go/go.mod 不存在！"
    exit 1
fi

if [ -f "src/generated/grpc-go/go.sum" ]; then
    echo "✓ src/generated/grpc-go/go.sum 存在"
else
    echo "✗ src/generated/grpc-go/go.sum 不存在！"
    exit 1
fi

# 6. 永久添加 Go bin 到 PATH（如果尚未添加）
echo ""
echo "步骤 6: 永久添加 Go bin 到 PATH..."
SHELL_RC="$HOME/.zshrc"
if [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

if ! grep -q 'export PATH="$PATH:$HOME/go/bin"' "$SHELL_RC" 2>/dev/null; then
    echo 'export PATH="$PATH:$HOME/go/bin"' >> "$SHELL_RC"
    echo "✓ 已添加到 $SHELL_RC"
    echo "  请运行: source $SHELL_RC"
else
    echo "✓ PATH 配置已存在于 $SHELL_RC"
fi

echo ""
echo "================================"
echo "✅ 修复完成！"
echo ""
echo "下一步操作："
echo "1. 在 VS Code 中按 Cmd+Shift+P"
echo "2. 输入 'Reload Window'"
echo "3. 回车重新加载窗口"
echo ""
echo "或者直接重启 VS Code"
echo ""
echo "如果还有错误，请运行："
echo "  source ~/.zshrc"
echo "  ./fix-go-errors.sh"
