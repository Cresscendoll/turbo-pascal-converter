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
      tkYtdThrough: LocalizedText := '2026 uses the January rate';
      tkCurrencyIntro1: LocalizedText :=
        'Thirty-two currencies are embedded as start-of-year USD-pivot series.';
      tkCurrencyIntro2: LocalizedText :=
        'Year availability is checked after both currencies are selected.';
      tkCurrencyNote1: LocalizedText :=
        'EUR starts in 1999; UAH and BYN in 1996; RUB in 1993.';
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
        'Invalid currency number. Enter 1 to 32, or 0 to cancel.';
      tkAmountPrompt: LocalizedText :=
        'Enter amount (positive, point or comma): ';
      tkInvalidAmount: LocalizedText :=
        'Invalid amount. Use a positive number up to 1E15.';
      tkPairLabel: LocalizedText := 'Pair';
      tkAvailableYearsLabel: LocalizedText := 'Available years';
      tkYearInstruction: LocalizedText :=
        'The selected year uses the first official January rate, not an annual average.';
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
        'UAH starts here in 1996; the 01.01.1996 record is still the';
      tkNotesUAH2: LocalizedText :=
        'coupon-karbovanets. 1992-1995 have no January source record.';
      tkNotesNaturalBoundaries: LocalizedText :=
        'EUR starts in 1999, BRL in 1995, MXN in 1994, and RUB in 1993.';
      tkNotesRedenomTitle: LocalizedText := 'Redenomination notes:';
      tkNotesRedenom1: LocalizedText :=
        'PLZ 10,000:1 on 01.01.1995; MXP 1,000:1 on 01.01.1993.';
      tkNotesRedenom2: LocalizedText :=
        'At January 1, 1999 BGN still means old BGL; new BGN starts in 2000.';
      tkNotesRedenom3: LocalizedText :=
        'At January 1, 2005 RON still means old ROL; new RON starts in 2006.';
      tkNotesYtd1: LocalizedText :=
        'Every year uses the first official January observation.';
      tkNotesYtd2: LocalizedText :=
        'If January 1 has no published quote, the first available January';
      tkNotesYtd3: LocalizedText :=
        'quote is used. No annual or YTD averages are embedded.';
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
      tkYtdThrough: LocalizedText := '2026 - курс на январь';
      tkCurrencyIntro1: LocalizedText :=
        'Встроены данные для 32 валют; расчёт идёт через USD на начало года.';
      tkCurrencyIntro2: LocalizedText :=
        'Доступность лет проверяется после выбора обеих валют.';
      tkCurrencyNote1: LocalizedText :=
        'EUR доступен с 1999 года; UAH и BYN - с 1996; RUB - с 1993.';
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
        'Неверный номер валюты. Введите число от 1 до 32 или 0 для отмены.';
      tkAmountPrompt: LocalizedText :=
        'Введите сумму (положительное число, точка или запятая): ';
      tkInvalidAmount: LocalizedText :=
        'Неверная сумма. Введите положительное число не больше 1E15.';
      tkPairLabel: LocalizedText := 'Пара';
      tkAvailableYearsLabel: LocalizedText := 'Доступные годы';
      tkYearInstruction: LocalizedText :=
        'Выбран год с первым официальным январским курсом, не средним за год.';
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
      tkNotesUAH1: LocalizedText := 'UAH в этой версии доступен с 1996 года; курс на 01.01.1996 - это';
      tkNotesUAH2: LocalizedText := 'купоно-карбованец. Для 1992-1995 нет январской записи источника.';
      tkNotesNaturalBoundaries: LocalizedText := 'EUR - с 1999 года, BRL - с 1995, MXN - с 1994, RUB - с 1993.';
      tkNotesRedenomTitle: LocalizedText := 'Заметки о деноминации:';
      tkNotesRedenom1: LocalizedText := 'PLZ 10 000:1 с 01.01.1995; MXP 1 000:1 с 01.01.1993.';
      tkNotesRedenom2: LocalizedText := 'На 1 января 1999 года BGN ещё означает старый BGL; новый BGN - с 2000.';
      tkNotesRedenom3: LocalizedText := 'На 1 января 2005 года RON ещё означает старый ROL; новый RON - с 2006.';
      tkNotesYtd1: LocalizedText := 'Для каждого года берётся первая официальная январская запись.';
      tkNotesYtd2: LocalizedText := 'Если на 1 января курса нет, берётся первая доступная запись января.';
      tkNotesYtd3: LocalizedText := 'Средние за год и YTD-средние в данные больше не встраиваются.';
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
      31: CurrencyCode := 'RUB';
      32: CurrencyCode := 'BYN';
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
      31: CurrencyName := 'Russian Ruble';
      32: CurrencyName := 'Belarusian Ruble';
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
      31: CurrencyName := 'Российский рубль';
      32: CurrencyName := 'Белорусский рубль';
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
        if Year <= 1996 then
          HistoricalUnit := 'UAH: coupon-karbovanets (nominal)'
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
        if Year <= 2005 then
          HistoricalUnit := 'ROL: old leu (10,000 ROL = 1 RON)'
        else
          HistoricalUnit := 'RON: new Romanian leu';
      15:
        if Year <= 1999 then
          HistoricalUnit := 'BGL: old lev (1,000 BGL = 1 BGN)'
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
        HistoricalUnit := 'BRL: Brazilian real';
      31:
        if Year <= 1997 then
          HistoricalUnit := 'RUR: old Russian ruble (1,000 RUR = 1 RUB)'
        else
          HistoricalUnit := 'RUB: Russian ruble';
      32:
        if Year <= 1999 then
          HistoricalUnit := 'BYB: old ruble (10,000,000 BYB = 1 BYN)'
        else if Year <= 2016 then
          HistoricalUnit := 'BYR: ruble after 01.01.2000 (10,000 BYR = 1 BYN)'
        else
          HistoricalUnit := 'BYN: ruble after 01.07.2016';
    end
  else
    case CurrencyIndex of
      1:
        if Year <= 1996 then
          HistoricalUnit := 'UAH: украинский купоно-карбованец (номинал)'
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
        if Year <= 2005 then
          HistoricalUnit := 'ROL: старый лей (10 000 ROL = 1 RON)'
        else
          HistoricalUnit := 'RON: новый румынский лей';
      15:
        if Year <= 1999 then
          HistoricalUnit := 'BGL: старый лев (1 000 BGL = 1 BGN)'
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
        HistoricalUnit := 'BRL: бразильский реал';
      31:
        if Year <= 1997 then
          HistoricalUnit := 'RUR: старый российский рубль (1 000 RUR = 1 RUB)'
        else
          HistoricalUnit := 'RUB: российский рубль';
      32:
        if Year <= 1999 then
          HistoricalUnit := 'BYB: старый рубль (10 000 000 BYB = 1 BYN)'
        else if Year <= 2016 then
          HistoricalUnit := 'BYR: рубль после 01.01.2000 (10 000 BYR = 1 BYN)'
        else
          HistoricalUnit := 'BYN: рубль после 01.07.2016';
    end;
end;

function HistoricalAmountName(CurrencyIndex: Integer; Year: Integer;
  Language: TLanguage): String;
begin
  HistoricalAmountName := CurrencyName(CurrencyIndex, Language);
  if Language = LanguageEnglish then
    case CurrencyIndex of
      1:
        if Year <= 1996 then
          HistoricalAmountName := 'Ukrainian coupon-karbovanets'
        else
          HistoricalAmountName := 'Ukrainian hryvnia';
      11:
        if Year <= 1994 then
          HistoricalAmountName := 'old Polish zloty'
        else
          HistoricalAmountName := 'Polish zloty';
      14:
        if Year <= 2005 then
          HistoricalAmountName := 'old Romanian leu'
        else
          HistoricalAmountName := 'new Romanian leu';
      15:
        if Year <= 1999 then
          HistoricalAmountName := 'old Bulgarian lev'
        else
          HistoricalAmountName := 'new Bulgarian lev';
      19:
        if Year <= 2004 then
          HistoricalAmountName := 'old Turkish lira'
        else
          HistoricalAmountName := 'new Turkish lira';
      27:
        if Year <= 1993 then
          HistoricalAmountName := 'old Mexican peso'
        else
          HistoricalAmountName := 'Mexican peso';
      28: HistoricalAmountName := 'Brazilian real';
      31:
        if Year <= 1997 then
          HistoricalAmountName := 'old Russian ruble'
        else
          HistoricalAmountName := 'Russian ruble';
      32:
        if Year <= 1999 then
          HistoricalAmountName := 'old Belarusian ruble'
        else if Year <= 2016 then
          HistoricalAmountName := 'Belarusian ruble (BYR)'
        else
          HistoricalAmountName := 'Belarusian ruble (BYN)';
    end
  else
    case CurrencyIndex of
      1:
        if Year <= 1996 then
          HistoricalAmountName := 'украинский купоно-карбованец'
        else
          HistoricalAmountName := 'украинская гривна';
      11:
        if Year <= 1994 then
          HistoricalAmountName := 'старый польский злотый'
        else
          HistoricalAmountName := 'польский злотый';
      14:
        if Year <= 2005 then
          HistoricalAmountName := 'старый румынский лей'
        else
          HistoricalAmountName := 'новый румынский лей';
      15:
        if Year <= 1999 then
          HistoricalAmountName := 'старый болгарский лев'
        else
          HistoricalAmountName := 'новый болгарский лев';
      19:
        if Year <= 2004 then
          HistoricalAmountName := 'старая турецкая лира'
        else
          HistoricalAmountName := 'новая турецкая лира';
      27:
        if Year <= 1993 then
          HistoricalAmountName := 'старое мексиканское песо'
        else
          HistoricalAmountName := 'мексиканское песо';
      28: HistoricalAmountName := 'бразильский реал';
      31:
        if Year <= 1997 then
          HistoricalAmountName := 'старый российский рубль'
        else
          HistoricalAmountName := 'российский рубль';
      32:
        if Year <= 1999 then
          HistoricalAmountName := 'старый белорусский рубль'
        else if Year <= 2016 then
          HistoricalAmountName := 'белорусский рубль (BYR)'
        else
          HistoricalAmountName := 'белорусский рубль (BYN)';
    end;
end;

function RateKindText(RateKind: Integer; Language: TLanguage): String;
begin
  if Language = LanguageEnglish then
    case RateKind of
      4: RateKindText :=
        'first official January rate (or first January quote after Jan 1)';
    else
      RateKindText := 'embedded start-of-year rate';
    end
  else
    case RateKind of
      4: RateKindText :=
        'первый официальный январский курс (или первая запись после 1 января)';
    else
      RateKindText := 'встроенный курс на начало года';
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
