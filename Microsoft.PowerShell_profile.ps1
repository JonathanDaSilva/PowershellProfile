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
  param(
    [String]$version = "14"
  )
  $version   = "android-" + $version
  $buildDir  = "build-android"
  $toolchain = "C:\tools\android-cmake\android.toolchain.cmake"
  $make      = "C:\tools\android-ndk\prebuilt\windows-x86_64\bin\make.exe"
  $qtcmake   = "C:\Qt\Qt5.3.2\5.3\android_armv7\lib\cmake\"
  $ant       = "C:\tools\apache-ant-1.9.4\"
  Set-Alias deploy "C:\Qt\Qt5.3.2\5.3\android_armv7\bin\androiddeployqt.exe"
  # Create the build directory if doesn't exist
  if(-not (Test-Path $buildDir)) {
    New-Item -ItemType Directory $buildDir
  }
  # build process
  Set-Location $buildDir
  cmake.exe -G"MinGW Makefiles" -DCMAKE_TOOLCHAIN_FILE="$toolchain" -DCMAKE_MAKE_PROGRAM="$make" -DCMAKE_PREFIX_PATH="$qtcmake" ..
  cmake --build .
  # Move librarie to the current directory
  if(Test-Path "application.so") {
    Remove-Item "application.so"
  }
  if(Test-Path("..\libs\")) {
    Copy-Item "..\libs\*" "build\libs\" -Recurse -Force
    Remove-Item "..\libs\" -Force -Confirm:$False
  }
  # Create apk
  deploy --output "build" --input "application.json" --android-platform $version
  Copy-Item "build\bin\QtApp-Debug.apk" "application.apk"
  Set-Location ..
}

# function qandroid
# {
  # param(
  #   [String]$version = "18"
  # )
#   $version   = "android-" + $version
#   $directory = "build"
#   qmakeandroid
#   make
#   make install INSTALL_ROOT=build
#   deployandroid --output "$directory" --input "android-libtest.so-deployment-settings.json" --android-platform=$version --ant "$ant"
#   Copy-Item ".\$directory\bin\QtApp-debug.apk" ".\build.apk"

#   $pack      = (Get-Content .\build\AndroidManifest.xml | where {$_ -match 'package='}).split()[1].split('"')[1]
#   $act       = (Get-Content .\build\AndroidManifest.xml | where {$_ -match 'activity'} | where {$_ -match 'android:name'}).split('"')[1]
#   adb install -r "./build.apk"
#   adb shell am start -n $pack/$act
# }

Import-Module EnvVariable
