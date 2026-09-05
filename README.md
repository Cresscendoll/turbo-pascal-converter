# Turbo Pascal Historical Currency Converter

A small retro-style, offline historical currency converter written entirely
in Pascal. It runs as a native Windows 11 console TUI and keeps the source
close to classic Turbo Pascal style.

## What it does

- Uses Free Pascal Compiler with `{$mode TP}`.
- Runs directly on Windows 11; DOSBox, Lazarus, Delphi, and a separate runtime
  are not required.
- Includes 32 currencies, including UAH, RUB, and BYN.
- Converts through a common USD pivot and accepts decimal points or commas.
- Shows only the years for which both selected currencies have embedded data.
- Uses the first official January observation for the selected year. If
  1 January has no published quote, the first available official January quote
  is used. It does not calculate an annual average or a YTD average.
- Keeps historical units visible around redenominations and currency changes.
- Provides English/Russian labels, keyboard controls, and native Windows
  console mouse input.

The TUI is designed for a console viewport of at least **72 x 24**
characters. A smaller window shows a localized resize message and keeps the
keyboard path available. If native mouse input is unavailable, the same
controls remain usable from the keyboard.

The application code is in `currency_converter.pas`. The native console TUI
adapter is in `tui.pas`; embedded rates are in `historical_rates.pas`;
localized resources are in `localization.pas`. All runtime data is compiled
into Pascal source.

## Historical data

The development snapshot is labeled **2026-09-05**. The generated database
contains **1,070** start-of-year records. The snapshot date identifies the
development cutoff; the selected 2026 rate is still the first January
observation, not a September YTD average.

Every stored value means **currency units per 1 USD**. A conversion is:

```text
amount / source_units_per_usd * destination_units_per_usd
```

Availability is intentionally currency-specific. For example, UAH starts in
1996 in this January-rate dataset because the embedded NBU daily series has no
January record for 1992-1995; EUR starts in 1999; RUB starts in 1993; BGN has
no 2026 record after Bulgaria's euro changeover. Historical denomination and
source details are documented in [SOURCES.md](SOURCES.md).

## Compile and run

With `fpc` available on `PATH`, compile from the repository directory:

```text
fpc -B -O2 -vw -Fu. -FEbuild -FUbuild -obuild\currency_converter.exe currency_converter.pas
build\currency_converter.exe
```

For the FPC 3.2.2 Windows installation used for local validation, the native
Win64 command is:

```text
C:\FPC\3.2.2\bin\i386-win32\ppcrossx64.exe -B -O2 -vw -Fu. -FE..\build-x64 -FU..\build-x64 -o..\build-x64\currency_converter.exe currency_converter.pas
```

## Offline by design

The finished application contains no HTTP or HTTPS requests, sockets, API
calls, downloads, telemetry, or external rate files. All rates are hard-coded
in Pascal source. Internet access was used only during development to obtain
the documented snapshot. The Windows console API calls only manage the local
console buffer, cursor, code pages, keyboard records, resize records, and
mouse records; they do not contact the network.

This is a small educational retro-programming experiment, not a live financial
data service.
