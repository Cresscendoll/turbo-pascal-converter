# Turbo Pascal Historical Currency Converter

A small retro-style, offline historical currency converter written in Pascal.
It keeps the numbered menus, ASCII borders, and straightforward calculations
of a classic console utility, while running as a native Windows 11 executable.
The interface supports English and Russian in one executable.

## What it does

- Uses Free Pascal Compiler with `{$mode TP}`.
- Runs directly on Windows 11; DOSBox, Lazarus, Delphi, and another runtime
  are not required.
- Includes 30 currencies, with UAH prominently included.
- Converts through a common USD pivot and accepts decimal points or commas.
- Lets the user choose a pair, then shows only the historical years available
  for both currencies.
- Labels transition years, redenominated units, partial-year averages, and the
  2026 year-to-date record.
- Starts with an English/Russian selector using LEFT/RIGHT and ENTER, and can
  change language from the main menu.
- Keeps Pascal source files in UTF-8 and sets the native Windows console to
  UTF-8 at startup so Cyrillic text renders correctly.

The application code is in `currency_converter.pas`. The embedded historical
data is in the Pascal unit `historical_rates.pas`, and the localized resources
are in `localization.pas`. Both are static Pascal source; neither is a runtime
data file.

## Historical data

The snapshot label is **2026-09-05**. Values for 1992-2025 are annual
reference averages where the source provides them. 2026 values are year-to-date
averages through **2026-09-05**, not a completed annual average. BGN has no
2026 record because Bulgaria adopted the euro on 2026-01-01.

Each embedded value means **currency units per 1 USD**. A conversion is:

```text
amount / source_units_per_usd * destination_units_per_usd
```

UAH 1992-1995 is kept in nominal coupon-karbovanets, UAH 1996 is the
post-reform hryvnia period, and the documented old/new unit changes are applied
to PLN, RON, BGN, TRY, MXN, and BRL. See [SOURCES.md](SOURCES.md) for the
method, availability table, and official references.

## Compile and run

With `fpc` available on `PATH`, compile from the repository directory:

```text
fpc -B -O2 -vw -Fu. -FEbuild -FUbuild -obuild\currency_converter.exe currency_converter.pas
build\currency_converter.exe
```

For the FPC 3.2.2 Windows installation used for local validation, the native
Win64 command was:

```text
C:\FPC\3.2.2\bin\i386-win32\ppcrossx64.exe -B -O2 -vw -Fu. -FE..\build-x64 -FU..\build-x64 -o..\build-x64\currency_converter.exe currency_converter.pas
```

## Offline by design

The finished application contains no HTTP or HTTPS requests, sockets, API
calls, downloads, telemetry, or external rate files. All rates are hard-coded
in Pascal source. Internet access was used only during development to obtain
the documented snapshot. The Windows console API calls are limited to setting
the input/output code page to UTF-8; they do not contact the network.

This is a small educational retro-programming experiment, not a live financial
data service.
