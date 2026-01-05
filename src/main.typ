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
  margin: 0.4in,
  paper: "us-letter",
)

#set par(
  leading: 0.5em,
  spacing: 0.5em,
)

#show link: underline

// Helper functions
#let section(title) = {
  v(0.32cm)
  text(size: 12pt)[*#upper(title)*]
  line(length: 100%, stroke: 0.5pt)
  v(0.16cm)
}

#let icon(name) = [#fa-icon(name, size: 7pt)]

#let format-date-range(from, to, expected: false) = {
  let fmt = "[month repr:short] [year]"
  let from_ = datetime(month: from.month, year: from.year, day: 1).display(fmt)
  let to_ = datetime(month: to.month, year: to.year, day: 1).display(fmt)

  if expected [Expected #to_] else [#from_ - #to_]
}

// Header
#align(center)[
  #text(size: 18pt)[*#cfg.profile.name*] \
  #v(0.16cm)
  #text(size: 10pt)[#cfg.profile.position • #cfg.profile.location] \
  #v(0.24cm)
  #text(size: 10pt)[
    #stack(
      dir: ltr,
      spacing: 0.4cm,
      ..cfg
        .profile
        .links
        .map(l => {
          [#icon(l.icon) #h(1pt) #link(l.to)[#l.value]]
        })
        .flatten(),
    )
  ]
  #v(0.08cm)
]


// Summary
#section("Summary")
#{
  (..cfg.summary, "").join(". ")
}

// Education
#section("Education")
#{
  for x in cfg.education {
    grid(
      columns: (1fr, auto),
      align: (start, end),
      gutter: 0.24cm,
      [*#x.institution* | #x.location],
      format-date-range(x.from, x.to, expected: x.expected),
    )

    (
      x
        .degree
        .filter(d => d.type == "major")
        .map(d => d.degree + " in " + d.field),
      x.degree.filter(d => d.type == "minor").map(d => "Minor in " + d.field),
    )
      .flatten()
      .join(", ")

    v(0.24cm)
  }
}

// Experience
#section("Experience")
#{
  for x in cfg.experience {
    grid(
      columns: (1fr, auto),
      align: (start, end),
      gutter: 0.24cm,
      [*#x.company* | #x.location], format-date-range(x.from, x.to),
    )
    text(fill: rgb("#444"))[_#x.title;_ \ ]
    v(0.08cm)
    for y in x.description [• #y \ ]
    v(0.24cm)
  }
}

// Skills
#section("Skills")
#{
  for x in cfg.skills [
    *#x.category:* #x.items.join(", ") \
  ]
}

// Projects
#section("Projects")
#{
  for x in cfg.projects [
    *#x.name* \
    #link("https://github.com/" + x.repo)[github.com/#x.repo] • #icon("star") #x.stars #icon("code-fork") #x.forks • #text(fill: rgb("#444"))[_#x.tags.join(", ")_] \
    #v(0.16cm)
    #x.description.join(". ") \
    #v(0.24cm)
  ]
}
