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

#set document(title: "Cross-site scripting (XSS)", author: "BSI")
#set page(
  paper: "a4",
  margin: (x: 2.2cm, top: 2.2cm, bottom: 2cm),
  header: context {
    if counter(page).get().first() > 1 {
      set text(font: sans-head, size: 8pt, fill: muted)
      [Bezpieczeństwo Systemów Informatycznych #h(1fr) Cross-site scripting (XSS)]
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
  #text(font: sans-head, size: 24pt, weight: "bold", fill: ink)[Cross-site scripting (XSS)]
  #v(4pt)
  #line(length: 100%, stroke: 1.5pt + accent)
]

Instrukcja omawia podatność cross-site scripting (XSS) w prostej aplikacji sklepu internetowego.
XSS polega na wstawieniu danych wpisanych przez użytkownika do strony w taki sposób, że
przeglądarka traktuje je jako kod (HTML lub JavaScript) i wykonuje. Ćwiczenie pokazuje trzy odmiany
tej podatności: odbitą (ang. _reflected_), trwałą (ang. _stored_) oraz opartą na modelu DOM
(ang. _DOM-based_). Dla
każdej odmiany instrukcja prowadzi od wykrycia, przez wykorzystanie, do wersji poprawionej, odpornej
na atak.

Model DOM (Document Object Model) to drzewiasta reprezentacja strony, którą przeglądarka buduje z
kodu HTML i którą skrypty mogą odczytywać oraz zmieniać.

Po zakończeniu ćwiczenia student potrafi:

- wskazać miejsce, w którym dane użytkownika trafiają do strony bez kodowania,
- wykorzystać XSS odbity przez spreparowany adres URL,
- wykorzystać XSS trwały przez treść zapisaną w aplikacji i wykonywaną u innych użytkowników,
- wykorzystać XSS oparty na modelu DOM w wariancie, w którym kod atakującego nie trafia na serwer,
- wskazać poprawkę właściwą dla danego kontekstu (kodowanie wyjścia, `textContent`) i sprawdzić,
  czy usuwa ona podatność,
- opisać znaleziska i przebieg testu w formie przyjętej w raporcie z testu penetracyjnego.

Test penetracyjny to kontrolowana próba ataku na system, prowadzona w celu wykrycia podatności.
Wymaga on pisemnej zgody właściciela systemu, określającej zakres i termin testów. Te same
czynności wykonane bez zgody mogą stanowić przestępstwo (art.~267 Kodeksu karnego). Ćwiczenie
dotyczy wyłącznie lokalnej aplikacji pod adresem `http://127.0.0.1:8000`, uruchomionej na własnym
komputerze. Opisane techniki wolno stosować wyłącznie wobec własnych systemów lub za pisemną zgodą
właściciela. Nie wolno ich kierować na inne cele, w szczególności na sieci i systemy~AGH. Nie wolno
też wysyłać innym osobom adresów ani treści z ładunkiem z tego ćwiczenia, ponieważ kod wykonałby się
w przeglądarkach osób, które nie wyraziły zgody na test.

#outline(title: [Spis treści], depth: 1, indent: auto)

= Wymagania

#block(sticky: true)[Do wykonania ćwiczenia potrzebne jest następujące oprogramowanie:]

- *Node.js w wersji 18 lub nowszej* – pobierany ze strony
  #link("https://nodejs.org/")[nodejs.org]. Node.js to środowisko uruchomieniowe języka JavaScript
  poza przeglądarką; służy do uruchomienia aplikacji ćwiczeniowej. Poprawność instalacji sprawdza
  polecenie `node --version`.
- *Burp Suite Community* – narzędzie pośredniczące w ruchu HTTP, opisane w ćwiczeniu~1. Służy do
  obejrzenia, powtórzenia i udokumentowania żądań ze wstrzykniętą wartością.
- *Przeglądarka* – wbudowana przeglądarka Chromium z Burp Suite, ta sama co w ćwiczeniu~1. Całe
  ćwiczenie wykonuje się w tej przeglądarce, dzięki czemu każde żądanie trafia do historii Burpa.
  Narzędzia deweloperskie otwiera się w niej klawiszem~F12. Menu przeglądarki jest w języku systemu, a narzędzia
  deweloperskie zwykle w języku angielskim; nazwy elementów podano tak, jak wyświetla je
  przeglądarka, z odpowiednikiem w drugim języku w nawiasie.
- *Pliki aplikacji* – z katalogu ćwiczenia: `app.mjs`, `package.json` i `package-lock.json`.

Oprogramowanie z tej listy należy zainstalować przed zajęciami i sprawdzić, czy aplikacja uruchamia
się poleceniami `npm install` oraz `npm start` (część~2). Redakcję znalezisk w formie raportu można dokończyć po zajęciach.

= Jak działa XSS

Aplikacja webowa buduje stronę, wstawiając do kodu HTML wartości pochodzące od użytkownika: wpisaną
frazę, treść opinii, imię z adresu. Jeśli wartość trafia do strony bez zmian, a zawiera znaki
składni HTML, przeglądarka dołącza ją do strony jako kod, a nie jako tekst. Znacznik `<script>`
zawarty w takiej wartości zostaje wykonany jak każdy inny skrypt strony.

Przyczyną jest brak kodowania wyjścia (ang. _output encoding_). Kodowanie wyjścia zamienia znaki
składni HTML na encje znakowe (ang. _character entities_), czyli zapisy, które przeglądarka
wyświetla jako pojedynczy znak. Zamiana obejmuje znaki `&` na `&amp;`, `<` na `&lt;`, `>` na `&gt;`,
`"` na `&quot;` oraz `'` na `&#39;`.
Po zamianie przeglądarka wyświetla te znaki jako zwykły tekst i nie rozpoczyna od nich znacznika.

Podatny fragment aplikacji ćwiczeniowej wygląda następująco (język JavaScript):

```js
const q = req.query.q ?? "";
res.send(`<p>Szukana fraza: ${q}</p>`);
```

Zmienna `q` pochodzi z pola wyszukiwarki. Dla zwykłej frazy, na przykład wartości `Monitor`,
przeglądarka otrzymuje poprawny fragment strony:

```html
<p>Szukana fraza: Monitor</p>
```

Gdy użytkownik wpisze w pole wartość `<script>alert(1)</script>`, przeglądarka otrzymuje stronę
z dodatkowym znacznikiem skryptu:

```html
<p>Szukana fraza: <script>alert(1)</script></p>
```

Przeglądarka nie odróżnia tego skryptu od kodu napisanego przez autora strony i wykonuje go. Wartość
z pola zostaje w ten sposób włączona do kodu strony, co stanowi istotę podatności.

#rysunek(diagram(
  spacing: (2.4cm, 1.1cm),
  dnode((0, 0), [Pole lub\ adres URL]),
  dnode((1, 0), [Aplikacja wstawia\ wartość do HTML]),
  dnode((2, 0), [Przeglądarka\ wykonuje jako kod], fill: warn-light, stroke: warn),
  dedge((0, 0), (1, 0), dtag[`<script>...`], "-|>", label-side: left),
  dedge((1, 0), (2, 0), dtag[strona z kodem], "-|>", label-side: left),
), [Wartość od użytkownika zostaje wstawiona do treści strony. Przeglądarka otrzymuje ją jako część
kodu HTML i wykonuje zawarty w niej skrypt.])

Skutkiem XSS jest wykonanie kodu atakującego w przeglądarce innego użytkownika, w ramach jego sesji.
Kod ma dostęp do tych samych danych co strona. Może odczytać ciasteczka sesji, wysłać żądania
w imieniu zalogowanego użytkownika albo podmienić zawartość strony.

#block(sticky: true)[Trzy odmiany XSS różnią się tym, skąd pochodzi wartość i gdzie trafia:]

#table(
  columns: (auto, 1fr),
  inset: (x: 7pt, y: 5pt),
  table.header[Odmiana][Skąd pochodzi wartość i gdzie trafia],
  [odbita (ang. _reflected_)], [wartość z pojedynczego żądania (np. z adresu URL) wraca w odpowiedzi na to
    samo żądanie; atak wymaga nakłonienia ofiary do otwarcia spreparowanego adresu (część~3)],
  [trwała (ang. _stored_)], [wartość zostaje zapisana w aplikacji i wyświetlona każdemu, kto otworzy stronę;
    atak nie wymaga spreparowanego adresu (część~4)],
  [oparta na modelu DOM (ang. _DOM-based_)], [skrypt działający w przeglądarce odczytuje wartość
    i wstawia ją do strony, więc podatność jest w kodzie klienta (kodzie JavaScript wykonywanym
    w przeglądarce); w ćwiczeniu wartość pochodzi
    z fragmentu adresu po `#` (końcowej części adresu URL, której przeglądarka nie wysyła na serwer)
    (część~5)],
)

Ciasteczko (ang. _cookie_) to krótka wartość, którą serwer zapisuje w przeglądarce i którą
przeglądarka dołącza do każdego kolejnego żądania do tej samej aplikacji. Ciasteczko sesji
identyfikuje zalogowanego użytkownika, więc osoba, która je pozna, może działać w aplikacji jako ten
użytkownik. Skrypty strony odczytują ciasteczka przez właściwość `document.cookie`, chyba że serwer
oznaczył ciasteczko atrybutem `HttpOnly` (część~6.3). W ćwiczeniu dowodem wykonania kodu jest
wywołanie `alert(document.cookie)`. Funkcja `alert` wyświetla okno komunikatu z podanym tekstem,
w tym przypadku z ciasteczkami bieżącej strony. Jest to nieszkodliwy sposób pokazania, że skrypt
atakującego działa i ma dostęp do danych sesji. Wartość przygotowaną przez atakującego, która
zawiera wstrzykiwany kod, nazywa się ładunkiem (ang. _payload_).

= Uruchomienie aplikacji

W katalogu ćwiczenia (z plikiem `package.json`) wykonaj polecenia:

```
npm install
npm start
```

Pierwsze polecenie pobiera zależność (framework `express`), drugie uruchamia aplikację. Aplikacja
nasłuchuje pod adresem `http://127.0.0.1:8000`. Okno terminala z uruchomioną aplikacją pozostaw
otwarte do końca ćwiczenia.

Opinie dodawane w części~4 są przechowywane w pamięci procesu, dlatego zatrzymanie
aplikacji (Ctrl+C) i ponowne uruchomienie przywracają stan początkowy. Aplikacja ustawia przy
logowaniu ciasteczko sesji `session`, którego wartością jest sam login. Ciasteczko nie ma atrybutu
`HttpOnly`, więc skrypty strony mogą je odczytać przez `document.cookie`.

Aplikacja udostępnia trzy podatne miejsca, każde z wersją poprawioną:

#table(
  columns: (auto, 1fr),
  inset: (x: 7pt, y: 5pt),
  table.header[Adres][Opis],
  [`GET /search?q=`], [wyszukiwarka; fraza `q` wstawiana do strony bez kodowania (część~3)],
  [`POST /reviews`], [zapis opinii, parametry `author` i `text` (część~4)],
  [`GET /reviews`], [opinie o sklepie; podpis i treść opinii wyświetlane bez kodowania (część~4)],
  [`GET /welcome`], [powitanie; fragment adresu po `#` wstawiany przez `innerHTML`, czyli jako kod
    HTML (część~5)],
  [`GET /fixed/search`], [wersja poprawiona wyszukiwarki (część~6)],
  [`GET /fixed/reviews`], [wersja poprawiona listy opinii (część~6)],
  [`GET /fixed/welcome`], [wersja poprawiona powitania (część~6)],
)

#krok[
  Uruchom Burp Suite. W zakładce _Proxy_, w podzakładce _Intercept_, upewnij się, że
  przechwytywanie jest wyłączone (_Intercept off_), i kliknij _Open browser_. Wszystkie kolejne
  kroki ćwiczenia wykonuje się w tej przeglądarce.

  Otwórz w niej adres `http://127.0.0.1:8000`, w polu _Login_ pozostaw wartość `admin` i kliknij
  _Zaloguj_. Aplikacja
  ustawi ciasteczko `session=admin`, które odczyta wstrzyknięty skrypt. Bez logowania
  `document.cookie` jest puste, a okno komunikatu nie pokaże żadnej wartości.
]

Po zalogowaniu aplikacja wraca na stronę startową, a pod nagłówkiem sklepu pojawia się napis
„Zalogowany jako admin”. Napis „Nie jesteś zalogowany” oznacza, że logowanie się nie powiodło
i należy je powtórzyć.

#uwaga[
  Raport z testu opisuje jego przebieg, dlatego od części~3 należy zapisywać każdy sprawdzony adres
  lub żądanie, użytą wartość i wynik. Zrzuty ekranu wskazane w akapitach „Dowodem do raportu”
  należy wykonać od razu, ponieważ po ponownym uruchomieniu aplikacji zapisane opinie znikają.
]

= XSS odbity (reflected)

Wyszukiwarka przyjmuje frazę w parametrze `q` w adresie URL i wstawia ją do strony z wynikami:

```js
res.send(`<p>Szukana fraza: ${q}</p>`);
```

Wartość `q` trafia do strony bez kodowania. Parametry w adresie URL najprościej testuje się bezpośrednio
w pasku adresu przeglądarki.

== Potwierdzenie podatności

#krok[
  W pasku adresu przeglądarki wpisz adres, w którym fraza zawiera znacznik pogrubienia:

  `http://127.0.0.1:8000/search?q=<b>test</b>`
]

Na stronie słowo „test” zostanie pogrubione, a znaczniki nie będą widoczne. Oznacza to, że wartość
z parametru została dołączona do strony jako kod HTML.
Taki wynik wystarcza, aby podejrzewać XSS.

#zrzut("zrzuty/05_reflected_bold.png", [Wynik wyszukiwania dla frazy `<b>test</b>`. Słowo „test”
jest pogrubione, a znaczniki nie są widoczne, ponieważ przeglądarka potraktowała je jako kod HTML.])

== Wykonanie skryptu

W wyszukiwarce zadziałałby znacznik `<script>` z części~1, ponieważ serwer wstawia go do kodu HTML
strony. W ćwiczeniu stosuje się jednak jeden ładunek dla wszystkich trzech odmian, także dla
części~5, w której znacznik `<script>` nie zostaje wykonany (przyczyna jest opisana w części~5).
Ładunek wykorzystuje atrybut obsługi zdarzenia (taki jak `onerror`), którego wartość
przeglądarka wykonuje jako kod JavaScript po wystąpieniu zdarzenia. Znacznik obrazka z nieistniejącym źródłem i atrybutem `onerror` wykonuje
kod, gdy obrazka nie uda się wczytać:

#krok[
  W pasku adresu wpisz adres ze wstrzykniętym obrazkiem. Spacje w adresie zapisano jako `%20`
  (kodowanie procentowe, ang. _percent-encoding_, czyli zapis znaku jako `%` i dwóch cyfr
  szesnastkowych jego kodu; polska litera zajmuje dwa takie zapisy, np. `ś` to `%C5%9B`);
  przeglądarka zamienia je w ten sposób także wtedy, gdy adres
  zostanie wpisany ze spacjami.

  `http://127.0.0.1:8000/search?q=<img%20src=x%20onerror=alert(document.cookie)>`
]

Przeglądarka próbuje wczytać obrazek ze źródła `x`, nie znajduje go i wykonuje kod z atrybutu
`onerror`. Pojawi się okno komunikatu z zawartością ciasteczka `session`. Oznacza to, że skrypt
atakującego wykonał się na stronie aplikacji i odczytał ciasteczko sesji. Okno należy zamknąć
przyciskiem _OK_; w miejscu frazy pozostanie ikona niewczytanego obrazka.

#zrzut("zrzuty/01_reflected_alert.png", [XSS odbity w wyszukiwarce. Wartość parametru `q` została
wstawiona do strony jako kod; przeglądarka wykonała ją i wyświetliła ciasteczko sesji w oknie komunikatu.])

W ataku odbitym wartość wraca tylko w odpowiedzi na to konkretne żądanie. Aby zaatakować inną osobę,
atakujący przygotowuje powyższy adres i nakłania ofiarę do jego otwarcia, na przykład w wiadomości.
Po otwarciu kod wykonuje się w przeglądarce ofiary, w ramach jej sesji.

== Dokumentowanie żądania w Burp Suite

Do raportu wygodnie jest zapisać samo żądanie ze wstrzykniętą wartością oraz fragment odpowiedzi, w
którym widać wstrzyknięty kod. Poprzedni krok wykonano we wbudowanej przeglądarce Burpa, więc
żądanie zostało już zapisane w jego historii.

#krok[
  W Burpie w zakładce _Proxy_, w podzakładce _HTTP history_, odszukaj żądanie `GET /search`
  ze wstrzykniętym obrazkiem. W kolumnie _URL_ ma ono postać `/search?q=%3Cimg...`, ponieważ
  znaki `<` i `>` są zakodowane jako `%3C` i `%3E`; najnowsze żądania znajdują się na dole listy.
  Kliknij je prawym przyciskiem myszy i wybierz _Send to Repeater_.
  W zakładce _Repeater_ naciśnij _Send_, a nad odpowiedzią wybierz widok _Raw_. Aby odnaleźć
  wstrzyknięty znacznik w odpowiedzi, wpisz `onerror` w polu wyszukiwania pod odpowiedzią.
]

W treści odpowiedzi znajduje się znacznik `<img ... onerror=...>` zwrócony bez zmian. W wierszu
żądania (pierwszym wierszu, z metodą i adresem) przeglądarka zakodowała znaki `<` i `>` jako `%3C`
i `%3E`, a spacje mają postać `%20` nadaną w adresie. Serwer dekoduje te zapisy przed wstawieniem
wartości do strony.

Zaraz za żądaniem `/search` w historii znajduje się żądanie `GET /x`. Jest to próba wczytania
obrazka ze źródła `x`, na którą serwer odpowiada kodem 404; nieudane wczytanie wywołuje zdarzenie
`onerror`.

#zrzut("zrzuty/12_burp_repeater.png", [Żądanie `GET /search` ze wstrzykniętą wartością parametru `q`
w zakładce _Repeater_. W odpowiedzi w widoku _Raw_ znacznik `<img ... onerror=...>` został zwrócony bez
kodowania (wyszukiwane słowo `onerror` jest podświetlone).])

Dowodem do raportu jest wiersz żądania `GET /search` z wartością parametru `q` oraz fragment
odpowiedzi, w którym widać wstrzyknięty znacznik. Oba fragmenty należy skopiować jako tekst
z zakładki _Repeater_ (zaznaczenie i Ctrl+C) i skrócić do istotnych wierszy, jak w przykładzie
w części~7.

= XSS trwały (stored)

Strona opinii przyjmuje podpis i treść opinii, zapisuje je w aplikacji i wyświetla listę wszystkim
odwiedzającym:

```js
reviews.push({ author, text });
// przy wyswietlaniu:
const items = reviews.map((r) => `<li><b>${r.author}</b>: ${r.text}</li>`).join("");
```

Podpis i treść opinii trafiają do strony bez kodowania. W odróżnieniu od ataku odbitego wartość zostaje
zapisana, a zawarty w niej kod wykonuje się u każdego, kto otworzy stronę opinii, bez żadnego spreparowanego adresu.

#krok[
  Otwórz adres `http://127.0.0.1:8000/reviews`. W formularzu w polu _Treść_ wpisz:

  `<img src=x onerror=alert(document.cookie)>`

  W polu _Podpis_ pozostaw wartość domyślną `gość` i kliknij _Dodaj_ tylko raz, ponieważ każde
  kliknięcie zapisuje kolejną opinię.
]

#zrzut("zrzuty/06_stored_form.png", [Formularz dodawania opinii z wpisanym w polu _Treść_ znacznikiem
obrazka z atrybutem `onerror`.], width: 85%)

Po dodaniu opinii aplikacja przekieruje przeglądarkę na listę opinii. Lista zawiera już nową
opinię, więc przeglądarka od razu wykona wstrzyknięty kod i wyświetli okno komunikatu z ciasteczkiem
sesji.

#zrzut("zrzuty/02_stored_alert.png", [XSS trwały w opiniach. Treść opinii została zapisana w
aplikacji, a zawarty w niej skrypt wykonał się przy wyświetleniu listy, co potwierdza okno komunikatu.], width: 80%)

Po zamknięciu okna komunikatu lista opinii wyświetla się w całości. W miejscu treści nowej opinii widoczna
jest ikona obrazka, którego nie udało się wczytać. Przeglądarka utworzyła z treści opinii element
`<img>`, zamiast wyświetlić ją jako tekst.

#zrzut("zrzuty/07_stored_list.png", [Lista opinii po zamknięciu okna komunikatu. Treść opinii podpisanej
jako `gość` została wstawiona jako element `<img>` z nieistniejącym źródłem, dlatego widoczna jest tylko
ikona niewczytanego obrazka.], width: 85%)

#krok[
  Odśwież stronę opinii klawiszem~F5 albo otwórz ją ponownie. Przed zamknięciem okna komunikatu
  wykonaj zrzut ekranu okna przeglądarki jako dowód do raportu.
]

Okno komunikatu pojawi się ponownie. Odmianę trwałą od odbitej odróżnia to, że kod wykonuje się za
każdym razem, ponieważ opinia pozostaje zapisana. U każdego innego użytkownika, który otworzy stronę
opinii, kod wykona się w jego przeglądarce i w ramach jego sesji. Jeśli opinie przegląda administrator sklepu, atak obejmuje także konta
o wyższych uprawnieniach.

#uwaga[
  Kod zapisany w opinii wykonuje się przy każdym wejściu na `/reviews`. Opinia będzie potrzebna
  w części~6, dlatego należy ją pozostawić do czasu sprawdzenia wersji poprawionej. Później można
  ją usunąć, zatrzymując aplikację (Ctrl+C) i uruchamiając ją ponownie poleceniem `npm start`.
]

Treść opinii jest wysyłana w ciele żądania (ang. _request body_, części żądania po nagłówkach) jako
parametr `text`, a podpis jako parametr `author`.

#krok[
  W Burpie w zakładce _Proxy_, w podzakładce _HTTP history_, zaznacz wiersz z metodą `POST`
  i adresem `/reviews` (zaraz za nim znajduje się żądanie `GET /reviews` wysłane po
  przekierowaniu). W panelu _Request_ poniżej listy ostatni wiersz, oddzielony od nagłówków pustym
  wierszem, zawiera ciało żądania z parametrami `author` i `text`. Skopiuj wiersz żądania oraz
  ciało do notatek.
]

Wartości parametrów są zapisane w kodowaniu procentowym (np. `%3Cimg` zamiast `<img`; w treści
formularza spacja jest zapisywana jako `+`). Zakodowane są także znaki `=`, `(` i `)` (`%3D`, `%28`,
`%29`) oraz polskie litery z podpisu, dlatego w ciele żądania nie występuje dosłowny tekst
`onerror=alert`.

Dowodem do raportu jest skopiowana treść żądania `POST /reviews` oraz zrzut ekranu listy opinii
z oknem komunikatu, wykonany w poprzednim kroku. XSS trwały ma zazwyczaj wyższą wagę niż odbity, ponieważ nie wymaga
nakłaniania ofiary do otwarcia spreparowanego adresu. Do wykonania kodu wystarcza otwarcie zwykłej
strony aplikacji.

= XSS oparty na modelu DOM (DOM-based)

Strona powitania wyświetla imię podane w adresie po znaku `#`. Odczytuje je skrypt działający w
przeglądarce i wstawia do strony:

```js
var name = decodeURIComponent(location.hash.slice(1));
if (name) document.getElementById("name").innerHTML = name;
```

Właściwość `location.hash` zwraca fragment adresu razem ze znakiem `#`; wywołanie `slice(1)` usuwa
ten znak, a `decodeURIComponent` dekoduje znaki zapisane w kodowaniu procentowym, np. `%20`.
Przeglądarka zapisuje znaki `<`, `>` i spacje we fragmencie adresu jako `%3C`, `%3E` i `%20`, więc
bez tego dekodowania wartość nie utworzyłaby znacznika. Pasek adresu wyświetla znaki `<` i `>`
w postaci czytelnej, jednak właściwość `location.hash` zwraca je w postaci zakodowanej. Właściwość
`innerHTML` ustawia zawartość elementu jako kod HTML. Skrypt pobiera więc wartość z adresu i wstawia
ją do strony jako HTML, bez kodowania. Przeglądarka nie wykonuje znaczników `<script>` wstawionych
przez `innerHTML`, dlatego ładunek korzysta z atrybutu `onerror`.

Fragment adresu po znaku `#` nie jest wysyłany na serwer, dlatego w tym przykładzie wartość nie
przechodzi przez serwer. Serwer dostarcza skrypt strony, ale nie przetwarza wstrzykniętej wartości.
Podatność znajduje się w całości w kodzie JavaScript wykonywanym w przeglądarce.

#rysunek(diagram(
  spacing: (2.3cm, 1.1cm),
  dnode((0, 0), [Adres z\ `#<img ...>`]),
  dnode((1, 0), [Skrypt czyta\ `location.hash`]),
  dnode((2, 0), [`innerHTML` tworzy\ `<img onerror>`], fill: warn-light, stroke: warn),
  dedge((0, 0), (1, 0), dtag[w przeglądarce], "-|>", label-side: left),
  dedge((1, 0), (2, 0), "-|>"),
), [Wartość po znaku `#` nie dociera do serwera. Odczytuje ją skrypt strony i wstawia przez
`innerHTML`, więc podatność w całości leży w kodzie wykonywanym w przeglądarce.])

#krok[
  W pasku adresu wpisz adres z imieniem po znaku `#`:

  `http://127.0.0.1:8000/welcome#Ala`

  Strona wyświetli powitanie „Witaj, Ala!”.
]

#zrzut("zrzuty/08_dom_ala.png", [Strona powitania dla adresu zakończonego fragmentem `#Ala`. Skrypt
strony odczytał imię z fragmentu adresu i wstawił je do powitania.], width: 85%)

#krok[
  Zmień fragment po `#` na wstrzyknięty znacznik:

  `http://127.0.0.1:8000/welcome#<img src=x onerror=alert(document.cookie)>`

  Zmiana samego fragmentu po `#` nie powoduje ponownego wczytania strony, a skrypt powitania
  wykonuje się tylko przy wczytaniu. Po wpisaniu adresu i naciśnięciu klawisza Enter odśwież
  stronę klawiszem~F5.
]

Po odświeżeniu strony skrypt wstawia wartość przez `innerHTML`, przeglądarka próbuje wczytać
obrazek, nie znajduje go i wykonuje kod z `onerror`. Pojawi się okno komunikatu z ciasteczkiem
sesji.

#zrzut("zrzuty/03_dom_alert.png", [XSS oparty na modelu DOM na stronie powitania. Wartość z fragmentu
adresu po `#` została wstawiona przez `innerHTML`, a zawarty w niej skrypt wykonał się
w przeglądarce bez udziału serwera.], width: 85%)

Efekt działania skryptu można obejrzeć w narzędziach deweloperskich przeglądarki.

#krok[
  Zamknij okno komunikatu. Kliknij prawym przyciskiem myszy małą ikonę niewczytanego obrazka za
  słowem „Witaj,” i wybierz _Zbadaj_ (_Inspect_).
]

Narzędzia deweloperskie otworzą się w zakładce _Elements_ (_Elementy_) z zaznaczonym elementem
`<img>`, który ma atrybut `onerror` i znajduje się wewnątrz elementu `<span id="name">`. Jeśli
zaznaczony zostanie inny element, w zakładce _Elements_ należy rozwinąć element `<p>` pod
nagłówkiem _Powitanie_ (trójkąt po lewej), a następnie element `<span id="name">`.

#zrzut("zrzuty/09_dom_devtools.png", [Zakładka _Elements_ w narzędziach deweloperskich. Wewnątrz
elementu `<span id="name">` znajduje się element `<img>` z atrybutem `onerror`, utworzony przez skrypt
strony z fragmentu adresu.], width: 78%)

#krok[
  Kliknij w obszar strony i naciśnij Ctrl+U. Źródło strony otworzy się w nowej karcie, której
  adres zaczyna się od `view-source:`. Wyszukaj w nim tekst `<img` (Ctrl+F), a następnie tekst
  `innerHTML`.
]

Wyszukiwanie tekstu `<img` nie zwróci żadnego wyniku, ponieważ serwer nie wysłał tego znacznika.
Źródło strony zawiera tylko skrypt odczytujący fragment adresu, a wyszukiwanie tekstu `innerHTML`
wskaże jego wiersz, który należy zapisać do raportu. Skrypt strony dodał element `<img>` w chwili
przypisania wartości do `innerHTML`.

Dowodem do raportu jest adres ze wstrzykniętym fragmentem, wiersz kodu klienta, który wstawia
wartość przez `innerHTML` (widoczny w źródle strony `/welcome`), oraz zrzut ekranu okna komunikatu
albo zakładki _Elements_ z elementem `<img>` wewnątrz `<span id="name">`. Dowód nie zawiera żądania
do serwera ze wstrzykniętą wartością, ponieważ wartość nie opuszcza przeglądarki. W historii Burpa
pojawią się żądania `GET /welcome` (bez fragmentu po `#`) oraz `GET /x`, ale żadne z nich nie
zawiera wstrzykniętej wartości.

= Poprawki

Wszystkie trzy odmiany mają tę samą przyczynę. Wartość od użytkownika trafia do strony tam, gdzie
przeglądarka traktuje ją jako kod. Poprawka polega na tym, aby w miejscu wstawienia wartość była
traktowana jako tekst. Właściwy sposób zależy od tego, dokąd wartość trafia (od kontekstu).

== Kodowanie wyjścia w HTML (XSS odbity i trwały)

Gdy wartość wstawiana jest do treści HTML po stronie serwera, przed wstawieniem koduje się znaki
składni HTML. W aplikacji ćwiczeniowej wersje poprawione `/fixed/search` oraz `/fixed/reviews`
używają funkcji `esc`, która zamienia znaki `&`, `<`, `>`, `"` oraz `'` na encje znakowe
(część~1):

```js
const items = reviews.map((r) => `<li><b>${esc(r.author)}</b>: ${esc(r.text)}</li>`).join("");
```

Po kodowaniu wartość `<img src=x onerror=...>` trafia do strony jako `&lt;img src=x ...&gt;`.
Przeglądarka wyświetla ją jako tekst i nie rozpoczyna od niej znacznika. Takie kodowanie wystarcza
w treści elementów i w wartościach zwykłych atrybutów ujętych w cudzysłów, np. `value` lub `title`.
Nie chroni wartości wstawianej do kodu JavaScript, czyli do znacznika `<script>` lub do atrybutu
obsługi zdarzenia (np. `onclick`), ani adresu w atrybucie `href` (np. `javascript:alert(1)`). Te
konteksty wymagają innych zabezpieczeń.

#krok[
  Sprawdź oba ataki na wersjach poprawionych. Do sprawdzenia poprawki wystarczy dowolny kod,
  np. `alert(1)`. Odnośniki w menu aplikacji prowadzą do wersji podatnych, dlatego adresy wersji
  poprawionych wpisz w pasku adresu. Dla wyszukiwarki otwórz adres:

  `http://127.0.0.1:8000/fixed/search?q=<img%20src=x%20onerror=alert(1)>`

  Jeśli aplikacja była uruchamiana ponownie, dodaj najpierw opinię z części~4 na stronie
  `/reviews`. Następnie otwórz adres `http://127.0.0.1:8000/fixed/reviews`. Strona nie ma
  formularza i wyświetla te same opinie co `/reviews`, zakodowane przed wstawieniem.
]

Wstrzyknięty znacznik pojawi się na stronie jako zwykły tekst, a okno komunikatu nie zostanie
wyświetlone. Ładunek nadal trafia do strony, ale w postaci encji znakowych, które przeglądarka
wyświetla jako zwykłe znaki.

#zrzut("zrzuty/10_fixed_search.png", [Wersja poprawiona wyszukiwarki. Wstrzyknięty znacznik jest
wyświetlony jako zwykły tekst po słowach „Szukana fraza”.])

#zrzut("zrzuty/04_fixed_reviews.png", [Wersja poprawiona opinii. Ta sama wstrzyknięta opinia jest
wyświetlona jako tekst, razem ze znakami `<` i `>`, a skrypt nie wykonuje się.])

Do opisu przebiegu testu należy zapisać oba adresy wersji poprawionych, użytą wartość oraz wynik
(znacznik wyświetlony jako tekst, brak okna komunikatu). Wynik ten potwierdza rekomendację
w raporcie.

W praktyce kodowanie wykonują biblioteki szablonów (ang. _template engines_), które domyślnie kodują
wstawiane wartości. Ręczne składanie kodu strony z fragmentów tekstu, jak w aplikacji ćwiczeniowej,
pomija to zabezpieczenie i jest częstą przyczyną XSS.

== Wstawianie jako tekst w kodzie klienta (XSS oparty na modelu DOM)

W XSS opartym na modelu DOM wartość do strony wstawia skrypt działający w przeglądarce. Serwer jej
nie wstawia, więc kodowanie po stronie serwera nie ma tu zastosowania. Poprawka polega na wstawieniu
wartości jako tekstu.
Właściwość `textContent` ustawia zawartość elementu jako zwykły tekst, więc znaczniki w wartości nie
stają się kodem. Skrypt wersji poprawionej `/fixed/welcome` różni się od podatnego jedną właściwością:

```js
document.getElementById("name").textContent = name;
```

#krok[
  Powtórz atak na wersji poprawionej, wpisując w pasku adresu:

  `http://127.0.0.1:8000/fixed/welcome#<img src=x onerror=alert(1)>`

  Jeśli w karcie był już otwarty adres `/fixed/welcome` z innym fragmentem po `#`, odśwież stronę
  klawiszem~F5.
]

W powitaniu pojawi się tekst znacznika, a okno komunikatu nie zostanie wyświetlone. Adres i wynik
tego sprawdzenia należy zapisać tak samo jak dla wersji poprawionych wyszukiwarki i opinii.

#zrzut("zrzuty/11_fixed_welcome.png", [Wersja poprawiona strony powitania. Wartość z fragmentu adresu
została wstawiona przez `textContent`, więc znacznik jest widoczny jako tekst.])

== Zabezpieczenia uzupełniające

#block(sticky: true)[Poprawki opisane w częściach~6.1 i~6.2 usuwają przyczynę XSS. Dwa dodatkowe
mechanizmy ograniczają skutki, gdy podatność jednak wystąpi:]

- *Ciasteczko z atrybutem `HttpOnly`* nie jest dostępne dla skryptów strony, więc `document.cookie`
  go nie odczyta. Ogranicza to kradzież ciasteczka sesji, ale nie usuwa samej podatności, ponieważ
  skrypt atakującego nadal wykonuje się i może działać w imieniu użytkownika.
- *Nagłówek `Content-Security-Policy` (CSP)* to polityka, którą serwer wysyła wraz ze stroną i która
  określa między innymi, z jakich źródeł przeglądarka może wczytywać skrypty i czy może wykonywać skrypty
  osadzone w stronie (znaczniki `<script>` bez atrybutu `src` oraz atrybuty obsługi zdarzeń, takie
  jak `onerror`). Dobrze dobrana polityka blokuje wykonanie wstrzykniętego kodu. Stanowi jednak
  warstwę dodatkową i nie zastępuje kodowania wyjścia.

= Zapis znaleziska w raporcie

Raport z testu penetracyjnego, poza listą znalezisk, opisuje przebieg testu, czyli to, które adresy i wartości
sprawdzono i w jakiej kolejności. W tym ćwiczeniu przebieg obejmuje trzy sprawdzone miejsca
(wyszukiwarkę, opinie i powitanie) oraz powtórzenie każdego ataku na wersji poprawionej.

#block(sticky: true)[Znalezisko opisuje się według następującego schematu:]

+ Tytuł i identyfikator, np. „F-01. XSS odbity w wyszukiwarce produktów”.
+ Lokalizacja: endpoint (punkt końcowy, czyli metoda HTTP i ścieżka obsługiwane przez aplikację)
  oraz parametr, np. `GET /search`, parametr `q`.
+ Opis: na czym polega błąd i jaki skutek może wywołać.
+ Kategoria według OWASP Top 10 oraz numer CWE. OWASP Top 10 to publikowana przez fundację OWASP
  lista najpoważniejszych ryzyk bezpieczeństwa aplikacji webowych; oznaczenie `A05:2025` to
  kategoria 5 w wydaniu z 2025 roku. CWE (Common Weakness Enumeration) to katalog typów słabości
  oprogramowania. XSS należy do kategorii `A05:2025 Injection` oraz do `CWE-79` (Improper
  Neutralization of Input During Web Page Generation ('Cross-site Scripting')).
+ Waga (krytyczna, wysoka, średnia, niska, według skali z ćwiczenia~1) z jednozdaniowym
  uzasadnieniem opisującym skutek dla właściciela systemu. W aplikacji ćwiczeniowej ciasteczko
  sesji nie ma atrybutu `HttpOnly`, więc wykonanie skryptu pozwala przejąć sesję ofiary. Przy
  ustalaniu wagi należy uwzględnić, czy atak wymaga dodatkowego działania ofiary, np. otwarcia
  spreparowanego adresu.
+ Kroki odtworzenia: numerowana lista czynności, która pozwala innej osobie powtórzyć test.
+ Dowód: adres lub żądanie ze wstrzykniętą wartością oraz fragment odpowiedzi, fragment kodu albo
  zrzut strony, na którym widać wykonanie kodu.
+ Rekomendacja: zmiana po stronie aplikacji, która usuwa przyczynę błędu.

Przykład dowodu dla XSS odbitego w wyszukiwarce:

```
GET /search?q=%3Cimg%20src=x%20onerror=alert(document.cookie)%3E HTTP/1.1
Host: 127.0.0.1:8000

HTTP/1.1 200 OK
...
<p>Szukana fraza: <img src=x onerror=alert(document.cookie)></p>
```

Dla znalezisk dotyczących XSS odbitego i trwałego rekomendacją jest kodowanie wartości przed
wstawieniem do treści HTML (zamiana znaków składni HTML na encje znakowe), jak w wersjach
`/fixed/search` oraz `/fixed/reviews`. Dla znaleziska dotyczącego XSS opartego na modelu DOM
rekomendacją jest wstawienie wartości jako tekstu (`textContent`) zamiast jako kodu (`innerHTML`),
jak w wersji `/fixed/welcome`. Jako zabezpieczenie uzupełniające można zalecić oznaczenie ciasteczka
`session` atrybutem `HttpOnly` oraz wysyłanie nagłówka `Content-Security-Policy` (część~6.3),
z zaznaczeniem, że nie zastępują one tych poprawek.

Znalezisko dotyczące XSS trwałego obejmuje dwa endpointy: wartość jest zapisywana przez
`POST /reviews` (parametr `text`), a wykonywana przy wyświetleniu listy przez `GET /reviews`; w polu
lokalizacji należy podać oba. Parametr `author` jest wstawiany do strony w tym samym wierszu kodu,
również bez kodowania (fragment kodu w części~4); w raporcie można go wymienić z adnotacją, że wniosek wynika
z analizy kodu, a nie z testu.

W znalezisku dotyczącym XSS opartego na modelu DOM lokalizacją jest strona `/welcome`, źródło
wartości `location.hash` oraz wiersz skryptu, który przypisuje wartość do `innerHTML`. Dowodem jest
ten wiersz kodu przepisany ze źródła strony oraz adres użyty w teście.

Ciasteczka innych użytkowników użyte jako dowód należy ograniczyć do minimum, zamaskować w raporcie
i usunąć po zakończeniu testu. W ćwiczeniu ciasteczko `session=admin` pochodzi z własnego konta
testowego i nie wymaga maskowania.

#block(sticky: true)[Po zakończeniu ćwiczenia notatki powinny zawierać materiał do trzech
znalezisk:]

#table(
  columns: (25%, 30%, 1fr),
  table.header[Znalezisko][Lokalizacja][Dowód i sprawdzenie poprawki],
  [F-01. XSS odbity], [`GET /search`, parametr `q`],
    [wiersz żądania i fragment odpowiedzi z zakładki _Repeater_ (część~3); wynik dla
     `/fixed/search`],
  [F-02. XSS trwały], [`POST /reviews`, parametr `text`; `GET /reviews`],
    [treść żądania `POST` i zrzut listy opinii (część~4); wynik dla `/fixed/reviews`],
  [F-03. XSS oparty na modelu DOM], [`GET /welcome`, źródło wartości `location.hash`],
    [adres użyty w teście, wiersz kodu z `innerHTML` ze źródła strony i zrzut okna komunikatu
     (część~5); wynik dla `/fixed/welcome`],
)

= Pytania kontrolne

+ Dlaczego fraza `<b>test</b>` w wyszukiwarce jest wyświetlana jako pogrubione słowo, a nie jako
  tekst ze znacznikami?
+ Dlaczego w ćwiczeniu zastosowano znacznik obrazka z atrybutem `onerror` zamiast znacznika
  `<script>`?
+ Na czym polega różnica między XSS odbitym a trwałym z punktu widzenia sposobu dotarcia do ofiary?
+ Dlaczego XSS oparty na modelu DOM na stronie `/welcome` nie zostawia śladu w żądaniu wysłanym
  na serwer?
+ Czym różni się `innerHTML` od `textContent` i dlaczego ta różnica usuwa podatność?
+ Dlaczego kodowanie wyjścia po stronie serwera nie naprawia XSS opartego na modelu DOM?
+ Co ogranicza atrybut `HttpOnly` ciasteczka, a czego nie usuwa?

#v(1.5em)
#ramka("DALSZA PRAKTYKA", accent, accent-light)[
  #set text(9.5pt)
  Do dalszych ćwiczeń można wykorzystać
  #link("https://portswigger.net/web-security/cross-site-scripting")[PortSwigger Web Security
  Academy] (bezpłatne laboratoria z XSS, z ćwiczeniem i rozwiązaniem dla każdej odmiany) oraz
  aplikację OWASP Juice Shop. Testy należy prowadzić wyłącznie we własnym środowisku lub za pisemną
  zgodą właściciela systemu.
]
