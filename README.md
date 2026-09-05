# Turbo Pascal Currency Converter

A small retro-style offline currency converter written in Pascal. It is a
deliberately simple console program with numbered menus, ASCII borders, and a
classic Turbo Pascal feel.

## What it does

- Written as one Pascal source file: `currency_converter.pas`.
- Compiled with Free Pascal Compiler (FPC) using `{$mode TP}`.
- Builds a native Windows executable that runs directly on Windows 11.
- Does not require DOSBox, Lazarus, Delphi, or another runtime.
- Supports 30 currencies, including UAH, USD, EUR, GBP, CHF, JPY, CNY, CAD,
  AUD, NZD, PLN, CZK, HUF, RON, BGN, SEK, NOK, DKK, TRY, ILS, AED, SAR,
  INR, KRW, SGD, HKD, MXN, BRL, ZAR, and THB.
- Accepts decimal points or commas and permits repeated conversions in one
  session.

## Frozen rates

The embedded rates are a static snapshot dated **05.09.2026**. They are not
live data and the program never updates them automatically. Conversion uses
one consistent model: each rate is UAH per one unit of currency, so a result
is calculated as:

```text
amount * source_rate_in_UAH / destination_rate_in_UAH
```

The primary data source is the [National Bank of Ukraine official exchange-rate
API](https://bank.gov.ua/en/open-data/api-dev), queried for 05.09.2026. BRL is
derived from the [ECB reference-rate data API](https://data-api.ecb.europa.eu/service/data/EXR/D.BRL.EUR.SP00.A?startPeriod=2026-09-04&endPeriod=2026-09-04&format=csvdata)
for 04.09.2026, the latest available ECB business-day observation before the
snapshot date. BGN is retained as a legacy conversion using the ECB's fixed
[1.95583 BGN per EUR changeover rate](https://www.ecb.europa.eu/press/pr/date/2025/html/ecb.pr250708~b9676a9fa8.en.html),
because Bulgaria adopted the euro on 01.01.2026.

## Compile and run

Install the [Free Pascal Compiler](https://www.freepascal.org/download.html),
then from this directory run the normal compiler command:

```text
fpc -O2 -vw currency_converter.pas
currency_converter.exe
```

For the FPC 3.2.2 Windows package used for local validation, the native 64-bit
cross-compiler is available directly as `ppcrossx64.exe`:

```text
C:\FPC\3.2.2\bin\i386-win32\ppcrossx64.exe -O2 -vw currency_converter.pas
currency_converter.exe
```

The direct `fpc` command produces a normal 32-bit Windows executable; the
`ppcrossx64` command produces the validated native 64-bit build.

## Offline by design

The finished program contains no HTTP or HTTPS requests, sockets, API calls,
downloads, telemetry, or external rate files. All rates are hard-coded in the
Pascal source. Internet access was used only during development to obtain the
documented frozen snapshot.

This is a small educational retro-programming experiment, not a live financial
data service.
