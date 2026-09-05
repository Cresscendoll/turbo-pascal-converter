# Historical rate sources and method

This file documents the development-time research used to generate the static
Pascal unit `historical_rates.pas`. The executable does not read these URLs or
make any network request. The data cutoff is **2026-09-05**.

## Rate convention

Every stored value is `currency units per 1 USD`, named `UnitsPerUSD` in the
Pascal source. A conversion is therefore:

```text
destination_amount = source_amount / source_UnitsPerUSD
                     * destination_UnitsPerUSD
```

This keeps the direction explicit for currencies with very different scales.
The generated unit contains 1,039 records. `RateKind` identifies a full-year
annual average, a partial transition-year average, or the 2026 year-to-date
average.

## Primary data sources

- [IMF Exchange Rates dataset](https://data.imf.org/Datasets/ER) and the
  [IMF API documentation](https://data.imf.org/en/Resource-Pages/IMF-API).
  The development query used the IMF SDMX series
  `XDC_USD.PA_RT.A` (period-average national currency units per USD) for
  annual 1992-2025 values, plus monthly `XDC_USD.PA_RT.M` values for the
  explicitly documented transition segments.
- [National Bank of Ukraine open-data API documentation](https://bank.gov.ua/en/open-data/api-dev)
  and the [NBU daily exchange-rate range endpoint](https://bank.gov.ua/NBU_Exchange/exchange_site?start=20260101&end=20260905&sort=exchangedate&order=asc&json).
  The endpoint supplied the 2026 daily UAH reference series through
  2026-09-05. The arithmetic average uses the 248 dated observations returned
  by the endpoint, including its published carry-forward values.
- [NBU 2002 annual report](https://bank.gov.ua/admin_uploads/article/A_report_2002e.pdf?v=6),
  table of period-average exchange rates, for the nominal Ukrainian
  coupon-karbovanets values used for 1992-1995: 208, 4,539, 31,700, and
  147,307 units per USD respectively.
- [ECB Data API](https://data-api.ecb.europa.eu/service/data/EXR/) for EUR and
  BRL observations. For EUR, daily `D.USD.EUR.SP00.A` observations from
  1999-01-01 through 2025-12-31 were reciprocated and averaged by year. For
  BRL 2026, daily `D.USD+BRL.EUR.SP00.A` observations through 2026-09-05 were
  divided pairwise to obtain BRL per USD and then averaged.

## Currency coverage

The menu has 30 currencies. Availability is intentionally currency-specific;
the converter displays the intersection for the selected pair.

| # | Code | Embedded years | Historical-unit note |
|---:|:---:|:---:|---|
| 1 | UAH | 1992-2026 | Coupon-karbovanets in 1992-1995; hryvnia partial period in 1996 |
| 2 | USD | 1992-2026 | US dollar pivot |
| 3 | EUR | 1999-2026 | Euro reference unit from 1999 |
| 4 | GBP | 1992-2026 | Pound sterling |
| 5 | CHF | 1992-2026 | Swiss franc |
| 6 | JPY | 1992-2026 | Japanese yen |
| 7 | CNY | 1992-2026 | Chinese yuan |
| 8 | CAD | 1992-2026 | Canadian dollar |
| 9 | AUD | 1992-2026 | Australian dollar |
| 10 | NZD | 1992-2026 | New Zealand dollar |
| 11 | PLN | 1992-2026 | Old PLZ in 1992-1994; PLN from 1995 |
| 12 | CZK | 1993-2026 | Czech koruna series begins in 1993 |
| 13 | HUF | 1992-2026 | Hungarian forint |
| 14 | RON | 1992-2026 | Old ROL in 1992-2004; new RON partial in 2005 |
| 15 | BGN | 1992-2025 | Old BGL in 1992-1998; new BGN partial in 1999; no 2026 record |
| 16 | SEK | 1992-2026 | Swedish krona |
| 17 | NOK | 1992-2026 | Norwegian krone |
| 18 | DKK | 1992-2026 | Danish krone |
| 19 | TRY | 1992-2026 | Old TRL in 1992-2004; new TRY from 2005 |
| 20 | ILS | 1992-2026 | Israeli shekel |
| 21 | AED | 1992-2026 | UAE dirham |
| 22 | SAR | 1992-2026 | Saudi riyal |
| 23 | INR | 1992-2026 | Indian rupee |
| 24 | KRW | 1992-2026 | South Korean won |
| 25 | SGD | 1992-2026 | Singapore dollar |
| 26 | HKD | 1992-2026 | Hong Kong dollar |
| 27 | MXN | 1992-2026 | Old peso in 1992; new MXN from 1993 |
| 28 | BRL | 1994-2026 | Real partial period from 1994-07-01 |
| 29 | ZAR | 1992-2026 | South African rand |
| 30 | THB | 1992-2026 | Thai baht |

## Historical handling

The IMF series normalizes some historical observations to a modern currency
unit. Where the user-facing historical unit changed, the generated values are
scaled back to the nominal unit for the old period:

- **Ukraine:** the NBU report supplies nominal coupon-karbovanets averages for
  1992-1995. The 1996 value is the IMF monthly average for September-December,
  after the hryvnia reform. The NBU history page describes the coupon period
  and [the reform announcement](https://bank.gov.ua/en/archive-news/all/21195748-the-ukrainian-hryvnia-marks-its-19th-anniversary)
  records 100,000 karbovanets = 1 hryvnia from 1996-09-02.
- **Poland:** [National Bank of Poland FAQ](https://nbp.pl/pytania-i-odpowiedzi)
  documents 10,000 old zloty = 1 new zloty on 1995-01-01. IMF values for
  1992-1994 are multiplied by 10,000.
- **Mexico:** [Banco de Mexico](https://www.banxico.org.mx/footer-es/preguntas-frecuentes-dudas-ba.html)
  documents 1,000 old pesos = 1 new peso effective 1993-01-01. Only 1992 is
  scaled by 1,000.
- **Bulgaria:** [Bulgarian National Bank](https://www.bnb.bg/AboutUs/PressOffice/POPressReleases/POPRDate/RELEASE_19980806_BG)
  documents the 1999 lev redenomination. 1992-1998 are multiplied by 1,000;
  July-December 1999 uses the new lev monthly segment. Bulgaria adopted the
  euro on 2026-01-01; the [ECB changeover notice](https://www.ecb.europa.eu/press/pr/date/2026/html/ecb.pr260101~c830245e42.en.html)
  is why BGN 2026 is left unavailable rather than guessed.
- **Romania:** [Romanian legislation](https://legislatie.just.ro/Public/DetaliiDocumentAfis/53757)
  documents 10,000 old lei = 1 new leu on 2005-07-01. 1992-2004 are scaled
  by 10,000; July-December 2005 uses the new-leu monthly segment.
- **Turkey:** the [TCMB 2005 annual report](https://www.tcmb.gov.tr/wps/wcm/connect/d8da04d9-c299-4721-8580-8c696177803e/2005AR.pdf?CACHEID=ROOTWORKSPACE-d8da04d9-c299-4721-8580-8c696177803e-pz7cncI&MOD=AJPERES)
  records the new Turkish lira effective 2005-01-01. 1992-2004 are stored in
  old nominal lira by multiplying the modern-unit series by 1,000,000.
- **Brazil:** the [Central Bank of Brazil Real Plan note](https://www.bcb.gov.br/controleinflacao/planoreal?modalAberto=30anosreal_noticia5)
  dates the real to 1994-07-01. The converter starts BRL in 1994 and uses the
  July-December monthly segment, avoiding a false full-year real average.
- **Euro and Czech koruna:** the [ECB euro introduction page](https://www.ecb.europa.eu/euro/intro/html/index.en.html)
  dates the euro's launch to 1999-01-01, while the IMF series for CZK begins
  in 1993; the UI reports those natural availability boundaries.

## Caveats

- These are official reference/period-average series, not retail cash-desk,
  card, or intraday prices.
- Annual reference data can be revised by its publisher. This repository keeps
  the values frozen for the stated development snapshot.
- 2026 is preliminary YTD data through 2026-09-05. NBU and ECB observation
  calendars differ, and BGN 2026 is deliberately absent.
- Transition-year records are labeled partial in the application. They should
  not be interpreted as a single-unit full-year average when a redenomination
  happened during the year.
