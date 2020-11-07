# OpenAudible move split books into Author folders.

Clear-Host

$AUDIBLE_BOOK_PATH = $env:USERPROFILE + "\OpenAudible\books"
$MODULE_PATH = "$Env:UserProfile\Documents\WindowsPowerShell\Modules\"
$TAGLIB_PATH = $MODULE_PATH + "taglib"

$location = Get-Location

if ((Test-Path $TAGLIB_PATH)  -eq $false) {
    try {
        Import-Module taglib -ErrorAction SilentlyContinue | Out-Null
    } catch {
        Write-Host "Hi"
    } finally {
        if ((Test-Path $MODULE_PATH) -eq $false) {
            New-Item -Path $MODULE_PATH -ItemType Directory
        }
        Set-Location $MODULE_PATH
        $command = 'git clone https://github.com/danielmbond/powershell-taglib.git taglib'
        Invoke-Expression -Command:$command -ErrorAction SilentlyContinue | Out-Null
        Import-Module taglib | Out-Null
    }
}

$mp3s = Get-ChildItem -Path $AUDIBLE_BOOK_PATH -Include *.mp3, *.m4a -Recurse
foreach ($mp3 in $mp3s) {
    $fullname = $mp3.FullName
    if(Test-Path $fullname) {
        $artist = $mp3 | get-artist
        if ($fullname.contains($artist)) {
            Write-Output "cool - $fullname"
        } else {
            $artistPath = "$AUDIBLE_BOOK_PATH\" + $artist
            if ((Test-Path $artistPath) -ne $true) {
                Write-Output "Creating: $artistPath"
                New-Item -ItemType Directory -Path $artistPath
            } 
            if (Test-Path($mp3.FullName)) {
                Move-Item -Path $($mp3 | Split-Path -Parent) -Destination $artistPath
            }
        }
    }
}
