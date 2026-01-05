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
  _Report_ 
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

The following report exposes the outcomes of the Exploratory Data Analysis (EDA) performed over the Yellow Trip Record Data from the New York City Taxi and Limousine Commission
@tlc. We subsequently raise a hypothesis about the this dataset which involves the training of XGBoost regressors over the 2024 historic data and evaluated on the 2025.

= Dataset Description
The main set of data used in the development of this report is the Yellow Trip Record Data from the NYC TLC @tlc. The data is open for download on the organization's website under diferrent filetypes. We chose PARQUET files we easily ingested into our EDA using DuckDB @duckdb.


The dataset is based on 19 columns which describe the whole historic of Yellow Taxi trips on NYC for a given year: each trip is characterized by a starting point (pick-up) and ending point (drop-off) in some predefined NYC Taxi zone, for which the corresponding timestamps are reported.  The trip can contain other data like he number of passangers, the time-and-distance fare computed by the meter and other tolls that may apply depending on the characteristics of the trip. Data is anonymized, meaning that no information on the actual driver license, nor the exact geolocation information of the trip are reported. The following table outlines the schema of the dataset:

#figure(
  table(
  columns: (auto, 1fr),
  inset: 9pt,
  align: (x, y) => if x == 0 { left } else { left },
  table.header(
    [*Field Name*], [*Description*]
  ),
  [`VendorID`], [Code indicating the TPEP provider (1=Creative Mobile, 2=Curb, etc.).],
  [`tpep_pickup_datetime`], [Date and time the meter was engaged.],
  [`tpep_dropoff_datetime`], [Date and time the meter was disengaged.],
  [`passenger_count`], [Number of passengers in the vehicle (driver-entered).],
  [`trip_distance`], [Elapsed trip distance in miles reported by the taximeter.],
  [`PULocationID`], [TLC Taxi Zone ID where the meter was engaged.],
  [`DOLocationID`], [TLC Taxi Zone ID where the meter was disengaged.],
  [`RatecodeID`], [Final rate code (1=Standard, 2=JFK, 3=Newark, etc.).],
  [`store_and_fwd_flag`], [Flag ('Y'/'N') indicating if record was held in vehicle memory before sending.],
  [`payment_type`], [Code signifying payment method (1=Credit, 2=Cash, etc.).],
  [`fare_amount`], [Time-and-distance fare calculated by the meter.],
  [`extra`], [Miscellaneous extras and surcharges.],
  [`mta_tax`], [automatically triggered tax based on the metered rate.],
  [`tip_amount`], [Tip amount (automatically populated for credit card tips).],
  [`tolls_amount`], [Total amount of all tolls paid in the trip.],
  [`improvement_surcharge`], [Surcharge levied at the flag drop for improvements.],
  [`congestion_surcharge`], [Total amount collected for NYS congestion surcharge.],
  [`Airport_fee`], [Fee for pickups at LaGuardia and JFK Airports.],
  [`total_amount`], [Total charged to passenger (excluding cash tips).],
),
  caption: [Summary Statistics for 2024 Yellow Taxi Trip Records],
)

\
The `PULocationID` and `DOLocationID` correspond to the pick-up and drop-off locations, respectively, under the NYC Taxi Zone identification. A look-up table can be found under the same website.

We note that during the development of this EDA, the data for the December 2025 was not available to the public. Nonetheless, the downloaded dataset have $41.169.720$ rows (2024) and $44.417.596$ rows (2025).

= Exploratory Data Analysis (EDA)
The EDA is performed using the totality of the 2024 historic data. As briefly mentioned, we used DuckDB to ingest each of the 12 PARQUET files and allowing for an in-process SQL database, making dataset filtering and aggregation really easy and fast.

== Descriptive Analysis and Missing Data

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto),
    inset: 5pt,
    align: (col, row) => if col == 0 { left } else { right },
    table.header(
      [*Variable*], [*Mean*], [*Std*], [*Min*], [*Median*], [*Max*]
    ),
    [`VendorID`], [1.76], [0.43], [1.00], [2.00], [7.00],
    [`passenger_count`], [1.33], [0.82], [0.00], [1.00], [9.00],
    [`trip_distance`], [4.98], [419.23], [0.00], [1.76], [3.99e+05],
    [`RatecodeID`], [2.32], [10.93], [1.00], [1.00], [99.00],
    [`PULocationID`], [164.24], [64.34], [1.00], [161.00], [265.00],
    [`DOLocationID`], [163.45], [69.60], [1.00], [162.00], [265.00],
    [`payment_type`], [1.11], [0.65], [0.00], [1.00], [5.00],
    [`fare_amount`], [19.27], [76.72], [-2.26e+03], [13.50], [3.36e+05],
    [`extra`], [1.39], [1.82], [-9.25], [1.00], [65.99],
    [`mta_tax`], [0.48], [0.13], [-0.50], [0.50], [41.30],
    [`tip_amount`], [3.31], [4.09], [-300.00], [2.60], [999.99],
    [`tolls_amount`], [0.56], [2.24], [-140.63], [0.00], [1.70e+03],
    [`improvement_surcharge`], [0.96], [0.26], [-1.00], [1.00], [2.00],
    [`total_amount`], [27.83], [78.05], [-2.27e+03], [21.00], [3.36e+05],
    [`congestion_surcharge`], [2.23], [0.87], [-2.50], [2.50], [2.52],
    [`Airport_fee`], [0.15], [0.50], [-1.75], [0.00], [1.75],
  ),
  caption: [Summary Statistics for 2024 Yellow Taxi Trip Records],
)
\
The summary statistics of all columns does not reveal any pathological behaviour for all variables, with some outlier values in some cases which we deem to be possible (for example, the maximum value of the `total_amount` column). Negative values on what we consider should be positive variables are discussed next.

=== Missing Data 
Approximately 10% of the dataset (around 4.09 million rows) contains missing values across specific columns: `passenger_count`, `RatecodeID`, `store_and_fwd_flag`, `congestion_surcharge`, and `Airport_fee`. The reason is not random but appears linked to specific recording devices, particularly `VendorID = 2` and `VendorID = 1`. However, our analysis concluded that the missing values are due to a "lack of information" rather than specific event types (like system errors).
In case of wanting to use this data, we propose not to drop these cases and use the following data imputation strategies to preserve data integrity without introducing bias:
  - *`passenger_count`*: Imputed by sampling from the empirical marginal distribution to maintain the original variance.
  - *`RatecodeID`*: Imputed with `99` (the standard code for "Null/Unknown").
  - *`store_and_fwd_flag`*: Imputed with the most frequent value.
  - *`congestion_surcharge`*: Imputed with the most frequent value.
  - *`Airport_fee`*: Imputed based applying the mean fee if the `PULocationID` corresponds to JFK or LaGuardia airports.

Moreover, a small fraction of records (1-2%) contained negative values in payment-related fields (`fare_amount`, `total_amount`, etc.). These are considered anomalies and are corrected by replacing them with the mean of non-negative cases.

== Trip Analysis
We now shift our focus the more physical information of the trips: starting and endpoint and time elapsed. We will identify journeys following the relation $("PUId", "DOId") equiv ("DOId", "PUId")$, so that we can understand which Taxi Zones participate the most accross all combinations of journeys on both directions.

=== Most visited zones
The analysis reveals a highly unequal distribution of taxi traffic across New York City's 265 zones. A Lorenz Curve visualization demonstrates that a small fraction of zones accounts for the vast majority of trip events (pickups and drop-offs).
\
#figure(
  image("img/lorenz_zones.png", width: 75%),
  caption: [
   Lorenz Curve visualization of participating Taxi Zones
  ],
  supplement: [Plot],
)<fig:mmx1k>
\

The top 6 zones alone account for approximately 20% of all 41.17 million trips recorded in 2024. This confirms that the most of NYC taxi traffic is highly concentrated in specific Manhattan neighborhoods and their interaction with other highly visited zones like airports:

\

#align(center, 
table(
  columns: (auto, auto),
  inset: 8pt,
  align: horizon,
  table.header([*Rank*], [*Zone Name*]),
  [1], [Upper East Side South],
  [2], [Upper East Side North],
  [3], [Midtown Center],
  [4], [Times Sq/Theatre District],
  [5], [Midtown East],
  [6], [JFK Airport]
))

=== Taxi Zone Dynamics
The nature of a zone (whether it is predominantly a "Pickup" or "Drop-off" location) shifts dynamically throughout the day. For example, Upper West Side North shows clear cyclic patterns where it transitions from a pick-up source to a drop-off destination. This is most likely due to the fact that these few zones exchange such a high volume of passengers among themselves that their demand metrics are likely strongly correlated. This is easily visualized via the $"Net Flow" = "Drop Offs" - "Pick Ups"$:
\
#figure(
  image("img/net_upper.png", width: 75%),
  caption: [
   Hourly Net Flow evolution of Upper West Side North
  ],
  supplement: [Plot],
)<fig:mmx1k>
\

\
#figure(
  image("img/net_midtown.png", width: 75%),
  caption: [
   Hourly Net Flow evolution of Midtown Center
  ],
  supplement: [Plot],
)<fig:mmx1k>
\



== Most common journeys
A similar analysis can be performed over the set of pairs $("PUId", "DOId")$ to analyze which are the most frequent routes for 2024 (on both directions):

\
#figure(
  table(
    columns: (auto, 2fr, 2fr, auto),
    inset: 8pt,
    align: (col, row) => if col == 0 { center } else if col == 3 { right } else { left },
    table.header([*Rank*], [*Origin Zone*], [*Destination Zone*], [*Trip Count*]),
    [1], [Upper East Side North], [Upper East Side South], [521,319],
    [2], [Upper East Side South], [Upper East Side South], [393,894],
    [3], [Upper East Side North], [Upper East Side North], [382,760],
    [4], [Midtown Center], [Upper East Side South], [249,015],
    [5], [Lincoln Square East], [Upper West Side South], [210,908],
    [6], [JFK Airport], [JFK Airport], [205,682],
    [7], [Midtown Center], [Upper East Side North], [201,101],
    [8], [Midtown East], [Upper East Side South], [192,683],
    [9], [Upper West Side North], [Upper West Side North], [185,553],
    [10], [Lenox Hill West], [Upper East Side North], [175,965]
  ),
  caption: [Top 10 Most Visited Yellow Taxi Routes (2024)],
)
\

The data shows that the Upper East Side (UES) related zones are the center of Yellow Taxi movement in 2024. The top three most frequent routes in the entire city all involve UES zones. Indeed, the single most popular route is $("Upper East Side North", "Upper East Side South")$, with over 521.000 trips. Moreover, there is massive internal circulation within the UES: trips starting and ending in UES South (Rank 2) or UES North (Rank 3) combined account for nearly 780.000 trips.
\

Another significant finding is the route $("JFK Airport",  "JFK Airport")$ being the 6th most common route in the entire dataset, with 205.682 trips. This likely represents short intra-terminal transfers or shuttles.


===  Trip Duration Distribution
The analysis of trip durations (time elapsed between pickup and drop-off) reveals a distinct statistical pattern across the majority of NYC taxi zones: the distribution is unimodal and right-skewed. Most trips are relatively short, with a long "tail" of fewer, longer-duration trips.
\
Following the article by Zhang et al., 2016 @zhang_investigation_2016, we fit a log-normal distribution to each of the zone data, and in the majority of cases we find a good fit. This is most likely due to the fact that travel times are multiplicative products of various factors like distance, congestion or weather, rather than additive, naturally resulting in a log-normal shape.

#figure(
  image("img/lognormal_uess.png", width: 70%),
  caption: [
   Trip Duration Distribution with Log-Normal fit (Upper East Side South)
  ],
  supplement: [Plot],
)<fig:mmx1k>
\
While most neighborhood zones follow the standard log-normal curve, the airport zones (JFK and LaGuardia) follow a unique bimodal distribution.
\
#figure(
  image("img/jfk.png", width: 70%),
  caption: [
   Trip Duration Distribution (JFK Airport)
  ],
  supplement: [Plot],
)<fig:mmx1k>
\

Indeed, a first peak can be observed near 0, which corresponds to the previously discussed intra-terminal transfers and short duration trips to move around the airport. Then, the actual travel distance between the airport zone and other neighbourhoods around NYC can be found as another curve, caracterized by its significantly higher mean value.

= Hypothesis

After extracting insightful information about the dataset, we formulate the following hypothesis:

\
#align(center)[
  _"Can we predict the hourly pick-ups and drop-offs of each TLC Taxi Zone with XGBoost and using a limited amount of features?"_
]
\

To verify (or discard) our hypothesis we will train a XGBoost regressor on the 2024 dataset we performed the EDA on, and use the 2025 dataset as test set. Moreover we will proceed in two steps:
1. First, we train the XGBoost model using only the taxi zone and time as features.
2. Next, we introduce more features to the model: public events, holidays and weather.

== Baseline model
The dataset with features is easily constructed using the SQL interface of DuckDB: we create a grid of all possible $("Month", "Day", "Hour", "Weekday")$ for the given year, and cross apply it to the 265 TLC Taxi Zones (ignoring the "N/A" zone). Then, we use the training data to aggregate over these fields to count how many pick-ups or drop-offs have occurred under such circumstances. This generates a initial raw dataset which we will transform to generate the training features.
\

This being the baseline model, the set of features as previously mentioned cosists only of the taxi zone and the timestamp of pick-up/drop-off (day, month, hour, etc.). Nonetheless, to boost the prediction accuracy, it is useful to introduce $sin$ and $cos$ transformation over these temporal columns to generate features which encapsulate the periodicity of the calendar: to this end, we introduce the function `compute_cyclical_features`.
\

The feature engineering and training process is performed sequentially using a `Pipeline` object from the `sklearn` library, containing three steps:

    1. *`cyclical_features`*: Calls `compute_cyclical_features` function to create the `sin` and `cos` transformation over the timestamp data. 
    2. *`encoder`*: Encodes the only categorical column `Zone` using the `OrdinalEncoder`.
    3. *`model`*: Trains an XGBoost regressor model using the resulting dataset with parameters: `objective="count:poisson", eval_metric="poisson-nloglik" n_estimators=1000, learning_rate=0.1, max_depth=6, tree_method="hist"`
\

We evalute the resulting model using the MAE and $R^2$ coefficient and obtain:

#figure(
  table(
    columns: (auto, auto, auto),
    inset: 8pt,
    align: (col, row) => if col == 0 { left } else { right },
    table.header(
      [*Metric*], [*Pick-Ups*], [*Drop-Offs*]
    ),
    [Mean Absolute Error (MAE)], [6.87], [6.67],
    [$R^2$ Score], [0.83], [0.83],
  ),
  caption: [Baseline Model Performance Metrics],
)

\

== Extra features model
To introduce the extra features discussed previously, we use the following fonts:

1. *Weather*: The historic of 2024 and 2025 weather data from NYC is extracted from the Open-Meteo.com @Zippenfenig_Open-Meteo, containing data regarding temperature, precipitation, wind, etc.

2. *Holidays*: To include the holidays as features we use the `holidays` library in Python @murza_vacanzaholidays_2025, which can easily provide us with the holidays for the state of New York.

3. *Public Events*: Finally, an interesting experiment following the suggestion made in the assignment statement, would be to consider relevant events in NYC during the year which could in turn disrupt the usual taxi dynamics. To do this, we have asked Google Gemini to research on the web for significant events and generate a JSON file with their approximate timestamps and affected taxi zones.

The data ingestion is performed as usual: we use the rich set of connectors that DuckDB provides and use the SQL interface to manipulate the fonts as tabular data. The `Pipeline` is maintained except for a few changes:
1. We introduce the wind direction features to the cyclical feature computations as they are encoded as degrees by default.
2. Public event and holidays are encoded as binary features.
3. For the sake of completion, we also scale the numerical features introduced by the Weather dataset.

Training under the same parameters yields the following results:
#figure(
  table(
    columns: (auto, auto, auto),
    inset: 8pt,
    align: (col, row) => if col == 0 { left } else { right },
    table.header(
      [*Metric*], [*Pick-Ups*], [*Drop-Offs*]
    ),
    [Mean Absolute Error (MAE)], [7.00], [6.82],
    [$R^2$ Score], [0.83], [0.83],
  ),
  caption: [Extra Features Model Performance Metrics],
)
= Conclusion
After training the two XGBoost regressor models on the different datasets we conclude the following:
- The XGBoost regressor with taxi zone and temporal features seems to do already a good job at for a given zone and time.
- Adding extra features to the model, like the weather, holidays or some public events does not improve the accuracy of prediction.
- The model seems to learn learn the dynamics of city traffic, in the sense that it has learnt to predict whether there is going to be any traffic activity (pick-ups or drop-offs), but is not accurate in the actual magnitude, which is expected since randomness plays a huge factor in the actual realized value. Indeed, adding extra features like public events can help, but the chaos of NYC is unpredictable.
#pagebreak()

#bibliography("sources.bib")
