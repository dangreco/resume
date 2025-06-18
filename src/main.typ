#import "@preview/fontawesome:0.5.0": *

#let cfg = yaml("cfg.yml")

#set document(
  title: cfg.profile.name,
  author: cfg.profile.name,
)

#set text(
  font: "Libertinus Serif",
  size: 12pt,
  lang: "en",
  ligatures: false,
)

#set page(
  margin: (0.5in),
  paper: "us-letter",
)

#show link: underline

#align(center)[
  = #cfg.profile.name
  #v(-0.20cm)
  === #cfg.profile.position
  #text(size: 10pt)[#cfg.profile.location]
  #v(0.25cm)
  #text(size: 10pt)[
    #stack(
      dir: ltr,
      spacing: 0.5cm,
      ..for l in cfg.profile.links {
        ([#fa-icon(l.icon) #h(2pt) #link(l.to)[#l.value]], )
      },
    )
  ]
  #v(0.25cm)
]

== Summary
#line(length: 100%)
#cfg.summary.replace("\n", " ")

== Education
#line(length: 100%)
#v(0.25cm)

#for e in cfg.education {
  let format = "[month repr:long] [year]"
  let from = datetime(month: e.from.month, year: e.from.year, day: 1)
  let to = datetime(month: e.to.month, year: e.to.year, day: 1)

  grid(
    columns: (1fr, auto),
    align: (start, end),
    [
      *#e.institution* \
      #for d in e.degree.filter((d) => d.type == "major") {
        [*#d.degree in #d.field*]
      } \
      #for d in e.degree.filter((d) => d.type == "minor") {
        [Minor in #d.field]
      }
    ],
    [
      #e.location \
      #if e.expected [
        Expected #to.display(format)
      ] else [
        #from.display(format) - #to.display(format)
      ]
    ]
  )
  v(0.25cm)
}

== Experience
#line(length: 100%)
#v(0.25cm)

#for e in cfg.experience {
  let format = "[month repr:long] [year]"
  let from = datetime(month: e.from.month, year: e.from.year, day: 1)
  let to = datetime(month: e.to.month, year: e.to.year, day: 1)

  grid(
    columns: (1fr, auto),
    align: (start, end),
    [
      *#e.company* \
      #e.title

    ],
    [
      #e.location \
      #from.display(format) - #to.display(format)
    ]
  )
  v(0.1cm)
  for l in e.description.split("\n").filter((s) => s.trim().len() > 0) {
    [- #l]
  }
  v(0.25cm)
}

== Skills
#line(length: 100%)

#for c in cfg.skills {
  [
    *#c.category:*
    #c.items.join(", ")
    #linebreak()
  ]
}
