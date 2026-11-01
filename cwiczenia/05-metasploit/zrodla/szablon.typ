// wyglad instrukcji do cwiczen BSI
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#let accent = rgb("#1d4e89")
#let accent-light = rgb("#eef3fa")
#let ink = rgb("#1b2430")
#let muted = luma(105)
#let warn = rgb("#a15c00")
#let warn-light = rgb("#fff6e5")
#let sans-head = ("Inter", "Segoe UI", "Arial")
#let mono = ("Cascadia Mono", "Consolas")

#let dnode(pos, body, fill: accent-light, stroke: accent, ..a) = node(
  pos, align(center, text(font: sans-head, body)),
  fill: fill, stroke: 0.9pt + stroke, inset: 9pt, corner-radius: 3pt, ..a,
)
#let dtag(body) = text(font: sans-head, size: 8pt, fill: muted, body)
#let dedge(..a) = edge(stroke: 0.9pt + accent, ..a)

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

// jedna numeracja dla zrzutow i diagramow, w tekscie odwolanie @id[rys.] albo @id[rysunku]
#let ilustracja(id, body, cap, width) = align(center, block(width: width)[
  #figure(body, caption: cap, supplement: [Rys.], kind: "rys") #label(id)
])
#let rysunek(id, body, cap, width: 100%) = ilustracja(id, body, cap, width)
// typst compile --input brudnopis=1 wstawia ramke zamiast brakujacego pliku
#let zrzut(id, path, cap, width: 100%) = ilustracja(id,
  if "brudnopis" in sys.inputs {
    rect(width: 100%, height: 3cm, stroke: 0.5pt + luma(200))[#align(center + horizon)[ZRZUT: #path]]
  } else {
    box(stroke: 0.5pt + luma(200), radius: 2pt, clip: true, image(path, width: 100%))
  },
  cap, width)

#let w-kodzie = state("w-kodzie", false)

// wyjscie terminala jako tekst, np. #konsola(```...```)
#let konsola(r) = block(
  fill: rgb("#1e2430"), inset: (x: 11pt, y: 9pt), radius: 3pt, width: 100%, above: 1.1em, below: 1.1em,
  {
    set par(justify: false, leading: 0.5em)
    w-kodzie.update(true)
    text(font: mono, size: 8.5pt, fill: luma(232), r.text)
    w-kodzie.update(false)
  },
)

#let cwiczenie(tytul: "", body) = {
  set document(title: tytul, author: "BSI")
  set page(
    paper: "a4",
    margin: (x: 2.2cm, top: 2.2cm, bottom: 2cm),
    header: context {
      if counter(page).get().first() > 1 {
        set text(font: sans-head, size: 8pt, fill: muted)
        [Bezpieczeństwo Systemów Informatycznych #h(1fr) #tytul]
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
  set text(font: ("Noto Sans", "Segoe UI", "Arial"), size: 10pt, fill: ink, lang: "pl")
  set par(justify: true, leading: 0.68em, spacing: 1em)
  set list(indent: 0.4em, marker: text(fill: accent)[•])
  set enum(indent: 0.4em, numbering: n => text(fill: accent, weight: "semibold")[#n.])
  show strong: set text(weight: "semibold")

  // rozdzialy od 0
  set heading(numbering: (..n) => numbering("1.", n.pos().first() - 1, ..n.pos().slice(1)))
  show heading.where(level: 1): it => {
    // kazdy rozdzial (i spis tresci) od nowej strony
    pagebreak(weak: true)
    set text(font: sans-head, size: 14pt, weight: "semibold", fill: ink)
    block(above: 0em, below: 0.8em)[
      #it
      #v(-0.55em)
      #line(length: 100%, stroke: 0.6pt + luma(205))
    ]
  }
  show heading: set text(hyphenate: false)
  show heading.where(level: 2): it => {
    set text(font: sans-head, size: 11pt, weight: "semibold", fill: accent)
    block(above: 1.3em, below: 0.7em, sticky: true, it)
  }
  show outline.entry.where(level: 1): set block(above: 0.55em)
  show outline.entry: set text(font: sans-head, size: 9.5pt)

  show link: set text(fill: accent)
  show ref: set text(fill: accent)
  show raw: set text(font: mono, size: 0.92em)
  show raw.where(block: false): box.with(fill: rgb("#f0f2f5"), outset: (x: 1.5pt, y: 2.5pt), radius: 2pt)
  show raw.where(block: true): block.with(
    fill: rgb("#f6f8fa"), stroke: 0.5pt + luma(215), inset: (x: 11pt, y: 9pt), radius: 3pt, width: 100%,
  )
  // sierotki (a, i, w, z...), poza kodem, bo twarda spacja psuje kopiowane polecenia
  show raw: it => { w-kodzie.update(true); it; w-kodzie.update(false) }
  show regex("\b[aiouwzAIOUWZ] "): it => context {
    if w-kodzie.get() { it } else { [#it.text.trim()~] }
  }

  // rownania: numer po prawej, w tekscie odwolanie @rown-x[rownaniu]
  set math.equation(numbering: "(1)", number-align: right + horizon, supplement: [równanie])
  show math.equation.where(block: true): set block(above: 1.1em, below: 1.1em)
  // odwolanie w postaci "rownanie (1)", Typst sam pomija nawias
  show ref: it => {
    let el = it.element
    if el != none and el.func() == math.equation {
      let n = counter(math.equation).at(el.location()).first()
      link(el.location(), [#it.supplement~(#n)])
    } else if el != none and el.func() == heading {
      // odwolanie miedzy rozdzialami: klikalne @roz-x[czesci], numer bez kropki na koncu
      let n = numbering(el.numbering, ..counter(heading).at(el.location())).trim(".", at: end)
      link(el.location(), [#it.supplement~#n])
    } else { it }
  }

  set table(
    inset: (x: 7pt, y: 5pt),
    stroke: (_, y) => if y == 0 { (bottom: 0.8pt + accent) } else { (bottom: 0.4pt + luma(220)) },
    fill: (_, y) => if y == 0 { accent-light },
  )
  show table.cell.where(y: 0): set text(font: sans-head, size: 9pt, weight: "semibold", fill: accent)
  show table: set par(justify: false)
  show table: block.with(breakable: false)

  show figure: set block(above: 1.2em, below: 1.2em)
  show figure.caption: it => {
    set text(size: 8.5pt, fill: muted)
    set align(left)
    set par(justify: false)
    [#text(weight: "semibold", fill: ink)[#it.supplement #context it.counter.display(it.numbering).] #it.body]
  }

  block(width: 100%, below: 1.4em)[
    #text(font: sans-head, size: 8pt, weight: "semibold", tracking: 0.12em, fill: accent)[
      BEZPIECZEŃSTWO SYSTEMÓW INFORMATYCZNYCH · ĆWICZENIA
    ]
    #v(2pt)
    #text(font: sans-head, size: 24pt, weight: "bold", fill: ink)[#tytul]
    #v(4pt)
    #line(length: 100%, stroke: 1.5pt + accent)
  ]

  body
}
