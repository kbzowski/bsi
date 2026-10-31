# Ćwiczenie 4. Bezpieczeństwo haseł

Plik ze skrótami kilkunastu haseł i instrukcja pokazująca, co odróżnia hasło odporne na złamanie od
hasła słabego. Kolejne ataki narzędziem hashcat odczytują ze skrótów coraz trudniejsze hasła: od
słów z wycieków, przez słowa z typowymi podmianami znaków, po krótkie ciągi losowe. Dwa hasła w
pliku nie zostają odczytane żadnym atakiem; ćwiczenie dotyczy właśnie różnicy między nimi a pozostałymi.
Część opcjonalna powtarza ataki na skrótach policzonych funkcją bcrypt, aby pokazać różnicę między
szybką a wolną funkcją skrótu.

Instrukcja: [instrukcja.pdf](instrukcja.pdf)

## Zawartość katalogu

- `instrukcja.pdf` – instrukcja do ćwiczenia,
- `hashes_sha256.txt` – skróty haseł do złamania (SHA-256),
- `hashes_bcrypt.txt` – te same hasła zapisane funkcją bcrypt (część opcjonalna),
- `slownik.txt` – lista haseł do ataku słownikowego,
- `reguly.rule` – reguły podmian do ataku z regułami,
- `zrodla/` – źródło instrukcji w formacie Typst.

## Narzędzie

Ćwiczenie wykonuje się narzędziem hashcat w wersji 7 lub nowszej, pobieranym ze strony
[hashcat.net](https://hashcat.net/hashcat/). W systemie Windows pobiera się je jako archiwum `7z`,
które należy rozpakować; narzędzie nie wymaga instalacji. Poprawność sprawdza polecenie
`hashcat.exe --version`.

Karta graficzna nie jest wymagana. Część podstawowa jest wykonalna na samym procesorze. Część
opcjonalna z funkcją bcrypt jest obliczeniowo cięższa i w rozsądnym czasie wymaga karty graficznej.

## Zasady

Pliki służą wyłącznie do nauki. Skróty w pliku pochodzą z haseł ułożonych na potrzeby ćwiczenia.
Łamanie skrótów wolno prowadzić tylko na skrótach własnych lub na pliku dołączonym do ćwiczenia,
w całości na własnym komputerze. Kierowanie tych samych narzędzi na skróty pozyskane z cudzego
systemu, bez pisemnej zgody właściciela, może stanowić przestępstwo.
