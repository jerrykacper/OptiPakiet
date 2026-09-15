# OptiPakiet

Dwa narzędzia dla Windowsa, napisane w PowerShellu z interfejsem WPF.
Bez instalatorów trzecich firm, bez telemetrii, bez usług działających w tle.

---

## OptiLauncher 7.9.4

Optymalizacja i diagnostyka komputera.

**Czym różni się od darmowych „optymalizatorów"**

Większość z nich wrzuca kilkadziesiąt przełączników i zostawia człowieka
z pytaniem, co właściwie kliknął. OptiLauncher robi trzy rzeczy inaczej:

1. **Po każdej zmianie sprawdza, czy naprawdę weszła** i mówi wprost
   „potwierdzone" albo „NIE WESZŁO".
2. **Pokazuje efekt w liczbach** — punkt odniesienia przed zmianami
   i porównanie po restarcie.
3. **Pisze uczciwie, ile dana zmiana daje** — mierzalnie, zależnie od
   sprzętu, czy tylko kosmetycznie. Część opisów działa przeciw samemu
   programowi i tak ma być.

Każda zmiana trafia do `backup.json` i da się ją cofnąć jednym przyciskiem.

**Co jest w środku**

| Zakładka | Do czego |
|---|---|
| Pulpit | liczniki procesora, pamięci i dysku na żywo |
| Moje gry | wykrywanie gier ze Steam i Epic, ustawienia wydajności per gra |
| Autostart | co startuje z Windows, z opisem każdej pozycji |
| Procesy w tle | co zajmuje pamięć teraz, z opisem każdego procesu |
| Łącze | pomiar sieci i ustawienia sterownika karty |
| Diagnostyka | skan systemu, raport HTML, pomiar przed i po |
| Wygląd | dziewięć motywów, gęstość widoku, tło Mica |

Do tego zadania optymalizacyjne w sześciu grupach: gry i wydajność,
system, usługi, czyszczenie, sieć, aplikacje — każde z cofaniem zmian.

---

## Sprawdzanie Łącza 1.4

Diagnostyka sieci. Niczego nie zmienia — wyłącznie odczyt.

Mierzy opóźnienie, jitter i straty pakietów **osobno do routera i osobno
do internetu**. To rozstrzyga, gdzie naprawdę jest problem: jeśli ping do
routera skacze, winne jest Wi-Fi albo kabel i żadne ustawienie Windows
tego nie naprawi.

Pokazuje kartę sieciową, prędkość linku, MTU, serwery DNS, przy Wi-Fi siłę
sygnału i pasmo, publiczny adres IP, test pobierania i wysyłania oraz
traceroute z czasem na każdym skoku. Na końcu wypisuje wniosek zwykłym
językiem — łącznie z „nie ma tu czego optymalizować", jeśli tak jest.

---

## Instalacja

Pobierz paczkę, rozpakuj i uruchom `START.bat`.

Menu prowadzi przez resztę. Przy pierwszym uruchomieniu warto zacząć od
pozycji **[6] Diagnoza** — sprawdza składnię i startuje program z widoczną
konsolą, więc ewentualny błąd widać zamiast pustego ekranu.

Instalacja (**[4]** i **[5]**) kopiuje programy do
`%LOCALAPPDATA%\Programs`, tworzy skróty i rejestruje je w Ustawieniach
Windows — odinstalujesz jak każdy inny program. Ustawienia systemu
zostają nietknięte.

**Wymagania:** Windows 10 lub 11, PowerShell 5.1 (jest w systemie).
OptiLauncher prosi o uprawnienia administratora — bez nich nie da się
zmieniać ustawień systemu. Sprawdzanie Łącza ich nie potrzebuje.

Jeśli Windows oznaczy pliki jako pobrane z internetu i coś się nie
uruchamia: prawy klik na plik → Właściwości → zaznacz „Odblokuj".

---

## Aktualizacje

Program sprawdza raz na dobę, czy jest nowsza wersja. Sprawdzanie idzie
w tle, po pokazaniu okna — brak sieci niczego nie opóźnia.

W pasku tytułu, obok odznaki Administrator, siedzi wskaźnik stanu:
neutralny, gdy nic nie wiadomo, zielony „Aktualny" po sprawdzeniu,
bursztynowy z numerem, gdy czeka nowa wersja. Kliknięcie wymusza
sprawdzenie natychmiast, bez czekania na dobowy limit.

**Nic nie pobiera się samo.** Po znalezieniu nowej wersji pojawia się okno
z listą zmian i trzema przyciskami: aktualizuj, pomiń tę wersję, później.
Program działa z uprawnieniami administratora, więc ściąganie
i uruchamianie czegokolwiek bez kliknięcia byłoby dokładnie tym
zachowaniem, którego szukają antywirusy — i słusznie.

Zanim cokolwiek zostanie podmienione, pobrany plik przechodzi dwa
sprawdzenia: suma kontrolna SHA256 musi zgadzać się z manifestem,
a składnia skryptu musi dać się sparsować. Poprzednia wersja zostaje obok
jako `.bak` — jeśli nowa nie wstanie w ciągu kilku sekund, wraca stara.

### Blokady aktualizacji

Zadanie „Aktualizuj programy (winget)" puszcza `winget upgrade --all`.
Wygodne do momentu, w którym `--all` obejmie coś, czego nie chcesz ruszać —
narzędzie do podkręcania, sterownik peryferium, program z własnym systemem
licencji.

Narzędzia → **Blokady aktualizacji** pokazują listę zainstalowanych
pakietów; zaznaczone zostaną pominięte przy aktualizacji zbiorczej.
Pod spodem działa `winget pin`, więc blokada jest zdejmowalna jednym
kliknięciem i nie rusza niczego poza danymi wingeta.

### Baza opisów

Autostart i lista procesów pokazują nazwy plików. `RtkAudUService64` albo
`NvBackend` nie mówi nikomu nic, a to właśnie przy tych pozycjach trzeba
podjąć decyzję.

Do każdej znanej pozycji program dopisuje: co to jest, kto to wstawił,
krótki opis i ocenę w trzech stanach — **można wyłączyć** / **zależy od
Ciebie** / **zostaw włączone**. Oceny są uczciwe także wtedy, gdy wychodzą
przeciw wyłączaniu.

Baza to dane, nie kod, więc jedzie kanałem aktualizacji osobno od programu
i schodzi automatycznie w tle. Nowe opisy nie wymagają nowej wersji.

**Zadania optymalizacyjne tą drogą nie idą i nie będą szły.** Piszą do
rejestru i wyłączają usługi, więc plik z zadaniami pobierany z sieci byłby
zdalnym wykonywaniem kodu na koncie administratora.

---

## Pliki w tym repozytorium

| Plik | Do czego |
|---|---|
| `wersja.json` | manifest — informacja o wersjach i sumy kontrolne |
| `baza.json` | opisy pozycji autostartu i procesów |
| `OptiLauncher.ps1` | program główny |
| `SprawdzLacze.ps1` | diagnostyka sieci |

---

## Dane programu

```
%LOCALAPPDATA%\OptiLauncher\
    backup.json        kopia wartości sprzed zmian
    games.json         lista gier
    pomiar.json        punkt odniesienia
    aktualizacje.json  ustawienia sprawdzania wersji
    baza.json          pobrane opisy
    raporty\           raporty HTML
    log_*.txt          logi sesji
    Lacze\             dane Sprawdzania Łącza
```

Odinstalowanie pyta, czy usunąć te dane. Bez `backup.json` nie da się już
cofnąć zmian wprowadzonych w systemie — jeśli planujesz instalację
ponownie, zostaw je.

---

by Jerremi
