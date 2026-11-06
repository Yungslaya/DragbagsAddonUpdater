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
$env:LOCALAPPDATA=Join-Path $root 'profile'
& $path -SelfTest -AddonsPath "$root\AddOns"

