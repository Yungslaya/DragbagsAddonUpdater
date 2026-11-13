$ErrorActionPreference='Stop'
$path=Join-Path (Split-Path $PSScriptRoot -Parent) 'updater.ps1'
$tokens=$null;$errors=$null
$ast=[System.Management.Automation.Language.Parser]::ParseFile($path,[ref]$tokens,[ref]$errors)
if($errors.Count){throw ($errors|Out-String)}
$ast.FindAll({param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst]},$false) | ForEach-Object {Invoke-Expression $_.Extent.Text}
$cases=@(
 @('1.2.8','1.2.7','Update ready'),
 @('1.2.8','1.2.8','Up to date'),
 @('1.0.1','1.0.2','Local copy is newer'),
 @('1.2.0','1.3.0','Local copy is newer'),
 @('1.0.0','?','Check version'),
 @('1.0.0','','Not installed')
)
foreach($c in $cases){$actual=Get-VersionState $c[0] $c[1];if($actual -ne $c[2]){throw "State failed: $actual"}}
$root=Join-Path $env:TEMP ('Dragbags-tests-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path "$root\AddOns\TestAddon" -Force|Out-Null
'## Version: 2.0.0'|Set-Content "$root\AddOns\TestAddon\TestAddon.toc"
$a=[pscustomobject]@{Name='TestAddon';Latest='1.0.0';Url='https://example.invalid/no-download';State='Local copy is newer';Installed='2.0.0';Notes="## Changes`n- Added **notes**"}
$blocked=$false
try{Install-Addon "$root\AddOns" $a}catch{if($_.Exception.Message -notlike '*local copy is newer*'){throw};$blocked=$true}
if(-not $blocked){throw 'Downgrade was allowed'}
if((Get-InstalledVersion "$root\AddOns" 'TestAddon') -ne '2.0.0'){throw 'Local files changed'}
$notesText=Get-NotesText $a
if($notesText -notlike '*These notes describe GitHub*' -or $notesText -notlike '*Added notes*'){throw 'Notes text failed'}
# Remote release metadata is preserved for the selected addon.
$Owner='test';$Headers=@{};$Skip=@()
function Invoke-RestMethod {param($Uri,$Headers)
 if($Uri -like '*/users/*'){return [pscustomobject]@{name='TestAddon';fork=$false;archived=$false;description='test'}}
 return [pscustomobject]@{tag_name='v1.0.0';html_url='https://github.com/test/TestAddon/releases/tag/v1.0.0';body='Release details';assets=@([pscustomobject]@{name='TestAddon.zip';browser_download_url='https://example.invalid/addon.zip'})}
}
$r=@(Get-Status "$root\AddOns")
if($r.Count -ne 1 -or $r[0].Notes -ne 'Release details' -or $r[0].State -ne 'Local copy is newer'){throw 'Remote notes/status failed'}
'PASS: syntax, six version cases, downgrade blocked before download, files unchanged, release notes, remote metadata'
# --- 1.1.0: player files survive an update, and helper apps install and update ---
$AppName='DragbagsTest';$DataDir="$root\data";$LogFile="$root\data\log.txt";New-Item -ItemType Directory $DataDir -Force|Out-Null
$AppsRoots=@("$root\docs","$root\docs2");$DesktopDir="$root\desktop";New-Item -ItemType Directory "$root\docs","$root\docs2\TestApp",$DesktopDir -Force|Out-Null
$Keep=@{TestAddon=@('LedgerPlan.lua')}
$Apps=@(@{Repo='TestAddon';Asset='TestApp.pyw';Title='Test App';Folder='TestApp';File='Test App.pyw';Description='app'})
'mine'|Set-Content "$root\AddOns\TestAddon\LedgerPlan.lua"
New-Item -ItemType Directory "$root\pkg\TestAddon" -Force|Out-Null
'## Version: 3.0.0'|Set-Content "$root\pkg\TestAddon\TestAddon.toc"
'stub'|Set-Content "$root\pkg\TestAddon\LedgerPlan.lua"
Compress-Archive -Path "$root\pkg\TestAddon" -DestinationPath "$root\TestAddon.zip"
$script:appBody='VERSION = "3.0.0"'
function Invoke-WebRequest {param($Uri,$OutFile,$Headers,[switch]$UseBasicParsing)
 if($Uri -like '*.zip'){Copy-Item "$root\TestAddon.zip" $OutFile}else{$script:appBody|Set-Content $OutFile}
}
function Invoke-RestMethod {param($Uri,$Headers)
 if($Uri -like '*/users/*'){return [pscustomobject]@{name='TestAddon';fork=$false;archived=$false;description='test'}}
 return [pscustomobject]@{tag_name='v3.0.0';html_url='https://github.com/test/TestAddon/releases/tag/v3.0.0';body='Notes';assets=@(
  [pscustomobject]@{name='Other.zip';browser_download_url='https://example.invalid/other.zip'},
  [pscustomobject]@{name='TestApp.pyw';browser_download_url='https://example.invalid/TestApp.pyw'},
  [pscustomobject]@{name='TestAddon.zip';browser_download_url='https://example.invalid/TestAddon.zip'})}
}
$r=@(Get-Status "$root\AddOns")
if($r.Count -ne 2){throw "Expected addon + app rows, got $($r.Count)"}
if($r[0].Url -notlike '*TestAddon.zip' -or $r[0].State -ne 'Update ready'){throw 'Addon zip pick/state failed'}
if($r[1].Kind -ne 'app' -or $r[1].Name -ne 'Test App' -or $r[1].State -ne 'Not installed'){throw 'App row failed'}
Install-Addon "$root\AddOns" $r[0]
if((Get-InstalledVersion "$root\AddOns" 'TestAddon') -ne '3.0.0'){throw 'Addon not updated'}
if((Get-Content "$root\AddOns\TestAddon\LedgerPlan.lua") -ne 'mine'){throw 'Player plan was replaced'}
Install-Addon "$root\AddOns" $r[1]
if((Get-FileVersion "$root\docs\TestApp\Test App.pyw") -ne '3.0.0'){throw 'App not installed'}
if(-not (Test-Path "$root\desktop\Test App.lnk")){throw 'Shortcut missing'}
$r=@(Get-Status "$root\AddOns")
if($r[0].State -ne 'Up to date' -or $r[1].State -ne 'Up to date'){throw 'States after install failed'}
# an old copy with no version line counts as out of date; a wrong download is refused
'print(1)'|Set-Content "$root\docs\TestApp\Test App.pyw"
$r=@(Get-Status "$root\AddOns");if($r[1].State -ne 'Update ready'){throw 'Old app copy not flagged'}
$script:appBody='VERSION = "9.9.9"';$refused=$false
try{Install-Addon "$root\AddOns" $r[1]}catch{$refused=$true}
if(-not $refused -or (Get-Content "$root\docs\TestApp\Test App.pyw") -ne 'print(1)'){throw 'Wrong app download was installed'}
$script:appBody='VERSION = "3.0.0"';Install-Addon "$root\AddOns" $r[1]
if(@(Get-ChildItem "$root\data\backup" -Filter 'TestApp-*.pyw').Count -ne 1){throw 'App backup missing'}
'VERSION = "4.0.0"'|Set-Content "$root\docs\TestApp\Test App.pyw"
$r=@(Get-Status "$root\AddOns");if($r[1].State -ne 'Local copy is newer'){throw 'Newer app copy not kept'}
# a copy that already lives in the second Documents folder is the one that gets updated
Remove-Item "$root\docs\TestApp" -Recurse -Force
'VERSION = "1.0.0"'|Set-Content "$root\docs2\TestApp\Test App.pyw"
$r=@(Get-Status "$root\AddOns");if($r[1].Installed -ne '1.0.0' -or $r[1].State -ne 'Update ready'){throw 'Second Documents folder not found'}
Install-Addon "$root\AddOns" $r[1]
if((Get-FileVersion "$root\docs2\TestApp\Test App.pyw") -ne '3.0.0' -or (Test-Path "$root\docs\TestApp")){throw 'App not updated in place'}
'PASS: named zip picked, player plan kept, app installed with shortcut, old/wrong/newer app copies handled, second Documents folder'
$env:LOCALAPPDATA=Join-Path $root 'profile'
& $path -SelfTest -AddonsPath "$root\AddOns"

