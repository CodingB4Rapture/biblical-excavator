param(
    [string]$OutputRoot = ""
)

Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($OutputRoot))
{
    $OutputRoot = Join-Path $projectRoot "fonts\dialogue_font"
}

New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null

$fontFamilyName = "Trebuchet MS"
$fontPointSize = 22
$atlasWidth = 512
$atlasHeight = 256
$padding = 2
$fontStyle = [Drawing.FontStyle]::Regular
$font = [Drawing.Font]::new(
    $fontFamilyName,
    $fontPointSize,
    $fontStyle,
    [Drawing.GraphicsUnit]::Point
)
$measureBitmap = [Drawing.Bitmap]::new(192, 80)
$measureBitmap.SetResolution(96, 96)
$measureGraphics = [Drawing.Graphics]::FromImage($measureBitmap)
$measureGraphics.TextRenderingHint =
    [Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$stringFormat = [Drawing.StringFormat]::GenericTypographic
$lineHeight = [Math]::Ceiling($font.GetHeight($measureGraphics))
$emHeight = $font.FontFamily.GetEmHeight($fontStyle)
$cellAscent = $font.FontFamily.GetCellAscent($fontStyle)
$ascender = [Math]::Ceiling(
    $cellAscent / $emHeight * $fontPointSize * 96 / 72
)

$characters = [Collections.Generic.List[int]]::new()
for ($character = 32; $character -le 127; $character++)
{
    $characters.Add($character)
}
$characters.Add(9647)

$glyphData = [ordered]@{}
$glyphBitmaps = [ordered]@{}

foreach ($characterCode in $characters)
{
    $characterText = [char]$characterCode
    $tempBitmap = [Drawing.Bitmap]::new(192, $lineHeight)
    $tempBitmap.SetResolution(96, 96)
    $tempGraphics = [Drawing.Graphics]::FromImage($tempBitmap)
    $tempGraphics.Clear([Drawing.Color]::Transparent)
    $tempGraphics.TextRenderingHint =
        [Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $tempGraphics.DrawString(
        $characterText,
        $font,
        [Drawing.Brushes]::White,
        48,
        0,
        $stringFormat
    )
    $tempGraphics.Dispose()

    $minX = $tempBitmap.Width
    $maxX = -1
    for ($scanY = 0; $scanY -lt $tempBitmap.Height; $scanY++)
    {
        for ($scanX = 0; $scanX -lt $tempBitmap.Width; $scanX++)
        {
            if ($tempBitmap.GetPixel($scanX, $scanY).A -gt 0)
            {
                $minX = [Math]::Min($minX, $scanX)
                $maxX = [Math]::Max($maxX, $scanX)
            }
        }
    }

    $advance = [Math]::Max(
        1,
        [Math]::Round(
            $measureGraphics.MeasureString(
                $characterText,
                $font,
                2048,
                $stringFormat
            ).Width
        )
    )
    if ($characterCode -eq 32)
    {
        $advance = [Math]::Round($fontPointSize * 0.36)
    }

    if ($maxX -lt $minX)
    {
        $minX = 48
        $maxX = 48
    }

    $glyphWidth = [Math]::Max(1, $maxX - $minX + 1)
    $croppedBitmap = [Drawing.Bitmap]::new($glyphWidth, $lineHeight)
    $croppedBitmap.SetResolution(96, 96)
    $croppedGraphics = [Drawing.Graphics]::FromImage($croppedBitmap)
    $croppedGraphics.Clear([Drawing.Color]::Transparent)
    $croppedGraphics.DrawImage(
        $tempBitmap,
        [Drawing.Rectangle]::new(0, 0, $glyphWidth, $lineHeight),
        [Drawing.Rectangle]::new(
            $minX,
            0,
            $glyphWidth,
            $lineHeight
        ),
        [Drawing.GraphicsUnit]::Pixel
    )
    $croppedGraphics.Dispose()
    $tempBitmap.Dispose()

    $glyphBitmaps[[string]$characterCode] = $croppedBitmap
    $glyphData[[string]$characterCode] = [ordered]@{
        character = $characterCode
        h = $lineHeight
        offset = $minX - 48
        shift = $advance
        w = $glyphWidth
        x = 0
        y = 0
    }
}

$atlas = [Drawing.Bitmap]::new($atlasWidth, $atlasHeight)
$atlas.SetResolution(96, 96)
$atlasGraphics = [Drawing.Graphics]::FromImage($atlas)
$atlasGraphics.Clear([Drawing.Color]::Transparent)
$packX = $padding
$packY = $padding

foreach ($characterCode in $characters)
{
    $key = [string]$characterCode
    $glyph = $glyphData[$key]
    $glyphBitmap = $glyphBitmaps[$key]

    if ($packX + $glyph.w + $padding -gt $atlasWidth)
    {
        $packX = $padding
        $packY += $lineHeight + $padding
    }

    if ($packY + $lineHeight + $padding -gt $atlasHeight)
    {
        throw "Dialogue font glyphs do not fit the 512 x 256 atlas."
    }

    $glyph.x = $packX
    $glyph.y = $packY
    $atlasGraphics.DrawImageUnscaled($glyphBitmap, $packX, $packY)
    $packX += $glyph.w + $padding
}

$atlasGraphics.Dispose()
$fontPath = Join-Path $OutputRoot "dialogue_font.png"
$oldFontPath = Join-Path $OutputRoot "dialogue_font.old.png"
$atlas.Save($fontPath, [Drawing.Imaging.ImageFormat]::Png)
$atlas.Save($oldFontPath, [Drawing.Imaging.ImageFormat]::Png)
$atlas.Dispose()

foreach ($glyphBitmap in $glyphBitmaps.Values)
{
    $glyphBitmap.Dispose()
}

$fontResource = [ordered]@{
    '$GMFont' = ""
    '%Name' = "dialogue_font"
    AntiAlias = 1
    applyKerning = 1
    ascender = $ascender
    ascenderOffset = 0
    bold = $false
    canGenerateBitmap = $true
    charset = 0
    first = 0
    fontName = $fontFamilyName
    glyphOperations = 0
    glyphs = $glyphData
    hinting = 0
    includeTTF = $false
    interpreter = 0
    italic = $false
    kerningPairs = @()
    last = 0
    lineHeight = $lineHeight
    maintainGms1Font = $false
    name = "dialogue_font"
    parent = [ordered]@{
        name = "HUD and Dialogue"
        path = "folders/Interface and Feedback/HUD and Dialogue.yy"
    }
    pointRounding = 0
    ranges = @(
        [ordered]@{lower = 32; upper = 127},
        [ordered]@{lower = 9647; upper = 9647}
    )
    regenerateBitmap = $false
    resourceType = "GMFont"
    resourceVersion = "2.0"
    sampleText = @"
abcdef ABCDEF
0123456789 .,<>"'&!?
the quick brown fox jumps over the lazy dog
THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG
"@
    sdfSpread = 8
    size = [double]$fontPointSize
    styleName = "Regular"
    textureGroupId = [ordered]@{
        name = "Default"
        path = "texturegroups/Default"
    }
    TTFName = ""
    usesSDF = $false
}

$json = $fontResource | ConvertTo-Json -Depth 12
[IO.File]::WriteAllText(
    (Join-Path $OutputRoot "dialogue_font.yy"),
    $json + [Environment]::NewLine,
    [Text.UTF8Encoding]::new($false)
)

$measureGraphics.Dispose()
$measureBitmap.Dispose()
$font.Dispose()
