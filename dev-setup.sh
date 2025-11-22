#!/bin/bash

# Cline 开发环境初始化脚本
# 确保 Go 模块文件在 gopls 启动前就已存在

set -e

echo "🚀 初始化 Cline 开发环境..."
echo ""

# 设置 Go PATH
export PATH="$PATH:$HOME/go/bin"

# 1. 确保 src/generated/grpc-go 目录存在
echo "📁 创建生成文件目录..."
mkdir -p src/generated/grpc-go

# 2. 如果 go.mod 不存在，从 Git 恢复
if [ ! -f "src/generated/grpc-go/go.mod" ]; then
    echo "📥 从 Git 恢复 Go 模块文件..."
    git checkout src/generated/grpc-go/go.mod src/generated/grpc-go/go.sum 2>/dev/null || {
        echo "⚠️  Go 模块文件不在 Git 中，将重新生成"
    }
fi

# 3. 生成所有 proto 文件
echo "🔧 生成 protobuf 代码..."
npm run protos

# 4. 生成 Go proto 代码
echo "🔧 生成 Go protobuf 代码..."
node scripts/build-go-proto.mjs

# 5. 更新 Go 模块依赖
echo "📦 更新 Go 模块依赖..."
cd src/generated/grpc-go && go mod tidy
cd ../../..
cd cli && go mod tidy
cd ..

# 6. 构建 webview（首次需要）
if [ ! -d "webview-ui/build" ]; then
    echo "🎨 构建 webview..."
    npm run build:webview
fi

# 7. 编译扩展
echo "📦 编译扩展..."
node esbuild.mjs

# 8. 编译 Go CLI
echo "🔨 编译 Go CLI..."
cd cli && go build -o cline ./cmd/cline
cd ..

echo ""
echo "✅ 开发环境初始化完成！"
echo ""
echo "下一步："
echo "  1. 在 VS Code 中重新加载窗口（Cmd+Shift+P → Reload Window）"
echo "  2. 或者关闭并重新打开 VS Code"
echo "  3. 然后按 F5 启动扩展开发"
echo ""
echo "持续开发："
echo "  运行: npm run watch"
echo "  然后按 F5 启动扩展"
