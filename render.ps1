param(
    [ValidateSet('zh', 'en')][string]$Language = 'zh',
    [string]$Output,
    [string]$Preview
)

if (!$Output) { $Output = Join-Path $PSScriptRoot $(if ($Language -eq 'zh') { 'entry.zh.png' } else { 'entry.png' }) }
$Chinese = @{
    'The World Ledger' = '世界纪事'
    'SATURDAY  /  EVENING UTC' = '周六 / 晚间版 UTC'
    '21 November 2026' = '2026年11月21日'
    'CLIMATE  /  ANTALYA, TURKEY' = '气候 / 土耳其安塔利亚'
    'COP31 stalls' = 'COP31 谈判受阻'
    'into the night' = '持续至深夜'
    'ANTALYA' = '安塔利亚'
    'Fossil fuel language and climate' = '化石燃料措辞和气候资金'
    'finance remain in dispute.' = '仍存在分歧。'
    'SPACE  /  ESA–JAXA' = '太空 / 欧空局与日本宇航机构'
    'Mercury orbit' = '探测器进入'
    'achieved' = '水星轨道'
    'BepiColombo arrives after' = '贝皮科隆博号经过'
    'nearly eight years in transit.' = '近八年的飞行后抵达。'
    'EUROPE' = '欧洲'
    'Kryvyi Rih strike: officials report 2 dead' = '克里维里赫遇袭，官方通报 2 人死亡'
    'Ship burns after Gulf of Finland drone hit' = '芬兰湾船只遭无人机袭击后起火'
    'EU condemns alleged plot on Danish soil' = '欧盟谴责据称在丹麦境内策划的阴谋'
    'Geneva: autonomous arms talks extended' = '日内瓦延长自主武器谈判'
    'Turin: Alcaraz beats Shelton to reach final' = '都灵：阿尔卡拉斯胜谢尔顿晋级决赛'
    'Twickenham: England 37–12 New Zealand' = '特威克纳姆：英格兰 37–12 新西兰'
    'Dublin: Ireland 20–17 South Africa' = '都柏林：爱尔兰 20–17 南非'
    'AMERICAS' = '美洲'
    'Sinaloa: cartel chief Meza Flores captured' = '锡那罗亚毒枭梅萨·弗洛雷斯被捕'
    'Peru: 6.7 quake near Carhuamayo' = '秘鲁卡尔瓦马约附近发生 6.7 级地震'
    'Brasília hospital: Bolsonaro stable in ICU' = '巴西利亚医院称博索纳罗在重症病房病情稳定'
    'PERU' = '秘鲁'
    'MIDDLE EAST' = '中东'
    'Gaza City hospital: food-truck strike kills 3' = '加沙城医院称送餐卡车遇袭，3 人死亡'
    'Coalition: 3 Houthi missiles down at Riyadh' = '联军称在利雅得拦截 3 枚胡塞导弹'
    'AFRICA' = '非洲'
    'Bayelsa: Friday capsize toll reaches 24+' = '巴耶尔萨州周五沉船死亡人数达 24 人以上'
    'South Africa: ANC seeks local coalitions' = '南非非国大寻求组建地方执政联盟'
    'Turkana: Kenya begins crude oil drilling' = '肯尼亚图尔卡纳开始原油钻探'
    'ASIA & PACIFIC' = '亚太'
    'Jiuquan: final Shenzhou-24 drill complete' = '酒泉完成神舟二十四号发射前最后演练'
    'Macau: Hickman wins fifth motorcycle GP' = '澳门：希克曼第五次夺得摩托车大奖赛冠军'
    'APEC trio calls for Russia–Ukraine truce' = 'APEC 三国呼吁俄乌停火'
    'Udine rugby: Fiji 21–16 Italy' = '乌迪内橄榄球赛：斐济 21–16 意大利'
}

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$page = [Drawing.Bitmap]::new(1024, 1024, [Drawing.Imaging.PixelFormat]::Format24bppRgb)
$g = [Drawing.Graphics]::FromImage($page)
$g.SmoothingMode = 'AntiAlias'
$g.TextRenderingHint = 'AntiAliasGridFit'
$g.PageUnit = 'Pixel'
$ink = '#182923'
$paper = '#F7F3E9'
$rule = '#C1C9BC'
$accent = '#A13D2B'
$lime = '#E5EEA9'

function Brush($hex) {
    [Drawing.SolidBrush]::new([Drawing.ColorTranslator]::FromHtml($hex))
}

function Block($x, $y, $w, $h, $color) {
    $brush = Brush $color
    $g.FillRectangle($brush, $x, $y, $w, $h)
    $brush.Dispose()
}

function Line($x1, $y1, $x2, $y2, $color, $weight = 1) {
    $pen = [Drawing.Pen]::new([Drawing.ColorTranslator]::FromHtml($color), $weight)
    $g.DrawLine($pen, $x1, $y1, $x2, $y2)
    $pen.Dispose()
}

function TextAt($value, $x, $y, $size, $maxWidth, $color = $ink, $family = 'Arial', $style = 'Regular') {
    if ($Language -eq 'zh') { $value = $Chinese[$value]; $family = 'Microsoft YaHei UI' }
    $font = [Drawing.Font]::new($family, $size, $style, 'Pixel')
    if ($font.FontFamily.Name -ne $family) { throw "Missing font: $family" }
    $brush = Brush $color
    $format = [Drawing.StringFormat]::GenericTypographic
    $measurement = $g.MeasureString($value, $font, 2048, $format)
    while ($Language -eq 'zh' -and $measurement.Width -gt $maxWidth -and $size -gt 14) {
        $font.Dispose()
        $size--
        $font = [Drawing.Font]::new($family, $size, $style, 'Pixel')
        $measurement = $g.MeasureString($value, $font, 2048, $format)
    }
    if ($measurement.Width -gt $maxWidth -or $x + $maxWidth -gt 1024 -or
        $y + $measurement.Height -gt 1024 -or $x -lt 0 -or $y -lt 0) {
        throw "Text overflow at ($x,$y): $value ($($measurement.Width) > $maxWidth)"
    }
    $g.DrawString($value, $font, $brush, [Drawing.PointF]::new($x, $y), $format)
    $format.Dispose()
    $font.Dispose()
    $brush.Dispose()
}

function Region($x, $y, $name, $briefs) {
    Line $x $y ($x + 460) $y $rule 2
    Block $x $y 44 4 $accent
    TextAt $name $x ($y + 9) 23 460 $accent 'Arial' 'Bold'
    $row = $y + 47
    foreach ($brief in $briefs) {
        TextAt $brief $x $row 22 460 $ink 'Arial' 'Bold'
        $row += 34
    }
}

function Locator($x, $y, $coast, $pinX, $pinY, $color) {
    $points = foreach ($pair in $coast.Split(' ')) {
        $dx, $dy = $pair.Split(',')
        [Drawing.PointF]::new(($x + [int]$dx), ($y + [int]$dy))
    }
    $pen = [Drawing.Pen]::new([Drawing.ColorTranslator]::FromHtml($color), 2)
    $dot = Brush $color
    $g.DrawLines($pen, [Drawing.PointF[]]$points)
    $g.DrawEllipse($pen, ($x + $pinX - 8), ($y + $pinY - 8), 16, 16)
    $g.FillEllipse($dot, ($x + $pinX - 3), ($y + $pinY - 3), 6, 6)
    $pen.Dispose()
    $dot.Dispose()
}

Block 0 0 1024 1024 $paper
Block 38 25 948 5 $ink
TextAt 'The World Ledger' 36 38 60 620 $ink 'Georgia' 'Bold'
TextAt 'SATURDAY  /  EVENING UTC' 670 47 19 316 $accent 'Arial' 'Bold'
TextAt '21 November 2026' 670 72 31 316 $ink 'Georgia' 'Bold'

$climateWidth = 550
$spaceX = 38 + $climateWidth + 8
$spaceWidth = 986 - $spaceX
Block 38 119 $climateWidth 276 '#203C36'
Block $spaceX 119 $spaceWidth 276 '#ECD9C7'
TextAt 'CLIMATE  /  ANTALYA, TURKEY' 59 140 20 425 $lime 'Arial' 'Bold'
TextAt 'COP31 stalls' 55 172 63 415 $paper 'Georgia' 'Bold'
TextAt 'into the night' 55 236 60 419 $paper 'Georgia' 'Bold'
Locator 473 172 '0,14 15,21 29,31 41,30 49,45 57,50 68,43 76,31 94,25' 57 50 $lime
TextAt 'ANTALYA' 491 242 15 80 $lime 'Arial' 'Bold'
Line 60 316 (22 + $climateWidth) 316 '#78958A' 1
TextAt 'Fossil fuel language and climate' 60 329 24 425 $paper
TextAt 'finance remain in dispute.' 60 357 24 425 $paper
TextAt 'SPACE  /  ESA–JAXA' ($spaceX + 20) 140 19 310 $accent 'Arial' 'Bold'

$g.TranslateTransform(($spaceX + $spaceWidth - 103), 191)
$g.RotateTransform(-23)
$pen = [Drawing.Pen]::new([Drawing.ColorTranslator]::FromHtml('#925338'), 2.5)
$planet = Brush '#B56343'
$g.DrawEllipse($pen, -81, -26, 162, 52)
$g.FillEllipse($planet, -31, -31, 62, 62)
$g.DrawArc($pen, -81, -26, 162, 52, 0, 180)
$g.FillEllipse($planet, 64, 8, 11, 11)
$g.ResetTransform()
$pen.Dispose()
$planet.Dispose()

TextAt 'Mercury orbit' ($spaceX + 19) 218 44 ($spaceWidth - 32) $ink 'Georgia' 'Bold'
TextAt 'achieved' ($spaceX + 19) 265 44 ($spaceWidth - 32) $ink 'Georgia' 'Bold'
TextAt 'BepiColombo arrives after' ($spaceX + 20) 329 24 350 $ink
TextAt 'nearly eight years in transit.' ($spaceX + 20) 357 24 350 $ink

Region 38 426 'EUROPE' @(
    'Kryvyi Rih strike: officials report 2 dead'
    'Ship burns after Gulf of Finland drone hit'
    'EU condemns alleged plot on Danish soil'
    'Geneva: autonomous arms talks extended'
    'Turin: Alcaraz beats Shelton to reach final'
    'Twickenham: England 37–12 New Zealand'
    'Dublin: Ireland 20–17 South Africa'
)
Region 38 729 'AMERICAS' @(
    'Sinaloa: cartel chief Meza Flores captured'
    'Peru: 6.7 quake near Carhuamayo'
    'Brasília hospital: Bolsonaro stable in ICU'
)
Locator 419 738 '0,0 10,6 8,12 17,19 23,25 35,32 41,34' 33 21 $accent
TextAt 'PERU' 360 745 17 56 $accent 'Arial' 'Bold'
Region 526 426 'MIDDLE EAST' @(
    'Gaza City hospital: food-truck strike kills 3'
    'Coalition: 3 Houthi missiles down at Riyadh'
)
Region 526 555 'AFRICA' @(
    'Bayelsa: Friday capsize toll reaches 24+'
    'South Africa: ANC seeks local coalitions'
    'Turkana: Kenya begins crude oil drilling'
)
Region 526 718 'ASIA & PACIFIC' @(
    'Jiuquan: final Shenzhou-24 drill complete'
    'Macau: Hickman wins fifth motorcycle GP'
    'APEC trio calls for Russia–Ukraine truce'
    'Udine rugby: Fiji 21–16 Italy'
)

Line 38 947 986 947 $ink 2

$page.Save($Output, [Drawing.Imaging.ImageFormat]::Png)
if ($Preview) {
    $small = [Drawing.Bitmap]::new(300, 300)
    $previewGraphics = [Drawing.Graphics]::FromImage($small)
    $previewGraphics.InterpolationMode = 'HighQualityBicubic'
    $previewGraphics.DrawImage($page, 0, 0, 300, 300)
    $small.Save($Preview, [Drawing.Imaging.ImageFormat]::Png)
    $previewGraphics.Dispose()
    $small.Dispose()
}
$g.Dispose()
$page.Dispose()
