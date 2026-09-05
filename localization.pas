unit Localization;

{$mode TP}
{$codepage utf8}

interface

type
  TLanguage = (LanguageEnglish, LanguageRussian);

  TTextKey = (
    tkApplicationTitle, tkMainMenuTitle, tkCurrenciesTitle,
    tkYearTitle, tkResultTitle, tkNotesTitle, tkGoodbyeTitle,
    tkSnapshotLabel, tkStaticData, tkNoNetwork, tkCoverageLabel,
    tkYtdThrough, tkCurrencyIntro1, tkCurrencyIntro2, tkCurrencyNote1,
    tkCurrencyNote2, tkCancelHint, tkPressEnter, tkSelectPrompt, tkSourcePrompt,
    tkDestinationPrompt, tkInvalidCurrency, tkAmountPrompt,
    tkInvalidAmount, tkPairLabel, tkAvailableYearsLabel,
    tkYearInstruction, tkYearPrompt, tkUnavailableYear, tkNoCommonYears,
    tkReturnMainPrompt, tkResultWord, tkYearLabel, tkPivotSource,
    tkPivotDestination, tkSourceUnit, tkDestinationUnit, tkSourceData,
    tkDestinationData, tkRateType, tkStaticNotice, tkAnotherConversion,
    tkReturnMainMenu, tkInvalidRepeatChoice, tkMainConvert,
    tkMainCurrencies, tkMainNotes, tkMainLanguage, tkMainExit,
    tkInvalidMenu, tkNotesRateConvention, tkNotesCalculationModel,
    tkNotesUAH1, tkNotesUAH2, tkNotesNaturalBoundaries,
    tkNotesRedenomTitle, tkNotesRedenom1, tkNotesRedenom2,
    tkNotesRedenom3, tkNotesYtd1, tkNotesYtd2, tkNotesYtd3, tkNotesSources,
    tkThanks, tkClose, tkLanguageSelectorTitle, tkLanguageSelectorHelp,
    tkTuiSourceLabel, tkTuiDestinationLabel, tkTuiYearFieldLabel,
    tkTuiAmountLabel, tkTuiConvertButton, tkTuiBackButton,
    tkTuiLanguageButton, tkTuiClearButton, tkTuiQuitButton,
    tkTuiAvailableLabel, tkTuiMouseReady, tkTuiMouseUnavailable,
    tkTuiFooter, tkTuiMouseFooter, tkTuiPickerFooter,
    tkTuiCurrencyPickerTitle, tkTuiChooseSourceCurrency,
    tkTuiChooseDestinationCurrency, tkTuiYearPickerTitle,
    tkTuiAmountPlaceholder, tkTuiInvalidAmountShort, tkTuiNoResult,
    tkTuiConverted, tkTuiSmallConsole1, tkTuiSmallConsole2,
    tkTuiSmallConsole3, tkTuiResizeHint
  );

function LocalizedText(Key: TTextKey; Language: TLanguage): String;
function CurrencyCode(CurrencyIndex: Integer): String;
function CurrencyName(CurrencyIndex: Integer; Language: TLanguage): String;
function HistoricalUnit(CurrencyIndex: Integer; Year: Integer;
  Language: TLanguage): String;
function HistoricalAmountName(CurrencyIndex: Integer; Year: Integer;
  Language: TLanguage): String;
function RateKindText(RateKind: Integer; Language: TLanguage): String;
function LanguageLabel(Language: TLanguage): String;

implementation

function LocalizedText(Key: TTextKey; Language: TLanguage): String;
begin
  LocalizedText := '';
  if Language = LanguageEnglish then
    case Key of
      tkApplicationTitle: LocalizedText := 'Turbo Pascal Historical Converter';
      tkMainMenuTitle: LocalizedText := 'Main menu';
      tkCurrenciesTitle: LocalizedText := 'Supported currencies';
      tkYearTitle: LocalizedText := 'Select historical year';
      tkResultTitle: LocalizedText := 'Historical result';
      tkNotesTitle: LocalizedText := 'Historical notes';
      tkGoodbyeTitle: LocalizedText := 'Goodbye';
      tkSnapshotLabel: LocalizedText := 'Snapshot';
      tkStaticData: LocalizedText := 'static data';
      tkNoNetwork: LocalizedText := 'no network access';
      tkCoverageLabel: LocalizedText := 'Coverage';
      tkYtdThrough: LocalizedText := '2026 is YTD through';
      tkCurrencyIntro1: LocalizedText :=
        'Thirty currencies are embedded as historical USD-pivot series.';
      tkCurrencyIntro2: LocalizedText :=
        'Year availability is checked after both currencies are selected.';
      tkCurrencyNote1: LocalizedText :=
        'EUR begins in 1999; CZK begins in 1993; BRL begins in 1994.';
      tkCurrencyNote2: LocalizedText :=
        'BGN has no 2026 record after Bulgaria''s euro changeover.';
      tkCancelHint: LocalizedText :=
        'Enter 0 at a currency prompt to return to the main menu.';
      tkPressEnter: LocalizedText := 'Press ENTER to continue...';
      tkSelectPrompt: LocalizedText := 'Select: ';
      tkSourcePrompt: LocalizedText :=
        'Select source currency (0 = main menu): ';
      tkDestinationPrompt: LocalizedText :=
        'Select destination currency (0 = main menu): ';
      tkInvalidCurrency: LocalizedText :=
        'Invalid currency number. Enter 1 to 30, or 0 to cancel.';
      tkAmountPrompt: LocalizedText :=
        'Enter amount (positive, point or comma): ';
      tkInvalidAmount: LocalizedText :=
        'Invalid amount. Use a positive number up to 1E15.';
      tkPairLabel: LocalizedText := 'Pair';
      tkAvailableYearsLabel: LocalizedText := 'Available years';
      tkYearInstruction: LocalizedText :=
        'The year is an annual average, a transition average, or 2026 YTD.';
      tkYearPrompt: LocalizedText := 'Select year for conversion (0 = main menu): ';
      tkUnavailableYear: LocalizedText :=
        'This year is unavailable for this pair. Available ranges: ';
      tkNoCommonYears: LocalizedText :=
        'No common historical years are embedded for this pair.';
      tkReturnMainPrompt: LocalizedText :=
        'Press ENTER to return to the main menu...';
      tkResultWord: LocalizedText := 'RESULT';
      tkYearLabel: LocalizedText := 'Year';
      tkPivotSource: LocalizedText := 'Source pivot: 1 USD = ';
      tkPivotDestination: LocalizedText := 'Destination pivot: 1 USD = ';
      tkSourceUnit: LocalizedText := 'Source unit';
      tkDestinationUnit: LocalizedText := 'Destination unit';
      tkSourceData: LocalizedText := 'Source data';
      tkDestinationData: LocalizedText := 'Destination data';
      tkRateType: LocalizedText := 'Rate type';
      tkStaticNotice: LocalizedText :=
        'Rates are embedded and do not update automatically.';
      tkAnotherConversion: LocalizedText :=
        '1. Perform another conversion';
      tkReturnMainMenu: LocalizedText := '2. Return to main menu';
      tkInvalidRepeatChoice: LocalizedText :=
        'Invalid choice. Enter 1 or 2.';
      tkMainConvert: LocalizedText := '1. Convert historical currencies';
      tkMainCurrencies: LocalizedText := '2. View supported currencies';
      tkMainNotes: LocalizedText :=
        '3. Historical notes and methodology';
      tkMainLanguage: LocalizedText := '4. Change language';
      tkMainExit: LocalizedText := '0. Exit';
      tkInvalidMenu: LocalizedText :=
        'Invalid menu choice. Enter 0, 1, 2, 3, or 4.';
      tkNotesRateConvention: LocalizedText :=
        'Rate convention: embedded values are currency units per 1 USD.';
      tkNotesCalculationModel: LocalizedText :=
        'The calculation is source currency -> USD -> destination currency.';
      tkNotesUAH1: LocalizedText :=
        'UAH 1992-1995 uses official NBU period averages for the';
      tkNotesUAH2: LocalizedText :=
        'coupon-karbovanets. 1996 is the Sep-Dec hryvnia period.';
      tkNotesNaturalBoundaries: LocalizedText :=
        'EUR starts in 1999, CZK in 1993, and BRL in July 1994.';
      tkNotesRedenomTitle: LocalizedText := 'Redenomination notes:';
      tkNotesRedenom1: LocalizedText :=
        'PLZ 10,000:1 on 01.01.1995; MXP 1,000:1 on 01.01.1993.';
      tkNotesRedenom2: LocalizedText :=
        'BGL 1,000:1 on 05.07.1999; ROL 10,000:1 on 01.07.2005.';
      tkNotesRedenom3: LocalizedText :=
        'TRL lost six zeroes on 01.01.2005.';
      tkNotesYtd1: LocalizedText :=
        '2026 values are YTD averages through 05.09.2026, not a';
      tkNotesYtd2: LocalizedText :=
        'complete annual average. BGN 2026 is intentionally unavailable';
      tkNotesYtd3: LocalizedText :=
        'because Bulgaria adopted the euro on 01.01.2026.';
      tkNotesSources: LocalizedText :=
        'Sources and transformation details are documented in SOURCES.md.';
      tkThanks: LocalizedText :=
        'Thank you for using the historical converter.';
      tkClose: LocalizedText := 'Press ENTER to close the program...';
      tkLanguageSelectorTitle: LocalizedText :=
        'LANGUAGE SELECTOR / ВЫБОР ЯЗЫКА';
      tkLanguageSelectorHelp: LocalizedText :=
        'LEFT / RIGHT or 1 / 2, then ENTER';
      tkTuiSourceLabel: LocalizedText := 'SOURCE CURRENCY';
      tkTuiDestinationLabel: LocalizedText := 'DESTINATION CURRENCY';
      tkTuiYearFieldLabel: LocalizedText := 'YEAR';
      tkTuiAmountLabel: LocalizedText := 'AMOUNT';
      tkTuiConvertButton: LocalizedText := 'CONVERT';
      tkTuiBackButton: LocalizedText := 'BACK';
      tkTuiLanguageButton: LocalizedText := 'CHANGE LANGUAGE';
      tkTuiClearButton: LocalizedText := 'CLEAR';
      tkTuiQuitButton: LocalizedText := 'QUIT';
      tkTuiAvailableLabel: LocalizedText := 'Available';
      tkTuiMouseReady: LocalizedText := 'Mouse: ready.';
      tkTuiMouseUnavailable: LocalizedText :=
        'Mouse input unavailable - keyboard controls remain active.';
      tkTuiFooter: LocalizedText :=
        'Tab: next   Shift+Tab: previous   Enter: select   Esc: back';
      tkTuiMouseFooter: LocalizedText := 'Mouse: click controls';
      tkTuiPickerFooter: LocalizedText :=
        'Up/Down: move   Left/Right: column   Enter: choose   Esc: back';
      tkTuiCurrencyPickerTitle: LocalizedText := 'Choose currency';
      tkTuiChooseSourceCurrency: LocalizedText := 'Choose source currency';
      tkTuiChooseDestinationCurrency: LocalizedText :=
        'Choose destination currency';
      tkTuiYearPickerTitle: LocalizedText := 'Choose year';
      tkTuiAmountPlaceholder: LocalizedText := 'type amount';
      tkTuiInvalidAmountShort: LocalizedText :=
        'Enter a positive amount, then choose CONVERT.';
      tkTuiNoResult: LocalizedText :=
        'Choose fields, then activate CONVERT.';
      tkTuiConverted: LocalizedText := 'Conversion ready.';
      tkTuiSmallConsole1: LocalizedText :=
        'Console is too small for this TUI.';
      tkTuiSmallConsole2: LocalizedText :=
        'Resize it to at least 72 x 24 characters.';
      tkTuiSmallConsole3: LocalizedText :=
        'Keyboard remains available after resizing.';
      tkTuiResizeHint: LocalizedText :=
        'Resize the window, then press any key.';
    end
  else
    case Key of
      tkApplicationTitle: LocalizedText :=
        'Исторический конвертер Turbo Pascal';
      tkMainMenuTitle: LocalizedText := 'Главное меню';
      tkCurrenciesTitle: LocalizedText := 'Поддерживаемые валюты';
      tkYearTitle: LocalizedText := 'Выбор исторического года';
      tkResultTitle: LocalizedText := 'Исторический результат';
      tkNotesTitle: LocalizedText := 'Исторические заметки';
      tkGoodbyeTitle: LocalizedText := 'До свидания';
      tkSnapshotLabel: LocalizedText := 'Срез данных';
      tkStaticData: LocalizedText := 'статические данные';
      tkNoNetwork: LocalizedText := 'без доступа к сети';
      tkCoverageLabel: LocalizedText := 'Охват';
      tkYtdThrough: LocalizedText := '2026 - данные по';
      tkCurrencyIntro1: LocalizedText :=
        'Встроены данные для 30 валют; расчёт идёт через USD.';
      tkCurrencyIntro2: LocalizedText :=
        'Доступность лет проверяется после выбора обеих валют.';
      tkCurrencyNote1: LocalizedText :=
        'EUR доступен с 1999 года; CZK - с 1993; BRL - с 1994.';
      tkCurrencyNote2: LocalizedText :=
        'Для BGN нет записи за 2026 год после перехода Болгарии на евро.';
      tkCancelHint: LocalizedText :=
        'Для отмены введите 0 в запросе валюты.';
      tkPressEnter: LocalizedText := 'Нажмите ENTER, чтобы продолжить...';
      tkSelectPrompt: LocalizedText := 'Выбор: ';
      tkSourcePrompt: LocalizedText :=
        'Выберите исходную валюту (0 = в главное меню): ';
      tkDestinationPrompt: LocalizedText :=
        'Выберите валюту назначения (0 = в главное меню): ';
      tkInvalidCurrency: LocalizedText :=
        'Неверный номер валюты. Введите число от 1 до 30 или 0 для отмены.';
      tkAmountPrompt: LocalizedText :=
        'Введите сумму (положительное число, точка или запятая): ';
      tkInvalidAmount: LocalizedText :=
        'Неверная сумма. Введите положительное число не больше 1E15.';
      tkPairLabel: LocalizedText := 'Пара';
      tkAvailableYearsLabel: LocalizedText := 'Доступные годы';
      tkYearInstruction: LocalizedText :=
        'Год: полный средний, переходный неполный или 2026 по дату.';
      tkYearPrompt: LocalizedText := 'Выберите год для расчёта (0 = в главное меню): ';
      tkUnavailableYear: LocalizedText :=
        'Этот год недоступен для этой пары. Доступные диапазоны: ';
      tkNoCommonYears: LocalizedText :=
        'Для этой пары нет общих исторических лет.';
      tkReturnMainPrompt: LocalizedText :=
        'Нажмите ENTER, чтобы вернуться в главное меню...';
      tkResultWord: LocalizedText := 'РЕЗУЛЬТАТ';
      tkYearLabel: LocalizedText := 'Год';
      tkPivotSource: LocalizedText := 'Опорный курс исходной валюты: 1 USD = ';
      tkPivotDestination: LocalizedText := 'Опорный курс назначения: 1 USD = ';
      tkSourceUnit: LocalizedText := 'Исходная единица';
      tkDestinationUnit: LocalizedText := 'Единица назначения';
      tkSourceData: LocalizedText := 'Данные исходной валюты';
      tkDestinationData: LocalizedText := 'Данные валюты назначения';
      tkRateType: LocalizedText := 'Тип курса';
      tkStaticNotice: LocalizedText :=
        'Курсы встроены и автоматически не обновляются.';
      tkAnotherConversion: LocalizedText := '1. Выполнить ещё один расчёт';
      tkReturnMainMenu: LocalizedText := '2. Вернуться в главное меню';
      tkInvalidRepeatChoice: LocalizedText := 'Неверный выбор. Введите 1 или 2.';
      tkMainConvert: LocalizedText := '1. Перевести исторические валюты';
      tkMainCurrencies: LocalizedText := '2. Список поддерживаемых валют';
      tkMainNotes: LocalizedText := '3. Исторические заметки и методика';
      tkMainLanguage: LocalizedText := '4. Сменить язык';
      tkMainExit: LocalizedText := '0. Выход';
      tkInvalidMenu: LocalizedText := 'Неверный пункт меню. Введите 0, 1, 2, 3 или 4.';
      tkNotesRateConvention: LocalizedText := 'Правило курса: встроенное значение - число единиц валюты за 1 USD.';
      tkNotesCalculationModel: LocalizedText := 'Расчёт: исходная валюта -> USD -> валюта назначения.';
      tkNotesUAH1: LocalizedText := 'Значения UAH за 1992-1995 годы - официальные средние курсы НБУ для';
      tkNotesUAH2: LocalizedText := 'украинского купоно-карбованца. 1996 год - период гривны с сентября по декабрь.';
      tkNotesNaturalBoundaries: LocalizedText := 'EUR доступен с 1999 года, CZK - с 1993, BRL - с июля 1994 года.';
      tkNotesRedenomTitle: LocalizedText := 'Заметки о деноминации:';
      tkNotesRedenom1: LocalizedText := 'PLZ 10 000:1 с 01.01.1995; MXP 1 000:1 с 01.01.1993.';
      tkNotesRedenom2: LocalizedText := 'BGL 1 000:1 с 05.07.1999; ROL 10 000:1 с 01.07.2005.';
      tkNotesRedenom3: LocalizedText := 'TRL потерял шесть нулей с 01.01.2005.';
      tkNotesYtd1: LocalizedText := 'Значения 2026 года - средние за период по 05.09.2026, а не';
      tkNotesYtd2: LocalizedText := 'полный среднегодовой курс. Запись BGN за 2026 год не включена';
      tkNotesYtd3: LocalizedText := 'поскольку Болгария перешла на евро 01.01.2026.';
      tkNotesSources: LocalizedText := 'Источники и преобразования описаны в SOURCES.md.';
      tkThanks: LocalizedText := 'Спасибо за использование исторического конвертера.';
      tkClose: LocalizedText := 'Нажмите ENTER, чтобы закрыть программу...';
      tkLanguageSelectorTitle: LocalizedText := 'ВЫБОР ЯЗЫКА / LANGUAGE SELECTOR';
      tkLanguageSelectorHelp: LocalizedText := 'LEFT / RIGHT или 1 / 2, затем ENTER';
      tkTuiSourceLabel: LocalizedText := 'ИСХОДНАЯ ВАЛЮТА';
      tkTuiDestinationLabel: LocalizedText := 'ВАЛЮТА НАЗНАЧЕНИЯ';
      tkTuiYearFieldLabel: LocalizedText := 'ГОД';
      tkTuiAmountLabel: LocalizedText := 'СУММА';
      tkTuiConvertButton: LocalizedText := 'РАССЧЁТ';
      tkTuiBackButton: LocalizedText := 'НАЗАД';
      tkTuiLanguageButton: LocalizedText := 'СМЕНИТЬ ЯЗЫК';
      tkTuiClearButton: LocalizedText := 'ОЧИСТИТЬ';
      tkTuiQuitButton: LocalizedText := 'ВЫХОД';
      tkTuiAvailableLabel: LocalizedText := 'Доступно';
      tkTuiMouseReady: LocalizedText := 'Мышь: готова.';
      tkTuiMouseUnavailable: LocalizedText :=
        'Мышь недоступна - используйте клавиатуру.';
      tkTuiFooter: LocalizedText :=
        'Tab: далее   Shift+Tab: назад   Enter: выбор   Esc: назад';
      tkTuiMouseFooter: LocalizedText := 'Мышь: нажимайте элементы';
      tkTuiPickerFooter: LocalizedText :=
        'Стрелки: перемещение   Enter: выбор   Esc: назад';
      tkTuiCurrencyPickerTitle: LocalizedText := 'Выбор валюты';
      tkTuiChooseSourceCurrency: LocalizedText := 'Выбор исходной валюты';
      tkTuiChooseDestinationCurrency: LocalizedText := 'Выбор валюты назначения';
      tkTuiYearPickerTitle: LocalizedText := 'Выбор года';
      tkTuiAmountPlaceholder: LocalizedText := 'введите сумму';
      tkTuiInvalidAmountShort: LocalizedText :=
        'Введите положительную сумму и нажмите РАССЧЁТ.';
      tkTuiNoResult: LocalizedText :=
        'Выберите поля и нажмите РАССЧЁТ.';
      tkTuiConverted: LocalizedText := 'Расчёт готов.';
      tkTuiSmallConsole1: LocalizedText :=
        'Окно консоли слишком мало для этого интерфейса.';
      tkTuiSmallConsole2: LocalizedText :=
        'Увеличьте его минимум до 72 x 24 символов.';
      tkTuiSmallConsole3: LocalizedText :=
        'Клавиатура остаётся доступной после изменения размера.';
      tkTuiResizeHint: LocalizedText :=
        'Измените размер окна и нажмите любую клавишу.';
    end;
end;

function CurrencyCode(CurrencyIndex: Integer): String;
begin
  case CurrencyIndex of
    1: CurrencyCode := 'UAH';
    2: CurrencyCode := 'USD';
    3: CurrencyCode := 'EUR';
    4: CurrencyCode := 'GBP';
    5: CurrencyCode := 'CHF';
    6: CurrencyCode := 'JPY';
    7: CurrencyCode := 'CNY';
    8: CurrencyCode := 'CAD';
    9: CurrencyCode := 'AUD';
    10: CurrencyCode := 'NZD';
    11: CurrencyCode := 'PLN';
    12: CurrencyCode := 'CZK';
    13: CurrencyCode := 'HUF';
    14: CurrencyCode := 'RON';
    15: CurrencyCode := 'BGN';
    16: CurrencyCode := 'SEK';
    17: CurrencyCode := 'NOK';
    18: CurrencyCode := 'DKK';
    19: CurrencyCode := 'TRY';
    20: CurrencyCode := 'ILS';
    21: CurrencyCode := 'AED';
    22: CurrencyCode := 'SAR';
    23: CurrencyCode := 'INR';
    24: CurrencyCode := 'KRW';
    25: CurrencyCode := 'SGD';
    26: CurrencyCode := 'HKD';
    27: CurrencyCode := 'MXN';
    28: CurrencyCode := 'BRL';
    29: CurrencyCode := 'ZAR';
    30: CurrencyCode := 'THB';
  else
    CurrencyCode := '???';
  end;
end;

function CurrencyName(CurrencyIndex: Integer; Language: TLanguage): String;
begin
  if Language = LanguageEnglish then
    case CurrencyIndex of
      1: CurrencyName := 'Hryvnia';
      2: CurrencyName := 'US Dollar';
      3: CurrencyName := 'Euro';
      4: CurrencyName := 'Pound Sterling';
      5: CurrencyName := 'Swiss Franc';
      6: CurrencyName := 'Japanese Yen';
      7: CurrencyName := 'Chinese Yuan';
      8: CurrencyName := 'Canadian Dollar';
      9: CurrencyName := 'Australian Dollar';
      10: CurrencyName := 'New Zealand Dollar';
      11: CurrencyName := 'Polish Zloty';
      12: CurrencyName := 'Czech Koruna';
      13: CurrencyName := 'Hungarian Forint';
      14: CurrencyName := 'Romanian Leu';
      15: CurrencyName := 'Bulgarian Lev';
      16: CurrencyName := 'Swedish Krona';
      17: CurrencyName := 'Norwegian Krone';
      18: CurrencyName := 'Danish Krone';
      19: CurrencyName := 'Turkish Lira';
      20: CurrencyName := 'Israeli Shekel';
      21: CurrencyName := 'UAE Dirham';
      22: CurrencyName := 'Saudi Riyal';
      23: CurrencyName := 'Indian Rupee';
      24: CurrencyName := 'South Korean Won';
      25: CurrencyName := 'Singapore Dollar';
      26: CurrencyName := 'Hong Kong Dollar';
      27: CurrencyName := 'Mexican Peso';
      28: CurrencyName := 'Brazilian Real';
      29: CurrencyName := 'South African Rand';
      30: CurrencyName := 'Thai Baht';
    end
  else
    case CurrencyIndex of
      1: CurrencyName := 'Украина / гривна';
      2: CurrencyName := 'Доллар США';
      3: CurrencyName := 'Евро';
      4: CurrencyName := 'Фунт стерлингов';
      5: CurrencyName := 'Швейцарский франк';
      6: CurrencyName := 'Японская иена';
      7: CurrencyName := 'Китайский юань';
      8: CurrencyName := 'Канадский доллар';
      9: CurrencyName := 'Австралийский доллар';
      10: CurrencyName := 'Новозеландский доллар';
      11: CurrencyName := 'Польский злотый';
      12: CurrencyName := 'Чешская крона';
      13: CurrencyName := 'Венгерский форинт';
      14: CurrencyName := 'Румынский лей';
      15: CurrencyName := 'Болгарский лев';
      16: CurrencyName := 'Шведская крона';
      17: CurrencyName := 'Норвежская крона';
      18: CurrencyName := 'Датская крона';
      19: CurrencyName := 'Турецкая лира';
      20: CurrencyName := 'Израильский шекель';
      21: CurrencyName := 'Дирхам ОАЭ';
      22: CurrencyName := 'Саудовский риял';
      23: CurrencyName := 'Индийская рупия';
      24: CurrencyName := 'Южнокорейская вона';
      25: CurrencyName := 'Сингапурский доллар';
      26: CurrencyName := 'Гонконгский доллар';
      27: CurrencyName := 'Мексиканское песо';
      28: CurrencyName := 'Бразильский реал';
      29: CurrencyName := 'Южноафриканский рэнд';
      30: CurrencyName := 'Тайский бат';
    end;
end;

function HistoricalUnit(CurrencyIndex: Integer; Year: Integer;
  Language: TLanguage): String;
begin
  HistoricalUnit := CurrencyCode(CurrencyIndex) + ': ' +
    CurrencyName(CurrencyIndex, Language);
  if Language = LanguageEnglish then
    case CurrencyIndex of
      1:
        if Year <= 1995 then
          HistoricalUnit := 'UAH: coupon-karbovanets (nominal)'
        else if Year = 1996 then
          HistoricalUnit := 'UAH: hryvnia after 02.09.1996'
        else
          HistoricalUnit := 'UAH: hryvnia';
      3: HistoricalUnit := 'EUR: euro reference unit';
      11:
        if Year <= 1994 then
          HistoricalUnit := 'PLZ: old zloty (10,000 PLZ = 1 PLN)'
        else
          HistoricalUnit := 'PLN: zloty';
      12:
        if Year = 1993 then
          HistoricalUnit := 'CZK: koruna after 1993 split'
        else
          HistoricalUnit := 'CZK: Czech koruna';
      14:
        if Year <= 2004 then
          HistoricalUnit := 'ROL: old leu (10,000 ROL = 1 RON)'
        else if Year = 2005 then
          HistoricalUnit := 'RON: new leu from 01.07.2005'
        else
          HistoricalUnit := 'RON: new Romanian leu';
      15:
        if Year <= 1998 then
          HistoricalUnit := 'BGL: old lev (1,000 BGL = 1 BGN)'
        else if Year = 1999 then
          HistoricalUnit := 'BGN: new lev from 05.07.1999'
        else
          HistoricalUnit := 'BGN: new Bulgarian lev';
      19:
        if Year <= 2004 then
          HistoricalUnit := 'TRL: old lira (1,000,000 TRL = 1 TRY)'
        else
          HistoricalUnit := 'TRY: new Turkish lira';
      27:
        if Year = 1992 then
          HistoricalUnit := 'MXP: old peso (1,000 MXP = 1 MXN)'
        else
          HistoricalUnit := 'MXN: new Mexican peso';
      28:
        if Year = 1994 then
          HistoricalUnit := 'BRL: real from 01.07.1994'
        else
          HistoricalUnit := 'BRL: Brazilian real';
    end
  else
    case CurrencyIndex of
      1:
        if Year <= 1995 then
          HistoricalUnit := 'UAH: украинский купоно-карбованец (номинал)'
        else if Year = 1996 then
          HistoricalUnit := 'UAH: гривна после 02.09.1996'
        else
          HistoricalUnit := 'UAH: украинская гривна';
      3: HistoricalUnit := 'EUR: справочная евро';
      11:
        if Year <= 1994 then
          HistoricalUnit := 'PLZ: старый злотый (10 000 PLZ = 1 PLN)'
        else
          HistoricalUnit := 'PLN: польский злотый';
      12:
        if Year = 1993 then
          HistoricalUnit := 'CZK: крона после раздела 1993 года'
        else
          HistoricalUnit := 'CZK: чешская крона';
      14:
        if Year <= 2004 then
          HistoricalUnit := 'ROL: старый лей (10 000 ROL = 1 RON)'
        else if Year = 2005 then
          HistoricalUnit := 'RON: новый лей с 01.07.2005'
        else
          HistoricalUnit := 'RON: новый румынский лей';
      15:
        if Year <= 1998 then
          HistoricalUnit := 'BGL: старый лев (1 000 BGL = 1 BGN)'
        else if Year = 1999 then
          HistoricalUnit := 'BGN: новый лев с 05.07.1999'
        else
          HistoricalUnit := 'BGN: новый болгарский лев';
      19:
        if Year <= 2004 then
          HistoricalUnit := 'TRL: старая лира (1 000 000 TRL = 1 TRY)'
        else
          HistoricalUnit := 'TRY: новая турецкая лира';
      27:
        if Year = 1992 then
          HistoricalUnit := 'MXP: старое песо (1 000 MXP = 1 MXN)'
        else
          HistoricalUnit := 'MXN: новое мексиканское песо';
      28:
        if Year = 1994 then
          HistoricalUnit := 'BRL: реал с 01.07.1994'
        else
          HistoricalUnit := 'BRL: бразильский реал';
    end;
end;

function HistoricalAmountName(CurrencyIndex: Integer; Year: Integer;
  Language: TLanguage): String;
begin
  HistoricalAmountName := CurrencyName(CurrencyIndex, Language);
  if Language = LanguageEnglish then
    case CurrencyIndex of
      1:
        if Year <= 1995 then
          HistoricalAmountName := 'Ukrainian coupon-karbovanets'
        else if Year = 1996 then
          HistoricalAmountName := 'Ukrainian hryvnia (Sep-Dec 1996)'
        else
          HistoricalAmountName := 'Ukrainian hryvnia';
      11:
        if Year <= 1994 then
          HistoricalAmountName := 'old Polish zloty'
        else
          HistoricalAmountName := 'Polish zloty';
      14:
        if Year <= 2004 then
          HistoricalAmountName := 'old Romanian leu'
        else if Year = 2005 then
          HistoricalAmountName := 'new Romanian leu';
      15:
        if Year <= 1998 then
          HistoricalAmountName := 'old Bulgarian lev'
        else if Year = 1999 then
          HistoricalAmountName := 'new Bulgarian lev';
      19:
        if Year <= 2004 then
          HistoricalAmountName := 'old Turkish lira'
        else
          HistoricalAmountName := 'new Turkish lira';
      27:
        if Year = 1992 then
          HistoricalAmountName := 'old Mexican peso'
        else
          HistoricalAmountName := 'Mexican peso';
      28: HistoricalAmountName := 'Brazilian real';
    end
  else
    case CurrencyIndex of
      1:
        if Year <= 1995 then
          HistoricalAmountName := 'украинский купоно-карбованец'
        else if Year = 1996 then
          HistoricalAmountName := 'украинская гривна (сентябрь-декабрь 1996)'
        else
          HistoricalAmountName := 'украинская гривна';
      11:
        if Year <= 1994 then
          HistoricalAmountName := 'старый польский злотый'
        else
          HistoricalAmountName := 'польский злотый';
      14:
        if Year <= 2004 then
          HistoricalAmountName := 'старый румынский лей'
        else
          HistoricalAmountName := 'новый румынский лей';
      15:
        if Year <= 1998 then
          HistoricalAmountName := 'старый болгарский лев'
        else
          HistoricalAmountName := 'новый болгарский лев';
      19:
        if Year <= 2004 then
          HistoricalAmountName := 'старая турецкая лира'
        else
          HistoricalAmountName := 'новая турецкая лира';
      27:
        if Year = 1992 then
          HistoricalAmountName := 'старое мексиканское песо'
        else
          HistoricalAmountName := 'мексиканское песо';
      28: HistoricalAmountName := 'бразильский реал';
    end;
end;

function RateKindText(RateKind: Integer; Language: TLanguage): String;
begin
  if Language = LanguageEnglish then
    case RateKind of
      1: RateKindText := 'full-year annual average';
      2: RateKindText := 'partial-year transition average';
      3: RateKindText := '2026 year-to-date average through 05.09.2026';
    else
      RateKindText := 'embedded historical average';
    end
  else
    case RateKind of
      1: RateKindText := 'средний курс за полный год';
      2: RateKindText := 'средний курс за переходный неполный год';
      3: RateKindText := 'средний курс за 2026 год по 05.09.2026';
    else
      RateKindText := 'встроенный исторический курс';
    end;
end;

function LanguageLabel(Language: TLanguage): String;
begin
  if Language = LanguageEnglish then
    LanguageLabel := 'ENGLISH'
  else
    LanguageLabel := 'РУССКИЙ';
end;

end.
