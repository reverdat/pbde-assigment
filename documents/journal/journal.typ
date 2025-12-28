#import "@preview/lovelace:0.3.0": *
#set text(font: "TeX Gyre Termes", size: 11pt)
#show math.equation: set text(font: "TeX Gyre Termes Math")
#set page(
    header: context{
        if counter(page).get().first() > 1 [
            _Arnau Pérez - PBDE_ 
            #h(1fr)
            MESIO, UPC
        ]
    },
    paper: "a4",
    numbering: "1",
    margin: 1.25in,
)

#set document(
  title: [Final Assignment]
)

#set par(leading: 0.55em, spacing: 0.55em, first-line-indent: 1.8em, justify: true)
#set heading(numbering: "1.")
#show heading: set block(above: 1.4em, below: 1em)

#let fmt-date(d) = strong(
  d.display("[weekday] [day] of [month repr:long] [year]")
)


#align(center, text(18pt)[
  *Final Assignment* 
])
#align(center, text(16pt)[
  _Journal_ 
])



#align(center)[
    #stack(
        spacing: 0.65em,
        [_Arnau Pérez Reverte_],
        [_05-01-2026_],
        [_Programming and Statistical Databases , MESIO UPC-UB_]
    )
]

\

#let date = datetime(year: 2025, month: 12, day: 28)

#fmt-date(date)
#align(left)[
I am (finally) starting this assignment today. Major milestone for me since I learned how to use Nix to declare a development environment for the teacher to use in case he wants to reproduce the results. Moreover, the $mono("devenv.nix")$ file also includes Typst, so even the documents submitted are reproducible -- _i use nix btw_.

Anyway, the actual work to be put is this journal as I write my thoughts and the $mono("EDA.ipynb")$ file with the EDA findings.
]


