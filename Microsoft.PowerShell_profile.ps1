Set-ExecutionPolicy Unrestricted
# Modules
$profileDir = Split-Path -parent $Profile
# Test that PsGet is install
if(-not (Test-Path $($profileDir+"\Modules\PsGet\PsGet.psm1") )) {
  (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
}
Install-Module -ModuleURL https://github.com/JonathanDaSilva/PSTimestamp/zipball/master
Install-Module posh-git

# Update Modules
$lastUpdate = $profileDir+'\.last-update'
if(-not $(Test-Path $lastUpdate)) {
  # If never update
  Set-Content $lastUpdate 0
}
$time = [Int] $(Get-Content $lastUpdate)
if( $((Get-TimeStamp) - $time) -gt $(3600*24*7)) {
  # Check if it's hasn't been update for one week
  Write-Host "Update Modules..." -ForegroundColor "Green"
  Update-Module -All -Module PsGet
  Set-Content $lastUpdate $(Get-TimeStamp)
} else {
  Write-Host "No Update" -ForegroundColor "Green"
}

# Change the default Prompt
Function Global:prompt
{
  Write-Host $(Get-Location) -NoNewLine
  Write-VcsStatus
  return "`n>>"
}

# Alias
Set-Alias 7z 7za
$VIMPATH = "C:\Program Files (x86)\Vim\vim74\gvim.exe"
Set-Alias vi $VIMPATH
Set-Alias vim $VIMPATH
if(Test-Path Alias:\curl) {
  Remove-Item Alias:\curl # Delete the powershell curl alias
}
if(Test-Path Alias:\wget) {
  Remove-Item Alias:\wget # Delete the powershell wget alias
}

function reload
{
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
}

function ass # AndroidScreenShot
{
  adb shell /system/bin/screencap -p /sdcard/screenshot.png
  adb pull  /sdcard/screenshot.png D:/Bureau/screenshot.png
  adb shell rm /sdcard/screenshot.png
}

function Add-Path
{
  param (
    [Object]$dir = $(Get-Location)
  )
  if(-not (In-Path $dir)) {
    $env:Path += ";$($dir)"
    [Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)
    Write-Host "$(Get-Location) :: Added to Path" -ForegroundColor "green"
  } else {
    Write-Host "$(Get-Location) :: Already in Path" -ForegroundColor "red"
  }
}

function Remove-Path
{
  param (
    [Object]$dir = $(Get-Location)
  )
  if(In-Path) {
    $env:Path = $env:Path.replace($dir, '')
    $env:Path = $env:Path.replace(';;', ';')
    [Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)
    Write-Host "$(Get-Location) :: Deleted for the path" -ForegroundColor "green"
  } else {
    Write-Host "$(Get-Location) :: Is not in the path" -ForegroundColor "red"
  }
}

function In-Path
{
  param(
    [Object]$dir = $(Get-Location)
  )
  $found   = $FALSE
  foreach($path in $env:Path.split(';')) {
    if($path -eq $dir) {
      $found = $TRUE
    }
  }
  return $found
}
function p
{
  Set-Location "D:\Programmation\"
}

function qandroid
{
  param(
    [String]$version = "18"
  )
  $version   = "android-" + $version
  $directory = "build"
  $ant       = "C:\Android\Ant\bin\ant.bat"
  qmakeandroid
  make
  make install INSTALL_ROOT=build
  deployandroid --output "$directory" --input "android-libtest.so-deployment-settings.json" --android-platform=$version --ant "$ant"
  Copy-Item ".\$directory\bin\QtApp-debug.apk" ".\build.apk"

  $pack      = (Get-Content .\build\AndroidManifest.xml | where {$_ -match 'package='}).split()[1].split('"')[1]
  $act       = (Get-Content .\build\AndroidManifest.xml | where {$_ -match 'activity'} | where {$_ -match 'android:name'}).split('"')[1]
  adb install -r "./build.apk"
  adb shell am start -n $pack/$act
}
