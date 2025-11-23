# Tool Permissions Flow

```mermaid
flowchart TD
  Start[Tool message arrives] --> Registered{Tool registered?}
  Registered -- No --> Unhandled[Return unhandled tool]
  Registered -- Yes --> Load[Load TaskConfig]
  Load --> Partial{Partial stream?}
  Partial -- Yes --> PartialUI[handlePartialBlock and update UI]
  Partial -- No --> PlanCheck{Plan mode restricted?}
  PlanCheck -- Yes --> PlanDenied[Push error and checkpoint]
  PlanCheck -- No --> AutoApprove[Check AutoApprove settings]
  AutoApprove --> Approved{Auto approved?}
  Approved -- Yes --> Validator[Run validator]
  Approved -- No --> Prompt[Show approval UI]
  Prompt --> Decision{User allowed?}
  Decision -- No --> Denied[Push denied response and revert changes]
  Decision -- Yes --> Validator
  Validator --> ClineCheck{ClineIgnore blocked?}
  ClineCheck -- Yes --> ClineDenied[Abort tool]
  ClineCheck -- No --> PreHook[Run PreToolUse hook]
  PreHook --> HookCancel{Hook canceled?}
  HookCancel -- Yes --> HookAbort[Cancel task]
  HookCancel -- No --> Execute[Handler executes tool]
  Execute --> PushResult[Push tool result]
  PushResult --> PostHook[PostToolUse hook]
  PostHook --> PostCancel{Post hook cancel?}
  PostCancel -- Yes --> CancelTask[Cancel task]
  PostCancel -- No --> Done[Telemetry and checkpoint]

  subgraph MCP
    MCPFetch[Fetch MCP tools] --> MergeAuto[Merge MCP autoApprove]
    MergeAuto --> AutoApprove
    ToggleAuto[Toggle MCP autoApprove] --> MergeAuto
  end