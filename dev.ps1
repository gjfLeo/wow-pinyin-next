$linkPath = 'C:\Programs\World of Warcraft\_retail_\Interface\AddOns\PinyinNext'

if (Test-Path $linkPath) {
    Remove-Item -Path $linkPath -Recurse -Force
}

New-Item `
  -ItemType SymbolicLink `
  -Path $linkPath `
  -Target (Get-Location)
