param (
    [string]$Keyword = "",
    [string]$Language = ""
)

Add-Type -AssemblyName PresentationCore

# システムの表示言語（UI 言語）を取得（例: ja-JP）
if ([string]::IsNullOrWhiteSpace($Language)) {
    $Language = [System.Globalization.CultureInfo]::InstalledUICulture.Name
}

# XmlLanguage オブジェクトを作成（例: ja-JP, en-US）
$xmlLang = [System.Windows.Markup.XmlLanguage]::GetLanguage($Language)

# フォント一覧の取得
$fontEntries = [System.Windows.Media.Fonts]::SystemFontFamilies | ForEach-Object {
    $dict = $_.FamilyNames

    # 指定言語の名前 or フォールバックとして .Source（英語）
    $localizedName = if ($dict.ContainsKey($xmlLang)) { $dict[$xmlLang] } else { $_.Source }
    $sourceName = $_.Source

    # カスタムオブジェクトで格納
    [PSCustomObject]@{
        Localized = $localizedName
        English   = $sourceName
    }
}

# キーワードによるフィルタ（部分一致）
$filtered = if ($Keyword -ne "") {
    $fontEntries | Where-Object {
        $_.Localized -like "*$Keyword*" -or $_.English -like "*$Keyword*"
    }
}
else {
    $fontEntries
}

# 表示整形（重複排除）
$filtered |
Sort-Object Localized, English -Unique |
ForEach-Object {
    if ($_.Localized -eq $_.English) {
        $_.Localized
    }
    else {
        "$($_.Localized) ($($_.English))"
    }
}
