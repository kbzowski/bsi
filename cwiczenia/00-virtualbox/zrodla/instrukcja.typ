#import "szablon.typ": *
#show: cwiczenie.with(tytul: [VirtualBox - maszyna z pliku OVA])
#set heading(numbering: none)

Część ćwiczeń wykonuje się na gotowej maszynie wirtualnej, czyli programowo tworzonym komputerze z własnym
systemem operacyjnym. Maszyna jest wydawana jako plik OVA, który zawiera jej opis i obraz dysku. Dokument
opisuje obsługę takiej maszyny w programie VirtualBox. Nazwę pliku, dane logowania i dalsze polecenia
podaje instrukcja danego ćwiczenia. Komputer fizyczny nazywa się gospodarzem (ang. _host_), a system
działający w maszynie gościem (ang. _guest_). Zrzuty pochodzą z VirtualBoxa 7.2 w systemie Windows,
a czerwone ramki wskazują elementy omawiane w tekście.

== Wymagania i instalacja

Komputer musi mieć procesor x86-64. VirtualBox na komputerach z procesorem Arm, w tym Mac z procesorem Apple
Silicon, nie uruchamia systemów x86. Zalecane minimum to 12 GB RAM oraz 40 GB wolnego miejsca na dysku na
każdą maszynę.

#krok[
  Sprawdź, czy wirtualizacja sprzętowa jest włączona. W Menedżerze zadań (Ctrl+Shift+Esc) przejdź na kartę
  _Wydajność_, wybierz pozycję _Procesor_ i odczytaj pole _Wirtualizacja_. Powinno ono mieć wartość _Włączone_.
]

#krok[
  Na stronie #link("https://www.virtualbox.org/wiki/Downloads") wybierz pakiet dla swojego systemu
  (@rys-pobieranie[rys.]) i zainstaluj go z ustawieniami domyślnymi. Dodatek _Extension Pack_ nie jest potrzebny.
]

#zrzut("rys-pobieranie", "zrzuty/00_strona_pobierania.png", [Strona pobierania, zaznaczony pakiet dla systemu Windows.], width: 80%)

== Import maszyny

Suma kontrolna to skrót wyliczany z zawartości pliku. Jej zgodność z wartością podaną przy odnośniku do pliku
potwierdza, że plik został pobrany w całości i bez zmian.

#krok[
  W PowerShellu, w katalogu z pobranym plikiem, wylicz sumę i porównaj pole `Hash` z podaną wartością:

  ```
  Get-FileHash .\plik.ova -Algorithm SHA256
  ```
]

Polecenie `Get-FileHash` wylicza skrót pliku wskazanego ścieżką, a `-Algorithm SHA256` wybiera algorytm.
Przy niezgodności należy pobrać plik ponownie.

#krok[
  W oknie głównym VirtualBoxa, nazywanym menedżerem, otwórz menu _Plik_ i wybierz pozycję _Importuj urządzenie wirtualne_
  (@rys-menu-import[rys.]).
]

#zrzut("rys-menu-import", "zrzuty/01_menu_import.png", [Polecenie importu w menu _Plik_.], width: 42%)

#krok[
  W polu _Plik_ wskaż plik OVA i rozwiń sekcję _Ustawienia_ (@rys-import-plik[rys.]).
]

#zrzut("rys-import-plik", "zrzuty/02_import_plik.png", [Wybór pliku OVA i sekcja _Ustawienia_.], width: 50%)

#krok[
  Sprawdź pole _Nazwa_ i _Folder podstawowy maszyny_, czyli katalog, w którym powstanie dysk maszyny
  (@rys-import-ustawienia[rys.]). Pozostałych pól nie zmieniaj. Kliknij przycisk _Zakończ_.
]

#zrzut("rys-import-ustawienia", "zrzuty/03_import_ustawienia.png", [Parametry importu. Nazwa i parametry zależą od maszyny.], width: 75%)

Postęp importu widać w panelu powiadomień w prawym górnym rogu menedżera (@rys-import-postep[rys.]). Po zakończeniu
maszyna pojawia się na liście ze stanem _Wyłączona_ (@rys-menedzer[rys.]). Lista może zawierać także inne maszyny.

#zrzut("rys-import-postep", "zrzuty/04_import_postep.png", [Postęp importu w panelu powiadomień.], width: 30%)

#zrzut("rys-menedzer", "zrzuty/05_menedzer_po_imporcie.png", [Maszyna na liście i przycisk _Uruchom_.], width: 60%)

== Uruchomienie

#krok[
  Zaznacz maszynę na liście i kliknij przycisk _Uruchom_ (@rys-menedzer[rys.]). Po uruchomieniu systemu zaloguj się
  danymi z instrukcji ćwiczenia (@rys-logowanie[rys.]).
]

#zrzut("rys-logowanie", "zrzuty/10_logowanie.png", [Ekran logowania systemu gościa.], width: 45%)

== Praca w oknie maszyny

Kliknięcie wewnątrz okna maszyny przekazuje jej klawiaturę i mysz. Klawisz gospodarza (ang. _Host key_) oddaje je
z powrotem systemowi gospodarza. Domyślnie jest to prawy Ctrl, a jego nazwa znajduje się na pasku stanu w prawym dolnym rogu
okna (@rys-pasek[rys.]). Zapis Host+F oznacza przytrzymanie tego klawisza i naciśnięcie klawisza F.

#zrzut("rys-pasek", "zrzuty/23_pasek_stanu.png", [Nazwa klawisza gospodarza na pasku stanu okna maszyny.], width: 60%)

Menu _Widok_ zawiera tryb pełnoekranowy (Host+F), tryb skalowany (Host+C) i automatyczne dopasowanie rozdzielczości gościa
do rozmiaru okna (@rys-menu-widok[rys.]). Ponowne użycie skrótu wyłącza dany tryb. Menu _Urządzenia_ zawiera ustawienie
wspólnego schowka, który po wybraniu opcji _Dwukierunkowy_ działa w obu kierunkach (@rys-schowek[rys.]).

#zrzut("rys-menu-widok", "zrzuty/13_menu_widok.png", [Tryby ekranu w menu _Widok_.], width: 45%)

#zrzut("rys-schowek", "zrzuty/15_menu_schowek.png", [Wspólny schowek w menu _Urządzenia_.], width: 55%)

== Migawka

Migawka (ang. _snapshot_) zapisuje stan maszyny, do którego można później wrócić. Warto ją wykonać przed pierwszym krokiem
ćwiczenia. Migawka działającej maszyny obejmuje także zawartość pamięci, więc po przywróceniu system wraca do zapisanego
momentu bez ponownego uruchamiania.

#krok[
  W oknie działającej maszyny otwórz menu _Maszyna_ i wybierz pozycję _Zrób migawkę_ (@rys-menu-maszyna[rys.]). Podaj
  nazwę i kliknij _OK_ (@rys-migawka[rys.]).
]

#zrzut("rys-menu-maszyna", "zrzuty/14_menu_maszyna.png", [Pozycja _Zrób migawkę_.], width: 32%)

#zrzut("rys-migawka", "zrzuty/16_migawka.png", [Okno tworzenia migawki.], width: 40%)

#krok[
  Aby przywrócić migawkę, zamknij maszynę. W menedżerze otwórz zakładkę _Migawki_, zaznacz migawkę i kliknij _Przywróć_
  (@rys-migawki[rys.]). Odznacz pole tworzenia migawki bieżącego stanu, jeżeli ten stan nie jest potrzebny, i potwierdź
  (@rys-przywracanie[rys.]). Zmiany wprowadzone po migawce zostają utracone.
]

#zrzut("rys-migawki", "zrzuty/19_migawki.png", [Lista migawek i przycisk _Przywróć_.])

#zrzut("rys-przywracanie", "zrzuty/20_przywracanie.png", [Potwierdzenie przywrócenia migawki.], width: 40%)

== Zamykanie

#krok[
  Zamknij okno maszyny, wybierz sposób zamknięcia (@rys-zamykanie[rys.]) i kliknij _OK_.
]

#zrzut("rys-zamykanie", "zrzuty/17_zamykanie.png", [Sposoby zamknięcia maszyny.], width: 40%)

#table(
  columns: (auto, 1fr),
  table.header[Opcja][Działanie],
  [_Zapisz stan maszyny_], [Zapisuje pamięć na dysku. Praca wraca do tego samego miejsca przy następnym uruchomieniu.],
  [_Wyślij sygnał wyłączenia_], [Odpowiada naciśnięciu przycisku zasilania, system gościa kończy pracę w zwykły sposób.],
  [_Wyłącz maszynę_], [Odpowiada odłączeniu zasilania i służy do sytuacji, gdy system nie reaguje. Niezapisane dane zostają utracone.],
)

Pole _Przywróć aktualną migawkę_ dodatkowo odrzuca zmiany od czasu migawki i przy zwykłym zamykaniu pozostaje puste. Po sygnale
wyłączenia system gościa może wyświetlić własne pytanie o rodzaj działania (@rys-kali-shutdown[rys.]). Należy wtedy wybrać
_Shut Down_.

#zrzut("rys-kali-shutdown", "zrzuty/18_kali_shutdown.png", [Pytanie systemu gościa po sygnale wyłączenia.], width: 32%)

== Usunięcie

#krok[
  Wyłącz maszynę, kliknij ją na liście prawym przyciskiem myszy i wybierz pozycję _Usuń_ (@rys-menu-usun[rys.]). Zaznacz pole
  usunięcia plików i kliknij _Usuń_ (@rys-usun-pliki[rys.]).
]

Bez zaznaczenia pola maszyna znika tylko z listy, a jej dysk nadal zajmuje miejsce. Maszynę można odtworzyć wyłącznie przez
ponowny import pliku OVA.

#zrzut("rys-menu-usun", "zrzuty/21_menu_usun.png", [Menu kontekstowe maszyny.], width: 45%)

#zrzut("rys-usun-pliki", "zrzuty/22_usun_pliki.png", [Potwierdzenie usunięcia razem z plikami.], width: 40%)

== Rozwiązywanie problemów

#table(
  columns: (1fr, 1.6fr),
  table.header[Objaw][Postępowanie],
  [`VT-x is disabled in the BIOS` lub `AMD-V is disabled in the BIOS`], [Wirtualizacja jest wyłączona. Należy włączyć w BIOS-ie lub UEFI opcję _Intel Virtualization Technology_ albo _SVM Mode_.],
  [`VT-x is not available` lub `AMD-V is not available`], [Należy sprawdzić opcję w BIOS-ie lub UEFI. Przy włączonej wirtualizacji przyczyną jest zwykle aktywny hipernadzorca Windows, opisany niżej.],
  [Import zgłasza `VERR_DISK_FULL`.], [Brak miejsca na dysku. Należy zwolnić miejsce albo wskazać inny _Folder podstawowy maszyny_.],
  [Klawiatura lub mysz nie wracają do systemu gospodarza.], [Należy nacisnąć klawisz gospodarza.],
)

Hipernadzorca to program uruchamiający maszyny wirtualne. Hipernadzorca Windows (Hyper-V) działa między innymi z WSL2, Docker
Desktop i izolacją rdzenia. Gdy jest aktywny, VirtualBox może pracować przez niego wolniej, co sygnalizuje zielona ikona
żółwia na pasku stanu. Jeżeli maszyna działa zbyt wolno, hipernadzorcę można wyłączyć w PowerShellu uruchomionym jako
administrator i ponownie uruchomić komputer:

```
bcdedit /set hypervisorlaunchtype off
```

Program `bcdedit` zmienia konfigurację rozruchu Windows, `/set` ustawia opcję, `hypervisorlaunchtype` określa uruchamianie
hipernadzorcy, a `off` je wyłącza. WSL2, Docker Desktop i izolacja rdzenia przestają wtedy działać, co obniża poziom zabezpieczeń komputera.
Dlatego po skończonej pracy należy przywrócić ustawienie wartością `auto` zamiast `off` i ponownie uruchomić komputer.
