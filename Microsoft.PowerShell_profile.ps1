Set-ExecutionPolicy Unrestricted

# Modules
if(-not (Test-Path $((Split-Path $Profile)+"\Modules\PsGet\PsGet.psm1") )) {
  (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
}
Install-Module -ModuleURL https://github.com/JonathanDaSilva/PSTimestamp/zipball/master
Install-Module posh-git


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

function prompt
{
  Write-Host $pwd.ProviderPath -noNewLine
  Write-VcsStatus
  Write-Host
}

function reload
{
  . $Profile
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
  $found   = $FALSE
  $current = Get-Location
  foreach($path in $env:Path.split(';')) {
    if($path -eq $current) {
      $found = $TRUE
    }
  }

  if(-not $found) {
    $env:Path += ";$(Get-Location)"
    [Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)
    Write-Host "$(Get-Location) :: Added to Path" -ForegroundColor "green"
  } else {
    Write-Host "$(Get-Location) :: Already in Path" -ForegroundColor "red"
  }
}

function p
{
  cd "D:\Programmation\"
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

# Load posh-git example profile
. 'D:\Documents\WindowsPowerShell\Modules\posh-git\profile.example.ps1'

