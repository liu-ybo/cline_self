#!/usr/bin/env node

import fs from "fs/promises"
import os from "os"
import path from "path"

async function findAllGlobalStoragePaths() {
	console.log("🔍 查找所有 VS Code globalStorage 路径\n")

	const possiblePaths = [
		// 正常 VS Code
		path.join(os.homedir(), "Library", "Application Support", "Code", "User", "globalStorage", "saoudrizwan.claude-dev"),
		// VS Code Insiders
		path.join(
			os.homedir(),
			"Library",
			"Application Support",
			"Code - Insiders",
			"User",
			"globalStorage",
			"saoudrizwan.claude-dev",
		),
		// Extension Development Host
		path.join(os.homedir(), "Library", "Application Support", "Code", "User", "workspaceStorage"),
		// Linux
		path.join(os.homedir(), ".config", "Code", "User", "globalStorage", "saoudrizwan.claude-dev"),
		// Windows
		path.join(os.homedir(), "AppData", "Roaming", "Code", "User", "globalStorage", "saoudrizwan.claude-dev"),
	]

	console.log("📂 搜索路径:\n")

	for (const storagePath of possiblePaths) {
		try {
			const exists = await fs
				.stat(storagePath)
				.then(() => true)
				.catch(() => false)
			if (exists) {
				console.log(`✅ ${storagePath}`)

				// 检查是否有 taskHistory.json
				const taskHistoryPath = path.join(storagePath, "state", "taskHistory.json")
				const hasHistory = await fs
					.stat(taskHistoryPath)
					.then(() => true)
					.catch(() => false)

				if (hasHistory) {
					const content = await fs.readFile(taskHistoryPath, "utf-8")
					const history = JSON.parse(content)
					console.log(`   📊 历史记录: ${history.length} 条`)
				} else {
					console.log(`   ⚠️  无 taskHistory.json`)
				}
			} else {
				console.log(`❌ ${storagePath}`)
			}
		} catch (err) {
			console.log(`❌ ${storagePath} - ${err.message}`)
		}
	}

	// 搜索 workspaceStorage 中的扩展实例
	const workspaceStoragePath = path.join(os.homedir(), "Library", "Application Support", "Code", "User", "workspaceStorage")
	console.log(`\n📁 搜索 workspaceStorage: ${workspaceStoragePath}\n`)

	try {
		const workspaceFolders = await fs.readdir(workspaceStoragePath)

		for (const folder of workspaceFolders) {
			const stateJsonPath = path.join(workspaceStoragePath, folder, "state.vscdb")
			try {
				const stateContent = await fs.readFile(stateJsonPath, "utf-8")
				if (stateContent.includes("saoudrizwan.claude-dev")) {
					console.log(`✅ 找到扩展工作区: ${folder}`)

					// 检查这个工作区的 globalState
					const globalStoragePath = path.join(workspaceStoragePath, folder, "globalState")
					const hasGlobalState = await fs
						.stat(globalStoragePath)
						.then(() => true)
						.catch(() => false)

					if (hasGlobalState) {
						console.log(`   📦 有 globalState 目录`)
					}
				}
			} catch (_err) {
				// 跳过无法读取的文件
			}
		}
	} catch (err) {
		console.log(`❌ 无法访问 workspaceStorage: ${err.message}`)
	}
}

findAllGlobalStoragePaths().catch((err) => {
	console.error("❌ 脚本执行失败:", err)
	process.exit(1)
})
