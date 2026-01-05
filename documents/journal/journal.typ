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

Anyway, the actual work to be put is this journal as I write my thoughts and the $mono("EDA.ipynb")$ file with the EDA findings. For now, I will be sticking with the full 2024 Yellow Taxi Trip Records dataset from the TLC. Once I take a look into the schema and such I will decide whether I link the historical data to other datasets (e.g. weather records etc.). The URL to download the PARQUET files have the format 
$
  "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-{month}.parquet"
$
so they can be scrapped easily inside the actual Jupyter Notebook.
I just had the idea that maybe my project could emphasize on understanding how much the actual taxi trips differ from the optimal shortest trip given traffic and weather conditions. This could be an opportunity to introduce an Operations Research motif to my assignment.
Checking the size of the hole dataset is approximately half a GB, so DuckDB should handle the job just fine.
]


\
#let date = datetime(year: 2025, month: 12, day: 29)

#fmt-date(date)
#align(left)[
Refining my idea on OR having taken a look into the actual dataset schema, it was foolish of me to think that the actual ride path was included in the data (_yikes_). However, I am thinking of perhaps, given that we have the origin and destination zones for each trip, we could observe the temporal evolution of the net flow of each zone ($text("Net_Flow") = text("Dropoffs") - text("Pickups")$), and then cluster on $(text("Net_Flow"), t)$. We could refine the temporal features later, that is, extract day, day of week, month, is it morning, etc. so that we could actually get insightful conclusions on the dynamics of NYC traffic. Moreover, if we happen to have records of trips without passengers of the data, we could well identify zones which at a given moment of the day taxis are performing empty rides and hence losing potential clients.
Anyway, I shall first take a look into the data and see what if there is need to preprocess data in a certain way. I really dislike this part of Data Science, preprocessing is just boring.
]

\ 
#let date = datetime(year: 2025, month: 12, day: 31)

#fmt-date(date)
#align(left)[
Last day of the year and yet, here I am.
]

\
 
#let date = datetime(year: 2025, month: 01, day: 03)

#fmt-date(date)
#align(left)[
I've been researching for papers on parametric distribution approximations for taxi trip duration and turns out that they follow 
a lognormal really tightly!
]

\

#let date = datetime(year: 2026, month: 01, day: 04)

#fmt-date(date)
#align(left)[
Fast week forward, given time constraints defined by all New Year's celebrations and other project deadlines, I have no choice but to reconsider my project's scope and make it feasible to deliver tomorrow. I've been doing EDA and preprocessing stuff during the whole week, but the main gross of the project is yet to be implemented. 

I have reconsidered, and I am going to implement a XGBoost regressor using certain dataset features to try to predict the number of pick-ups and drop-offs a given certain time. I will use 2024 data for training and 2025 data for testing. I can see however that TLC Admins are still on vacation, as they have yet to upload the December data. 


Funny thing I tried to use `HistGradientBoostingRegressor` from `sklearn`, but it has a hard limit on the number of possible categories for a categorical column, which `Zone` surpasses.

I am thinking of first using only the zone and timestamp data as regression features, train and score the model, and later see if adding more information actually improve the regression accuracy. I could add weather and public event data, for instance.



Turns out, they don't! The regression using temporal features seems to already do a pretty good job, and the extra features seem to make little to no effect. It makes sense: we are dealing with regression accuracy; adding features which encapsulate traffic disruption helps the model to know when there's probably an increase or decrease in pick-ups or drop-offs, but none of the features help with defining a more accurate estimate.
]

\

#let date = datetime(year: 2026, month: 01, day: 05)

#fmt-date(date)
#align(left)[
Today I'm simply writing the report, good thing that I'm using Typst :)
It's simply going to be a summary of the findings of the EDA, it should not take long. It's 19:44 and I'm still here.
]