# Cwiczenie 5. Metasploit - wejscie na maszyne

Maszyna wirtualna z piecioma uslugami sieciowymi. Cztery lamia sie jednym modulem Metasploita:
vsftpd 2.3.4 z backdoorem, Samba z bledem mapowania nazw uzytkownikow, Samba z luka SambaCry
i Drupal 7 z podatnym formularzem (Drupalgeddon2). Dodatkowo strona informacyjna zajmuje w labie
port 80 (na VM port 8000).
Cwiczenie pokazuje pelna sciezke ataku: baner, modul, payload, sesja, flaga.

Instrukcja: [instrukcja.pdf](instrukcja.pdf)

## Zawartosc katalogu

- `instrukcja.pdf` - instrukcja do cwiczenia,
- `zrodla/` - zrodlo instrukcji w formacie Typst wraz z szablonem i zrzutami ekranu.

Maszyna (plik OVA) jest wydawana osobno; link na stronie kursu.

## Narzedzie

Cwiczenie wykonuje sie Metasploit Frameworkiem (`msfconsole`) w konsoli labowej wydanej
maszyny. Nic nie trzeba instalowac; adresy uslug, polecenia startowe i przebieg krok po kroku
opisuje instrukcja.

## Zasady

Ataki wolno prowadzic wylacznie na wlasnej maszynie wydanej do cwiczenia. Kierowanie tych samych
narzedzi na systemy obce, bez pisemnej zgody wlasciciela, moze stanowic przestepstwo.
