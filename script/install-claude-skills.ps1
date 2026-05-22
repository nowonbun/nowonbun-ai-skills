param(
    [string]$TargetDir,
    [string]$SourceRoot,
    [string]$SkillSourceDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
[Console]::InputEncoding = New-Object System.Text.UTF8Encoding $false
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
$OutputEncoding = New-Object System.Text.UTF8Encoding $false

# ===== 설정 =====
# - SourceRoot: 저장소 루트 경로
#   예) D:\work\nowonbun-harness
# - SkillSourceDir: SourceRoot 기준 스킬 원본 폴더(기본값 claude-skills)
#   예) claude-skills
# - 하위 폴더를 포함한 모든 .md 파일을 스킬로 간주한다.
#   예) claude-skills\test1\test2\abc.md
#     -> .claude\skills\test1_test2_abc\SKILL.md
# - TargetDir: .claude 디렉터리의 상위 루트
#   예) C:\Users\nowonbun
$DefaultTargetDir = "C:\Users\nowonbun\"
$DefaultSourceRoot = "D:\work\nowonbun-harness"
$DefaultSkillSourceDir = "claude-skills"

if (-not $PSBoundParameters.ContainsKey("TargetDir")) {
    $TargetDir = $DefaultTargetDir
}

if (-not $PSBoundParameters.ContainsKey("SourceRoot")) {
    $SourceRoot = $DefaultSourceRoot
}

if (-not $PSBoundParameters.ContainsKey("SkillSourceDir")) {
    $SkillSourceDir = $DefaultSkillSourceDir
}

function Test-SkillSheet {
    param([Parameter(Mandatory = $true)][string]$FilePath)

    $lines = Get-Content -LiteralPath $FilePath -Encoding UTF8
    if ($lines.Count -lt 3) {
        return $false
    }

    if ($lines[0] -notmatch '^\s*---\s*$') {
        return $false
    }

    $frontmatterEnd = -1
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\s*---\s*$') {
            $frontmatterEnd = $i
            break
        }
    }

    if ($frontmatterEnd -lt 1) {
        return $false
    }

    $frontmatter = $lines[1..($frontmatterEnd - 1)]
    $hasName = $frontmatter | Where-Object { $_ -match '^\s*name\s*:\s*.+' } | Select-Object -First 1
    $hasDescription = $frontmatter | Where-Object { $_ -match '^\s*description\s*:\s*.+' } | Select-Object -First 1

    return ($null -ne $hasName -and $null -ne $hasDescription)
}

function Get-ManagedManifestPath {
    param([Parameter(Mandatory = $true)][string]$ClaudeRoot)
    return (Join-Path $ClaudeRoot "install-claude-skills.manifest.json")
}

function Get-PreviousManagedSkillNames {
    param([Parameter(Mandatory = $true)][string]$ManifestPath)

    if (-not (Test-Path -LiteralPath $ManifestPath)) {
        return @()
    }

    $raw = Get-Content -LiteralPath $ManifestPath -Raw -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return @()
    }

    $manifest = $raw | ConvertFrom-Json
    if ($null -eq $manifest -or $null -eq $manifest.skillNames) {
        return @()
    }

    return @($manifest.skillNames)
}

function Save-ManagedSkillNames {
    param(
        [Parameter(Mandatory = $true)][string]$ManifestPath,
        [Parameter(Mandatory = $true)][string[]]$SkillNames
    )

    $manifest = [pscustomobject]@{
        skillNames = @($SkillNames | Sort-Object -Unique)
    }

    $json = $manifest | ConvertTo-Json -Depth 3
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($ManifestPath, $json + [Environment]::NewLine, $utf8NoBom)
}

function Remove-StaleManagedSkillDirs {
    param(
        [Parameter(Mandatory = $true)][string]$SkillsRoot,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$PreviousSkillNames,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$CurrentSkillNames
    )

    $currentSkillNameSet = @{}
    foreach ($name in $CurrentSkillNames) {
        $currentSkillNameSet[$name] = $true
    }

    foreach ($oldName in ($PreviousSkillNames | Sort-Object -Unique)) {
        if ($currentSkillNameSet.ContainsKey($oldName)) {
            continue
        }

        $staleDir = Join-Path $SkillsRoot $oldName
        if (Test-Path -LiteralPath $staleDir) {
            $removed = $false
            for ($attempt = 1; $attempt -le 3; $attempt++) {
                try {
                    Remove-Item -LiteralPath $staleDir -Recurse -Force
                    $removed = $true
                    Write-Host "[DEL ] 이전 관리 스킬 삭제: $staleDir"
                    break
                }
                catch {
                    if ($attempt -eq 3) {
                        throw
                    }
                    Start-Sleep -Milliseconds 200
                }
            }
        }
    }
}

function Get-SkillNameFromRelativePath {
    param(
        [Parameter(Mandatory = $true)][string]$RelativePath
    )

    if ([System.IO.Path]::GetFileName($RelativePath).Equals('SKILL.md', [System.StringComparison]::OrdinalIgnoreCase)) {
        $normalizedInput = Split-Path -Path $RelativePath -Parent
    }
    else {
        $normalizedInput = [System.IO.Path]::ChangeExtension($RelativePath, $null)
    }

    $normalized = $normalizedInput -replace '[\\/]+', '_'
    $normalized = $normalized -replace '\s+', '_'
    $normalized = $normalized.Trim('_.')

    if ([string]::IsNullOrWhiteSpace($normalized)) {
        throw "스킬 이름으로 변환할 수 없는 경로입니다. relativePath=$RelativePath"
    }

    return $normalized
}

$sourceRootResolved = (Resolve-Path -LiteralPath $SourceRoot).Path

if ([System.IO.Path]::IsPathRooted($SkillSourceDir)) {
    $skillSourceRoot = (Resolve-Path -LiteralPath $SkillSourceDir).Path
}
else {
    $skillSourceRoot = Join-Path $sourceRootResolved $SkillSourceDir
}

if (-not (Test-Path -LiteralPath $skillSourceRoot)) {
    throw "스킬 원본 경로를 찾지 못했습니다. expected=$skillSourceRoot"
}

if (-not (Test-Path -LiteralPath $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

$targetDirResolved = (Resolve-Path -LiteralPath $TargetDir).Path

$claudeRoot = Join-Path $targetDirResolved ".claude"
$skillsRoot = Join-Path $claudeRoot "skills"
$manifestPath = Get-ManagedManifestPath -ClaudeRoot $claudeRoot

New-Item -ItemType Directory -Path $skillsRoot -Force | Out-Null

$skillFiles = Get-ChildItem -LiteralPath $skillSourceRoot -Recurse -File -Filter "*.md" |
    Sort-Object FullName |
    Where-Object { Test-SkillSheet -FilePath $_.FullName }

if (-not $skillFiles) {
    throw "메타(name, description)가 있는 스킬 시트를 찾지 못했습니다. skillSourceRoot=$skillSourceRoot"
}

$skillEntries = foreach ($file in $skillFiles) {
    $relativePath = $file.FullName.Substring($skillSourceRoot.Length).TrimStart('\')
    $skillName = Get-SkillNameFromRelativePath -RelativePath $relativePath

    [pscustomobject]@{
        SkillName    = $skillName
        SourcePath   = $file.FullName
        RelativePath = $relativePath
    }
}

$duplicateGroups = $skillEntries |
    Group-Object SkillName |
    Where-Object { $_.Count -gt 1 }

if ($duplicateGroups) {
    $lines = foreach ($g in $duplicateGroups) {
        $paths = ($g.Group | ForEach-Object { $_.RelativePath }) -join ", "
        "$($g.Name): $paths"
    }
    throw "중복 스킬 이름이 존재합니다.`n$($lines -join [Environment]::NewLine)"
}

$currentSkillNames = @($skillEntries | Select-Object -ExpandProperty SkillName)
$previousSkillNames = @(Get-PreviousManagedSkillNames -ManifestPath $manifestPath)
Remove-StaleManagedSkillDirs -SkillsRoot $skillsRoot -PreviousSkillNames @($previousSkillNames) -CurrentSkillNames @($currentSkillNames)

foreach ($entry in $skillEntries) {
    $skillDir = Join-Path $skillsRoot $entry.SkillName
    $skillTargetPath = Join-Path $skillDir "SKILL.md"

    New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
    Copy-Item -LiteralPath $entry.SourcePath -Destination $skillTargetPath -Force
    Write-Host "[COPY] $($entry.RelativePath) -> $skillTargetPath"
}

Save-ManagedSkillNames -ManifestPath $manifestPath -SkillNames @($currentSkillNames)

Write-Host ""
Write-Host "완료:"
Write-Host "- sourceRoot     : $sourceRootResolved"
Write-Host "- skillSourceRoot: $skillSourceRoot"
Write-Host "- targetDir      : $targetDirResolved"
Write-Host "- skillsRoot     : $skillsRoot"
