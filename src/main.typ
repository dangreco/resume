#import "@preview/fontawesome:0.6.0": *

#let cfg = yaml("cfg.yml")

// Document settings
#set document(
  title: cfg.profile.name,
  author: cfg.profile.name,
)
#set text(
  font: "Libertinus Serif",
  size: 10pt,
  lang: "en",
  ligatures: false,
)
#set page(
  margin: 0.5in,
  paper: "us-letter",
)
#set par(
  leading: 0.5em,
  spacing: 0.5em,
)
#show link: underline

// Helper functions
#let section(title) = {
  v(0.5cm)
  text(size: 11pt, weight: "bold", tracking: 0.05em)[#upper(title)]
  line(length: 100%, stroke: 0.5pt)
  v(0.25cm)
}

#let icon(name) = [#fa-icon(name, size: 7pt)]

#let format-date-range(from, to, expected: false) = {
  let fmt = "[month repr:short] [year]"
  let from_ = datetime(month: from.month, year: from.year, day: 1).display(fmt)
  let to_ = datetime(month: to.month, year: to.year, day: 1).display(fmt)
  if expected [Expected #to_] else [#from_ – #to_]
}

// Header
#align(left)[
  #text(size: 20pt, weight: "bold")[#cfg.profile.name]
  #v(0.15cm)
  #text(size: 10pt)[#cfg.profile.position #sym.dot.c #cfg.profile.location]
  #v(0.2cm)
  #text(size: 9pt)[
    #(
      cfg
        .profile
        .links
        .map(l => {
          [#icon(l.icon) #link(l.to)[#l.value]]
        })
        .join(h(0.4cm))
    )
  ]
]

// Summary
#section("Summary")
#cfg.summary.join(". ").

// Education
#section("Education")
#for x in cfg.education {
  grid(
    columns: (1fr, auto),
    align: (start, end),
    [*#x.degree.filter(d => d.type == "major").map(d => d.degree).join("")* #sym.dot.c #x.institution],
    text(size: 9pt)[#format-date-range(x.from, x.to)],
  )
  text(size: 9pt, fill: rgb("#555"))[#x.location]
  v(0.08cm)
  text()[
    #if (
      x.degree.filter(d => d.type == "major").len() > 0
    ) [*Major:* #x.degree.filter(d => d.type == "major").map(d => d.field).join(", ")]
    \
    #if (
      x.degree.filter(d => d.type == "minor").len() > 0
    ) [*Minor:* #x.degree.filter(d => d.type == "minor").map(d => d.field).join(", ")]
    \
    *Relevant Coursework:* #x.coursework.join(", ")
  ]
}

// Experience
#section("Experience")
#for x in cfg.experience {
  grid(
    columns: (1fr, auto),
    align: (start, end),
    [*#x.title* #sym.dot.c #x.company],
    text(size: 9pt)[#format-date-range(x.from, x.to)],
  )
  text(size: 9pt, fill: rgb("#555"))[#x.location]
  v(0.12cm)
  for y in x.description {
    grid(
      columns: (0.4cm, 1fr),
      [•], [#y],
    )
  }
  v(0.2cm)
}

// Skills
#section("Skills")
#for x in cfg.skills {
  [*#x.category:* #x.items.join(", ") \ ]
}

// Projects
#section("Projects")
#for x in cfg.projects {
  grid(
    columns: (1fr, auto),
    align: (start, end),
    [*#x.name*],
    text(size: 9pt)[#icon("star") #x.stars #h(0.2cm) #icon(
        "code-fork",
      ) #x.forks],
  )
  text(size: 9pt)[#link("https://github.com/" + x.repo)[github.com/#x.repo] #h(
      0.3cm,
    ) #text(fill: rgb("#555"))[#x.tags.join(" • ")]]
  v(0.12cm)
  for y in x.description {
    grid(
      columns: (0.4cm, 1fr),
      [•], [#y],
    )
  }
  v(0.2cm)
}
