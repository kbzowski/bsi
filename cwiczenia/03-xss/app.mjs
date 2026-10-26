// Sklep "Przecena" - BSI, cwiczenia z XSS (reflected, stored, DOM-based)
// uruchomienie: npm install, potem npm start
// dane (opinie) trzymane w pamieci, po restarcie wracaja do stanu poczatkowego
import express from "express";

const app = express();
// bez ETag, zeby Repeater zawsze dostawal 200 z cala strona, a nie 304
app.disable("etag");
app.use(express.urlencoded({ extended: false }));

// opinie o sklepie - przechowywane w pamieci procesu
const reviews = [
  { author: "alice", text: "Szybka dostawa, polecam." },
  { author: "bob", text: "Dobre ceny, wszystko zgodne z opisem." },
];

// pomocnicze

function page(title, body) {
  return `<!doctype html><html lang="pl"><meta charset="utf-8">
<title>${title}</title><body style="font-family:sans-serif;max-width:680px;margin:2rem auto">
<h1>Sklep „Przecena”</h1>${body}</body></html>`;
}

function esc(s) {
  // kodowanie znakow specjalnych HTML - uzywane tylko w wersjach poprawionych
  return String(s).replace(/[&<>"']/g, (c) =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c])
  );
}

function currentUser(cookie) {
  // ciasteczko sesji to sam login, bez podpisu (jak w cwiczeniu 1)
  const m = /(?:^|;\s*)session=([^;]+)/.exec(cookie || "");
  return m ? decodeURIComponent(m[1]) : null;
}

function nav(who) {
  const status = who
    ? `Zalogowany jako <b>${esc(who)}</b>. <a href="/logout">Wyloguj</a>`
    : `Nie jesteś zalogowany.`;
  return `<p style="color:#555">${status}</p>
<p><a href="/">Start</a> · <a href="/search?q=Monitor">Wyszukiwarka</a> ·
<a href="/reviews">Opinie</a> · <a href="/welcome">Powitanie</a></p><hr>`;
}

// strona glowna

app.get("/", (req, res) => {
  const who = currentUser(req.headers.cookie);
  res.send(
    page(
      "Sklep",
      `${nav(who)}
<h2>Logowanie</h2>
<form method="post" action="/login">
  <p>Login: <input name="username" value="admin"></p>
  <button>Zaloguj</button>
</form>

<h2>Wyszukiwarka produktów</h2>
<form method="get" action="/search">
  <p>Szukaj: <input name="q" value="Monitor"></p>
  <button>Szukaj</button>
</form>`
    )
  );
});

// logowanie - uproszczone, ustawia ciasteczko sesji bez hasla
// sluzy tylko temu, zeby w przegladarce istniala sesja widoczna w document.cookie
app.post("/login", (req, res) => {
  const username = req.body.username || "gosc";
  res.setHeader("Set-Cookie", `session=${encodeURIComponent(username)}; Path=/`);
  res.redirect("/");
});

app.get("/logout", (req, res) => {
  res.setHeader("Set-Cookie", "session=; Path=/; Max-Age=0");
  res.redirect("/");
});

// Reflected XSS
// PODATNE: wartosc parametru q trafia do HTML bez kodowania
// payload: /search?q=<img src=x onerror=alert(document.cookie)>
app.get("/search", (req, res) => {
  const who = currentUser(req.headers.cookie);
  const q = req.query.q ?? "";
  res.send(
    page(
      "Wyniki",
      `${nav(who)}
<h2>Wyniki wyszukiwania</h2>
<p>Szukana fraza: ${q}</p>
<p>Brak produktów pasujących do zapytania.</p>`
    )
  );
});

// wersja poprawiona - ta sama fraza, ale zakodowana przed wstawieniem do HTML
app.get("/fixed/search", (req, res) => {
  const who = currentUser(req.headers.cookie);
  const q = req.query.q ?? "";
  res.send(
    page(
      "Wyniki (wersja poprawiona)",
      `${nav(who)}
<h2>Wyniki wyszukiwania</h2>
<p>Szukana fraza: ${esc(q)}</p>
<p>Brak produktów pasujących do zapytania.</p>`
    )
  );
});

// Stored XSS
// PODATNE: tresc opinii zapisana w pamieci i wyswietlana bez kodowania
// payload w polu tresci: <img src=x onerror=alert(document.cookie)>
app.get("/reviews", (req, res) => {
  const who = currentUser(req.headers.cookie);
  const items = reviews
    .map((r) => `<li><b>${r.author}</b>: ${r.text}</li>`)
    .join("");
  res.send(
    page(
      "Opinie",
      `${nav(who)}
<h2>Opinie o sklepie</h2>
<ul>${items}</ul>
<h3>Dodaj opinię</h3>
<form method="post" action="/reviews">
  <p>Podpis: <input name="author" value="gość"></p>
  <p>Treść: <input name="text" size="40"></p>
  <button>Dodaj</button>
</form>`
    )
  );
});

app.post("/reviews", (req, res) => {
  const author = req.body.author || "anonim";
  const text = req.body.text || "";
  reviews.push({ author, text });
  res.redirect("/reviews");
});

// wersja poprawiona - podpis i tresc zakodowane przed wstawieniem do HTML
app.get("/fixed/reviews", (req, res) => {
  const who = currentUser(req.headers.cookie);
  const items = reviews
    .map((r) => `<li><b>${esc(r.author)}</b>: ${esc(r.text)}</li>`)
    .join("");
  res.send(
    page(
      "Opinie (wersja poprawiona)",
      `${nav(who)}
<h2>Opinie o sklepie</h2>
<ul>${items}</ul>`
    )
  );
});

// DOM-based XSS
// PODATNE: skrypt po stronie przegladarki wstawia fragment adresu (po #) przez innerHTML
// fragment po # nie jest wysylany na serwer, podatnosc jest w kodzie klienta
// payload: /welcome#<img src=x onerror=alert(document.cookie)>
app.get("/welcome", (req, res) => {
  const who = currentUser(req.headers.cookie);
  res.send(
    page(
      "Powitanie",
      `${nav(who)}
<h2>Powitanie</h2>
<p>Witaj, <span id="name">gościu</span>!</p>
<p style="color:#555">Imię można podać w adresie po znaku #, np. <code>/welcome#Ala</code>.</p>
<script>
  // PODATNE: fragment adresu wstawiany jako HTML
  var name = decodeURIComponent(location.hash.slice(1));
  if (name) document.getElementById("name").innerHTML = name;
</script>`
    )
  );
});

// wersja poprawiona - ten sam fragment wstawiany jako tekst (textContent), nie jako HTML
app.get("/fixed/welcome", (req, res) => {
  const who = currentUser(req.headers.cookie);
  res.send(
    page(
      "Powitanie (wersja poprawiona)",
      `${nav(who)}
<h2>Powitanie</h2>
<p>Witaj, <span id="name">gościu</span>!</p>
<script>
  var name = decodeURIComponent(location.hash.slice(1));
  if (name) document.getElementById("name").textContent = name;
</script>`
    )
  );
});

app.listen(8000, "127.0.0.1", () => {
  console.log("Aplikacja nasluchuje pod http://127.0.0.1:8000");
});
