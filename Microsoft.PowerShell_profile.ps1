# Put chocolatey in trusted packagesource
Set-PackageSource -Name "Chocolatey" -Trusted > ~/null

# PsGet Modules
PsGet\Install-Module -ModuleUrl "https://github.com/JonathanDaSilva/PSEnvVariable/archive/master.zip" -ErrorAction SilentlyContinue
PsGet\Install-Module PSReadLine -ErrorAction SilentlyContinue

# Store the emplacement of the profile for other programs
Set-Env PSProfile $profile

# Zzip
Set-Alias 7z "C:\tools\7zip\7za.exe"

# Git
Install-Package "git"     -ProviderName "Chocolatey"
Install-Package "p4merge" -ProviderName "Chocolatey"
Add-Path "C:\Program Files (x86)\Git\cmd\" -ErrorAction SilentlyContinue

Set-Alias ssh         "C:\Program Files (x86)\Git\bin\ssh.exe"
Set-Alias ssh-add     "C:\Program Files (x86)\Git\bin\ssh-add.exe"
Set-Alias ssh-agent   "C:\Program Files (x86)\Git\bin\ssh-agent.exe"
Set-Alias ssh-keygen  "C:\Program Files (x86)\Git\bin\ssh-keygen.exe"
Set-Alias ssh-keyscan "C:\Program Files (x86)\Git\bin\ssh-keyscan.exe"

# Curl
Remove-Item Alias:\curl -ErrorAction SilentlyContinue
Install-Package "curl" -ProviderName "Chocolatey"
Set-Alias curl $(Resolve-Path "C:\Chocolatey\lib\curl.*\tools\curl.exe").Path

# GnuWin
Remove-Item Alias:\wget -ErrorAction SilentlyContinue
Install-Package "GnuWin" -ProviderName "Chocolatey" -RequiredVersion "0.6.3"
Set-Alias wget    "C:\bin\GnuWin\bin\wget.exe"
Set-Alias openssl "C:\bin\GnuWin\bin\openssl.exe"

# Python
Add-Path $(Resolve-Path "C:\Python2*").Path -ErrorAction SilentlyContinue
Add-Path $(Resolve-Path "C:\Python3*").Path -ErrorAction SilentlyContinue
Add-Path $(Resolve-Path "C:\Python2*\Scripts").Path -ErrorAction SilentlyContinue
Add-Path $(Resolve-Path "C:\Python3*\Scripts").Path -ErrorAction SilentlyContinue
Set-Alias python  py
Set-Alias pythonw pyw

# Ruby
Add-Path "C:\tools\ruby\bin" -ErrorAction SilentlyContinue

# PHP
Add-Path "C:\tools\php\"
Add-Path "~\AppData\Roaming\Composer\vendor\bin" -ErrorAction SilentlyContinue

# IOJS
Install-Package "io.js" -ProviderName "Chocolatey"
Add-Path "C:\Program Files\iojs\" -ErrorAction SilentlyContinue
Add-Path "~/AppData/Roaming/npm" -ErrorAction SilentlyContinue

# Vim
$GVIMPATH = "C:\Program Files (x86)\Vim\vim74\gvim.exe"
Set-Alias vi  $GVIMPATH
Set-Alias vim $GVIMPATH

# VirtualBox
Install-Package "virtualbox" -ProviderName "Chocolatey"
Add-Path "C:\Program Files\Oracle\VirtualBox" -ErrorAction SilentlyContinue

# Vagrant
Install-Package "vagrant"    -ProviderName "Chocolatey"
Set-Alias vagrant "C:\HashiCorp\Vagrant\bin\vagrant.exe"

# Docker
function docker {
  & boot2docker ssh "docker $args"
}

# Alias
Install-Package cmake
Set-Alias cmake   "C:\Program Files (x86)\CMake\bin\cmake.exe"

# Encoding
Add-Path "C:\tools\Encoding" -ErrorAction SilentlyContinue
Set-Alias dgi "C:\tools\DGIndexNV\DGIndexNV.exe"

# Android
Install-Package "jdk8" -ProviderName Chocolatey
Set-Env JAVA_HOME $(Resolve-Path "C:\Program Files\Java\jdk*").Path
Set-Env ANDROID_NDK_ROOT "C:\tools\android-ndk"
Set-Env ANDROID_SDK "C:\tools\android-sdk"
Set-Env ANT "C:\tools\apache-ant\bin\ant.bat"

# Change the default Prompt
function Global:prompt
{
  Write-Host $(Get-Location)
  return ">>> "
}


function ass # AndroidScreenShot
{
  adb shell /system/bin/screencap -p /sdcard/screenshot.png
  adb pull  /sdcard/screenshot.png D:/Bureau/screenshot.png
  adb shell rm /sdcard/screenshot.png
  & "C:\Program Files\ShareX\ShareX.exe" "D:\Bureau\screenshot.png"
}

function p
{
  Set-Location "D:\Programmation\"
}

function Remove-Service
{
  param(
    [Parameter(Mandatory=$True,Position=1)]
    [String]$name = "",
    [Parameter(Mandatory=$False,Position=2)]
    [Boolean]$Confirm = $True,
    [Parameter(Mandatory=$False,Position=2)]
    [Boolean]$Verbose = $True
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
  $buildDir  = "build-windows"
  Remove-Item $buildDir -Force -Recurse -ErrorAction SilentlyContinue
  New-Item -ItemType Directory $buildDir > ~/null
  # build process
  Set-Location $buildDir
  cmake.exe -G"MinGW Makefiles" ..
  cmake --build .
  Set-Location ..
  # Copy the executable in the current folder
  Get-ChildItem -Path $buildDir -Filter "*.exe" | foreach($_) {
    & ".\$buildDir\$_"
  }
}

function android-cmake
{
  Set-Alias make   $(Resolve-Path "C:\Qt\Tools\mingw*_32\bin\mingw32-make.exe").Path
  Set-Alias qmake  $(Resolve-Path "C:\Qt\*\android_armv7\bin\qmake.exe").Path
  Set-Alias deploy $(Resolve-Path "C:\Qt\*\android_armv7\bin\androiddeployqt.exe").Path
  $buildDir  = "build-android"
  $toolchain = "C:\tools\cmake-toolchain\androidqt.toolchain.cmake"
  $ant       = Get-Content Env:\ANT

  New-Item -ItemType Directory $buildDir -ErrorAction SilentlyContinue > ~/null
  Set-Location $buildDir
  Remove-Item * -Force -Recurse
  cmake -G"MinGW Makefiles" -DCMAKE_TOOLCHAIN_FILE="$toolchain" ..
  Remove-Item -Force -Recurse *
  qmake ../project.pro
  make
  make install INSTALL_ROOT=build
  deploy --output "build" --input "android-libproject.so-deployment-settings.json" --ant "$ant" --android-platform "android-18"
  Copy-Item ".\build\bin\QtApp-debug.apk" ".\build.apk"
  $pack      = (Get-Content .\build\AndroidManifest.xml | where {$_ -match 'package='}).split()[1].split('"')[1]
  $act       = (Get-Content .\build\AndroidManifest.xml | where {$_ -match 'activity'} | where {$_ -match 'android:name'}).split('"')[1]

  # Devices
  foreach($device in $(adb devices)) {
    if($device -match "^(\w+)\s+device$") {
      adb -s $matches[1] install -r "./build.apk"
      adb -s $matches[1] shell am start -n $pack/$act
    }
  }

  Set-Location ..
  Move-Item project.pro $buildDir/
}
