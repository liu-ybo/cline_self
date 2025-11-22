# 🎯 VS Code 内快速测试指南

## 启动测试环境

**按 F5** 启动 Extension Development Host

---

## ✅ 5 分钟快速测试清单

### 1️⃣ 基础对话测试（30秒）
在 Cline 侧边栏输入：
```
你好，请介绍一下你自己
```
**预期**: 正常回复，无错误

---

### 2️⃣ 文件读取测试（30秒）
```
读取 package.json 并告诉我项目名称
```
**预期**: 使用 `read_file` 工具，返回 "claude-dev"

---

### 3️⃣ 文件创建测试（1分钟）
```
创建一个文件 test.txt，内容是当前时间
```
**预期**: 
- ✅ 使用 `create_file` 工具
- ✅ 文件出现在文件浏览器
- ✅ 内容正确

---

### 4️⃣ 终端命令测试（30秒）
```
运行 ls -la 命令
```
**预期**:
- ✅ 使用 `run_in_terminal` 工具
- ✅ 显示文件列表
- ✅ Exit code: 0

---

### 5️⃣ Git 状态测试（30秒）
```
查看 git 状态
```
**预期**:
- ✅ 使用 Git 工具
- ✅ 显示当前分支和修改文件
- ✅ 看到 test.txt 为未追踪文件

---

### 6️⃣ 代码搜索测试（1分钟）
```
搜索 ToolExecutor 类在哪个文件
```
**预期**:
- ✅ 使用 `semantic_search` 或 `grep_search`
- ✅ 找到 src/core/task/ToolExecutor.ts
- ✅ 显示相关代码

---

### 7️⃣ 错误检查测试（30秒）
```
检查项目是否有编译错误
```
**预期**:
- ✅ 使用 `get_errors` 工具
- ✅ 返回 "No errors found"

---

### 8️⃣ 复杂任务测试（2分钟）
```
创建一个 TypeScript 函数文件 src/utils/math.ts，包含 add(a, b) 和 multiply(a, b) 两个函数，然后读取验证
```
**预期**:
- ✅ 创建文件
- ✅ 代码格式正确
- ✅ 验证成功

---

## 🔍 Debug Console 检查

在原 VS Code 窗口的 Debug Console 中检查：

✅ **正常日志示例**:
```
[Extension Host] Extension activated
[Cline] Tool: read_file - /path/to/package.json
[Cline] Tool: create_file - test.txt
[Cline] Tool: run_in_terminal - ls -la
```

❌ **错误示例**（需要修复）:
```
Error: Cannot read file
Error: Tool execution failed
TypeError: undefined is not a function
```

---

## 📊 测试结果评估

### ✅ 全部通过
- 所有 8 个测试都成功
- Debug Console 无错误
- **结论**: 项目完全正常！

### ⚠️ 部分通过（5-7 个成功）
- 大部分功能正常
- 个别工具有问题
- **建议**: 查看 Debug Console 找出具体问题

### ❌ 多数失败（< 5 个成功）
- 核心功能有问题
- **建议**: 
  1. 检查 Problems 面板
  2. 重启 watch 进程
  3. 重新按 F5

---

## 🧹 测试完成后清理

```bash
# 删除测试文件
rm test.txt
rm src/utils/math.ts

# 或者提交测试结果
git add test.txt
git commit -m "Test: Verify Cline functionality"
```

---

## 💡 提示

- 如果某个工具失败，尝试重新提问
- Debug Console 是排查问题的最佳工具
- 可以在 Cline 对话中直接问："为什么这个工具失败了？"
- Cline 会尝试自动修复大多数问题

---

## 🚀 高级测试（可选）

完成基础测试后，可以尝试：

1. **MCP 集成测试**（需要配置 MCP 服务器）
2. **多文件编辑测试**
3. **Git 分支操作测试**
4. **长对话测试**（测试上下文保持）
5. **错误恢复测试**（故意提供错误命令）

---

## 测试通过标准

✅ 8/8 测试通过 = **完美！**  
✅ 6-7/8 测试通过 = **良好**  
⚠️ 4-5/8 测试通过 = **需要改进**  
❌ < 4/8 测试通过 = **有严重问题**
