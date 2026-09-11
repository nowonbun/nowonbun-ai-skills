# 읽기 전용 정형 검사. 의미 검토와 본문 보존 검증은 호출자가 수행한다.
[CmdletBinding(DefaultParameterSetName = 'Files')]
param(
    [Parameter(Mandatory, ParameterSetName = 'Files')][string[]]$Paths,
    [Parameter(Mandatory, ParameterSetName = 'All')][switch]$All,
    [Parameter(Mandatory, ParameterSetName = 'SelfTest')][switch]$SelfTest
)
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$utf8 = [Text.UTF8Encoding]::new($false, $true)

function Assert-SafePath([string]$Path) {
    $full = [IO.Path]::GetFullPath($Path)
    if ($full -ne $root -and -not $full.StartsWith($root + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        throw "범위 밖 경로: $full"
    }
    # 상위 경로부터 확인하여 junction 아래에 접근하지 않는다.
    $chain = [Collections.Generic.Stack[string]]::new()
    $part = $full
    while ($part) { $chain.Push($part); $part = [IO.Path]::GetDirectoryName($part) }
    foreach ($part in $chain) {
        $item = Get-Item -LiteralPath $part -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "링크 경로 거부: $part" }
    }
    return $full
}

function Get-DocumentIssues([string]$Text, [bool]$IsSkill) {
    $lines = $Text -split '\r?\n'
    if ($Text.Contains([string][char]0xFFFD)) { '1: UTF-8 대체 문자 발견' }
    if ($IsSkill) {
        if ($Text -cnotmatch '\A\uFEFF?---\r?\nname: ([a-z0-9-]{1,64})\r?\ndescription: ([^\r\n]+)\r?\n---(?:\r?\n|$)') {
            '1: frontmatter 형식 오류 (name, description 순서의 단순 스칼라 형식 필요)'
        }
        foreach ($heading in @('Must', 'Must NOT', 'Definition of Done')) {
            if ($lines -cnotcontains "# $heading") { "1: 필수 H1 누락: $heading" }
        }
        if (-not ($lines | Where-Object { $_ -match '^# .+' -and $_ -notin @('# Must', '# Must NOT', '# Flow', '# Definition of Done') })) {
            '1: 문서 제목 H1 누락'
        }
    }
    $fence = ''; $start = 0
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\s{0,3}(`{3,}|~{3,})(.*)$') {
            $mark = $Matches[1]; $tail = $Matches[2]
            if (-not $fence) { $fence = $mark; $start = $i + 1 }
            elseif ($mark[0] -eq $fence[0] -and $mark.Length -ge $fence.Length -and -not $tail.Trim()) { $fence = '' }
        }
    }
    if ($fence) { "${start}: 닫히지 않은 코드 펜스" }
}

function Get-LocalReferences([string]$Text) {
    # 의도적으로 제한된 문법: 일반 문장과 코드 블록의 예시는 추측하지 않는다.
    $fence = ''
    $lines = $Text -split '\r?\n'
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match '^\s{0,3}(`{3,}|~{3,})(.*)$') {
            $mark = $Matches[1]; $tail = $Matches[2]
            if (-not $fence) { $fence = $mark }
            elseif ($mark[0] -eq $fence[0] -and $mark.Length -ge $fence.Length -and -not $tail.Trim()) { $fence = '' }
            continue
        }
        if ($fence) { continue }
        $pattern = '`(?<path>\.\.?/[^`\r\n]+)`|\]\((?<path>[^\s()]+)\)'
        foreach ($match in [regex]::Matches($line, $pattern)) {
            $ref = $match.Groups['path'].Value
            if ($ref -match '^(?:[a-zA-Z][a-zA-Z0-9+.-]*:|#|/|\\)' -or $ref -match '[<>*{}]') { continue }
            $ref = ($ref -split '#', 2)[0]
            if ($ref) { [pscustomobject]@{ Path = [Uri]::UnescapeDataString($ref); Line = $i + 1 } }
        }
    }
}

try {
    $null = Assert-SafePath $root
    if ($SelfTest) {
        $valid = "---`nname: sample`ndescription: 검사 예시`n---`n# Sample`n# Must`n# Must NOT`n# Definition of Done`n"
        if (@(Get-DocumentIssues $valid $true).Count) { throw '정상 문서 오탐' }
        if (-not @(Get-DocumentIssues ($valid.Replace('name: sample', 'name: INVALID')) $true).Count) { throw '잘못된 이름 미탐' }
        if (-not @(Get-DocumentIssues ($valid.Replace('# Must NOT', '')) $true).Count) { throw '필수 제목 누락 미탐' }
        if (-not @(Get-DocumentIssues ($valid + '```ps1') $true).Count) { throw '열린 펜스 미탐' }
        if (@(Get-DocumentIssues ($valid + "~~~ps1`ntext`n~~~") $true).Count) { throw '닫힌 펜스 오탐' }
        if (-not @(Get-DocumentIssues ($valid + [char]0xFFFD) $true).Count) { throw '대체 문자 미탐' }
        $rejected = $false
        try { $null = $utf8.GetString([byte[]]@(0xC3, 0x28)) } catch { $rejected = $true }
        if (-not $rejected) { throw '잘못된 UTF-8 미탐' }
        $rejected = $false
        try { $null = Assert-SafePath ([IO.Path]::GetDirectoryName($root)) } catch { $rejected = $true }
        if (-not $rejected) { throw '범위 이탈 미탐' }
        $refs = @(Get-LocalReferences '[로컬](./SKILL.md#scope) `../other/SKILL.md` [웹](https://example.com)')
        if ($refs.Count -ne 2 -or $refs[0].Path -ne './SKILL.md') { throw '참조 추출 오류' }
        if (@(Get-LocalReferences "``````text`n[예시](./missing.md)`n``````").Count) { throw '코드 예시 참조 오탐' }
        $ref = @(Get-LocalReferences '[검사기](./validate-skills.ps1)')[0]
        $null = Assert-SafePath (Join-Path $PSScriptRoot $ref.Path)
        $rejected = $false
        $ref = @(Get-LocalReferences '[누락](./__missing_validation_reference__.md)')[0]
        try { $null = Assert-SafePath (Join-Path $PSScriptRoot $ref.Path) } catch { $rejected = $true }
        if (-not $rejected) { throw '누락된 참조 미탐' }
        Write-Output 'PASS: 12개 자체 검사 (파일 쓰기 없음)'
        exit 0
    }
    $files = [Collections.Generic.List[string]]::new()
    if ($All) {
        $queue = [Collections.Generic.Queue[string]]::new(); $queue.Enqueue($root)
        while ($queue.Count) {
            $dir = Assert-SafePath $queue.Dequeue()
            foreach ($item in Get-ChildItem -LiteralPath $dir -Force) {
                if ($item.PSIsContainer -and $item.Name -match '^(?:\..*|backup.*|history|tests?|worktrees?|examples?)$') { continue }
                $safe = Assert-SafePath $item.FullName
                if ($item.PSIsContainer) { $queue.Enqueue($safe) }
                elseif ($item.Extension -eq '.md') { $files.Add($safe) }
            }
        }
    } else {
        foreach ($path in $Paths) {
            $absolute = if ([IO.Path]::IsPathRooted($path)) { $path } else { Join-Path (Get-Location).Path $path }
            $full = Assert-SafePath ([IO.Path]::GetFullPath($absolute))
            if ([IO.Path]::GetExtension($full) -ne '.md' -or (Get-Item -LiteralPath $full).PSIsContainer) { throw "Markdown 파일 필요: $full" }
            $files.Add($full)
        }
    }
    $failures = 0; $count = 0
    $manifest = [Text.StringBuilder]::new()
    foreach ($file in ($files | Sort-Object -Unique)) {
        $count++
        $bytes = [IO.File]::ReadAllBytes($file)
        try { $text = $utf8.GetString($bytes) } catch { Write-Output "${file}:1: UTF-8 디코딩 실패"; $failures++; continue }
        foreach ($issue in @(Get-DocumentIssues $text ([IO.Path]::GetFileName($file) -eq 'SKILL.md'))) {
            Write-Output "${file}:$issue"; $failures++
        }
        foreach ($ref in @(Get-LocalReferences $text)) {
            try { $null = Assert-SafePath ([IO.Path]::GetFullPath((Join-Path ([IO.Path]::GetDirectoryName($file)) $ref.Path))) }
            catch { Write-Output "${file}:$($ref.Line): 참조 확인 실패: $($ref.Path) ($($_.Exception.Message))"; $failures++ }
        }
        $sha = [Security.Cryptography.SHA256]::Create()
        try { $hash = [BitConverter]::ToString($sha.ComputeHash($bytes)).Replace('-', '').ToLowerInvariant() } finally { $sha.Dispose() }
        $null = $manifest.AppendLine("$hash $file")
    }
    $sha = [Security.Cryptography.SHA256]::Create()
    try { $scopeHash = [BitConverter]::ToString($sha.ComputeHash($utf8.GetBytes($manifest.ToString()))).Replace('-', '').ToLowerInvariant() } finally { $sha.Dispose() }
    Write-Output "검사 집합 SHA256=$scopeHash"
    Write-Output "검사 파일=$count 실패=$failures; 의미 검토 및 본문 보존은 별도 검증 필요"
    if ($failures) { exit 1 }
    exit 0
} catch {
    Write-Output "검사 중지: $($_.Exception.Message)"
    exit 1
}
