param(
    [switch]$Uninstall,
    [string]$KimiCodeHome = "$env:USERPROFILE\.kimi-code",
    [string]$Repo = "saltyming/kimi-agent-kit",
    [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"

$RawBase = "https://raw.githubusercontent.com/$Repo/$Branch"
$AgentsFile = Join-Path $KimiCodeHome "AGENTS.md"
$RulesDir = Join-Path $KimiCodeHome "rules"
$SkillsDir = Join-Path $KimiCodeHome "skills"
$Manifest = Join-Path $KimiCodeHome ".kimi-agent-kit-manifest"

$RuleFiles = @(
    "kimi-agent-kit--task-execution.md",
    "kimi-agent-kit--palette.md",
    "kimi-agent-kit--delegation.md",
    "kimi-agent-kit--git-workflow.md",
    "kimi-agent-kit--framework-conventions.md",
    "kimi-agent-kit--aside.md",
    "kimi-agent-kit--dispatch.md"
)

$SkillNames = @("palette-init", "palette-rules", "palette-spec", "palette-ui", "palette-ux")

function Fetch([string]$Url, [string]$Dest) {
    Invoke-WebRequest -Uri $Url -OutFile $Dest
}

if ($Uninstall) {
    if (-not (Test-Path $Manifest)) {
        Write-Host "No manifest at $Manifest. Nothing to uninstall."
        return
    }
    Get-Content $Manifest | ForEach-Object {
        if ($_ -match "^## ") { return }
        if (Test-Path $_ -PathType Container) {
            Remove-Item $_ -Recurse -Force
            Write-Host "  removed $_"
        } elseif (Test-Path $_ -PathType Leaf) {
            Remove-Item $_ -Force
            Write-Host "  removed $_"
        }
    }
    Remove-Item $Manifest -Force
    Write-Host "Uninstalled."
    return
}

Write-Host "Installing kimi-agent-kit..."
Write-Host "  KIMI_CODE_HOME: $KimiCodeHome"

New-Item -ItemType Directory -Force -Path $KimiCodeHome, $RulesDir, $SkillsDir | Out-Null
"## install @ $((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))" | Set-Content -Path $Manifest

Fetch "$RawBase/AGENTS.md" $AgentsFile
Add-Content -Path $Manifest -Value $AgentsFile
Write-Host "  wrote $AgentsFile"

foreach ($f in $RuleFiles) {
    $dest = Join-Path $RulesDir $f
    Fetch "$RawBase/kimi-rules/$f" $dest
    Add-Content -Path $Manifest -Value $dest
    Write-Host "  rule: $dest"
}

foreach ($s in $SkillNames) {
    $dest = Join-Path $SkillsDir $s
    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Fetch "$RawBase/kimi-skills/$s/SKILL.md" (Join-Path $dest "SKILL.md")
    Add-Content -Path $Manifest -Value $dest
    Write-Host "  skill: $dest"
}

Write-Host ""
Write-Host "Installed kimi-agent-kit."
Write-Host "Manifest: $Manifest"
