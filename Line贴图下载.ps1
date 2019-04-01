[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") | Out-Null
$PS1PATH = Split-Path -Parent $MyInvocation.MyCommand.Definition
$BAR = "---------------------------------------------"

#输入
while(([long]$StartNum = [Microsoft.VisualBasic.Interaction]::InputBox("输入初始ID", "初始ID", "")) -le 0){}
[long]$EndNum = [Microsoft.VisualBasic.Interaction]::InputBox("输入结束ID`n或图片数目(需前加""-"")`n`n建议一次下载少于40张，否则可能会下载到空文件，下载到空文件重新执行脚本下载即可。", "结束ID", "")
if($EndNum -lt 0){$EndNum = $StartNum - $EndNum -1}
[int]$ImgType = [Microsoft.VisualBasic.Interaction]::InputBox("选择图片类型:`n1-静图(png)`n2-动图(apng)", "选择图片类型", "1")
[int]$DLMode = [Microsoft.VisualBasic.Interaction]::InputBox("选择下载模式:`n1-DownloadFile`n2-DownLoadData`n3-aria2c`n4-Invoke-WebRequest", "下载模式", "1")

#目录选择
$dialog = New-Object -TypeName "System.Windows.Forms.FolderBrowserDialog"
$dialog.RootFolder = "Desktop"
$dialog.Description = "选择图片存储目录："
while($dialog.ShowDialog() -ne "OK"){}
$PNGPATH = $dialog.SelectedPath + "\"

Write-Host -ForegroundColor Green "开始执行..."
Write-Host -ForegroundColor Green "(1)下载..."

$client = new-object System.Net.WebClient

for($I = $StartNum; $I -le $EndNum; $I = $I + 1){
    Switch($ImgType){
        1{$URL = "https://stickershop.line-scdn.net/stickershop/v1/sticker/$I/ANDROID/sticker.png"}
        2{$URL = "https://stickershop.line-scdn.net/stickershop/v1/sticker/$I/IOS/sticker_animation@2x.png"}
    }
    $N = $I - $StartNum + 1
    $PNGFILE = $PNGPATH + $N + ".png"
    
    Write-Host -ForegroundColor Yellow $BAR
    Write-Host -ForegroundColor Yellow "NO.$N"
    "下载:$URL`n至->:$PNGFILE"

    switch($DLMode){
        1{$client.DownloadFile($URL, $PNGFILE)}
        2{[System.IO.File]::WriteAllBytes($PNGFILE, $client.DownloadData($URL))}
        3{"""$PS1PATH\aria2c.exe"" -d ""$dialog.SelectedPath"" -o ""$N.png"" ""$URL"""}
        4{
            Invoke-WebRequest -Uri $URL -OutFile $PNGFILE
            Unblock-File $PNGFILE
        }
    }
    Write-Host -ForegroundColor Green "本次操作完成"
}

Write-Host -ForegroundColor Yellow $BAR
Write-Host -ForegroundColor Green "所有下载操作已完成"

[Microsoft.VisualBasic.Interaction]::MsgBox("等待下载完成点击是", "YesNo,Information", "等待下载完成")

#动图的后续处理
if($ImgType -eq 2){
    Write-Host -ForegroundColor Green "`n(2)apng转换为gif..."
    $GIFPATH = $PNGPATH + "gifs_" + $StartNum + "\"
    New-Item "$GIFPATH" -ItemType Directory
    for($I = 1; $I -le $EndNum - $StartNum + 1; $I = $I + 1){
        Write-Host -ForegroundColor Yellow $BAR
        Write-Host -ForegroundColor Yellow "NO.$I" -NoNewline

        $PNGFILE = $PNGPATH + $I + ".png"
        $GIFFILE = $GIFPATH + $I + ".gif"
        &"$PS1PATH\apng2gif.exe" $PNGFILE $GIFFILE

        Write-Host -ForegroundColor Green "本次操作完成"
    }
    Write-Host -ForegroundColor Yellow $BAR
    Write-Host -ForegroundColor Green "所有转换操作已完成`n"
    
    if([Microsoft.VisualBasic.Interaction]::MsgBox("是否帮您启动 Ulead GIF Animator 来手动编辑GIF循环次数？`n默认搜索如下位置:`nC,D:\Program Files (x86)\Ulead GIF Animator\ga_main.exe", "YesNo,Question", "UGA") -eq "Yes"){
        if(Test-Path "C:\Program Files (x86)\Ulead GIF Animator\ga_main.exe"){$UGAFILE = "C:\Program Files (x86)\Ulead GIF Animator\ga_main.exe"}
        elseif(Test-Path "D:\Program Files (x86)\Ulead GIF Animator\ga_main.exe"){$UGAFILE = "D:\Program Files (x86)\Ulead GIF Animator\ga_main.exe"}
        else{
            $dialog = New-Object -TypeName "System.Windows.Forms.OpenFileDialog"
            $dialog.Title = "手动选择ga_main.exe："
            $dialog.Filter = "ga_main.exe|ga_main.exe|可执行文件|*.exe"
            while($dialog.ShowDialog() -ne "OK"){$UGAFILE = $dialog.FileName}
        }
        Write-Host -ForegroundColor Green "(3)启动UGA..."
        for($I = 1; $I -le $EndNum - $StartNum + 1; $I = $I + 1){
            Write-Host -ForegroundColor Yellow $BAR
            $GIFFILE = $GIFPATH + $I + ".gif"
            Write-Host -ForegroundColor Yellow "NO.$I"
            Write-Host "文件:$GIFFILE"
            Start-Process -FilePath $UGAFILE -ArgumentList $GIFFILE -Wait
        }
        Write-Host -ForegroundColor Green "`n操作已完成`n"
    }
}

Write-Host -ForegroundColor Green "所有操作已完成"
Write-Host -ForegroundColor Black -BackgroundColor Gray "按任意键退出..."
trap{[System.Console]::ReadKey() | Out-Null}