# Ćwiczenie 3. Cross-site scripting (XSS)

Celowo podatna aplikacja sklepu internetowego „Przecena” i instrukcja do ćwiczenia z podatności
cross-site scripting. Instrukcja omawia trzy odmiany XSS w trzech miejscach aplikacji: odbity
(reflected) w wyszukiwarce, trwały (stored) w opiniach o sklepie oraz oparty na modelu DOM
(DOM-based) na stronie powitania. Dla każdej odmiany pokazane jest wykrycie, wykorzystanie oraz
wersja poprawiona, która blokuje atak.

Instrukcja: [instrukcja.pdf](instrukcja.pdf)

## Zawartość katalogu

- `instrukcja.pdf` – instrukcja do ćwiczenia,
- `app.mjs` – aplikacja testowana w ćwiczeniu,
- `package.json` – zależności i polecenie uruchamiające,
- `package-lock.json` – dokładne wersje zależności,
- `zrodla/` – źródło instrukcji w formacie Typst wraz ze zrzutami ekranu.

## Uruchomienie aplikacji

Wymagany jest Node.js w wersji 18 lub nowszej.

```bash
npm install
npm start
```

Aplikacja nasłuchuje pod adresem `http://127.0.0.1:8000`. Opinie są przechowywane w pamięci procesu,
więc ponowne uruchomienie aplikacji przywraca stan początkowy.

## Narzędzia

Ćwiczenie wykonuje się we wbudowanej przeglądarce narzędzia Burp Suite Community, opisanego
w ćwiczeniu 1. Burp służy też do obejrzenia, powtórzenia i udokumentowania żądań. XSS oparty na
modelu DOM obserwuje się w narzędziach deweloperskich przeglądarki.

## Zasady

Aplikacja zawiera podatności celowo i służy wyłącznie do nauki. Należy ją uruchamiać tylko na
własnym komputerze. Opisane techniki wolno stosować wyłącznie wobec własnych systemów lub za
pisemną zgodą właściciela systemu.
