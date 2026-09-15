#Requires -Version 5.1
# =====================================================================
#  Sprawdzanie Lacza 1.4   |   by Jerremi
#
#  Nowe w 1.4: wyniki pokazuja sie teraz jako kolorowe kafelki ze znaczkiem
#  i poswiata w kolorze stanu (ten sam styl co w OptiLauncherze), test
#  predkosci wysylania (upload) obok juz istniejacego pobierania, a odczyt
#  publicznego adresu IP ma teraz trzy zapasowe metody z rzedu (OpenDNS,
#  DNS Google, zwykle HTTPS), gdyby jedna z nich byla zablokowana w danej
#  sieci.
#
#  Nowe w 1.3: publiczny adres IP (przez zapytanie DNS, nie HTTP - dziala
#  nawet gdy cos przycina ruch webowy), prosty test predkosci pobierania
#  (jeden strumien, speed.cloudflare.com) i traceroute z czasem na kazdym
#  skoku (wlasna implementacja na ICMP, bez tracert.exe).
#
#  Nowe w 1.1: interfejs w stylu OptiLaunchera 7.4 - animowane wejscie
#  okna, wiersze wyniku wjezdzaja pojedynczo w miare pomiaru, pasek
#  aktywnosci i pulsujaca kropka w stopce, przycisk "Kopiuj wynik".
#
#  Samodzielne narzedzie diagnostyczne. Mierzy opoznienie, jitter
#  i straty pakietow OSOBNO do routera i osobno do internetu - bo to
#  rozstrzyga, gdzie naprawde jest problem.
#
#  Niczego nie zmienia w systemie. Wylacznie odczyt.
#
#  Uruchamianie:
#    bez parametru        - okno programu
#    -Tryb instaluj       - instalacja (Menu Start, pulpit, deinstalator)
#    -Tryb konsola        - ten sam pomiar, ale w konsoli
#    -Tryb ikona          - zapisuje SprawdzLacze.ico obok skryptu
# =====================================================================

param([string]$Tryb = '')

$AppNazwa  = 'Sprawdzanie Lacza'
$AppKlucz  = 'SprawdzLacze'
$AppWersja = '1.4.0'
$AppAutor  = 'Jerremi'

# Zapisy pomiarow (recznie zapisane wyniki + historia CSV) leza w tym samym
# katalogu danych co OptiLauncher - to wylacznie plik na dysku uzytkownika,
# nie zmienia niczego w systemie (Sprawdzanie Lacza nadal "wylacznie odczyt"
# jesli chodzi o siec i ustawienia Windows).
$KatDanychLacza = Join-Path $env:LOCALAPPDATA 'OptiLauncher\Lacze'

# ikona wbudowana jako base64 - dzieki temu paczka to dwa pliki, nie trzy
$IkonaB64 = @'
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
i8X/BxJMELTNilDCAAAAAElFTkSuQmCC
'@

function Zapisz-Ikone {
    param([string]$Sciezka)
    try {
        [System.IO.File]::WriteAllBytes($Sciezka, [Convert]::FromBase64String(($IkonaB64 -replace '\s', '')))
        return $true
    } catch { return $false }
}

# =====================================================================
#  POMIAR - wspolny dla okna i konsoli
# =====================================================================
$KodPomiaru = @'
function Get-Karta {
    # Karta z domyslna trasa - czyli ta, przez ktora naprawde leci ruch.
    # Branie "pierwszej wlaczonej" myli sie przy VPN-ach i kartach wirtualnych.
    try {
        $r = Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction Stop |
             Sort-Object RouteMetric | Select-Object -First 1
        if ($r) {
            $a = Get-NetAdapter -InterfaceIndex $r.InterfaceIndex -ErrorAction Stop
            if ($a) { return $a }
        }
    } catch { }
    try {
        return (Get-NetAdapter -Physical -ErrorAction Stop |
                Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1)
    } catch { }
    return $null
}

function Get-Brama {
    try {
        return (Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction Stop |
                Sort-Object RouteMetric | Select-Object -First 1).NextHop
    } catch { return $null }
}

function Measure-Ping {
    param([string]$Cel, [int]$Ile = 10, [scriptblock]$Postep = $null)
    $czasy = New-Object System.Collections.ArrayList
    $zgub = 0
    $ping = New-Object System.Net.NetworkInformation.Ping
    for ($i = 0; $i -lt $Ile; $i++) {
        try {
            $r = $ping.Send($Cel, 1200)
            if ($r -and $r.Status -eq 'Success') { [void]$czasy.Add([double]$r.RoundtripTime) }
            else { $zgub++ }
        } catch { $zgub++ }
        if ($Postep) { & $Postep }
        Start-Sleep -Milliseconds 110
    }
    if ($czasy.Count -eq 0) { return @{ ok=$false; avg=0; min=0; max=0; jitter=0; loss=100 } }
    # Jitter jako srednia roznica miedzy kolejnymi pomiarami - to on
    # odpowiada za przycinanie w grach, nie sama wartosc pingu.
    $sj = 0.0; $n = 0
    for ($i = 1; $i -lt $czasy.Count; $i++) { $sj += [math]::Abs($czasy[$i] - $czasy[$i-1]); $n++ }
    $jit = 0.0
    if ($n -gt 0) { $jit = $sj / $n }
    $st = ($czasy | Measure-Object -Average -Minimum -Maximum)
    return @{
        ok     = $true
        avg    = [math]::Round($st.Average, 1)
        min    = [math]::Round($st.Minimum, 1)
        max    = [math]::Round($st.Maximum, 1)
        jitter = [math]::Round($jit, 1)
        loss   = [math]::Round(($zgub / [double]$Ile) * 100, 0)
    }
}

function Get-Wifi {
    $w = @{ sygnal=$null; radio=$null; pasmo=$null; kanal=$null }
    try {
        $txt = netsh wlan show interfaces 2>&1 | Out-String
        foreach ($line in ($txt -split "`r?`n")) {
            if (-not $w.sygnal -and $line -match '(\d+)\s*%')        { $w.sygnal = [int]$Matches[1] }
            if ($line -match '(?i)radio type\s*:\s*(.+)$')           { $w.radio  = $Matches[1].Trim() }
            if ($line -match '(?i)(band|pasmo)\s*:\s*(.+)$')         { $w.pasmo  = $Matches[2].Trim() }
            if ($line -match '(?i)(channel|kana)\S*\s*:\s*(\d+)')    { $w.kanal  = $Matches[2].Trim() }
        }
    } catch { }
    return $w
}

# UWAGA: standardowe klucze NDIS naprawde zaczynaja sie od gwiazdki (*EEE),
# a -RegistryKeyword traktuje gwiazdke jak wieloznacznik i zwraca kilka
# wlasciwosci naraz. Dlatego pobieramy wszystko raz i filtrujemy doslownie.
$WlasciwosciKarty = @(
    @{ kw='*EEE';                 nazwa='Energy Efficient Ethernet' }
    @{ kw='EnableGreenEthernet';  nazwa='Green Ethernet' }
    @{ kw='*InterruptModeration'; nazwa='Interrupt Moderation' }
    @{ kw='*FlowControl';         nazwa='Flow Control' }
    @{ kw='*SelectiveSuspend';    nazwa='Selective Suspend' }
    @{ kw='WakeOnMagicPacket';    nazwa='Wybudzanie pakietem sieciowym' }
)

function Get-WlasciwosciKarty {
    param($Ad)
    $out = New-Object System.Collections.ArrayList
    if (-not $Ad) { return ,$out }
    $wsz = @()
    try { $wsz = @(Get-NetAdapterAdvancedProperty -Name $Ad.Name -ErrorAction Stop) } catch { }
    foreach ($p in $WlasciwosciKarty) {
        $cur = $wsz | Where-Object { "$($_.RegistryKeyword)" -eq $p.kw } | Select-Object -First 1
        if ($cur) {
            $val = "$(@($cur.RegistryValue)[0])"
            [void]$out.Add(@{ nazwa = $p.nazwa; wartosc = $val; wylaczone = ($val -eq '0') })
        }
    }
    return ,$out
}

# Popularne platformy gamingowe - orientacyjny pomiar. To NIE sa adresy
# serwerow gry (tych zwykle nie da sie przewidziec), tylko glowne wejscia
# danej platformy - dlatego wynik traktujemy jako przyblizenie, nie wyrocznie.
# Brak odpowiedzi na ping czesto oznacza po prostu, ze dana firma blokuje
# ICMP na brzegu sieci, a nie ze cos jest nie tak z laczem.
$SerweryGier = @(
    @{ nazwa = 'Steam (Valve)';  cel = 'steampowered.com' }
    @{ nazwa = 'Xbox Live';      cel = 'xbox.com' }
    @{ nazwa = 'Discord';        cel = 'discord.com' }
    @{ nazwa = 'Riot Games';     cel = 'riotgames.com' }
)

function Measure-Serwery {
    param([array]$Lista, [int]$Ile = 6, [scriptblock]$Postep = $null)
    $wyniki = New-Object System.Collections.ArrayList
    foreach ($s in $Lista) {
        $ip = $null
        try {
            $rec = Resolve-DnsName -Name $s.cel -Type A -ErrorAction Stop |
                   Where-Object { $_.Type -eq 'A' } | Select-Object -First 1
            if ($rec) { $ip = $rec.IPAddress }
        } catch { }
        if (-not $ip) {
            [void]$wyniki.Add(@{ nazwa = $s.nazwa; cel = $s.cel; ok = $false; avg=0; jitter=0; loss=100 })
            if ($Postep) { & $Postep }
            continue
        }
        $m = Measure-Ping $ip $Ile
        $m.nazwa = $s.nazwa
        $m.cel   = $s.cel
        [void]$wyniki.Add($m)
        if ($Postep) { & $Postep }
    }
    return ,$wyniki
}

# Adres publiczny - najpierw przez zapytanie DNS do OpenDNS zamiast
# polaczenia HTTP (dziala nawet, gdy jakis program czy firewall przycina
# ruch HTTP(S), a DNS zwykle zostawia w spokoju - ten sam trik, ktorego
# uzywa spora czesc narzedzi sieciowych: "dig @resolver1.opendns.com
# myip.opendns.com"). Jesli siec blokuje wlasnie zapytania do obcego
# serwera DNS (co tez sie zdarza), probuje przez DNS Google, a na koncu
# zwyklym zapytaniem HTTPS - zeby wynik pojawil sie tak czy inaczej.
function Get-PublicznyIP {
    # Metoda 1: trik DNS przez OpenDNS - dziala nawet gdy cos przycina
    # zwykly ruch webowy, ale niektore routery/sieci blokuja zapytania
    # do wskazanego wprost serwera DNS (port 53 poza standardowa trasa).
    try {
        $rec = Resolve-DnsName -Name 'myip.opendns.com' -Server 'resolver1.opendns.com' `
                                -Type A -ErrorAction Stop | Select-Object -First 1
        if ($rec -and $rec.IPAddress) { return "$($rec.IPAddress)" }
    } catch { }

    # Metoda 2: ten sam trik, ale przez DNS Google (inny serwer - jesli
    # akurat OpenDNS jest niedostepny/zablokowany, Google moze przejsc).
    try {
        $rec = Resolve-DnsName -Name 'o-o.myaddr.l.google.com' -Server 'ns1.google.com' `
                                -Type TXT -ErrorAction Stop | Select-Object -First 1
        if ($rec -and $rec.Strings) {
            $ip = ($rec.Strings -join '').Trim('"')
            if ($ip) { return $ip }
        }
    } catch { }

    # Metoda 3: zwykle zapytanie HTTP jako ostatnia deska ratunku - jesli
    # obie proby po DNS zawiodly (np. siec blokuje zapytania do obcych
    # serwerow DNS), zwykla strona przez HTTPS zwykle dziala.
    foreach ($url in @('https://api.ipify.org', 'https://icanhazip.com')) {
        try {
            $odp = Invoke-RestMethod -Uri $url -TimeoutSec 5 -ErrorAction Stop
            $ip  = "$odp".Trim()
            if ($ip -match '^\d{1,3}(\.\d{1,3}){3}$' -or $ip -match ':') { return $ip }
        } catch { }
    }

    return $null
}

# Prosty test predkosci pobierania - jeden strumien, jeden serwer
# (speed.cloudflare.com, publiczny i bez klucza API). To NIE jest pelny
# test jak speedtest.net (tam mierzy sie kilkoma polaczeniami naraz) -
# na bardzo szybkich laczach (900+ Mb/s) wynik bywa nizszy od realnego,
# bo jedno polaczenie TCP samo potrafi byc waskim gardlem. Traktowac
# jako orientacyjny odczyt, nie wyrocznie.
function Measure-Predkosc {
    param([long]$Bajtow = 20000000, [int]$TimeoutSec = 20)
    $url = "https://speed.cloudflare.com/__down?bytes=$Bajtow"
    try {
        $sw  = [System.Diagnostics.Stopwatch]::StartNew()
        $odp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec $TimeoutSec -ErrorAction Stop
        $sw.Stop()
        $sek = $sw.Elapsed.TotalSeconds
        $bajty = [int64]$odp.RawContentLength
        if ($bajty -le 0 -and $odp.Content) { $bajty = [int64]$odp.Content.Length }
        if ($sek -le 0 -or $bajty -le 0) { return @{ ok = $false } }
        $mbps = [math]::Round((($bajty * 8) / $sek) / 1MB, 1)
        return @{ ok = $true; mbps = $mbps; mb = [math]::Round($bajty / 1MB, 1); sek = [math]::Round($sek, 1) }
    } catch {
        return @{ ok = $false }
    }
}

# To samo, w druga strone - wysylamy losowe dane na speed.cloudflare.com
# (endpoint __up) i mierzymy czas. Domyslnie mniejsza porcja niz przy
# pobieraniu, bo lacza domowe sa zwykle mocno asymetryczne (wysylanie
# duzo wolniejsze) - nie ma sensu czekac dlugo na wynik, ktory i tak
# jest tylko orientacyjny.
function Measure-PredkoscWysylania {
    param([long]$Bajtow = 8000000, [int]$TimeoutSec = 20)
    $url = "https://speed.cloudflare.com/__up"
    try {
        $dane = New-Object byte[] $Bajtow
        (New-Object System.Random).NextBytes($dane)
        $sw  = [System.Diagnostics.Stopwatch]::StartNew()
        $null = Invoke-WebRequest -Uri $url -Method Post -Body $dane -UseBasicParsing -TimeoutSec $TimeoutSec -ErrorAction Stop
        $sw.Stop()
        $sek = $sw.Elapsed.TotalSeconds
        if ($sek -le 0) { return @{ ok = $false } }
        $mbps = [math]::Round((($Bajtow * 8) / $sek) / 1MB, 1)
        return @{ ok = $true; mbps = $mbps; mb = [math]::Round($Bajtow / 1MB, 1); sek = [math]::Round($sek, 1) }
    } catch {
        return @{ ok = $false }
    }
}

# Traceroute z czasem na kazdym skoku - wlasna implementacja na ICMP
# (rosnace TTL), bez wywolywania tracert.exe i parsowania jego tekstu.
# Kazdy skok probujemy do 3 razy, zanim uznamy go za "nie odpowiada" -
# routery posrednie czesto ograniczaja ICMP i pojedyncza cisza nic nie
# znaczy, ale trzy ciszy z rzedu to prawdopodobnie blokada na tym wezle.
function Get-Traceroute {
    param([string]$Cel, [int]$MaxSkokow = 20, [int]$TimeoutMs = 1000, [scriptblock]$Postep = $null)
    $wyniki  = New-Object System.Collections.ArrayList
    $ping    = New-Object System.Net.NetworkInformation.Ping
    $bufor   = [byte[]](0..31 | ForEach-Object { 0 })
    $dotarto = $false
    for ($ttl = 1; $ttl -le $MaxSkokow -and -not $dotarto; $ttl++) {
        $opts   = New-Object System.Net.NetworkInformation.PingOptions ($ttl, $true)
        $czasy  = New-Object System.Collections.ArrayList
        $adres  = $null
        for ($proba = 0; $proba -lt 3; $proba++) {
            try {
                $r = $ping.Send($Cel, $TimeoutMs, $bufor, $opts)
                if ($r -and $r.Address -and -not $adres) { $adres = $r.Address.ToString() }
                if ($r -and ($r.Status -eq [System.Net.NetworkInformation.IPStatus]::TtlExpired -or
                             $r.Status -eq [System.Net.NetworkInformation.IPStatus]::Success)) {
                    [void]$czasy.Add([double]$r.RoundtripTime)
                    if ($r.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) { $dotarto = $true }
                }
            } catch { }
        }
        $srednia = 0
        if ($czasy.Count -gt 0) { $srednia = [math]::Round((($czasy | Measure-Object -Average).Average), 0) }
        [void]$wyniki.Add(@{
            skok        = $ttl
            adres       = $(if ($adres) { $adres } else { $null })
            czas        = $srednia
            odpowiedzial= ($czasy.Count -gt 0)
        })
        if ($Postep) { & $Postep }
    }
    return ,$wyniki
}
'@

# =====================================================================
#  TRYBY POMOCNICZE
# =====================================================================
if ($Tryb -ne '') {

    function Info { param($m) Write-Host "  $m" -ForegroundColor Gray }
    function Ok   { param($m) Write-Host "  $m" -ForegroundColor Green }
    function Uwaga{ param($m) Write-Host "  $m" -ForegroundColor Yellow }
    function Blad { param($m) Write-Host "  $m" -ForegroundColor Red }

    switch ($Tryb.ToLower()) {

    'ikona' {
        $cel = Join-Path (Split-Path -Parent $PSCommandPath) 'SprawdzLacze.ico'
        if (Zapisz-Ikone $cel) { Ok "Zapisano: $cel" } else { Blad 'Nie udalo sie zapisac ikony.' }
        Write-Host ''
        Read-Host '  Enter konczy'
        exit 0
    }

    # -----------------------------------------------------------------
    'instaluj' {
        $ErrorActionPreference = 'Stop'
        Write-Host ''
        Write-Host '  ==============================================' -ForegroundColor Cyan
        Write-Host "     Instalacja: $AppNazwa $AppWersja"            -ForegroundColor Cyan
        Write-Host '  ==============================================' -ForegroundColor Cyan
        Write-Host ''

        $Zrodlo = $PSCommandPath
        if (-not $Zrodlo) { $Zrodlo = $MyInvocation.MyCommand.Path }

        $KatInst = Join-Path $env:LOCALAPPDATA "Programs\$AppKlucz"
        $DstPs1  = Join-Path $KatInst 'SprawdzLacze.ps1'
        $DstIco  = Join-Path $KatInst 'SprawdzLacze.ico'
        $DstUni  = Join-Path $KatInst 'Odinstaluj.ps1'

        Info "Katalog: $KatInst"
        if (-not (Test-Path $KatInst)) { New-Item -ItemType Directory -Path $KatInst -Force | Out-Null }

        Copy-Item -LiteralPath $Zrodlo -Destination $DstPs1 -Force
        Unblock-File -LiteralPath $DstPs1 -ErrorAction SilentlyContinue
        $MaIkone = Zapisz-Ikone $DstIco
        if (-not $MaIkone) { Uwaga 'Nie udalo sie zapisac ikony - skrot dostanie ikone PowerShella.' }
        Ok 'Pliki na miejscu.'

        $Uninst = @'
Add-Type -AssemblyName System.Windows.Forms
$AppName = 'Sprawdzanie Lacza'
$Klucz   = 'SprawdzLacze'
$Dir     = Split-Path -Parent $MyInvocation.MyCommand.Path

$a = [System.Windows.Forms.MessageBox]::Show(
    "Usunac $AppName z tego komputera?", "Deinstalacja", 'YesNo', 'Question')
if ($a -ne 'Yes') { exit }

$paths = @(
    (Join-Path ([Environment]::GetFolderPath('Desktop')) "$AppName.lnk"),
    (Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\$AppName.lnk")
)
foreach ($p in $paths) { Remove-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue }

Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$Klucz" `
            -Recurse -Force -ErrorAction SilentlyContinue

Start-Process cmd.exe -ArgumentList '/c','timeout /t 2 /nobreak >nul & rmdir /s /q',"`"$Dir`"" `
              -WindowStyle Hidden

[System.Windows.Forms.MessageBox]::Show("$AppName zostal usuniety.", "Deinstalacja") | Out-Null
'@
        Set-Content -LiteralPath $DstUni -Value $Uninst -Encoding UTF8

        $PsExe   = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
        $LnkArgs = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$DstPs1`""

        function Nowy-Skrot {
            param([string]$Sciezka)
            $ws  = New-Object -ComObject WScript.Shell
            $lnk = $ws.CreateShortcut($Sciezka)
            $lnk.TargetPath       = $PsExe
            $lnk.Arguments        = $LnkArgs
            $lnk.WorkingDirectory = $KatInst
            $lnk.Description      = "Diagnostyka lacza by $AppAutor"
            if ($MaIkone) { $lnk.IconLocation = "$DstIco,0" }
            $lnk.Save()
        }

        Nowy-Skrot (Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\$AppNazwa.lnk")
        Ok 'Menu Start: gotowe.'

        Write-Host ''
        $mk = Read-Host '  Utworzyc skrot na pulpicie? [T/n]'
        if ($mk -eq '' -or $mk -match '^[tTyY]') {
            Nowy-Skrot (Join-Path ([Environment]::GetFolderPath('Desktop')) "$AppNazwa.lnk")
            Ok 'Pulpit: gotowe.'
        } else { Info 'Pominieto skrot na pulpicie.' }

        $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppKlucz"
        if (-not (Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
        $rozmiar = 0
        try {
            $rozmiar = [int][math]::Round(((Get-ChildItem $KatInst -Recurse -File |
                       Measure-Object Length -Sum).Sum / 1KB), 0)
        } catch { }
        $props = @{
            DisplayName     = $AppNazwa
            DisplayVersion  = $AppWersja
            Publisher       = $AppAutor
            InstallLocation = $KatInst
            UninstallString = "`"$PsExe`" -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$DstUni`""
            NoModify        = 1
            NoRepair        = 1
            EstimatedSize   = $rozmiar
        }
        if ($MaIkone) { $props['DisplayIcon'] = $DstIco }
        foreach ($k in $props.Keys) {
            $typ = 'String'
            if ($props[$k] -is [int]) { $typ = 'DWord' }
            New-ItemProperty -Path $RegPath -Name $k -Value $props[$k] -PropertyType $typ -Force | Out-Null
        }
        Ok 'Zarejestrowano - widoczny w Ustawieniach Windows.'

        Write-Host ''
        Write-Host '  ==============================================' -ForegroundColor Green
        Write-Host '     ZAINSTALOWANO'                               -ForegroundColor Green
        Write-Host '  ==============================================' -ForegroundColor Green
        Write-Host ''
        Info 'Uruchamiasz z Menu Start albo z pulpitu.'
        Write-Host ''
        Read-Host '  Enter konczy'
        exit 0
    }

    # -----------------------------------------------------------------
    'konsola' {
        Invoke-Expression $KodPomiaru

        function Wiersz {
            param([string]$E, [string]$W, [string]$S = '')
            $k = 'Gray'
            if ($S -eq 'ok')   { $k = 'Green' }
            if ($S -eq 'warn') { $k = 'Yellow' }
            if ($S -eq 'err')  { $k = 'Red' }
            Write-Host ("  {0,-26}" -f $E) -NoNewline -ForegroundColor DarkGray
            Write-Host $W -ForegroundColor $k
        }
        function Naglowek {
            param([string]$T)
            Write-Host ''
            Write-Host ("  " + $T) -ForegroundColor Cyan
            Write-Host ("  " + ('-' * $T.Length)) -ForegroundColor DarkGray
        }

        Clear-Host
        Write-Host ''
        Write-Host "  $AppNazwa $AppWersja" -ForegroundColor White
        Write-Host "  by $AppAutor" -ForegroundColor DarkGray

        Naglowek 'KARTA'
        $ad = Get-Karta
        if (-not $ad) {
            Wiersz 'Stan' 'brak aktywnego polaczenia' 'err'
            Read-Host '  Enter konczy'
            exit 1
        }
        Wiersz 'Karta' "$($ad.InterfaceDescription)"
        Wiersz 'Predkosc linku' "$($ad.LinkSpeed)"
        $wifi = $false
        try { $wifi = ("$($ad.PhysicalMediaType)" -match '802.11') } catch { }
        Wiersz 'Typ' $(if ($wifi) { 'Wi-Fi' } else { 'kabel' })
        if ($wifi) {
            $w = Get-Wifi
            if ($w.sygnal) {
                $s = 'ok'
                if ($w.sygnal -lt 50) { $s = 'err' } elseif ($w.sygnal -lt 70) { $s = 'warn' }
                Wiersz 'Sila sygnalu' "$($w.sygnal) %" $s
            }
            if ($w.radio) { Wiersz 'Standard' $w.radio }
            if ($w.pasmo) { Wiersz 'Pasmo' $w.pasmo }
        }

        $brama = Get-Brama
        $g = @{ ok=$false; jitter=0; loss=0 }
        if ($brama) {
            Naglowek "PING DO ROUTERA ($brama)"
            Write-Host '  ' -NoNewline
            $g = Measure-Ping $brama 10 { Write-Host '.' -NoNewline -ForegroundColor DarkGray }
            Write-Host ''
            if ($g.ok) {
                $s = 'ok'
                if ($g.jitter -gt 5 -or $g.loss -gt 0) { $s = 'err' } elseif ($g.jitter -gt 2) { $s = 'warn' }
                Wiersz 'Srednia' "$($g.avg) ms"
                Wiersz 'Jitter' "$($g.jitter) ms" $s
                Wiersz 'Straty' "$($g.loss) %" $(if ($g.loss -gt 0) { 'err' } else { 'ok' })
            } else { Wiersz 'Wynik' 'brak odpowiedzi' 'err' }
        }

        Naglowek 'PING DO INTERNETU (1.1.1.1)'
        Write-Host '  ' -NoNewline
        $c = Measure-Ping '1.1.1.1' 10 { Write-Host '.' -NoNewline -ForegroundColor DarkGray }
        Write-Host ''
        if ($c.ok) {
            $s = 'ok'
            if ($c.avg -gt 80) { $s = 'err' } elseif ($c.avg -gt 40) { $s = 'warn' }
            Wiersz 'Srednia' "$($c.avg) ms" $s
            Wiersz 'Min / max' "$($c.min) / $($c.max) ms"
            Wiersz 'Jitter' "$($c.jitter) ms" $(if ($c.jitter -gt 10) { 'warn' } else { 'ok' })
            Wiersz 'Straty' "$($c.loss) %" $(if ($c.loss -gt 0) { 'err' } else { 'ok' })
        } else { Wiersz 'Wynik' 'brak odpowiedzi' 'err' }

        Naglowek 'WNIOSEK'
        if ($brama -and $g.ok -and ($g.jitter -gt 5 -or $g.loss -gt 0)) {
            Wiersz 'Diagnoza' 'Problem MIEDZY komputerem a routerem.' 'err'
        } elseif ($c.ok -and $c.loss -gt 0) {
            Wiersz 'Diagnoza' 'Pakiety gina za routerem - strona operatora.' 'warn'
        } elseif ($wifi -and $c.ok -and $c.jitter -gt 10) {
            Wiersz 'Diagnoza' 'Jitter wysoki jak na Wi-Fi - kabel pomoze.' 'warn'
        } elseif ($c.ok) {
            Wiersz 'Diagnoza' 'Lacze zachowuje sie prawidlowo.' 'ok'
        } else {
            Wiersz 'Diagnoza' 'Brak polaczenia z internetem.' 'err'
        }

        Naglowek 'PUBLICZNY ADRES IP'
        $pubIP = Get-PublicznyIP
        if ($pubIP) {
            Wiersz 'Adres' $pubIP
            Write-Host '  Jesli inny niz WAN na stronie routera - prawdopodobnie CGNAT.' -ForegroundColor DarkGray
        } else {
            Wiersz 'Wynik' 'nie udalo sie odczytac' 'warn'
        }

        Naglowek 'PREDKOSC POBIERANIA (orientacyjnie)'
        Write-Host '  mierze...' -ForegroundColor DarkGray
        $pred = Measure-Predkosc
        if ($pred.ok) {
            $s = 'ok'
            if ($pred.mbps -lt 20) { $s = 'err' } elseif ($pred.mbps -lt 50) { $s = 'warn' }
            Wiersz 'Predkosc' ("$($pred.mbps) Mb/s  (pobrano $($pred.mb) MB w $($pred.sek) s)") $s
        } else {
            Wiersz 'Wynik' 'nie udalo sie zmierzyc' 'warn'
        }

        Naglowek 'PREDKOSC WYSYLANIA (orientacyjnie)'
        Write-Host '  mierze...' -ForegroundColor DarkGray
        $predUp = Measure-PredkoscWysylania
        if ($predUp.ok) {
            $s = 'ok'
            if ($predUp.mbps -lt 5) { $s = 'err' } elseif ($predUp.mbps -lt 15) { $s = 'warn' }
            Wiersz 'Predkosc' ("$($predUp.mbps) Mb/s  (wyslano $($predUp.mb) MB w $($predUp.sek) s)") $s
        } else {
            Wiersz 'Wynik' 'nie udalo sie zmierzyc' 'warn'
        }

        Naglowek 'TRASA DO INTERNETU (traceroute, orientacyjnie)'
        Write-Host '  ' -NoNewline
        $trasa = Get-Traceroute -Cel '1.1.1.1' -MaxSkokow 18 -TimeoutMs 700 { Write-Host '.' -NoNewline -ForegroundColor DarkGray }
        Write-Host ''
        foreach ($skok in $trasa) {
            if (-not $skok.odpowiedzial) {
                Wiersz "Skok $($skok.skok)" '* brak odpowiedzi'
            } else {
                $s = 'ok'
                if ($skok.czas -gt 80) { $s = 'err' } elseif ($skok.czas -gt 40) { $s = 'warn' }
                $adresTxt = if ($skok.adres) { $skok.adres } else { '?' }
                Wiersz "Skok $($skok.skok)" "$adresTxt   -   $($skok.czas) ms" $s
            }
        }

        Naglowek 'SERWERY GIER (orientacyjnie)'
        Write-Host '  ' -NoNewline
        $wynikiGier = Measure-Serwery $SerweryGier 6 { Write-Host '.' -NoNewline -ForegroundColor DarkGray }
        Write-Host ''
        foreach ($wg in $wynikiGier) {
            if ($wg.ok) {
                $s = 'ok'
                if ($wg.avg -gt 100 -or $wg.loss -gt 0) { $s = 'warn' }
                Wiersz $wg.nazwa ("$($wg.avg) ms, jitter $($wg.jitter) ms, straty $($wg.loss)%") $s
            } else {
                Wiersz $wg.nazwa 'brak odpowiedzi' ''
            }
        }

        Naglowek 'USTAWIENIA STEROWNIKA KARTY'
        $wl = Get-WlasciwosciKarty $ad
        if ($wl.Count -eq 0) {
            Write-Host '  Sterownik nie udostepnia zadnej z monitorowanych wlasciwosci.' -ForegroundColor DarkGray
        } else {
            foreach ($p in $wl) {
                Wiersz $p.nazwa $(if ($p.wylaczone) { 'wylaczone' } else { "wlaczone (wartosc: $($p.wartosc))" }) `
                       $(if ($p.wylaczone) { 'ok' } else { 'warn' })
            }
        }

        Write-Host ''
        Write-Host '  Gotowe. Nic nie zostalo zmienione - to byl wylacznie odczyt.' -ForegroundColor DarkGray
        Write-Host ''
        Read-Host '  Enter konczy'
        exit 0
    }

    default {
        Blad "Nieznany tryb: $Tryb"
        Info 'Dostepne: instaluj, konsola, ikona'
        exit 1
    }
    }
}

# =====================================================================
#  OKNO
# =====================================================================
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

[xml]$XAML = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Sprawdzanie Lacza" Height="720" Width="580"
        WindowStartupLocation="CenterScreen" WindowStyle="None" Opacity="0"
        AllowsTransparency="True" Background="Transparent" ResizeMode="CanMinimize"
        FontFamily="Segoe UI" TextOptions.TextFormattingMode="Display"
        UseLayoutRounding="True" SnapsToDevicePixels="True">
  <Window.Resources>
    <SolidColorBrush x:Key="Bg"      Color="#0B0F18"/>
    <SolidColorBrush x:Key="Surface" Color="#151C29"/>
    <SolidColorBrush x:Key="Line"    Color="#233043"/>
    <SolidColorBrush x:Key="Txt"     Color="#E8EDF5"/>
    <SolidColorBrush x:Key="Muted"   Color="#8B98A9"/>
    <SolidColorBrush x:Key="Dim"     Color="#5C6B80"/>
    <SolidColorBrush x:Key="Accent"  Color="#38BDF8"/>

    <CubicEase x:Key="EaseOut" EasingMode="EaseOut"/>

    <LinearGradientBrush x:Key="Grad" StartPoint="0,0" EndPoint="1,1">
      <GradientStop Color="#38BDF8" Offset="0"/>
      <GradientStop Color="#34D399" Offset="1"/>
    </LinearGradientBrush>
    <LinearGradientBrush x:Key="GradHot" StartPoint="0,0" EndPoint="1,1">
      <GradientStop Color="#7DD3FC" Offset="0"/>
      <GradientStop Color="#6EE7B7" Offset="1"/>
    </LinearGradientBrush>
    <LinearGradientBrush x:Key="HeadGrad" StartPoint="0,0" EndPoint="1,0">
      <GradientStop Color="#111827" Offset="0"/>
      <GradientStop Color="#16202F" Offset="0.6"/>
      <GradientStop Color="#111827" Offset="1"/>
    </LinearGradientBrush>
    <LinearGradientBrush x:Key="Sheen" StartPoint="0,0" EndPoint="0,1">
      <GradientStop Color="#38FFFFFF" Offset="0"/>
      <GradientStop Color="#00FFFFFF" Offset="0.55"/>
    </LinearGradientBrush>

    <Style x:Key="Glowny" TargetType="Button">
      <Setter Property="Foreground" Value="#08121B"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="FontSize" Value="13"/>
      <Setter Property="Height" Value="42"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Grid x:Name="wrap">
              <Border x:Name="glow" CornerRadius="12" Margin="-2" Background="{StaticResource Grad}" Opacity="0">
                <Border.Effect>
                  <BlurEffect Radius="14"/>
                </Border.Effect>
              </Border>
              <Border x:Name="bg" CornerRadius="10" Background="{StaticResource Grad}">
                <Grid>
                  <Border x:Name="hot" CornerRadius="10" Background="{StaticResource GradHot}" Opacity="0"/>
                  <Border x:Name="sheen" CornerRadius="10" Background="{StaticResource Sheen}" Opacity="0.5"/>
                  <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="18,0"/>
                </Grid>
              </Border>
            </Grid>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Trigger.EnterActions>
                  <BeginStoryboard>
                    <Storyboard>
                      <DoubleAnimation Storyboard.TargetName="glow" Storyboard.TargetProperty="Opacity" To="0.55" Duration="0:0:0.2"/>
                      <DoubleAnimation Storyboard.TargetName="hot" Storyboard.TargetProperty="Opacity" To="1" Duration="0:0:0.2"/>
                      <ThicknessAnimation Storyboard.TargetName="wrap" Storyboard.TargetProperty="Margin" To="-1.5" Duration="0:0:0.2" EasingFunction="{StaticResource EaseOut}"/>
                    </Storyboard>
                  </BeginStoryboard>
                </Trigger.EnterActions>
                <Trigger.ExitActions>
                  <BeginStoryboard>
                    <Storyboard>
                      <DoubleAnimation Storyboard.TargetName="glow" Storyboard.TargetProperty="Opacity" To="0" Duration="0:0:0.3"/>
                      <DoubleAnimation Storyboard.TargetName="hot" Storyboard.TargetProperty="Opacity" To="0" Duration="0:0:0.3"/>
                      <ThicknessAnimation Storyboard.TargetName="wrap" Storyboard.TargetProperty="Margin" To="0" Duration="0:0:0.28" EasingFunction="{StaticResource EaseOut}"/>
                    </Storyboard>
                  </BeginStoryboard>
                </Trigger.ExitActions>
              </Trigger>
              <Trigger Property="IsPressed" Value="True">
                <Trigger.EnterActions>
                  <BeginStoryboard>
                    <Storyboard>
                      <ThicknessAnimation Storyboard.TargetName="wrap" Storyboard.TargetProperty="Margin" To="2.5" Duration="0:0:0.07"/>
                    </Storyboard>
                  </BeginStoryboard>
                </Trigger.EnterActions>
                <Trigger.ExitActions>
                  <BeginStoryboard>
                    <Storyboard>
                      <ThicknessAnimation Storyboard.TargetName="wrap" Storyboard.TargetProperty="Margin" To="-1.5" Duration="0:0:0.18" EasingFunction="{StaticResource EaseOut}"/>
                    </Storyboard>
                  </BeginStoryboard>
                </Trigger.ExitActions>
              </Trigger>
              <Trigger Property="IsEnabled" Value="False">
                <Setter Property="Opacity" Value="0.35"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="Drugi" TargetType="Button">
      <Setter Property="Foreground" Value="{StaticResource Muted}"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="FontSize" Value="12"/>
      <Setter Property="Height" Value="42"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Grid x:Name="wrap">
              <Border x:Name="base" CornerRadius="10" Background="#101828" BorderBrush="#233043" BorderThickness="1"/>
              <Border x:Name="hov" CornerRadius="10" Background="#17293C" BorderBrush="{StaticResource Accent}" BorderThickness="1" Opacity="0"/>
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="16,0"/>
            </Grid>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Foreground" Value="{StaticResource Txt}"/>
                <Trigger.EnterActions>
                  <BeginStoryboard>
                    <Storyboard>
                      <DoubleAnimation Storyboard.TargetName="hov" Storyboard.TargetProperty="Opacity" To="1" Duration="0:0:0.16"/>
                      <ThicknessAnimation Storyboard.TargetName="wrap" Storyboard.TargetProperty="Margin" To="-1.5" Duration="0:0:0.2" EasingFunction="{StaticResource EaseOut}"/>
                    </Storyboard>
                  </BeginStoryboard>
                </Trigger.EnterActions>
                <Trigger.ExitActions>
                  <BeginStoryboard>
                    <Storyboard>
                      <DoubleAnimation Storyboard.TargetName="hov" Storyboard.TargetProperty="Opacity" To="0" Duration="0:0:0.26"/>
                      <ThicknessAnimation Storyboard.TargetName="wrap" Storyboard.TargetProperty="Margin" To="0" Duration="0:0:0.26" EasingFunction="{StaticResource EaseOut}"/>
                    </Storyboard>
                  </BeginStoryboard>
                </Trigger.ExitActions>
              </Trigger>
              <Trigger Property="IsEnabled" Value="False">
                <Setter Property="Opacity" Value="0.3"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="Ikonka" TargetType="Button">
      <Setter Property="Foreground" Value="#8B98A9"/>
      <Setter Property="FontSize" Value="13"/>
      <Setter Property="Width" Value="42"/>
      <Setter Property="Height" Value="44"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Grid>
              <Border x:Name="hov" Background="#233043" Opacity="0"/>
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Grid>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Foreground" Value="#E8EDF5"/>
                <Trigger.EnterActions>
                  <BeginStoryboard>
                    <Storyboard>
                      <DoubleAnimation Storyboard.TargetName="hov" Storyboard.TargetProperty="Opacity" To="1" Duration="0:0:0.14"/>
                    </Storyboard>
                  </BeginStoryboard>
                </Trigger.EnterActions>
                <Trigger.ExitActions>
                  <BeginStoryboard>
                    <Storyboard>
                      <DoubleAnimation Storyboard.TargetName="hov" Storyboard.TargetProperty="Opacity" To="0" Duration="0:0:0.22"/>
                    </Storyboard>
                  </BeginStoryboard>
                </Trigger.ExitActions>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="IkonkaX" TargetType="Button" BasedOn="{StaticResource Ikonka}">
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Grid>
              <Border x:Name="hov" Background="#D32B48" Opacity="0"/>
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Grid>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Foreground" Value="White"/>
                <Trigger.EnterActions>
                  <BeginStoryboard>
                    <Storyboard>
                      <DoubleAnimation Storyboard.TargetName="hov" Storyboard.TargetProperty="Opacity" To="1" Duration="0:0:0.14"/>
                    </Storyboard>
                  </BeginStoryboard>
                </Trigger.EnterActions>
                <Trigger.ExitActions>
                  <BeginStoryboard>
                    <Storyboard>
                      <DoubleAnimation Storyboard.TargetName="hov" Storyboard.TargetProperty="Opacity" To="0" Duration="0:0:0.22"/>
                    </Storyboard>
                  </BeginStoryboard>
                </Trigger.ExitActions>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style TargetType="ProgressBar">
      <Setter Property="Height" Value="4"/>
      <Setter Property="Foreground" Value="{StaticResource Grad}"/>
      <Setter Property="Background" Value="#16202F"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ProgressBar">
            <Border CornerRadius="2" Background="{TemplateBinding Background}" ClipToBounds="True">
              <Border x:Name="fala" Background="{TemplateBinding Foreground}" CornerRadius="2"
                      HorizontalAlignment="Left" Width="150" Opacity="0" Margin="-150,0,0,0"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="Tag" Value="busy">
                <Trigger.EnterActions>
                  <BeginStoryboard x:Name="sbFala">
                    <Storyboard RepeatBehavior="Forever">
                      <DoubleAnimation Storyboard.TargetName="fala" Storyboard.TargetProperty="Opacity"
                                       To="1" Duration="0:0:0.2"/>
                      <ThicknessAnimation Storyboard.TargetName="fala" Storyboard.TargetProperty="Margin"
                                          From="-150,0,0,0" To="580,0,0,0" Duration="0:0:1.4"/>
                    </Storyboard>
                  </BeginStoryboard>
                </Trigger.EnterActions>
                <Trigger.ExitActions>
                  <StopStoryboard BeginStoryboardName="sbFala"/>
                  <BeginStoryboard>
                    <Storyboard>
                      <DoubleAnimation Storyboard.TargetName="fala" Storyboard.TargetProperty="Opacity"
                                       To="0" Duration="0:0:0.25"/>
                    </Storyboard>
                  </BeginStoryboard>
                </Trigger.ExitActions>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style TargetType="ScrollBar">
      <Setter Property="Width" Value="8"/>
      <Setter Property="Background" Value="Transparent"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ScrollBar">
            <Grid Background="Transparent">
              <Track x:Name="PART_Track" IsDirectionReversed="True">
                <Track.Thumb>
                  <Thumb x:Name="th">
                    <Thumb.Template>
                      <ControlTemplate TargetType="Thumb">
                        <Border Background="#2C3B52" CornerRadius="4" Margin="2,0"/>
                      </ControlTemplate>
                    </Thumb.Template>
                  </Thumb>
                </Track.Thumb>
                <Track.IncreaseRepeatButton>
                  <RepeatButton Command="ScrollBar.PageDownCommand" Opacity="0" Focusable="False"/>
                </Track.IncreaseRepeatButton>
                <Track.DecreaseRepeatButton>
                  <RepeatButton Command="ScrollBar.PageUpCommand" Opacity="0" Focusable="False"/>
                </Track.DecreaseRepeatButton>
              </Track>
            </Grid>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Trigger.EnterActions>
                  <BeginStoryboard>
                    <Storyboard>
                      <DoubleAnimation Storyboard.TargetName="th" Storyboard.TargetProperty="Opacity" To="1" Duration="0:0:0.15"/>
                    </Storyboard>
                  </BeginStoryboard>
                </Trigger.EnterActions>
                <Trigger.ExitActions>
                  <BeginStoryboard>
                    <Storyboard>
                      <DoubleAnimation Storyboard.TargetName="th" Storyboard.TargetProperty="Opacity" To="0.75" Duration="0:0:0.25"/>
                    </Storyboard>
                  </BeginStoryboard>
                </Trigger.ExitActions>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
  </Window.Resources>

  <Border x:Name="Root" Background="{StaticResource Bg}" CornerRadius="14"
          BorderBrush="{StaticResource Line}" BorderThickness="1" RenderTransformOrigin="0.5,0.5">
    <Border.RenderTransform>
      <ScaleTransform x:Name="RootScale" ScaleX="0.985" ScaleY="0.985"/>
    </Border.RenderTransform>
    <Grid>
      <Grid.RowDefinitions>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="*"/>
        <RowDefinition Height="Auto"/>
      </Grid.RowDefinitions>

      <!-- pasek tytulu -->
      <Grid x:Name="Pasek" Grid.Row="0" Background="{StaticResource HeadGrad}" Height="44">
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <Border Height="1" VerticalAlignment="Bottom" Background="#1B2636"/>
        <StackPanel Orientation="Horizontal" VerticalAlignment="Center" Margin="16,0,0,0">
          <Border Width="24" Height="24" CornerRadius="8" Background="{StaticResource Grad}">
            <TextBlock Text="&#xE839;" FontFamily="Segoe MDL2 Assets" FontSize="11" Foreground="#08121B"
                       HorizontalAlignment="Center" VerticalAlignment="Center"/>
          </Border>
          <TextBlock Text="Sprawdzanie Łącza" Foreground="{StaticResource Txt}" FontSize="13"
                     FontWeight="SemiBold" VerticalAlignment="Center" Margin="10,0,0,0"/>
          <Border Background="#16202F" CornerRadius="6" Padding="7,1,7,2" Margin="8,1,0,0" VerticalAlignment="Center">
            <TextBlock x:Name="Wersja" Text="" Foreground="{StaticResource Muted}" FontSize="10.5"/>
          </Border>
        </StackPanel>
        <StackPanel Grid.Column="1" Orientation="Horizontal">
          <Button x:Name="BtnMin"   Content="&#xE921;" FontFamily="Segoe MDL2 Assets" FontSize="10" Style="{StaticResource Ikonka}"/>
          <Button x:Name="BtnClose" Content="&#xE8BB;" FontFamily="Segoe MDL2 Assets" FontSize="10" Style="{StaticResource IkonkaX}"/>
        </StackPanel>
      </Grid>

      <!-- naglowek -->
      <Border Grid.Row="1" Background="{StaticResource Surface}" BorderBrush="{StaticResource Line}"
              BorderThickness="0,0,0,1" Padding="20,16">
        <StackPanel x:Name="Naglowek">
          <TextBlock Text="Gdzie naprawdę jest problem?" Foreground="{StaticResource Txt}" FontSize="15" FontWeight="SemiBold"/>
          <TextBlock Text="Program mierzy opóźnienie, jitter i straty pakietów osobno do routera i osobno do internetu. Jeśli ping do routera skacze, winne jest Wi-Fi albo kabel — i żadne ustawienie systemu tego nie naprawi."
                     Foreground="{StaticResource Muted}" FontSize="11.5" TextWrapping="Wrap" Margin="0,7,0,0" LineHeight="18"/>
          <TextBlock Text="Nic nie jest zmieniane w systemie. Wyłącznie odczyt."
                     Foreground="{StaticResource Dim}" FontSize="11" Margin="0,7,0,0"/>
          <Grid Margin="0,15,0,0">
            <Grid.ColumnDefinitions>
              <ColumnDefinition Width="Auto"/>
              <ColumnDefinition Width="Auto"/>
              <ColumnDefinition Width="Auto"/>
              <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>
            <Button x:Name="BtnMierz" Grid.Column="0" Content="Zmierz łącze" Style="{StaticResource Glowny}" Width="170"/>
            <Button x:Name="BtnKopiuj" Grid.Column="1" Content="Kopiuj wynik" Style="{StaticResource Drugi}"
                    Width="140" Margin="10,0,0,0" IsEnabled="False"/>
            <Button x:Name="BtnZapisz" Grid.Column="2" Content="Zapisz do pliku" Style="{StaticResource Drugi}"
                    Width="140" Margin="10,0,0,0" IsEnabled="False" ToolTip="Zapisuje wynik do pliku tekstowego i dopisuje wpis do historii pomiarów"/>
          </Grid>
          <ProgressBar x:Name="Postep" Margin="0,14,0,0" Minimum="0" Maximum="100" Value="100"/>
        </StackPanel>
      </Border>

      <!-- wyniki -->
      <ScrollViewer x:Name="Przewijak" Grid.Row="2" VerticalScrollBarVisibility="Auto" Padding="20,14,14,14">
        <StackPanel x:Name="Wyniki"/>
      </ScrollViewer>

      <!-- stopka -->
      <Border Grid.Row="3" Background="#111827" Padding="20,11" CornerRadius="0,0,13,13">
        <Grid>
          <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
            <Border x:Name="Kropka" Width="7" Height="7" CornerRadius="4" Background="{StaticResource Accent}"
                    Opacity="0.25" Margin="0,0,9,0" VerticalAlignment="Center"/>
            <TextBlock x:Name="Status" Text="Gotowy." Foreground="{StaticResource Muted}" FontSize="11.5" VerticalAlignment="Center"/>
          </StackPanel>
          <TextBlock x:Name="Stopka" Text="" Foreground="{StaticResource Dim}" FontSize="11"
                     HorizontalAlignment="Right" VerticalAlignment="Center"/>
        </Grid>
      </Border>
    </Grid>

    <Border.Triggers>
      <EventTrigger RoutedEvent="FrameworkElement.Loaded">
        <BeginStoryboard>
          <Storyboard>
            <DoubleAnimation Storyboard.TargetName="RootScale" Storyboard.TargetProperty="ScaleX"
                             From="0.985" To="1" Duration="0:0:0.4" EasingFunction="{StaticResource EaseOut}"/>
            <DoubleAnimation Storyboard.TargetName="RootScale" Storyboard.TargetProperty="ScaleY"
                             From="0.985" To="1" Duration="0:0:0.4" EasingFunction="{StaticResource EaseOut}"/>
          </Storyboard>
        </BeginStoryboard>
      </EventTrigger>
    </Border.Triggers>
  </Border>
</Window>
'@

$Window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $XAML))

$UI = @{}
foreach ($n in 'Pasek','BtnMin','BtnClose','BtnMierz','Wyniki','Status','Wersja','Stopka',
               'Root','Naglowek','Przewijak','BtnKopiuj','BtnZapisz','Postep','Kropka') {
    $UI[$n] = $Window.FindName($n)
}
$UI.Wersja.Text = "v$AppWersja"
$UI.Stopka.Text = "by $AppAutor"

# ikona okna prosto z base64 - bez pliku na dysku
try {
    $bytes = [Convert]::FromBase64String(($IkonaB64 -replace '\s', ''))
    $ms = New-Object System.IO.MemoryStream(,$bytes)
    $bi = New-Object System.Windows.Media.Imaging.BitmapImage
    $bi.BeginInit(); $bi.StreamSource = $ms; $bi.CacheOption = 'OnLoad'; $bi.EndInit()
    $Window.Icon = $bi
} catch { }

$UI.Pasek.Add_MouseLeftButtonDown({ try { $Window.DragMove() } catch { } })
$UI.BtnMin.Add_Click({ $Window.WindowState = 'Minimized' })
$script:Zamykam = $false
function Zamknij-Okno {
    if ($script:Zamykam) { return }
    $script:Zamykam = $true
    try {
        $a = Anim 0 $null 150 0 $false
        $a.Add_Completed({ try { $Window.Close() } catch { } })
        $Window.BeginAnimation([Windows.UIElement]::OpacityProperty, $a)
        $t = New-Object Windows.Threading.DispatcherTimer
        $t.Interval = [TimeSpan]::FromMilliseconds(400)
        $t.Add_Tick({ $t.Stop(); try { $Window.Close() } catch { } }.GetNewClosure())
        $t.Start()
    } catch { $Window.Close() }
}
$UI.BtnClose.Add_Click({ Zamknij-Okno })

function Br { param([string]$Hex) (New-Object Windows.Media.BrushConverter).ConvertFromString($Hex) }

# =====================================================================
#  ANIMACJE
#  Kazdy wiersz dostaje wlasny pedzel i wlasna transformacje, wiec
#  podswietlenie jednego nie rusza pozostalych.
# =====================================================================
function Ease {
    $e = New-Object Windows.Media.Animation.CubicEase
    $e.EasingMode = 'EaseOut'
    return $e
}

function Anim {
    param([double]$To, $From = $null, [int]$Ms = 220, [int]$Delay = 0, [bool]$Ez = $true)
    $a = New-Object Windows.Media.Animation.DoubleAnimation
    if ($null -ne $From) { $a.From = [double]$From }
    $a.To = $To
    $a.Duration = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds($Ms))
    if ($Delay -gt 0) { $a.BeginTime = [TimeSpan]::FromMilliseconds($Delay) }
    if ($Ez) { $a.EasingFunction = (Ease) }
    return $a
}

function Zanik {
    param($El, [double]$To, [int]$Ms = 220, $From = $null, [int]$Delay = 0)
    if (-not $El) { return }
    try { $El.BeginAnimation([Windows.UIElement]::OpacityProperty, (Anim $To $From $Ms $Delay)) } catch { }
}

function Przesun {
    param($El, [double]$To, $From = $null, [int]$Ms = 260, [int]$Delay = 0)
    if (-not $El) { return }
    $t = $El.RenderTransform
    if (-not ($t -is [Windows.Media.TranslateTransform])) {
        $t = New-Object Windows.Media.TranslateTransform
        $El.RenderTransform = $t
    }
    try { $t.BeginAnimation([Windows.Media.TranslateTransform]::YProperty, (Anim $To $From $Ms $Delay)) } catch { }
}

function Barwa {
    param($Pedzel, [string]$Hex, [int]$Ms = 170)
    if (-not $Pedzel) { return }
    try {
        $c = New-Object Windows.Media.Animation.ColorAnimation
        $c.To = [Windows.Media.Color][Windows.Media.ColorConverter]::ConvertFromString($Hex)
        $c.Duration = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds($Ms))
        $Pedzel.BeginAnimation([Windows.Media.SolidColorBrush]::ColorProperty, $c)
    } catch { }
}

function Ozyw-Wiersz {
    param($El, [string]$Bg = '#151C29', [string]$BgHot = '#1C2738',
                [string]$Bd = '#233043', [string]$BdHot = '#31567A')
    if (-not $El) { return }
    $bgB = New-Object Windows.Media.SolidColorBrush ([Windows.Media.ColorConverter]::ConvertFromString($Bg))
    $bdB = New-Object Windows.Media.SolidColorBrush ([Windows.Media.ColorConverter]::ConvertFromString($Bd))
    $El.Background  = $bgB
    $El.BorderBrush = $bdB
    $El.Add_MouseEnter({ Barwa $bgB $BgHot 160; Barwa $bdB $BdHot 160; Przesun $El -2 $null 180 }.GetNewClosure())
    $El.Add_MouseLeave({ Barwa $bgB $Bg 240;    Barwa $bdB $Bd 240;    Przesun $El 0 $null 240 }.GetNewClosure())
}

# tresc pomiaru do schowka
$script:Raport = New-Object System.Collections.ArrayList


# Kolor I ikonka na kazdy stan wyniku - to one daja "kafelkom" charakter
# (ten sam jezyk wizualny co w OptiLauncherze: kolorowa poswiata + znaczek
# w zaokraglonym kwadraciku zamiast plaskiej kropki).
$Stany = @{
    'ok'   = @{ c = '#34D399'; ic = [char]0xE73E }   # CheckMark
    'warn' = @{ c = '#FBBF24'; ic = [char]0xE7BA }   # Warning
    'err'  = @{ c = '#FB7185'; ic = [char]0xE783 }   # ErrorBadge
    ''     = @{ c = '#60A5FA'; ic = [char]0xE946 }   # Info
}

function New-WynikBadge {
    # Ten sam "chip" co znaczki zadan w OptiLauncherze: zaokraglony
    # kwadracik z delikatnym gradientem i wlasna poswiata, tylko mniejszy -
    # dopasowany do wysokosci wiersza wyniku.
    param([string]$Glyph, [string]$Hex, [double]$Size = 30, [double]$GlyphSize = 13)
    $col = [Windows.Media.Color][Windows.Media.ColorConverter]::ConvertFromString($Hex)

    $badge = New-Object Windows.Controls.Border
    $badge.Width  = $Size
    $badge.Height = $Size
    $badge.CornerRadius = New-Object Windows.CornerRadius ($Size * 0.32)
    $badge.BorderThickness = New-Object Windows.Thickness 1
    $badge.BorderBrush = New-Object Windows.Media.SolidColorBrush (
        [Windows.Media.Color]::FromArgb(80, $col.R, $col.G, $col.B))

    $grad = New-Object Windows.Media.LinearGradientBrush
    $grad.StartPoint = New-Object Windows.Point 0,0
    $grad.EndPoint   = New-Object Windows.Point 1,1
    $stop1 = New-Object Windows.Media.GradientStop ([Windows.Media.Color]::FromArgb(58, $col.R, $col.G, $col.B)), 0
    $stop2 = New-Object Windows.Media.GradientStop ([Windows.Media.Color]::FromArgb(16, $col.R, $col.G, $col.B)), 1
    $grad.GradientStops.Add($stop1)
    $grad.GradientStops.Add($stop2)
    $badge.Background = $grad

    $badge.Effect = New-Object Windows.Media.Effects.DropShadowEffect -Property @{
        Color = $col; Opacity = 0.30; BlurRadius = 10; ShadowDepth = 0
    }

    $ico = New-Object Windows.Controls.TextBlock
    $ico.Text = $Glyph
    $ico.FontFamily = New-Object Windows.Media.FontFamily 'Segoe MDL2 Assets'
    $ico.FontSize = $GlyphSize
    $ico.Foreground = New-Object Windows.Media.SolidColorBrush $col
    $ico.HorizontalAlignment = 'Center'
    $ico.VerticalAlignment   = 'Center'
    $badge.Child = $ico
    return $badge
}

function Dodaj-Wiersz {
    param([string]$Etykieta, [string]$Wartosc, [string]$Stan = '', [bool]$Naglowek = $false)

    if ($Naglowek) {
        # Krotka, pionowa kreska w gradiencie akcentu zamiast samego tekstu -
        # ten sam motyw co pasek na przycisku "Zmierz lacze".
        $sp = New-Object Windows.Controls.StackPanel
        $sp.Orientation = 'Horizontal'
        $sp.Margin = New-Object Windows.Thickness 2,16,0,8

        $bar = New-Object Windows.Controls.Border
        $bar.Width = 3; $bar.Height = 13
        $bar.CornerRadius = New-Object Windows.CornerRadius 2
        $bar.VerticalAlignment = 'Center'
        $bar.Margin = New-Object Windows.Thickness 0,0,8,0
        $barGrad = New-Object Windows.Media.LinearGradientBrush
        $barGrad.StartPoint = New-Object Windows.Point 0,0
        $barGrad.EndPoint   = New-Object Windows.Point 0,1
        $barGrad.GradientStops.Add((New-Object Windows.Media.GradientStop ([Windows.Media.ColorConverter]::ConvertFromString('#38BDF8')), 0))
        $barGrad.GradientStops.Add((New-Object Windows.Media.GradientStop ([Windows.Media.ColorConverter]::ConvertFromString('#34D399')), 1))
        $bar.Background = $barGrad
        $sp.Children.Add($bar) | Out-Null

        $tb = New-Object Windows.Controls.TextBlock
        $tb.Text = $Etykieta
        $tb.FontSize = 11
        $tb.FontWeight = 'SemiBold'
        $tb.Foreground = Br '#60A5FA'
        $sp.Children.Add($tb) | Out-Null

        $UI.Wyniki.Children.Add($sp) | Out-Null
        [void]$script:Raport.Add('')
        [void]$script:Raport.Add("== $Etykieta ==")
        Zanik   $sp 1 260 0
        Przesun $sp 0 12 300
        return
    }

    $info = $Stany["$Stan"]; if (-not $info) { $info = $Stany[''] }
    $kolor = $info.c

    $bd = New-Object Windows.Controls.Border
    $bd.BorderThickness = New-Object Windows.Thickness 1
    Ozyw-Wiersz $bd
    $bd.CornerRadius = New-Object Windows.CornerRadius 14
    $bd.Padding = New-Object Windows.Thickness 14,12,14,12
    $bd.Margin = New-Object Windows.Thickness 0,0,0,8
    # Stonowana poswiata w kolorze stanu pod kafelkiem - ten sam trik co
    # przy kartach zadan w OptiLauncherze (maly promien, niska
    # nieprzezroczystosc, zeby wyniki nie zlewaly sie w jedna plame kolorow).
    $bd.Effect = New-Object Windows.Media.Effects.DropShadowEffect -Property @{
        Color = [Windows.Media.ColorConverter]::ConvertFromString($kolor)
        Opacity = 0.18; BlurRadius = 12; ShadowDepth = 3; Direction = 270
    }

    $root = New-Object Windows.Controls.Grid

    # wash - waski pasek koloru stanu przy lewej krawedzi, gasnacy w prawo,
    # pod tekstem - zeby czytelnosc wartosci nie ucierpiala.
    $wash = New-Object Windows.Controls.Border
    $wash.CornerRadius = New-Object Windows.CornerRadius 14
    $wash.IsHitTestVisible = $false
    $washCol = [Windows.Media.Color][Windows.Media.ColorConverter]::ConvertFromString($kolor)
    $washGrad = New-Object Windows.Media.LinearGradientBrush
    $washGrad.StartPoint = New-Object Windows.Point 0,0
    $washGrad.EndPoint   = New-Object Windows.Point 1,0
    $washGrad.GradientStops.Add((New-Object Windows.Media.GradientStop ([Windows.Media.Color]::FromArgb(34, $washCol.R, $washCol.G, $washCol.B)), 0))
    $washGrad.GradientStops.Add((New-Object Windows.Media.GradientStop ([Windows.Media.Color]::FromArgb(7,  $washCol.R, $washCol.G, $washCol.B)), 0.22))
    $washGrad.GradientStops.Add((New-Object Windows.Media.GradientStop ([Windows.Media.Color]::FromArgb(0,  $washCol.R, $washCol.G, $washCol.B)), 0.42))
    $wash.Background = $washGrad
    $root.Children.Add($wash) | Out-Null

    $g = New-Object Windows.Controls.Grid
    $c1 = New-Object Windows.Controls.ColumnDefinition; $c1.Width = [Windows.GridLength]::Auto
    $c2 = New-Object Windows.Controls.ColumnDefinition; $c2.Width = New-Object Windows.GridLength(1, [Windows.GridUnitType]::Star)
    $g.ColumnDefinitions.Add($c1); $g.ColumnDefinitions.Add($c2)

    $badge = New-WynikBadge -Glyph $info.ic -Hex $kolor
    $badge.VerticalAlignment = 'Top'
    $badge.Margin = New-Object Windows.Thickness 0,0,12,0
    [Windows.Controls.Grid]::SetColumn($badge, 0)
    $g.Children.Add($badge) | Out-Null

    $sp = New-Object Windows.Controls.StackPanel
    $l = New-Object Windows.Controls.TextBlock
    $l.Text = $Etykieta
    $l.FontSize = 11.5
    $l.Foreground = Br '#8B98A9'
    $sp.Children.Add($l) | Out-Null

    $v = New-Object Windows.Controls.TextBlock
    $v.Text = $Wartosc
    $v.FontSize = 13
    $v.TextWrapping = 'Wrap'
    $v.Margin = New-Object Windows.Thickness 0,3,0,0
    if ($Stan) { $v.Foreground = Br $kolor } else { $v.Foreground = Br '#E8EDF5' }
    $sp.Children.Add($v) | Out-Null

    [Windows.Controls.Grid]::SetColumn($sp, 1)
    $g.Children.Add($sp) | Out-Null

    $root.Children.Add($g) | Out-Null
    $bd.Child = $root
    $UI.Wyniki.Children.Add($bd) | Out-Null
    [void]$script:Raport.Add(("{0}: {1}" -f $Etykieta, $Wartosc))
    Zanik   $bd 1 260 0
    Przesun $bd 0 14 320
}

# --------------------------------------------------------------- worker
$sync = [hashtable]::Synchronized(@{})
$sync.Queue = New-Object System.Collections.Concurrent.ConcurrentQueue[object]
$sync.Busy  = $false

# param MUSI byc pierwsza instrukcja bloku, dlatego sklejamy w tej
# kolejnosci: naglowek z param, potem wspolny kod pomiaru, potem reszta.
$CialoWorkera = 'param($sync)' + [Environment]::NewLine + $KodPomiaru + @'

function Wyslij { param($o) $sync.Queue.Enqueue($o) }
function Stan   { param($t) Wyslij @{ typ='stan'; tekst=$t } }
function Wiersz { param($e, $w, $s = '') Wyslij @{ typ='wiersz'; etykieta="$e"; wartosc="$w"; stan="$s" } }
function Sekcja { param($t) Wyslij @{ typ='sekcja'; tekst="$t" } }

try {
    Wyslij @{ typ='czysc' }

    Sekcja 'KARTA SIECIOWA'
    Stan 'Odczyt karty...'
    $ad = Get-Karta
    if (-not $ad) {
        Wiersz 'Stan' 'Nie wykryto aktywnego polaczenia sieciowego.' 'err'
        Wyslij @{ typ='koniec' }
        return
    }
    Wiersz 'Karta' "$($ad.InterfaceDescription)"
    Wiersz 'Predkosc linku' "$($ad.LinkSpeed)"

    $wifi = $false
    try { $wifi = ("$($ad.PhysicalMediaType)" -match '802.11') } catch { }
    Wiersz 'Rodzaj polaczenia' $(if ($wifi) { 'Wi-Fi' } else { 'kabel' })

    if ($wifi) {
        $w = Get-Wifi
        if ($w.sygnal) {
            $s = 'ok'
            if ($w.sygnal -lt 50) { $s = 'err' } elseif ($w.sygnal -lt 70) { $s = 'warn' }
            Wiersz 'Sila sygnalu' "$($w.sygnal) %" $s
        }
        if ($w.radio) { Wiersz 'Standard Wi-Fi' $w.radio }
        if ($w.pasmo) { Wiersz 'Pasmo' $w.pasmo }
        if ($w.kanal) { Wiersz 'Kanal' $w.kanal }
    }

    try {
        $mtu = (Get-NetIPInterface -InterfaceIndex $ad.InterfaceIndex -AddressFamily IPv4 -ErrorAction Stop).NlMtu
        if ($mtu) { Wiersz 'MTU' "$mtu" $(if ($mtu -lt 1400) { 'warn' } else { '' }) }
    } catch { }
    try {
        $dns = (Get-DnsClientServerAddress -InterfaceIndex $ad.InterfaceIndex -AddressFamily IPv4 -ErrorAction Stop).ServerAddresses
        if ($dns) { Wiersz 'Serwery DNS' ($dns -join ', ') }
    } catch { }

    $brama = Get-Brama
    $g = @{ ok=$false; jitter=0; loss=0 }
    if ($brama) {
        Sekcja 'POLACZENIE Z ROUTEREM'
        Stan "Pomiar do bramy $brama ..."
        $g = Measure-Ping $brama 10
        if ($g.ok) {
            $s = 'ok'
            if ($g.jitter -gt 5 -or $g.loss -gt 0) { $s = 'err' } elseif ($g.jitter -gt 2) { $s = 'warn' }
            Wiersz 'Brama' "$brama"
            Wiersz 'Opoznienie' ("srednio {0} ms   (min {1}, max {2})" -f $g.avg, $g.min, $g.max)
            Wiersz 'Jitter' ("{0} ms" -f $g.jitter) $s
            Wiersz 'Straty pakietow' ("{0} %" -f $g.loss) $(if ($g.loss -gt 0) { 'err' } else { 'ok' })
        } else {
            Wiersz 'Wynik' 'Router nie odpowiada na ping.' 'err'
        }
    }

    Sekcja 'POLACZENIE Z INTERNETEM'
    Stan 'Pomiar do 1.1.1.1 ...'
    $c = Measure-Ping '1.1.1.1' 10
    if ($c.ok) {
        $s = 'ok'
        if ($c.avg -gt 80) { $s = 'err' } elseif ($c.avg -gt 40) { $s = 'warn' }
        Wiersz 'Opoznienie' ("srednio {0} ms   (min {1}, max {2})" -f $c.avg, $c.min, $c.max) $s
        Wiersz 'Jitter' ("{0} ms" -f $c.jitter) $(if ($c.jitter -gt 10) { 'warn' } else { 'ok' })
        Wiersz 'Straty pakietow' ("{0} %" -f $c.loss) $(if ($c.loss -gt 0) { 'err' } else { 'ok' })
    } else {
        Wiersz 'Wynik' 'Brak odpowiedzi z internetu.' 'err'
    }

    Sekcja 'WNIOSEK'
    if ($brama -and $g.ok -and ($g.jitter -gt 5 -or $g.loss -gt 0)) {
        Wiersz 'Diagnoza' 'Problem jest MIEDZY komputerem a routerem: kabel, Wi-Fi albo sam router. Zadne ustawienie Windows tego nie naprawi.' 'err'
    } elseif ($c.ok -and $c.loss -gt 0) {
        Wiersz 'Diagnoza' 'Do routera jest stabilnie, pakiety gina dalej. To strona operatora - warto zglosic.' 'warn'
    } elseif ($wifi -and $c.ok -and $c.jitter -gt 10) {
        Wiersz 'Diagnoza' 'Ping w normie, ale jitter wysoki jak na Wi-Fi. Kabel rozwiazalby to od reki.' 'warn'
    } elseif ($c.ok) {
        Wiersz 'Diagnoza' 'Lacze zachowuje sie prawidlowo - nie ma tu czego optymalizowac.' 'ok'
    } else {
        Wiersz 'Diagnoza' 'Brak polaczenia z internetem.' 'err'
    }

    Sekcja 'PUBLICZNY ADRES IP'
    Stan 'Odczyt adresu publicznego...'
    $pubIP = Get-PublicznyIP
    if ($pubIP) {
        Wiersz 'Adres' $pubIP
        Wiersz 'Uwaga' 'Przydatne przy hostowaniu gry / przekierowaniu portow. Jesli ten adres jest inny niz adres WAN pokazany na stronie routera, dostawca prawdopodobnie uzywa NAT operatorskiego (CGNAT) - przekierowanie portow wtedy nie zadziala.' ''
    } else {
        Wiersz 'Wynik' 'Nie udalo sie odczytac adresu publicznego.' 'warn'
    }

    Sekcja 'PREDKOSC POBIERANIA (orientacyjnie)'
    Stan 'Pomiar predkosci...'
    $pred = Measure-Predkosc
    if ($pred.ok) {
        $s = 'ok'
        if ($pred.mbps -lt 20) { $s = 'err' } elseif ($pred.mbps -lt 50) { $s = 'warn' }
        Wiersz 'Predkosc' ("{0} Mb/s   (pobrano {1} MB w {2} s)" -f $pred.mbps, $pred.mb, $pred.sek) $s
        Wiersz 'Uwaga' 'Jeden strumien, jeden serwer - na bardzo szybkich laczach (900+ Mb/s) wynik bywa nizszy od realnego.' ''
    } else {
        Wiersz 'Wynik' 'Nie udalo sie zmierzyc predkosci (brak polaczenia z speed.cloudflare.com).' 'warn'
    }

    Sekcja 'PREDKOSC WYSYLANIA (orientacyjnie)'
    Stan 'Pomiar predkosci wysylania...'
    $predUp = Measure-PredkoscWysylania
    if ($predUp.ok) {
        $s = 'ok'
        if ($predUp.mbps -lt 5) { $s = 'err' } elseif ($predUp.mbps -lt 15) { $s = 'warn' }
        Wiersz 'Predkosc' ("{0} Mb/s   (wyslano {1} MB w {2} s)" -f $predUp.mbps, $predUp.mb, $predUp.sek) $s
    } else {
        Wiersz 'Wynik' 'Nie udalo sie zmierzyc predkosci wysylania (brak polaczenia z speed.cloudflare.com).' 'warn'
    }

    Sekcja 'TRASA DO INTERNETU (traceroute, orientacyjnie)'
    Stan 'Sledzenie trasy do 1.1.1.1...'
    $trasa = Get-Traceroute -Cel '1.1.1.1' -MaxSkokow 18 -TimeoutMs 700
    foreach ($skok in $trasa) {
        $etykieta = "Skok $($skok.skok)"
        if (-not $skok.odpowiedzial) {
            Wiersz $etykieta '* brak odpowiedzi (mozliwa blokada ICMP na tym wezle)' ''
        } else {
            $s = 'ok'
            if ($skok.czas -gt 80) { $s = 'err' } elseif ($skok.czas -gt 40) { $s = 'warn' }
            $adresTxt = if ($skok.adres) { $skok.adres } else { '?' }
            Wiersz $etykieta ("{0}   -   {1} ms" -f $adresTxt, $skok.czas) $s
        }
    }

    Sekcja 'SERWERY GIER (orientacyjnie)'
    Stan 'Pomiar do popularnych platform...'
    $wynikiGier = Measure-Serwery $SerweryGier 6
    foreach ($wg in $wynikiGier) {
        if ($wg.ok) {
            $s = 'ok'
            if ($wg.avg -gt 100 -or $wg.loss -gt 0) { $s = 'warn' }
            Wiersz $wg.nazwa ("{0} ms   •   jitter {1} ms   •   straty {2}%" -f $wg.avg, $wg.jitter, $wg.loss) $s
        } else {
            Wiersz $wg.nazwa 'brak odpowiedzi (firma moze blokowac ping - to nie musi znaczyc problemu)' ''
        }
    }

    # numeryczne podsumowanie - do historii pomiarow i zapisu do pliku
    Wyslij @{
        typ      = 'podsumowanie'
        brama    = $brama
        routerOk = $g.ok;  routerAvg = $g.avg;  routerJitter = $g.jitter;  routerLoss = $g.loss
        inetOk   = $c.ok;  inetAvg   = $c.avg;  inetJitter   = $c.jitter;  inetLoss   = $c.loss
    }

    Sekcja 'USTAWIENIA STEROWNIKA KARTY'
    Stan 'Odczyt wlasciwosci karty...'
    $wl = Get-WlasciwosciKarty $ad
    if ($wl.Count -eq 0) {
        Wiersz 'Wynik' 'Sterownik tej karty nie udostepnia zadnej z monitorowanych wlasciwosci.' ''
    } else {
        foreach ($p in $wl) {
            Wiersz $p.nazwa $(if ($p.wylaczone) { 'wylaczone' } else { "wlaczone   (wartosc: $($p.wartosc))" }) `
                   $(if ($p.wylaczone) { 'ok' } else { 'warn' })
        }
    }
} catch {
    Wiersz 'Blad' ("Pomiar przerwany: " + $_.Exception.Message) 'err'
}
Wyslij @{ typ='koniec' }
'@

$script:PS = $null
$script:Handle = $null

function Start-Pomiar {
    if ($sync.Busy) { return }
    $sync.Busy = $true
    $UI.BtnMierz.IsEnabled  = $false
    $UI.BtnKopiuj.IsEnabled = $false
    $UI.BtnZapisz.IsEnabled = $false
    $UI.Status.Text = 'Pomiar w toku...'
    $script:Raport.Clear()
    $UI.Postep.Tag = 'busy'
    try {
        $p = New-Object Windows.Media.Animation.DoubleAnimation
        $p.From = 0.25; $p.To = 1
        $p.Duration = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(650))
        $p.AutoReverse    = $true
        $p.RepeatBehavior = [Windows.Media.Animation.RepeatBehavior]::Forever
        $UI.Kropka.BeginAnimation([Windows.UIElement]::OpacityProperty, $p)
    } catch { }

    $script:PS = [powershell]::Create()
    $null = $script:PS.AddScript($CialoWorkera).AddArgument($sync)
    $script:Handle = $script:PS.BeginInvoke()
}

function Stop-Pomiar {
    try { if ($script:PS) { $script:PS.EndInvoke($script:Handle) | Out-Null; $script:PS.Dispose() } } catch { }
    $script:PS = $null
    $sync.Busy = $false
    $UI.BtnMierz.IsEnabled  = $true
    $UI.BtnKopiuj.IsEnabled = ($script:Raport.Count -gt 0)
    $UI.BtnZapisz.IsEnabled = ($script:Raport.Count -gt 0)
    $UI.Postep.Tag = $null
    try {
        $UI.Kropka.BeginAnimation([Windows.UIElement]::OpacityProperty, $null)
        $UI.Kropka.Opacity = 0.25
    } catch { }
}

$Timer = New-Object Windows.Threading.DispatcherTimer
$Timer.Interval = [TimeSpan]::FromMilliseconds(120)
$Timer.Add_Tick({
    $msg = $null
    $ile = 0
    while ($sync.Queue.TryDequeue([ref]$msg) -and $ile -lt 60) {
        $ile++
        try {
            switch ($msg.typ) {
                'czysc'  { $UI.Wyniki.Children.Clear() }
                'sekcja' { Dodaj-Wiersz -Etykieta $msg.tekst -Wartosc '' -Naglowek $true }
                'wiersz' { Dodaj-Wiersz -Etykieta $msg.etykieta -Wartosc $msg.wartosc -Stan $msg.stan }
                'stan'   { $UI.Status.Text = "$($msg.tekst)"; Zanik $UI.Status 1 300 0.15 }
                'podsumowanie' {
                    $script:OstPomiar = $msg
                    try {
                        if (-not (Test-Path $KatDanychLacza)) { New-Item -ItemType Directory -Path $KatDanychLacza -Force | Out-Null }
                        $csv = Join-Path $KatDanychLacza 'historia.csv'
                        if (-not (Test-Path $csv)) {
                            Add-Content -LiteralPath $csv -Encoding UTF8 -Value 'czas,brama,router_ok,router_avg_ms,router_jitter_ms,router_strata_pct,inet_ok,inet_avg_ms,inet_jitter_ms,inet_strata_pct'
                        }
                        $wiersz = @(
                            (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), "$($msg.brama)",
                            $msg.routerOk, $msg.routerAvg, $msg.routerJitter, $msg.routerLoss,
                            $msg.inetOk, $msg.inetAvg, $msg.inetJitter, $msg.inetLoss
                        ) -join ','
                        Add-Content -LiteralPath $csv -Encoding UTF8 -Value $wiersz
                    } catch { }
                }
                'koniec' {
                    $UI.Status.Text = 'Pomiar zakonczony.'
                    Stop-Pomiar
                }
            }
        } catch {
            $UI.Status.Text = 'Blad interfejsu: ' + $_.Exception.Message
        }
    }
})
$Timer.Start()

$UI.BtnMierz.Add_Click({ Start-Pomiar })

$UI.BtnKopiuj.Add_Click({
    if ($script:Raport.Count -eq 0) { return }
    $t = "Sprawdzanie Lacza $AppWersja - " + (Get-Date -Format 'yyyy-MM-dd HH:mm') + [Environment]::NewLine
    $t += ($script:Raport -join [Environment]::NewLine)
    try {
        [System.Windows.Clipboard]::SetText($t)
        $UI.Status.Text = 'Wynik skopiowany do schowka.'
        Zanik $UI.Status 1 300 0.15
    } catch { $UI.Status.Text = 'Nie udalo sie skopiowac do schowka.' }
})

$UI.BtnZapisz.Add_Click({
    if ($script:Raport.Count -eq 0) { return }
    $t = "Sprawdzanie Lacza $AppWersja - " + (Get-Date -Format 'yyyy-MM-dd HH:mm') + [Environment]::NewLine
    $t += ($script:Raport -join [Environment]::NewLine)
    try {
        $kat = Join-Path $KatDanychLacza 'zapisane'
        if (-not (Test-Path $kat)) { New-Item -ItemType Directory -Path $kat -Force | Out-Null }
        $plik = Join-Path $kat ("pomiar_" + (Get-Date -Format 'yyyy-MM-dd_HHmmss') + '.txt')
        Set-Content -LiteralPath $plik -Value $t -Encoding UTF8
        $UI.Status.Text = "Zapisano: $plik"
        Zanik $UI.Status 1 300 0.15
    } catch { $UI.Status.Text = 'Nie udalo sie zapisac pliku.' }
})

$Window.Add_ContentRendered({ Zanik $Window 1 300 0 })

$Window.Add_Closed({
    try { $Timer.Stop() } catch { }
    try { if ($script:PS) { $script:PS.Stop(); $script:PS.Dispose() } } catch { }
})

$null = $Window.ShowDialog()
