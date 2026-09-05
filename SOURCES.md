# Historical rate sources and method

This file documents the development-time research used to generate the static
Pascal unit `historical_rates.pas`. The executable does not read these URLs or
make any network request. The development cutoff is **2026-09-05**.

## Rate convention

Every stored value is `currency units per 1 USD`, named `UnitsPerUSD` in the
Pascal source. A conversion is therefore:

```text
destination_amount = source_amount / source_UnitsPerUSD
                     * destination_UnitsPerUSD
```

The generated unit contains **1,070** records. All records use
`RateKindStartOfYear`.

## What a selected year means

This version does not use annual averages and does not use a 2026 YTD average.
For each currency and year, the generator selects the first valid official
observation dated in January. When 1 January is a holiday or a source has no
quote on that date, this is the first official January observation after
1 January. If the source has no valid January observation, that currency-year
is omitted and the UI reports the resulting pair-specific gap.

The 2026 snapshot label remains **2026-09-05** because that is the development
cutoff, but the 2026 value is still the January value. It is not an average of
the year through September.

## Primary data sources

- [Federal Reserve H.10 data download](https://www.federalreserve.gov/datadownload/choose.aspx?rel=h10)
  supplied daily dollar exchange-rate series for EUR, GBP, AUD, NZD, BRL, CAD,
  CNY, DKK, HKD, INR, JPY, KRW, MXN, NOK, SEK, SGD, CHF, THB, and ZAR. The
  H.10 series that quote USD per currency are inverted; series already quoted
  as currency per USD are used directly. Only the first valid January record
  for each year is embedded.
- [National Bank of Ukraine open-data API documentation](https://bank.gov.ua/en/open-data/api-dev)
  and its [daily exchange-rate range endpoint](https://bank.gov.ua/NBU_Exchange/exchange_site?start=20260101&end=20260905&sort=exchangedate&order=asc&json)
  supplied January observations from 1996 onward for UAH and the currencies
  whose daily series are not present in H.10: PLN, CZK, HUF, RON, BGN, TRY,
  and ILS. The USD quote on the same official date is used to form each
  currency's `UnitsPerUSD` value.
- [Bank of Russia XML data documentation](https://www.cbr.ru/development/SXML/)
  and the official [dynamic USD/RUB series](https://www.cbr.ru/scripts/XML_dynamic.asp?date_req1=01/01/1992&date_req2=05/09/2026&VAL_NM_RQ=R01235)
  supplied the first January official RUB value for 1993-2026. The first
  official RUB observation in the source is 01.07.1992, so RUB 1992 is left
  unavailable rather than treating a July value as a January value.
- [National Bank of the Republic of Belarus API documentation](https://www.nb-rb.by/apihelp/exrates.htm)
  and the [official-rate dynamics API](https://api.nbrb.by/exrates/rates/dynamics/145?startdate=2026-01-01&enddate=2026-09-05)
  supplied the direct BYN/USD quote for 1996-2021; the successor USD series
  (ID 431) supplied 2022-2026. The nominal historical unit is kept at each
  1 January boundary.
- The [Saudi Central Bank](https://www.sama.gov.sa/en-US/MediaCenter/News/Pages/news-557.aspx)
  documents the SAR peg at 3.75 per USD. The [Central Bank of the UAE](https://centralbank.ae/en/our-operations/monetary-policy-and-domestic-markets/domestic-market-operations/)
  documents the USD/AED peg; the embedded central parity is 3.6725 AED per
  USD. These fixed official parities are valid start-of-year values for the
  selected 1992-2026 range.

The sources above are institutional reference data, not retail cash-desk,
card, or intraday prices.

## Currency coverage

The menu contains 32 currencies. Availability is intentionally currency-
specific; the converter displays the intersection for the selected pair.

| # | Code | Embedded years | January-rate interpretation |
|---:|:---:|:---:|---|
| 1 | UAH | 1996-2026 | Coupon-karbovanets on 01.01.1996; hryvnia from 1997 |
| 2 | USD | 1992-2026 | USD pivot, exactly 1 |
| 3 | EUR | 1999-2026 | Euro reference unit |
| 4 | GBP | 1992-2026 | Pound sterling |
| 5 | CHF | 1992-2026 | Swiss franc |
| 6 | JPY | 1992-2026 | Japanese yen |
| 7 | CNY | 1992-2026 | Chinese yuan |
| 8 | CAD | 1992-2026 | Canadian dollar |
| 9 | AUD | 1992-2026 | Australian dollar |
| 10 | NZD | 1992-2026 | New Zealand dollar |
| 11 | PLN | 1996-2026 | New zloty; NBU used legacy `PLZ` code in early records |
| 12 | CZK | 1996-2026 | Czech koruna |
| 13 | HUF | 1996-2026 | Hungarian forint |
| 14 | RON | 1996-2026 | Old ROL through 2005; new RON from 2006 |
| 15 | BGN | 1996-2025 | Old BGL through 1999; new BGN from 2000; no 2026 |
| 16 | SEK | 1992-2026 | Swedish krona |
| 17 | NOK | 1992-2026 | Norwegian krone |
| 18 | DKK | 1992-2026 | Danish krone |
| 19 | TRY | 1996-2026 | Old TRL through 2004; new TRY from 2005 |
| 20 | ILS | 1996-2026 | Israeli shekel |
| 21 | AED | 1992-2026 | Fixed 3.6725 AED per USD parity |
| 22 | SAR | 1992-2026 | Fixed 3.75 SAR per USD parity |
| 23 | INR | 1992-2026 | Indian rupee |
| 24 | KRW | 1992-2026 | South Korean won |
| 25 | SGD | 1992-2026 | Singapore dollar |
| 26 | HKD | 1992-2026 | Hong Kong dollar |
| 27 | MXN | 1994-2026 | New peso; no valid January H.10 record in 1992-1993 |
| 28 | BRL | 1995-2026 | Brazilian real; 1994 has no January real record |
| 29 | ZAR | 1992-2026 | South African rand |
| 30 | THB | 1992-2026 | Thai baht |
| 31 | RUB | 1993-2026 | Old ruble through 1997; new ruble from 1998 |
| 32 | BYN | 1996-2026 | BYB through 1999; BYR through 2016; BYN from 2017 |

The missing early ranges are source-availability gaps under the January-only
rule, not zero rates. EUR begins with the euro's 1999 launch. BRL has no
January 1994 observation because the real was introduced on 01.07.1994. BGN
has no 2026 record because Bulgaria adopted the euro on 01.01.2026.

## Historical units and transitions

- **Ukraine:** the first available UAH record is 01.01.1996-era coupon-
  karbovanets data. The 1996 January rate is therefore not the later hryvnia
  rate; the converter does not mix the two nominal units. Hryvnia is used from
  1997 onward.
- **Poland:** records available here are new PLN. The old PLZ boundary
  (10,000 old zloty = 1 new zloty on 01.01.1995) is retained in the notes, but
  no 1992-1995 January record is embedded.
- **Romania:** 2005-01-01 is still old ROL in the January model; new RON is
  used from the 2006 record. The 10,000:1 change on 01.07.2005 is not averaged
  across a year.
- **Bulgaria:** 1999-01-01 is still old BGL; new BGN is used from 2000. The
  1,000:1 change on 05.07.1999 is not averaged across a year.
- **Turkey:** old TRL is used through 2004; the new TRY is used from 2005,
  reflecting the 1,000,000:1 redenomination effective 01.01.2005.
- **Mexico:** the new MXN period begins 01.01.1993, but the first January
  observation present in the selected H.10 source is in 1994, so 1993 is
  intentionally unavailable.
- **Russia:** CBR values are old nominal rubles through 1997 and new rubles
  from 1998 after the 1,000:1 redenomination. RUB 1992 is unavailable because
  the official daily series begins in July.
- **Belarus:** 1996-1999 uses old BYB, 2000-2016 uses BYR, and 2017 onward
  uses BYN. The 1,000:1 change on 01.01.2000 and 10,000:1 change on
  01.07.2016 are respected; the 2016 January rate is therefore still BYR.

## Caveats

- A January start-of-year quote is a point-in-time reference, not an annual
  average and not a retail exchange-office price.
- The exact observation date can differ by source because each institution
  publishes on its own calendar. The policy is deliberately limited to the
  first valid January observation.
- Some currencies have shorter coverage than the nominal 1992-2026 window.
  The UI calculates the common-year intersection after both currencies are
  selected.
- Institutional historical data can be revised by its publisher. This
  repository keeps a frozen development snapshot until it is regenerated.
