Param(
    [string]$Source = 'images/113.bmp'
)

if (!(Test-Path $Source)) {
    Write-Error "Source image not found: $Source"
    exit 1
}

Add-Type -AssemblyName System.Drawing

function Resize-SavePng {
    param(
        [string]$InputPath,
        [string]$OutputPath,
        [int]$Width,
        [int]$Height
    )
    $bmp = [System.Drawing.Image]::FromFile($InputPath)
    try {
        $dest = New-Object System.Drawing.Bitmap $Width, $Height
        $g = [System.Drawing.Graphics]::FromImage($dest)
        try {
            $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
            $g.Clear([System.Drawing.Color]::Transparent)
            $g.DrawImage($bmp, 0, 0, $Width, $Height)
            $dest.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
        }
        finally {
            $g.Dispose()
            $dest.Dispose()
        }
    }
    finally {
        $bmp.Dispose()
    }
}

function Save-IcoFromImage {
    param(
        [string]$InputPath,
        [string]$OutputIco
    )
    $bmp = [System.Drawing.Image]::FromFile($InputPath)
    try {
        $icon = [System.Drawing.Icon]::FromHandle(($bmp).GetHicon())
        try {
            $fs = [System.IO.File]::Create($OutputIco)
            try { $icon.Save($fs) } finally { $fs.Dispose() }
        } finally { $icon.Dispose() }
    }
    finally { $bmp.Dispose() }
}

Resize-SavePng -InputPath $Source -OutputPath 'favicon-16.png' -Width 16 -Height 16
Resize-SavePng -InputPath $Source -OutputPath 'favicon-32.png' -Width 32 -Height 32
Resize-SavePng -InputPath $Source -OutputPath 'apple-touch-icon.png' -Width 180 -Height 180
Save-IcoFromImage -InputPath 'favicon-32.png' -OutputIco 'favicon.ico'

Write-Output 'Generated: favicon-16.png, favicon-32.png, apple-touch-icon.png, favicon.ico'
