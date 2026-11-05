<#
  Dragbags Addon Updater
  Keeps Yungslaya's WoW: Forever addons up to date from GitHub.

  - Finds your WoW: Forever AddOns folder by itself (or lets you pick it).
  - Lists every addon Yungslaya publishes on GitHub (each repo's latest release .zip).
  - Updates the ones you have, installs the ones you pick.
  - Optional: checks and updates by itself every time you log in to Windows.

  It only touches addon folders that come from Yungslaya's GitHub releases.
  Old versions are kept in %LOCALAPPDATA%\DragbagsAddonUpdater\backup.

  Run modes:
    (no args)      window
    -Auto          no window: update installed addons, show a note if anything changed
    -List          print what it finds (for testing)
    -AddonsPath    use this AddOns folder instead of finding one
#>
param(
    [switch]$Auto,
    [switch]$List,
    [switch]$SelfTest,
    [string]$AddonsPath
)

$ErrorActionPreference = 'Stop'
$Owner    = 'Yungslaya'
$AppName  = 'DragbagsAddonUpdater'
$AppTitle = 'Dragbags Addon Updater'
$AppVer   = '1.0.0'
$Skip     = @('DragbagsAddonUpdater')          # repos that are not addons
$DataDir  = Join-Path $env:LOCALAPPDATA $AppName
$CfgFile  = Join-Path $DataDir 'config.json'
$LogFile  = Join-Path $DataDir 'updater.log'
$TaskName = 'Dragbags Addon Updater'

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
New-Item -ItemType Directory -Force -Path $DataDir | Out-Null

function Write-Log([string]$msg) {
    $line = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $msg
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

# ---------- settings ----------
function Get-Config {
    if (Test-Path $CfgFile) {
        try { return (Get-Content $CfgFile -Raw | ConvertFrom-Json) } catch { }
    }
    return [pscustomobject]@{ addonsPath = $null }
}
function Save-Config($cfg) {
    $cfg | ConvertTo-Json | Set-Content -Path $CfgFile -Encoding UTF8
}

# ---------- find the AddOns folder ----------
function Test-AddonsDir([string]$p) {
    return ($p -and (Test-Path $p) -and ((Split-Path $p -Leaf) -eq 'AddOns'))
}

# Accepts the WoW folder, the _forever_ folder, Interface or AddOns and returns ...\_forever_\Interface\AddOns
function Resolve-AddonsDir([string]$p) {
    if (-not $p) { return $null }
    $p = $p.TrimEnd('\')
    $tries = @($p, (Join-Path $p 'AddOns'), (Join-Path $p 'Interface\AddOns'), (Join-Path $p '_forever_\Interface\AddOns'))
    foreach ($t in $tries) { if (Test-AddonsDir $t) { return (Resolve-Path $t).Path } }
    # Interface exists but no AddOns yet: create it
    foreach ($t in @((Join-Path $p 'Interface'), (Join-Path $p '_forever_\Interface'))) {
        if (Test-Path $t) { $a = Join-Path $t 'AddOns'; New-Item -ItemType Directory -Force -Path $a | Out-Null; return $a }
    }
    return $null
}

function Find-AddonsDir {
    $cfg = Get-Config
    if ($cfg.addonsPath -and (Test-AddonsDir $cfg.addonsPath)) { return $cfg.addonsPath }
    $cands = @()
    foreach ($key in @('HKLM:\SOFTWARE\WOW6432Node\Blizzard Entertainment\World of Warcraft',
                       'HKLM:\SOFTWARE\Blizzard Entertainment\World of Warcraft')) {
        try {
            $ip = (Get-ItemProperty -Path $key -ErrorAction Stop).InstallPath
            if ($ip) { $cands += $ip; $cands += (Split-Path ($ip.TrimEnd('\')) -Parent) }
        } catch { }
    }
    foreach ($d in (Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -ne $null })) {
        $root = $d.Root
        $cands += (Join-Path $root 'Program Files (x86)\World of Warcraft')
        $cands += (Join-Path $root 'Program Files\World of Warcraft')
        $cands += (Join-Path $root 'World of Warcraft')
        $cands += (Join-Path $root 'Games\World of Warcraft')
        $cands += (Join-Path $root 'Battle.net\World of Warcraft')
    }
    foreach ($c in $cands) {
        $r = Resolve-AddonsDir $c
        if ($r -and ($r -like '*_forever_*')) { return $r }
    }
    return $null
}

# ---------- GitHub ----------
$Headers = @{ 'User-Agent' = "$AppName/$AppVer"; 'Accept' = 'application/vnd.github+json' }

function Get-RemoteAddons {
    $repos = Invoke-RestMethod -Uri "https://api.github.com/users/$Owner/repos?per_page=100&type=owner" -Headers $Headers
    $out = @()
    foreach ($r in $repos) {
        if ($r.fork -or $r.archived -or ($Skip -contains $r.name)) { continue }
        try {
            $rel = Invoke-RestMethod -Uri "https://api.github.com/repos/$Owner/$($r.name)/releases/latest" -Headers $Headers
        } catch { continue }   # no release yet
        $zip = $rel.assets | Where-Object { $_.name -like '*.zip' } | Select-Object -First 1
        if (-not $zip) { continue }
        $out += [pscustomobject]@{
            Name        = $r.name
            Latest      = ($rel.tag_name -replace '^[vV]', '')
            Url         = $zip.browser_download_url
            Description = $r.description
        }
    }
    return $out
}

# ---------- local versions ----------
function Get-InstalledVersion([string]$addons, [string]$name) {
    $toc = Join-Path $addons "$name\$name.toc"
    if (-not (Test-Path $toc)) {
        $any = Get-ChildItem -Path (Join-Path $addons $name) -Filter '*.toc' -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $any) { return $null }
        $toc = $any.FullName
    }
    $line = Select-String -Path $toc -Pattern '^##\s*Version:\s*(.+)$' | Select-Object -First 1
    if ($line) { return $line.Matches[0].Groups[1].Value.Trim() }
    return '?'
}

function Test-Newer([string]$latest, [string]$installed) {
    if (-not $installed) { return $false }
    $a = $null; $b = $null
    if ([version]::TryParse($latest, [ref]$a) -and [version]::TryParse($installed, [ref]$b)) { return ($a -gt $b) }
    return ($latest -ne $installed)
}

function Get-Status([string]$addons) {
    $remote = Get-RemoteAddons
    foreach ($r in $remote) {
        $inst = Get-InstalledVersion $addons $r.Name
        $state = 'Not installed'
        if ($inst) { if (Test-Newer $r.Latest $inst) { $state = 'Update ready' } else { $state = 'Up to date' } }
        $r | Add-Member -NotePropertyName Installed -NotePropertyValue $inst -Force
        $r | Add-Member -NotePropertyName State -NotePropertyValue $state -Force
    }
    return $remote
}

# ---------- install / update one addon ----------
function Install-Addon([string]$addons, $addon) {
    $work = Join-Path $env:TEMP ("$AppName-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Force -Path $work | Out-Null
    try {
        $zip = Join-Path $work 'addon.zip'
        Invoke-WebRequest -Uri $addon.Url -OutFile $zip -Headers $Headers -UseBasicParsing
        $ex = Join-Path $work 'x'
        Expand-Archive -Path $zip -DestinationPath $ex -Force
        # the addon folders are the top-level folders that hold a .toc
        $folders = @(Get-ChildItem -Path $ex -Directory | Where-Object { Get-ChildItem -Path $_.FullName -Filter '*.toc' -File })
        if ($folders.Count -eq 0) { throw "The download for $($addon.Name) has no addon folder inside." }
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        foreach ($f in $folders) {
            $dest = Join-Path $addons $f.Name
            if (Test-Path $dest) {
                $bak = Join-Path $DataDir ("backup\" + $f.Name + "-" + $stamp)
                New-Item -ItemType Directory -Force -Path (Split-Path $bak -Parent) | Out-Null
                Move-Item -Path $dest -Destination $bak
                # keep only the 2 newest backups of this addon
                Get-ChildItem (Split-Path $bak -Parent) -Directory | Where-Object { $_.Name -like ($f.Name + '-*') } |
                    Sort-Object Name -Descending | Select-Object -Skip 2 | Remove-Item -Recurse -Force
            }
            Copy-Item -Path $f.FullName -Destination $dest -Recurse -Force
        }
        Write-Log ("Installed {0} {1} -> {2}" -f $addon.Name, $addon.Latest, $addons)
    } finally {
        Remove-Item -Path $work -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Test-WowRunning { return [bool](Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match '^Wow' }) }

# ---------- auto-update at Windows login ----------
function Get-AutoEnabled { return [bool](Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) }

function Set-AutoEnabled([bool]$on) {
    if ($on) {
        # keep a copy in AppData so the task still works if the download folder is deleted
        $self = Join-Path $DataDir 'updater.ps1'
        if ($PSCommandPath -ne $self) { Copy-Item -Path $PSCommandPath -Destination $self -Force }
        $arg = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $self + '" -Auto'
        $action  = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $arg
        $trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
        $trigger.Delay = 'PT1M'
        $set     = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
        Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $set -Description 'Keeps Yungslaya''s WoW addons up to date.' -Force | Out-Null
        Write-Log 'Auto-update at login: on'
    } else {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
        Write-Log 'Auto-update at login: off'
    }
}

# ---------- silent mode ----------
function Show-Note([string]$text) {
    Add-Type -AssemblyName System.Windows.Forms, System.Drawing
    $n = New-Object System.Windows.Forms.NotifyIcon
    $n.Icon = [System.Drawing.SystemIcons]::Information
    $n.BalloonTipTitle = $AppTitle
    $n.BalloonTipText = $text
    $n.Visible = $true
    $n.ShowBalloonTip(8000)
    Start-Sleep -Seconds 9
    $n.Dispose()
}

function Invoke-Auto([string]$addons) {
    if (-not $addons) { Write-Log 'Auto: no AddOns folder found'; return }
    $done = @()
    foreach ($a in (Get-Status $addons)) {
        if ($a.State -eq 'Update ready') {
            try { Install-Addon $addons $a; $done += "$($a.Name) $($a.Latest)" }
            catch { Write-Log ("Auto: failed {0}: {1}" -f $a.Name, $_.Exception.Message) }
        }
    }
    if ($done.Count -gt 0) {
        $msg = 'Updated: ' + ($done -join ', ')
        if (Test-WowRunning) { $msg += '. Type /reload in game.' }
        Show-Note $msg
    }
    Write-Log ('Auto: checked, updated ' + $done.Count)
}

# ---------- entry: non-window modes ----------
if (-not $AddonsPath) { $AddonsPath = Find-AddonsDir } else { $AddonsPath = Resolve-AddonsDir $AddonsPath }

if ($List) {
    "AddOns folder: $AddonsPath"
    if ($AddonsPath) { Get-Status $AddonsPath | Format-Table Name, Installed, Latest, State -AutoSize | Out-String -Width 200 }
    return
}
if ($Auto) {
    try { Invoke-Auto $AddonsPath } catch { Write-Log ('Auto error: ' + $_.Exception.Message) }
    return
}

# ---------- window ----------
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$font     = New-Object System.Drawing.Font('Segoe UI', 12)
$fontBold = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
$fontBig  = New-Object System.Drawing.Font('Segoe UI', 18, [System.Drawing.FontStyle]::Bold)
$gold     = [System.Drawing.Color]::FromArgb(227, 178, 79)
$ink      = [System.Drawing.Color]::FromArgb(27, 20, 6)
$bg       = [System.Drawing.Color]::FromArgb(24, 26, 30)
$panel    = [System.Drawing.Color]::FromArgb(33, 36, 42)
$fg       = [System.Drawing.Color]::FromArgb(236, 230, 216)
$muted    = [System.Drawing.Color]::FromArgb(164, 158, 145)
$green    = [System.Drawing.Color]::FromArgb(70, 200, 105)

$form = New-Object System.Windows.Forms.Form
$form.Text = $AppTitle
$form.Size = New-Object System.Drawing.Size(760, 560)
$form.MinimumSize = New-Object System.Drawing.Size(640, 480)
$form.StartPosition = 'CenterScreen'
$form.BackColor = $bg
$form.ForeColor = $fg
$form.Font = $font

$title = New-Object System.Windows.Forms.Label
$title.Text = $AppTitle
$title.Font = $fontBig
$title.ForeColor = $gold
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(20, 16)
$form.Controls.Add($title)

$pathLabel = New-Object System.Windows.Forms.Label
$pathLabel.AutoSize = $false
$pathLabel.Size = New-Object System.Drawing.Size(560, 48)
$pathLabel.Location = New-Object System.Drawing.Point(22, 60)
$pathLabel.ForeColor = $muted
$form.Controls.Add($pathLabel)

$changeBtn = New-Object System.Windows.Forms.Button
$changeBtn.Text = 'Change folder'
$changeBtn.Size = New-Object System.Drawing.Size(140, 36)
$changeBtn.Location = New-Object System.Drawing.Point(590, 62)
$changeBtn.Anchor = 'Top, Right'
$changeBtn.FlatStyle = 'Flat'
$changeBtn.ForeColor = $fg
$form.Controls.Add($changeBtn)

$grid = New-Object System.Windows.Forms.ListView
$grid.View = 'Details'
$grid.FullRowSelect = $true
$grid.CheckBoxes = $true
$grid.Location = New-Object System.Drawing.Point(22, 116)
$grid.Size = New-Object System.Drawing.Size(708, 250)
$grid.Anchor = 'Top, Bottom, Left, Right'
$grid.BackColor = $panel
$grid.ForeColor = $fg
$grid.BorderStyle = 'FixedSingle'
[void]$grid.Columns.Add('Addon', 220)
[void]$grid.Columns.Add('You have', 120)
[void]$grid.Columns.Add('Newest', 120)
[void]$grid.Columns.Add('Status', 220)
$form.Controls.Add($grid)

$updateBtn = New-Object System.Windows.Forms.Button
$updateBtn.Text = 'Update / Install'
$updateBtn.Font = $fontBold
$updateBtn.Size = New-Object System.Drawing.Size(220, 48)
$updateBtn.Location = New-Object System.Drawing.Point(22, 380)
$updateBtn.Anchor = 'Bottom, Left'
$updateBtn.BackColor = $gold
$updateBtn.ForeColor = $ink
$updateBtn.FlatStyle = 'Flat'
$form.Controls.Add($updateBtn)

$refreshBtn = New-Object System.Windows.Forms.Button
$refreshBtn.Text = 'Check again'
$refreshBtn.Size = New-Object System.Drawing.Size(150, 48)
$refreshBtn.Location = New-Object System.Drawing.Point(254, 380)
$refreshBtn.Anchor = 'Bottom, Left'
$refreshBtn.FlatStyle = 'Flat'
$refreshBtn.ForeColor = $fg
$form.Controls.Add($refreshBtn)

$autoBox = New-Object System.Windows.Forms.CheckBox
$autoBox.Text = 'Update automatically when I log in to Windows'
$autoBox.AutoSize = $true
$autoBox.Location = New-Object System.Drawing.Point(24, 440)
$autoBox.Anchor = 'Bottom, Left'
$autoBox.ForeColor = $fg
$form.Controls.Add($autoBox)

$status = New-Object System.Windows.Forms.Label
$status.AutoSize = $false
$status.Size = New-Object System.Drawing.Size(708, 30)
$status.Location = New-Object System.Drawing.Point(22, 474)
$status.Anchor = 'Bottom, Left, Right'
$status.ForeColor = $muted
$form.Controls.Add($status)

$script:addons = $AddonsPath
$script:items = @()

function Set-Status([string]$t, $color) {
    $status.Text = $t
    if ($color) { $status.ForeColor = $color } else { $status.ForeColor = $muted }
    $form.Refresh()
}

function Show-Path {
    if ($script:addons) { $pathLabel.Text = "Your AddOns folder:`n$($script:addons)" }
    else { $pathLabel.Text = "Couldn't find WoW: Forever. Click 'Change folder' and pick your World of Warcraft folder." }
}

function Load-List {
    $grid.Items.Clear()
    Show-Path
    if (-not $script:addons) { Set-Status 'Pick your WoW folder first.'; return }
    Set-Status 'Checking GitHub...'
    try { $script:items = @(Get-Status $script:addons) }
    catch { Set-Status ("Couldn't reach GitHub. Check your internet and click 'Check again'.") $gold; return }
    $ready = 0
    foreach ($a in $script:items) {
        $row = New-Object System.Windows.Forms.ListViewItem($a.Name)
        $have = '-'
        if ($a.Installed) { $have = $a.Installed }
        [void]$row.SubItems.Add($have)
        [void]$row.SubItems.Add($a.Latest)
        [void]$row.SubItems.Add($a.State)
        $row.Tag = $a
        $row.ToolTipText = $a.Description
        if ($a.State -eq 'Update ready') { $row.Checked = $true; $row.ForeColor = $gold; $ready++ }
        elseif ($a.State -eq 'Up to date') { $row.ForeColor = $green }
        [void]$grid.Items.Add($row)
    }
    if ($script:items.Count -eq 0) { Set-Status 'No addons published yet.' }
    elseif ($ready -gt 0) { Set-Status ("$ready update(s) ready. Click 'Update / Install'.") $gold }
    else { Set-Status 'Everything you have is up to date. Tick an addon to install it.' $green }
}

$changeBtn.Add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = 'Pick your World of Warcraft folder (or its _forever_ folder)'
    if ($dlg.ShowDialog() -eq 'OK') {
        $r = Resolve-AddonsDir $dlg.SelectedPath
        if ($r) {
            $script:addons = $r
            $cfg = Get-Config; $cfg | Add-Member -NotePropertyName addonsPath -NotePropertyValue $r -Force; Save-Config $cfg
            Load-List
        } else { Set-Status "That folder isn't a WoW: Forever install. Pick the World of Warcraft folder." $gold }
    }
})

$refreshBtn.Add_Click({ Load-List })

$updateBtn.Add_Click({
    $picked = @($grid.Items | Where-Object { $_.Checked } | ForEach-Object { $_.Tag })
    if ($picked.Count -eq 0) { Set-Status 'Tick the addons you want first.'; return }
    $updateBtn.Enabled = $false
    $ok = @(); $bad = @()
    foreach ($a in $picked) {
        Set-Status ("Getting {0} {1}..." -f $a.Name, $a.Latest)
        try { Install-Addon $script:addons $a; $ok += $a.Name }
        catch { $bad += $a.Name; Write-Log ("Failed {0}: {1}" -f $a.Name, $_.Exception.Message) }
    }
    $updateBtn.Enabled = $true
    Load-List
    $msg = ''
    if ($ok.Count -gt 0) { $msg = 'Done: ' + ($ok -join ', ') + '.' }
    if ($bad.Count -gt 0) { $msg += ' Failed: ' + ($bad -join ', ') + ' (see log).' }
    if ((Test-WowRunning) -and $ok.Count -gt 0) { $msg += ' Type /reload in game.' }
    Set-Status $msg $green
})

$autoBox.Add_Click({
    try { Set-AutoEnabled $autoBox.Checked
          if ($autoBox.Checked) { Set-Status 'Auto-update is on. It checks a minute after you log in to Windows.' $green }
          else { Set-Status 'Auto-update is off.' } }
    catch { Set-Status ("Couldn't change auto-update: " + $_.Exception.Message) $gold }
})

$form.Add_Shown({ $autoBox.Checked = (Get-AutoEnabled); Load-List })

if ($SelfTest) { Show-Path; "window ok: $($form.Controls.Count) controls; path=$($script:addons)"; $form.Dispose(); return }
[void]$form.ShowDialog()
