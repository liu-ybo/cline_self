# Cline 功能测试用例

## 前置条件
1. 按 F5 启动 Extension Development Host
2. 在新窗口中打开 Cline 侧边栏
3. 开始新对话

---

## 测试用例 1: 文件读取工具
**输入命令:**
```
请读取 package.json 文件的内容，并告诉我项目名称
```

**预期结果:**
- ✅ Cline 使用 `read_file` 工具
- ✅ 显示项目名称为 "claude-dev"
- ✅ 无错误信息

---

## 测试用例 2: 文件创建工具
**输入命令:**
```
在项目根目录创建一个 test-hello.txt 文件，内容是 "Hello from Cline test!"
```

**预期结果:**
- ✅ Cline 使用 `create_file` 工具
- ✅ 文件创建成功
- ✅ 可以在文件浏览器中看到 test-hello.txt

**验证命令:**
```bash
cat test-hello.txt
```

---

## 测试用例 3: 文件编辑工具
**输入命令:**
```
在 test-hello.txt 文件末尾添加一行 "Test completed!"
```

**预期结果:**
- ✅ Cline 使用 `replace_string_in_file` 工具
- ✅ 文件内容更新成功

**验证命令:**
```bash
cat test-hello.txt
```

---

## 测试用例 4: 目录列表工具
**输入命令:**
```
列出 src/core 目录下的所有文件和文件夹
```

**预期结果:**
- ✅ Cline 使用 `list_dir` 工具
- ✅ 显示目录结构（应包含 task, prompts 等子目录）

---

## 测试用例 5: 文件搜索工具
**输入命令:**
```
搜索所有 TypeScript 配置文件（tsconfig*.json）
```

**预期结果:**
- ✅ Cline 使用 `file_search` 工具
- ✅ 找到 tsconfig.json, tsconfig.test.json 等文件

---

## 测试用例 6: 终端命令执行
**输入命令:**
```
运行命令 node --version 查看 Node.js 版本
```

**预期结果:**
- ✅ Cline 使用 `run_in_terminal` 工具
- ✅ 显示 Node.js 版本号
- ✅ 命令执行成功（Exit Code: 0）

---

## 测试用例 7: Git 状态检查
**输入命令:**
```
查看当前 git 仓库的状态
```

**预期结果:**
- ✅ Cline 使用 `mcp_gitkraken_git_status` 或 `get_changed_files`
- ✅ 显示当前分支和修改文件
- ✅ 应该能看到 test-hello.txt 为未追踪文件

---

## 测试用例 8: 代码搜索
**输入命令:**
```
在代码中搜索 "ToolExecutor" 类的定义位置
```

**预期结果:**
- ✅ Cline 使用 `semantic_search` 或 `grep_search` 工具
- ✅ 找到 src/core/task/ToolExecutor.ts 文件
- ✅ 显示相关代码片段

---

## 测试用例 9: 错误诊断
**输入命令:**
```
检查项目中是否有编译错误
```

**预期结果:**
- ✅ Cline 使用 `get_errors` 工具
- ✅ 显示 "No errors found" 或列出具体错误

---

## 测试用例 10: 多步骤任务
**输入命令:**
```
创建一个简单的 TypeScript 函数文件 src/test-utils.ts，包含一个 add 函数（两数相加），然后读取这个文件确认创建成功
```

**预期结果:**
- ✅ Cline 分步执行多个工具
- ✅ 使用 `create_file` 创建文件
- ✅ 使用 `read_file` 验证文件
- ✅ 文件内容正确

---

## 测试用例 11: Git 分支操作
**输入命令:**
```
列出所有 git 分支
```

**预期结果:**
- ✅ Cline 使用 `mcp_gitkraken_git_branch` 工具
- ✅ 显示分支列表（至少有 main 分支）

---

## 测试用例 12: 复杂文件编辑
**输入命令:**
```
在 package.json 中添加一个新的 npm script: "test:integration": "echo 'Integration test'"
```

**预期结果:**
- ✅ Cline 先读取 package.json
- ✅ 使用 `replace_string_in_file` 精确编辑
- ✅ 保持 JSON 格式正确
- ✅ 不破坏其他配置

**验证命令:**
```bash
npm run test:integration
```

---

## CLI 功能测试

### 测试 CLI 编译和运行
```bash
# 设置环境变量
export PATH="$PATH:/Users/liubo/go/bin"

# 进入 CLI 目录
cd /Users/liubo/Downloads/resposity-project/project/cline_self/cli

# 测试编译
go build -v ./cmd/cline

# 查看帮助
./cline --help

# 查看版本
./cline version

# 列出实例（如果有运行的话）
./cline instances list

# 启动新实例
./cline instances start --port 50051

# 查看实例状态
./cline instances list

# 停止实例
./cline instances kill localhost:50051
```

---

## 自动化测试脚本

### 运行单元测试
```bash
cd /Users/liubo/Downloads/resposity-project/project/cline_self
npm test
```

### 运行 E2E 测试（如果有）
```bash
cd /Users/liubo/Downloads/resposity-project/project/cline_self
npm run test:e2e
```

### 运行 Playwright 测试
```bash
cd /Users/liubo/Downloads/resposity-project/project/cline_self
npx playwright test
```

---

## Go CLI 单元测试
```bash
cd /Users/liubo/Downloads/resposity-project/project/cline_self/cli

# 运行所有测试
go test ./...

# 运行带详细输出的测试
go test -v ./...

# 运行特定包的测试
go test -v ./pkg/cli/...
go test -v ./pkg/hostbridge/...

# 运行测试并显示覆盖率
go test -cover ./...
```

---

## MCP 服务器测试（可选）

如果配置了 MCP 服务器，可以测试：

### 测试文件系统 MCP
**输入命令:**
```
使用 MCP filesystem 工具读取 /tmp 目录
```

### 测试 GitHub MCP
**输入命令:**
```
使用 GitHub MCP 获取某个仓库的 issues
```

---

## Debug Console 检查项

在原 VS Code 窗口的 Debug Console 中应该看到：

✅ 扩展激活日志
✅ 工具执行日志
✅ gRPC 连接日志
✅ 无错误或警告

---

## 常见问题排查

### 如果工具不执行
1. 检查 Debug Console 是否有错误
2. 确认 watch 进程正在运行
3. 重新按 F5 重启扩展

### 如果 Git 工具不工作
1. 确认项目是 git 仓库
2. 检查是否安装了 GitKraken MCP
3. 尝试使用 `get_changed_files` 工具

### 如果终端命令失败
1. 检查命令是否在 PATH 中
2. 确认权限设置
3. 查看终端输出的错误信息

---

## 测试完成清理

```bash
# 删除测试文件
rm test-hello.txt
rm src/test-utils.ts

# 恢复 package.json（如果修改了）
git checkout package.json

# 或者保留修改并提交
git add .
git commit -m "Add test files"
```

---

## 预期最终状态

✅ 所有 12 个基础测试用例通过
✅ CLI 命令正常工作
✅ 无编译错误
✅ Debug Console 无严重错误
✅ 扩展可以正常与 AI 对话并执行工具
