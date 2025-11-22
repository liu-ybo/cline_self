#!/usr/bin/env node

import fs from "fs/promises"
import os from "os"
import path from "path"

async function debugTaskHistory() {
	console.log("🔍 调试 Cline 历史记录功能\n")

	// 1. 检查 VS Code 存储路径
	const vscodeDir = path.join(os.homedir(), ".vscode")
	console.log("1️⃣ VS Code 目录:", vscodeDir)

	try {
		const vscodeDirExists = await fs
			.stat(vscodeDir)
			.then(() => true)
			.catch(() => false)
		console.log("   目录存在:", vscodeDirExists ? "✅" : "❌")
	} catch (err) {
		console.log("   无法访问:", err.message)
	}

	// 2. 查找 globalStorage
	const globalStoragePaths = [
		path.join(vscodeDir, "globalStorage", "saoudrizwan.claude-dev"),
		path.join(os.homedir(), "Library", "Application Support", "Code", "User", "globalStorage", "saoudrizwan.claude-dev"),
		path.join(os.homedir(), ".config", "Code", "User", "globalStorage", "saoudrizwan.claude-dev"),
	]

	console.log("\n2️⃣ 搜索 globalStorage 路径:")
	let foundStoragePath = null

	for (const storagePath of globalStoragePaths) {
		try {
			const exists = await fs
				.stat(storagePath)
				.then(() => true)
				.catch(() => false)
			console.log(`   ${storagePath}: ${exists ? "✅ 存在" : "❌ 不存在"}`)
			if (exists && !foundStoragePath) {
				foundStoragePath = storagePath
			}
		} catch (err) {
			console.log(`   ${storagePath}: ❌ 错误 - ${err.message}`)
		}
	}

	if (!foundStoragePath) {
		console.log("\n❌ 未找到任何存储路径")
		console.log("\n💡 提示: Extension Development Host 使用不同的路径")
		console.log("   尝试运行一次完整的对话任务后再检查")
		return
	}

	// 3. 检查 taskHistory.json
	const taskHistoryFile = path.join(foundStoragePath, "state", "taskHistory.json")
	console.log("\n3️⃣ 任务历史文件:", taskHistoryFile)

	try {
		const fileExists = await fs
			.stat(taskHistoryFile)
			.then(() => true)
			.catch(() => false)
		console.log("   文件存在:", fileExists ? "✅" : "❌")

		if (fileExists) {
			const content = await fs.readFile(taskHistoryFile, "utf-8")
			const history = JSON.parse(content)
			console.log("   任务数量:", history.length)

			if (history.length > 0) {
				console.log("\n📊 历史记录样例:")
				const latest = history[history.length - 1]
				console.log("   ID:", latest.id)
				console.log("   任务:", latest.task.substring(0, 100) + (latest.task.length > 100 ? "..." : ""))
				console.log("   时间:", new Date(latest.ts).toLocaleString())
				console.log("   Token (输入/输出):", latest.tokensIn, "/", latest.tokensOut)
				console.log("   成本: $", latest.totalCost?.toFixed(4) || "0")
			} else {
				console.log("\n⚠️  历史记录为空")
				console.log("   原因: 还没有完成任何任务")
			}
		}
	} catch (err) {
		console.log("   错误:", err.message)
	}

	// 4. 检查 tasks 目录
	const tasksDir = path.join(foundStoragePath, "tasks")
	console.log("\n4️⃣ 任务详情目录:", tasksDir)

	try {
		const tasksDirExists = await fs
			.stat(tasksDir)
			.then(() => true)
			.catch(() => false)
		console.log("   目录存在:", tasksDirExists ? "✅" : "❌")

		if (tasksDirExists) {
			const taskFolders = await fs.readdir(tasksDir)
			console.log("   任务文件夹数:", taskFolders.length)

			if (taskFolders.length > 0) {
				console.log("\n   最近的任务文件夹:")
				for (const folder of taskFolders.slice(-3)) {
					const folderPath = path.join(tasksDir, folder)
					const stat = await fs.stat(folderPath)
					if (stat.isDirectory()) {
						const files = await fs.readdir(folderPath)
						console.log(`   - ${folder}: ${files.length} 个文件`)
						console.log(`     文件: ${files.join(", ")}`)
					}
				}
			}
		}
	} catch (err) {
		console.log("   错误:", err.message)
	}

	// 5. 给出建议
	console.log("\n💡 建议:")
	console.log("   1. 在 Extension Development Host 中创建一个新任务")
	console.log("   2. 完整完成一次对话（直到任务结束）")
	console.log("   3. 点击 History 按钮查看记录")
	console.log("   4. 如果还是看不到，重新运行此脚本检查文件")
}

debugTaskHistory().catch((err) => {
	console.error("❌ 脚本执行失败:", err)
	process.exit(1)
})
