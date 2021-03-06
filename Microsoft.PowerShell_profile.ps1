# Store the emplacement of the profile for other programs
Set-Env PSProfile $profile

# ZLocation
Import-Module ZLocation
Write-Host -Foreground Green "`n[ZLocation] knows about $((Get-ZLocation).Keys.Count) locations.`n"

# MSYS2
Add-Path "C:\msys64\mingw64\bin\"
Add-Path "C:\msys64\usr\bin\"
function msys   { C:\msys64\usr\bin\bash.exe --login }
Remove-Item alias:\wget -ErrorAction "SilentlyContinue"
Remove-Item alias:\curl -ErrorAction "SilentlyContinue"
Remove-Item alias:\ls   -ErrorAction "SilentlyContinue"

# Ansible
function ansible          { Invoke-MSYS "ansible" $args}
function ansible-playbook { Invoke-MSYS "ansible-playbook" $args}
function ansible-galaxy   { Invoke-MSYS "ansible-galaxy" $args}
function ansible-vault    { Invoke-MSYS "ansible-vault" $args}
function ansible-lint     { Invoke-MSYS "ansible-lint" $args}

# Python
Add-Path "C:\Python2*\Scripts"
Add-Path "C:\Python3*\Scripts"
Set-Alias python  "C:\Windows\py.exe"
Set-Alias pythonw "C:\Windows\pyw.exe"

# NodeJS
Add-Path "C:\Program Files\nodejs\"

# Vim
$GVIMPATH = $(Resolve-Path "C:\Program Files\Vim\vim8*\gvim.exe").Path
Set-Alias vi  $GVIMPATH
Set-Alias vim $GVIMPATH

# Cmake
# Set-Alias cmake "C:\Program Files (x86)\CMake\bin\cmake.exe"

# Android
Set-Env ANDROID_HOME      "C:\Android\"
# Set-Env JAVA_HOME $(Resolve-Path "C:\Program Files\Java\jdk*").Path
# Set-Env ANDROID_NDK_ROOT "C:\Android\NDK"
# Set-Env GRADLE           "C:\Android\gradle\bin\gradle.bat"
# Add-Path "$($env:JAVA_HOME)/bin"

# Change the default Prompt
function Global:prompt
{
  Write-Host $(Get-Location)
  return ">>> "
}


function ass # AndroidScreenShot
{
  $sh      = New-Object -COM WScript.Shell
  $lnk     = (Resolve-Path "~/Links/Desktop.lnk").Path
  $desktop = $sh.CreateShortcut($lnk).TargetPath

  adb shell /system/bin/screencap -p /sdcard/screenshot.png
  adb pull  /sdcard/screenshot.png "$desktop/screenshot.png"
  adb shell rm /sdcard/screenshot.png
  & "C:\Program Files\ShareX\ShareX.exe" "$desktop\screenshot.png"
}

function run
{
  npm run $args
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

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
