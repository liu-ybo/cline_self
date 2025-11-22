# 🔧 Problems 面板 Go 错误快速修复指南

## 问题现象

每次重新打开 VS Code 或清理项目后，Problems 面板出现大量 Go 错误：
```
could not import github.com/cline/grpc-go/cline (missing import)
reading src/generated/grpc-go/go.mod: no such file or directory
missing metadata for import of "context"
```

## 根本原因

### gopls（Go 语言服务器）的启动时序问题

```
VS Code 启动
    ↓
gopls 自动启动并扫描
    ↓
尝试读取 src/generated/grpc-go/go.mod  ← 此时文件可能不存在
    ↓
缓存错误状态
    ↓
即使后来生成了文件，错误仍然显示（缓存未更新）
```

### 为什么文件会丢失？

1. **清理操作**：`rm -rf dist` 或 `npm run clean` 删除了生成的文件
2. **Git checkout**：切换分支时，`src/generated/` 被 `.gitignore` 忽略
3. **首次克隆**：新克隆的仓库中没有生成文件（现已修复：go.mod 和 go.sum 已加入 Git）

## 解决方案

### 方案 1：运行初始化脚本（推荐）

```bash
./dev-setup.sh
```

然后在 VS Code 中：
- 按 `Cmd+Shift+P`
- 输入 "Reload Window"
- 回车重新加载窗口

### 方案 2：手动重新生成（临时修复）

```bash
# 1. 设置 Go PATH
export PATH="$PATH:$HOME/go/bin"

# 2. 生成 Go proto 代码
node scripts/build-go-proto.mjs

# 3. 更新 Go 模块
cd src/generated/grpc-go && go mod tidy && cd ../..
cd cli && go mod tidy && cd ..

# 4. 重启 gopls
pkill -f gopls
```

等待几秒钟让 gopls 自动重启，或者重新加载 VS Code 窗口。

### 方案 3：仅重启 gopls（最快）

如果文件已经存在，只是 gopls 缓存问题：

```bash
pkill -f gopls
```

或在 VS Code 中：
- 按 `Cmd+Shift+P`
- 输入 "Go: Restart Language Server"
- 回车

## 预防措施

### 1. 始终使用初始化脚本启动开发

```bash
# 每次开始开发前
./dev-setup.sh

# 然后在 VS Code 中重新加载窗口
```

### 2. 不要手动删除 src/generated/grpc-go/go.mod

这两个文件现在已经在 Git 中：
- `src/generated/grpc-go/go.mod`
- `src/generated/grpc-go/go.sum`

如果不小心删除了，可以恢复：
```bash
git checkout src/generated/grpc-go/go.mod src/generated/grpc-go/go.sum
```

### 3. 添加 VS Code 设置（可选）

在 `.vscode/settings.json` 中添加：
```json
{
  "go.buildOnSave": "off",
  "go.lintOnSave": "off"
}
```

这可以减少 gopls 在保存时的重新扫描。

## 快速诊断

### 检查文件是否存在
```bash
ls -la src/generated/grpc-go/go.mod
```

**预期输出**：
```
-rw-r--r--  1 user  staff  340 Nov 22 11:32 src/generated/grpc-go/go.mod
```

### 检查 gopls 状态
```bash
ps aux | grep gopls
```

**预期输出**：应该看到 gopls 进程在运行

### 检查 Problems 面板
在 VS Code 中：
- 按 `Cmd+Shift+M` 打开 Problems 面板
- 过滤 "go.mod"：应该看到相关错误（如果有）

## 工作流程最佳实践

### 日常开发流程

```bash
# 1. 早上开始工作
git pull
./dev-setup.sh

# 2. 在 VS Code 中重新加载窗口
# Cmd+Shift+P → Reload Window

# 3. 启动 watch 模式
npm run watch

# 4. 按 F5 开始开发
```

### 切换分支后

```bash
# 1. 切换分支
git checkout feature-branch

# 2. 重新初始化
./dev-setup.sh

# 3. 重新加载 VS Code 窗口
```

### 清理项目后

```bash
# 如果你运行了 clean 命令
npm run clean  # 或 rm -rf dist

# 立即重新生成
./dev-setup.sh
```

## 常见错误信息对照

| 错误信息 | 原因 | 解决方案 |
|---------|------|---------|
| `no such file or directory: go.mod` | go.mod 不存在 | 运行 `./dev-setup.sh` |
| `missing import github.com/cline/grpc-go` | proto 文件未生成 | `node scripts/build-go-proto.mjs` |
| `missing metadata for import` | gopls 缓存问题 | `pkill -f gopls` |
| `undefined: ClientRegistry` | 代码正常，gopls 误报 | 重新加载窗口 |

## 终极解决方案

如果以上都不行，执行完全重置：

```bash
# 1. 关闭 VS Code

# 2. 清理所有缓存
rm -rf node_modules
rm -rf webview-ui/node_modules
rm -rf src/generated
rm -rf dist

# 3. 重新安装和生成
npm run install:all
./dev-setup.sh

# 4. 重新打开 VS Code
code .
```

## 总结

**记住这三步**：
1. 🔧 运行 `./dev-setup.sh` 生成所有文件
2. 🔄 重新加载 VS Code 窗口（Cmd+Shift+P → Reload Window）
3. 🚀 按 F5 开始开发

**核心原则**：确保 Go 模块文件在 gopls 启动前就已存在！
