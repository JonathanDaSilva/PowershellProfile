$profileDir = Split-Path -parent $Profile
# Test that PsGet is install
if(-not (Test-Path $($profileDir+"\Modules\PsGet\PsGet.psm1") )) {
  (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
}

Install-Module -Startup -ModuleURL https://github.com/JonathanDaSilva/PSEnvVariable/zipball/master
Install-Module PSReadline
# Import-Module virtualenvwrapper

# Change the default Prompt
function Global:prompt
{
  Write-Host $(Get-Location)
  return ">>> "
}

# Alias
Set-Alias 7z 7za
$VIMPATH = "C:\Program Files (x86)\Vim\vim74\gvim.exe"
Set-Alias vi $VIMPATH
Set-Alias vim $VIMPATH
Remove-Item Alias:\curl -ErrorAction "SilentlyContinue" # Delete the powershell curl alias
Remove-Item Alias:\wget -ErrorAction "SilentlyContinue" # Delete the powershell wget alias

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

function p
{
  Set-Location "D:\Programmation\"
}

function Remove-Service
{
  param(
    [Parameter(Mandatory=$True,Position=1)]
    [String]$name = ""
  )
  if(Get-Service $name -ErrorAction "SilentlyContinue") {
    $service = Get-WmiObject -Class Win32_Service -Filter "Name='$name'"
    $service.delete()
    Write-Host "$name Service Deleted" -ForegroundColor "Green"
  } else {
    Write-Host "$name Service doesn't exist" -ForegroundColor "Red"
  }
}

function qt-cmake
{
  $buildDir  = "build"
  $qtcmake   = "C:\Qt\Qt5.3.2\5.3\mingw482_32\lib\cmake\"
  # Create the build directory if doesn't exist
  if(-not (Test-Path $buildDir)) {
    New-Item -ItemType Directory $buildDir
  }
  # build process
  Set-Location $buildDir
  cmake.exe -G"MinGW Makefiles" -DCMAKE_PREFIX_PATH="$qtcmake" ..
  cmake --build .
  Set-Location ..
  # Copy the executable in the current folder
  Get-ChildItem -Path $buildDir -Filter "*.exe" | foreach($_) {
    & ".\$buildDir\$_"
  }
}

function android-cmake
{
  Set-Alias make   "C:\Qt\Tools\mingw491_32\bin\mingw32-make.exe"
  Set-Alias qmake  "C:\Qt\5.4\android_armv7\bin\qmake.exe"
  Set-Alias deploy "C:\Qt\5.4\android_armv7\bin\androiddeployqt.exe"
  $buildDir  = "build-android"
  $toolchain = "C:\tools\toolchain\pro.toolchain.cmake"
  $ant       = "C:\tools\apache-ant-1.9.4\bin\ant.bat"
  New-Item -ItemType Directory -ErrorAction SilentlyContinue $buildDir
  Set-Location $buildDir
  cmake -G"MinGW Makefiles" -DCMAKE_TOOLCHAIN_FILE="$toolchain" ..
  Remove-Item -Force -Recurse *
  qmake ../project.pro
  make
  make install INSTALL_ROOT=build
  deploy --output "build" --input "android-libproject.so-deployment-settings.json" --ant "$ant"
  Copy-Item ".\build\bin\QtApp-debug.apk" ".\build.apk"
  $pack      = (Get-Content .\build\AndroidManifest.xml | where {$_ -match 'package='}).split()[1].split('"')[1]
  $act       = (Get-Content .\build\AndroidManifest.xml | where {$_ -match 'activity'} | where {$_ -match 'android:name'}).split('"')[1]
  adb install -r "./build.apk"
  adb shell am start -n $pack/$act
  Set-Location ..
  Move-Item project.pro $buildDir/
}
