import fs from "fs"
import path from "path"

// Simple simulation of a read_file tool invocation using repo defaults
const repoRoot = path.resolve(new URL(import.meta.url).pathname, "..", "..")
const targetRelPathArg = process.argv[2] || "src/core/task/ToolExecutor.ts"
const targetRelPath = targetRelPathArg
const absoluteTarget = path.resolve(repoRoot, targetRelPath)

console.log(`Simulating read_file for: ${targetRelPath}`)
console.log(`Repo root: ${repoRoot}`)

// DEFAULT_AUTO_APPROVAL_SETTINGS (copied from src/shared/AutoApprovalSettings.ts)
const DEFAULT_AUTO_APPROVAL_SETTINGS = {
	version: 1,
	enabled: true,
	favorites: [],
	maxRequests: 20,
	actions: {
		readFiles: true,
		readFilesExternally: false,
		editFiles: false,
		editFilesExternally: false,
		executeSafeCommands: true,
		executeAllCommands: false,
		useBrowser: false,
		useMcp: true,
	},
	enableNotifications: false,
}

console.log("\nStep 1: Is tool registered?")
console.log(" - Tool name: read_file (handled by ReadFileToolHandler) — registered in ToolExecutor.registerToolHandlers")

console.log("\nStep 2: Plan-mode check")
console.log(" - Using default settings: assume not in strict plan mode for simulation")

console.log("\nStep 3: Auto-approve decision (AutoApprove.shouldAutoApproveToolWithPath)")
// Determine if path is in workspace (simple heuristic)
function isLocatedInPath(dirPath, pathToCheck) {
	const relative = path.relative(dirPath, pathToCheck)
	if (!relative) {
		return false
	}
	if (relative.startsWith("..")) {
		return false
	}
	if (path.isAbsolute(relative)) {
		return false
	}
	return true
}

const cwd = repoRoot // simulate workspace root
const isLocal = isLocatedInPath(cwd, absoluteTarget)
console.log(` - Is path inside workspace? ${isLocal}`)
const autoApproval = DEFAULT_AUTO_APPROVAL_SETTINGS.actions.readFiles
const autoApprovalExternal = DEFAULT_AUTO_APPROVAL_SETTINGS.actions.readFilesExternally || false
let willAutoApprove = false
if (isLocal && autoApproval) {
	willAutoApprove = true
}
if (!isLocal && autoApproval && autoApprovalExternal) {
	willAutoApprove = true
}
console.log(` - autoApprovalSettings.readFiles = ${autoApproval}`)
console.log(` - autoApprovalSettings.readFilesExternally = ${autoApprovalExternal}`)
console.log(` => Auto-approved? ${willAutoApprove}`)

console.log("\nStep 4: .clineignore path check (ToolValidator.checkClineIgnorePath)")
const clineIgnorePath = path.join(repoRoot, ".clineignore")
let clineIgnoreBlocked = false
if (fs.existsSync(clineIgnorePath)) {
	const lines = fs
		.readFileSync(clineIgnorePath, "utf8")
		.split(/\r?\n/)
		.map((l) => l.trim())
		.filter((l) => l && !l.startsWith("#"))
	console.log(` - .clineignore lines: ${lines.length}`)
	for (const rule of lines) {
		// simple prefix match heuristic for simulation
		if (targetRelPath.startsWith(rule) || targetRelPath.includes(rule)) {
			clineIgnoreBlocked = true
			console.log(` - Matched rule: ${rule} -> ACCESS BLOCKED`)
			break
		}
	}
} else {
	console.log(" - No .clineignore found — no path blocking")
}
console.log(` => Path blocked by .clineignore? ${clineIgnoreBlocked}`)

console.log("\nStep 5: If not auto-approved, show approval UI (ask). Simulating user decision...")
let userAllowed = true
if (!willAutoApprove) {
	// Simulate user pressing allow
	userAllowed = true
	console.log(" - User prompted; simulated pressing Allow")
} else {
	console.log(" - Skipped user prompt because auto-approved")
}

console.log("\nStep 6: PreToolUse hook (ToolHookUtils.runPreToolUseIfEnabled)")
console.log(" - Hooks enabled? (assume true for simulation) -> execute PreToolUse hook")
console.log(
	" - For this simulation we do NOT run the actual hook executor; assume hook returns { cancel: false, contextModification: undefined }",
)
const preHookCancelled = false
console.log(` => PreToolUse canceled? ${preHookCancelled}`)

console.log("\nStep 7: Execute tool handler (ReadFileToolHandler)")
if (clineIgnoreBlocked) {
	console.log(" - Aborting execution: path is blocked by .clineignore")
} else if (!userAllowed) {
	console.log(" - Aborting execution: user denied approval")
} else if (preHookCancelled) {
	console.log(" - Aborting execution: PreToolUse hook canceled")
} else {
	console.log(` - Reading file at: ${absoluteTarget}`)
	if (fs.existsSync(absoluteTarget)) {
		const content = fs.readFileSync(absoluteTarget, "utf8")
		console.log(" - Read succeeded. First 300 chars:")
		console.log(content.slice(0, 300).replace(/\n/g, "\n"))
	} else {
		console.log(" - File does not exist — handler would report error to user")
	}
}

console.log("\nStep 8: PostToolUse hook (observe)")
console.log(" - For simulation assume PostToolUse returns { cancel: false }")

console.log("\nSimulation complete.")
