[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") | Out-Null
$PS1PATH = Split-Path -Parent $MyInvocation.MyCommand.Definition
$BAR = "---------------------------------------------"

$WebURL = [Microsoft.VisualBasic.Interaction]::InputBox("输入主题链接", "主题链接", "")
#$WebURL = "https://store.line.me/themeshop/product/7b5e6b78-52c1-41d6-b9ca-a5f30220705a/zh-Hans"
$dialog = New-Object -TypeName "System.Windows.Forms.FolderBrowserDialog"
$dialog.RootFolder = "Desktop"
$dialog.Description = "选择图片存储目录："
while($dialog.ShowDialog() -ne "OK"){}
#$dialog.SelectedPath="C:\Users\SBBTD\Desktop"
$IMGPATH = $dialog.SelectedPath + "\"

$Web = Invoke-WebRequest $WebURL
$regex = [regex]"https://shop.line-scdn.net/themeshop/v1/products/\w{2}/\w{2}/\w{2}/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/\d/ANDROID/en/preview_\d{3}_\d{3,4}x\d{3,4}.png"

$ma = $regex.Matches($Web)

for($I=1;$I -le $ma.Count;$I=$I+1){
    $ImgURL = $ma[$I-1].Value
    $IMGFILE = $IMGPATH + "$I.1.png"
    Write-Host -ForegroundColor Yellow $BAR
    Write-Host -ForegroundColor Yellow "NO.$I"
    Write-Host "下载:$ImgURL`n至->:$IMGFILE"
    $client = new-object System.Net.WebClient
    $client.DownloadFile("$ImgURL", "$IMGFILE")
}
Write-Host -ForegroundColor Yellow $BAR
Write-Host -ForegroundColor Green "所有下载操作已完成"

$TILEPATH = $IMGPATH
$image = New-Object System.Drawing.Bitmap("$($IMGPATH)2.1.png")
$Height = $image.Height
$Width = $image.Width

for($I = 1;$I -le 5;$I = $I + 1){
    Write-Host -ForegroundColor Yellow "裁切 NO.$I"
    $tileWidth = 112
    $tileHeight = 112
    $tileLeft = (2 * $I - 1) * 16 + ($I - 1) * 112
    $tileTop = 96
    $imgPart=New-Object System.Drawing.Rectangle($tileLeft ,$tileTop ,$tileWidth ,$tileHeight)
    $s = $image.Clone($imgPart,"Format24bppRgb")
    $s.Save("$TILEPATH$I.png","Png")
    $s.Dispose()
}

Write-Host -ForegroundColor Yellow "裁切 NO.6"
$imgPart=New-Object System.Drawing.Rectangle(32,541,90,90)
$s = $image.Clone($imgPart,"Format24bppRgb")
$s.Save("$($TILEPATH)6.png","Png")
$s.Dispose()

Write-Host -ForegroundColor Yellow "裁切 NO.7"
$imgPart=New-Object System.Drawing.Rectangle(32,851,90,90)
$s = $image.Clone($imgPart,"Format24bppRgb")
$s.Save("$($TILEPATH)7.png","Png")
$s.Dispose()

Write-Host -ForegroundColor Green "任意键退出..."
trap{[System.Console]::Read() | Out-Null}