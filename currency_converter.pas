program CurrencyConverter;

{$mode TP}
{$codepage utf8}
{$APPTYPE CONSOLE}

{ A small, offline historical converter presented as a retro Windows TUI. }
{ The data unit remains separate so the calculation can be regression-tested. }

uses
  Crt, Localization, Historical_Rates, TUI;

const
  SnapshotDate = '05.09.2026';
  CurrencyCount = 30;
  MaximumAmount = 1.0E15;

type
  TCurrency = record
    Code: String[3];
  end;

  TScreen = (ScreenLanguage, ScreenMain, ScreenCurrencyPicker,
    ScreenYearPicker);
  TPickerKind = (PickerSource, PickerDestination);
  TControl = (ControlSource, ControlDestination, ControlYear,
    ControlAmount, ControlConvert, ControlBack, ControlLanguage,
    ControlClear, ControlQuit);

var
  Currencies: array[1..CurrencyCount] of TCurrency;
  CurrentLanguage: TLanguage;
  CurrentScreen: TScreen;
  PickerKind: TPickerKind;
  FocusControl: TControl;
  SelectorChoice: Integer;
  PickerSelection: Integer;
  SelectedYear: Integer;
  AvailableYears: array[1..35] of Integer;
  AvailableYearCount: Integer;
  AmountText: String[40];
  AmountCursor: Integer;
  StatusText: String;
  ResultVisible: Boolean;
  ResultSourceIndex: Integer;
  ResultDestinationIndex: Integer;
  ResultYear: Integer;
  ResultInputAmount: Double;
  ResultOutputAmount: Double;
  ResultSourceKind: Integer;
  ResultDestinationKind: Integer;
  MainRegions: array[TControl] of TTUIRegion;
  CurrencyRegions: array[1..CurrencyCount] of TTUIRegion;
  YearRegions: array[1..35] of TTUIRegion;
  PickerBackRegion: TTUIRegion;
  LanguageEnglishRegion: TTUIRegion;
  LanguageRussianRegion: TTUIRegion;
  MouseAvailable: Boolean;
  ConsoleTooSmall: Boolean;
  Running: Boolean;

function Utf8CharLength(Value: String; Position: Integer): Integer;
begin
  { FPC 3.2.2 TP-compatible mode stores these compiled literals as one-byte
    Windows code-page characters. The source files remain UTF-8 and the
    TUI sets the console code page explicitly, so one String element is one
    display cell for the localized text used here. }
  Utf8CharLength := 1;
end;

function Utf8VisualLength(Value: String): Integer;
begin
  Utf8VisualLength := Length(Value);
end;

procedure DeleteLastUtf8Char(var Value: String);
begin
  if Length(Value) > 0 then
    Delete(Value, Length(Value), 1);
end;

function FitText(Value: String; Width: Integer): String;
begin
  while Utf8VisualLength(Value) > Width do
    DeleteLastUtf8Char(Value);
  while Utf8VisualLength(Value) < Width do
    Value := Value + ' ';
  FitText := Value;
end;

function NumberText(Value: Integer): String;
var
  TextValue: String;
begin
  Str(Value, TextValue);
  NumberText := TextValue;
end;

function DecimalText(Value: Double): String;
var
  TextValue: String;
begin
  Str(Value: 0:2, TextValue);
  DecimalText := TextValue;
end;

function StripSpaces(Value: String): String;
var
  FirstChar: Integer;
  LastChar: Integer;
begin
  FirstChar := 1;
  while (FirstChar <= Length(Value)) and (Value[FirstChar] = ' ') do
    FirstChar := FirstChar + 1;
  LastChar := Length(Value);
  while (LastChar >= FirstChar) and (Value[LastChar] = ' ') do
    LastChar := LastChar - 1;
  if LastChar < FirstChar then
    StripSpaces := ''
  else
    StripSpaces := Copy(Value, FirstChar, LastChar - FirstChar + 1);
end;

function NormalizeNumber(Value: String): String;
var
  I: Integer;
begin
  Value := StripSpaces(Value);
  for I := 1 to Length(Value) do
    if Value[I] = ',' then
      Value[I] := '.';
  NormalizeNumber := Value;
end;

function HorizontalLine: String;
var
  I: Integer;
  Line: String;
begin
  Line := '+';
  for I := 1 to TUIWidth - 2 do
    Line := Line + '-';
  Line := Line + '+';
  HorizontalLine := Line;
end;

procedure SetRegion(var Region: TTUIRegion; X1: Integer; Y1: Integer;
  X2: Integer; Y2: Integer; Action: Integer);
begin
  Region.X1 := X1;
  Region.Y1 := Y1;
  Region.X2 := X2;
  Region.Y2 := Y2;
  Region.Action := Action;
end;

procedure InitializeCurrencies;
var
  I: Integer;
begin
  for I := 1 to CurrencyCount do
    Currencies[I].Code := CurrencyCode(I);
end;

function AvailableYearsText(SourceIndex: Integer;
  DestinationIndex: Integer): String; forward;

procedure DrawHeader(Title: String; Language: TLanguage;
  ShowLanguageButtons: Boolean);
var
  EnglishText: String;
  RussianText: String;
begin
  WriteTUI(1, 1, HorizontalLine, LightCyan);
  WriteTUI(3, 2, FitText(Title, 48), LightCyan);
  if ShowLanguageButtons then
  begin
    if Language = LanguageEnglish then
      EnglishText := '[EN]'
    else
      EnglishText := ' EN ';
    if Language = LanguageRussian then
      RussianText := '[RU]'
    else
      RussianText := ' RU ';
    WriteTUI(54, 2, EnglishText, Yellow);
    WriteTUI(61, 2, RussianText, Yellow);
    SetRegion(LanguageEnglishRegion, 53, 2, 58, 2, 0);
    SetRegion(LanguageRussianRegion, 60, 2, 65, 2, 0);
  end
  else
  begin
    LanguageEnglishRegion.X1 := 0;
    LanguageRussianRegion.X1 := 0;
  end;
  WriteTUI(1, 3, HorizontalLine, DarkGray);
end;

procedure DrawFooter(Language: TLanguage; PickerFooter: Boolean);
var
  FooterText: String;
begin
  if PickerFooter then
    FooterText := LocalizedText(tkTuiPickerFooter, Language)
  else
    FooterText := LocalizedText(tkTuiFooter, Language);
  { Mouse readiness is shown on the status row; keep the footer readable. }
  WriteTUI(3, 24, FitText(FooterText, 66), DarkGray);
end;

procedure DrawButton(Control: TControl; LabelText: String; var X: Integer);
var
  ButtonText: String;
  ButtonWidth: Integer;
  ButtonColor: Byte;
begin
  ButtonText := '[ ' + LabelText + ' ]';
  ButtonWidth := Utf8VisualLength(ButtonText);
  if FocusControl = Control then
    ButtonColor := Yellow
  else
    ButtonColor := White;
  WriteTUI(X, 22, ButtonText, ButtonColor);
  SetRegion(MainRegions[Control], X, 22, X + ButtonWidth - 1, 22,
    Ord(Control));
  X := X + ButtonWidth + 2;
end;

function CurrencyFieldText(Index: Integer; Language: TLanguage): String;
begin
  CurrencyFieldText := CurrencyCode(Index) + '  ' +
    CurrencyName(Index, Language);
end;

procedure DrawField(Y: Integer; Value: String; Focused: Boolean);
var
  FieldText: String;
  FieldColor: Byte;
begin
  if Focused then
  begin
    FieldText := '> [' + FitText(Value, 58) + '] <';
    FieldColor := Yellow;
  end
  else
  begin
    FieldText := '  [' + FitText(Value, 58) + ']  ';
    FieldColor := White;
  end;
  WriteTUI(3, Y, FitText(FieldText, 66), FieldColor);
end;

procedure DrawResultPanel(Language: TLanguage);
var
  Line: String;
begin
  WriteTUI(3, 17, '--- ' + LocalizedText(tkResultWord, Language) + ' ---',
    LightGreen);
  if not ResultVisible then
  begin
    WriteTUI(3, 18, FitText(LocalizedText(tkTuiNoResult, Language), 66),
      DarkGray);
    WriteTUI(3, 20, FitText(LocalizedText(tkTuiInvalidAmountShort,
      Language), 66), DarkGray);
    Exit;
  end;

  WriteTUI(3, 18, LocalizedText(tkYearLabel, Language) + ': ' +
    NumberText(ResultYear), White);
  Line := DecimalText(ResultInputAmount) + ' ' +
    CurrencyCode(ResultSourceIndex) + ' (' +
    HistoricalAmountName(ResultSourceIndex, ResultYear, Language) +
    ') = ' + DecimalText(ResultOutputAmount) + ' ' +
    CurrencyCode(ResultDestinationIndex) + ' (' +
    HistoricalAmountName(ResultDestinationIndex, ResultYear, Language) +
    ')';
  WriteTUI(3, 19, FitText(Line, 66), White);
  Line := LocalizedText(tkRateType, Language) + ': ' +
    CurrencyCode(ResultSourceIndex) + ' - ' +
    RateKindText(ResultSourceKind, Language) + '; ' +
    CurrencyCode(ResultDestinationIndex) + ' - ' +
    RateKindText(ResultDestinationKind, Language);
  WriteTUI(3, 20, FitText(Line, 66), White);
  Line := LocalizedText(tkSourceUnit, Language) + ': ' +
    HistoricalUnit(ResultSourceIndex, ResultYear, Language) + ' -> ' +
    HistoricalUnit(ResultDestinationIndex, ResultYear, Language);
  WriteTUI(3, 21, FitText(Line, 66), White);
end;

procedure RenderMain;
var
  AvailableText: String;
  AmountValue: String;
  X: Integer;
begin
  ClearTUI;
  DrawHeader(LocalizedText(tkApplicationTitle, CurrentLanguage),
    CurrentLanguage, True);

  WriteTUI(3, 4, LocalizedText(tkTuiSourceLabel, CurrentLanguage),
    LightCyan);
  DrawField(5, CurrencyFieldText(ResultSourceIndex, CurrentLanguage),
    FocusControl = ControlSource);
  SetRegion(MainRegions[ControlSource], 3, 5, 69, 5,
    Ord(ControlSource));

  WriteTUI(3, 7, LocalizedText(tkTuiDestinationLabel, CurrentLanguage),
    LightCyan);
  DrawField(8, CurrencyFieldText(ResultDestinationIndex, CurrentLanguage),
    FocusControl = ControlDestination);
  SetRegion(MainRegions[ControlDestination], 3, 8, 69, 8,
    Ord(ControlDestination));

  WriteTUI(3, 10, LocalizedText(tkTuiYearFieldLabel, CurrentLanguage),
    LightCyan);
  DrawField(11, NumberText(SelectedYear), FocusControl = ControlYear);
  SetRegion(MainRegions[ControlYear], 3, 11, 69, 11, Ord(ControlYear));
  AvailableText := LocalizedText(tkTuiAvailableLabel, CurrentLanguage) +
    ': ' + AvailableYearsText(ResultSourceIndex, ResultDestinationIndex);
  WriteTUI(3, 12, FitText(AvailableText, 66), DarkGray);

  WriteTUI(3, 13, LocalizedText(tkTuiAmountLabel, CurrentLanguage),
    LightCyan);
  AmountValue := AmountText;
  if AmountValue = '' then
    AmountValue := LocalizedText(tkTuiAmountPlaceholder, CurrentLanguage);
  DrawField(14, AmountValue, FocusControl = ControlAmount);
  SetRegion(MainRegions[ControlAmount], 3, 14, 69, 14,
    Ord(ControlAmount));

  if StatusText <> '' then
    WriteTUI(3, 16, FitText(StatusText, 66), Yellow)
  else if MouseAvailable then
    WriteTUI(3, 16, FitText(LocalizedText(tkTuiMouseReady,
      CurrentLanguage), 66), DarkGray)
  else
    WriteTUI(3, 16, FitText(LocalizedText(tkTuiMouseUnavailable,
      CurrentLanguage), 66), LightRed);

  DrawResultPanel(CurrentLanguage);

  X := 3;
  DrawButton(ControlConvert, LocalizedText(tkTuiConvertButton,
    CurrentLanguage), X);
  DrawButton(ControlBack, LocalizedText(tkTuiBackButton, CurrentLanguage), X);
  DrawButton(ControlLanguage, LocalizedText(tkTuiLanguageButton,
    CurrentLanguage), X);
  DrawButton(ControlClear, LocalizedText(tkTuiClearButton, CurrentLanguage), X);
  DrawButton(ControlQuit, LocalizedText(tkTuiQuitButton, CurrentLanguage), X);
  WriteTUI(1, 23, HorizontalLine, DarkGray);
  DrawFooter(CurrentLanguage, False);

  if FocusControl = ControlAmount then
  begin
    SetTUICursorVisible(True);
    SetTUICursorPosition(6 + AmountCursor - 1, 14);
  end
  else
    SetTUICursorVisible(False);
end;

procedure DrawPickerCurrencyLine(Index: Integer; X: Integer; Y: Integer);
var
  Line: String;
  Color: Byte;
begin
  Line := NumberText(Index) + '. ' + CurrencyCode(Index) + ' ' +
    CurrencyName(Index, CurrentLanguage);
  if Index = PickerSelection then
  begin
    Line := '> ' + Line + ' <';
    Color := Yellow;
  end
  else
    Color := White;
  WriteTUI(X, Y, FitText(Line, 31), Color);
end;

procedure RenderCurrencyPicker;
var
  Index: Integer;
  Row: Integer;
  X: Integer;
  Title: String;
begin
  ClearTUI;
  if PickerKind = PickerSource then
    Title := LocalizedText(tkTuiChooseSourceCurrency, CurrentLanguage)
  else
    Title := LocalizedText(tkTuiChooseDestinationCurrency, CurrentLanguage);
  DrawHeader(Title, CurrentLanguage, True);
  WriteTUI(3, 4, LocalizedText(tkTuiCurrencyPickerTitle, CurrentLanguage),
    LightCyan);
  for Index := 1 to CurrencyCount do
  begin
    Row := ((Index - 1) mod 15) + 5;
    if Index <= 15 then
      X := 3
    else
      X := 37;
    SetRegion(CurrencyRegions[Index], X, Row, X + 30, Row, Index);
    DrawPickerCurrencyLine(Index, X, Row);
  end;
  WriteTUI(3, 20, FitText(LocalizedText(tkCurrencyIntro2,
    CurrentLanguage), 66), DarkGray);
  WriteTUI(3, 22, '[ ' + LocalizedText(tkTuiBackButton, CurrentLanguage) +
    ' ]', Yellow);
  SetRegion(PickerBackRegion, 3, 22, 14, 22, -1);
  WriteTUI(1, 23, HorizontalLine, DarkGray);
  DrawFooter(CurrentLanguage, True);
  SetTUICursorVisible(False);
end;

procedure DrawYearCell(Index: Integer; X: Integer; Y: Integer);
var
  CellText: String;
  Color: Byte;
begin
  if Index = PickerSelection then
  begin
    CellText := '> ' + NumberText(AvailableYears[Index]) + ' <';
    Color := Yellow;
  end
  else
  begin
    CellText := '[ ' + NumberText(AvailableYears[Index]) + ' ]';
    Color := White;
  end;
  WriteTUI(X, Y, FitText(CellText, 11), Color);
end;

procedure RenderYearPicker;
var
  Index: Integer;
  Column: Integer;
  Row: Integer;
  X: Integer;
  Y: Integer;
  Line: String;
begin
  ClearTUI;
  DrawHeader(LocalizedText(tkTuiYearPickerTitle, CurrentLanguage),
    CurrentLanguage, True);
  WriteTUI(3, 4, LocalizedText(tkPairLabel, CurrentLanguage) + ': ' +
    CurrencyCode(ResultSourceIndex) + ' -> ' +
    CurrencyCode(ResultDestinationIndex), LightCyan);
  for Index := 1 to AvailableYearCount do
  begin
    Column := (Index - 1) mod 5;
    Row := (Index - 1) div 5;
    X := 3 + Column * 14;
    Y := 6 + Row;
    SetRegion(YearRegions[Index], X, Y, X + 10, Y, Index);
    DrawYearCell(Index, X, Y);
  end;
  if AvailableYearCount = 0 then
    WriteTUI(3, 6, FitText(LocalizedText(tkNoCommonYears,
      CurrentLanguage), 66), LightRed);
  Line := LocalizedText(tkTuiAvailableLabel, CurrentLanguage) + ': ' +
    AvailableYearsText(ResultSourceIndex, ResultDestinationIndex);
  WriteTUI(3, 14, FitText(Line, 66), DarkGray);
  WriteTUI(3, 15, FitText(LocalizedText(tkYearInstruction,
    CurrentLanguage), 66), DarkGray);
  WriteTUI(3, 22, '[ ' + LocalizedText(tkTuiBackButton, CurrentLanguage) +
    ' ]', Yellow);
  SetRegion(PickerBackRegion, 3, 22, 14, 22, -1);
  WriteTUI(1, 23, HorizontalLine, DarkGray);
  DrawFooter(CurrentLanguage, True);
  SetTUICursorVisible(False);
end;

procedure RenderLanguageSelector;
var
  SelectorTitle: String;
  EnglishColor: Byte;
  RussianColor: Byte;
begin
  ClearTUI;
  SelectorTitle := LocalizedText(tkLanguageSelectorTitle, LanguageEnglish);
  if SelectorChoice = 1 then
    EnglishColor := Yellow
  else
    EnglishColor := White;
  if SelectorChoice = 2 then
    RussianColor := Yellow
  else
    RussianColor := White;
  WriteTUI(1, 1, HorizontalLine, LightCyan);
  WriteTUI(3, 2, FitText(SelectorTitle, 66), LightCyan);
  WriteTUI(1, 3, HorizontalLine, DarkGray);
  WriteTUI(3, 5, FitText('[ ' + LanguageLabel(LanguageEnglish) + ' ]',
    14), EnglishColor);
  WriteTUI(35, 5, FitText('[ ' + LanguageLabel(LanguageRussian) + ' ]',
    16), RussianColor);
  SetRegion(LanguageEnglishRegion, 3, 5, 16, 5, 1);
  SetRegion(LanguageRussianRegion, 35, 5, 52, 5, 2);
  WriteTUI(3, 7, LocalizedText(tkLanguageSelectorHelp,
    LanguageEnglish), White);
  WriteTUI(3, 8, LocalizedText(tkLanguageSelectorHelp,
    LanguageRussian), White);
  if MouseAvailable then
    WriteTUI(3, 10, LocalizedText(tkTuiMouseFooter, LanguageEnglish),
      DarkGray)
  else
    WriteTUI(3, 10, LocalizedText(tkTuiMouseUnavailable,
      LanguageEnglish), LightRed);
  WriteTUI(1, 23, HorizontalLine, DarkGray);
  DrawFooter(LanguageEnglish, False);
  SetTUICursorVisible(False);
end;

function YearAvailable(SourceIndex: Integer; DestinationIndex: Integer;
  Year: Integer): Boolean;
var
  SourceRate: Double;
  DestinationRate: Double;
  SourceKind: Integer;
  DestinationKind: Integer;
begin
  YearAvailable := False;
  if not GetHistoricalRate(SourceIndex, Year, SourceRate, SourceKind) then
    Exit;
  if not GetHistoricalRate(DestinationIndex, Year, DestinationRate,
    DestinationKind) then
    Exit;
  YearAvailable := True;
end;

procedure AppendYearRange(var TextValue: String; FirstYear: Integer;
  LastYear: Integer);
var
  Segment: String;
begin
  if TextValue <> '' then
    TextValue := TextValue + ', ';
  if FirstYear = LastYear then
    Segment := NumberText(FirstYear)
  else
    Segment := NumberText(FirstYear) + '-' + NumberText(LastYear);
  TextValue := TextValue + Segment;
end;

function AvailableYearsText(SourceIndex: Integer;
  DestinationIndex: Integer): String;
var
  Year: Integer;
  FirstYear: Integer;
  LastYear: Integer;
  InRange: Boolean;
  TextValue: String;
begin
  TextValue := '';
  InRange := False;
  for Year := FirstHistoricalYear to LastHistoricalYear do
  begin
    if YearAvailable(SourceIndex, DestinationIndex, Year) then
    begin
      if not InRange then
      begin
        FirstYear := Year;
        InRange := True;
      end;
      LastYear := Year;
    end
    else if InRange then
    begin
      AppendYearRange(TextValue, FirstYear, LastYear);
      InRange := False;
    end;
  end;
  if InRange then
    AppendYearRange(TextValue, FirstYear, LastYear);
  if TextValue = '' then
    TextValue := 'none';
  AvailableYearsText := TextValue;
end;

procedure BuildAvailableYearList;
var
  Year: Integer;
begin
  AvailableYearCount := 0;
  for Year := FirstHistoricalYear to LastHistoricalYear do
    if YearAvailable(ResultSourceIndex, ResultDestinationIndex, Year) then
    begin
      Inc(AvailableYearCount);
      AvailableYears[AvailableYearCount] := Year;
    end;
end;

function CountAvailableYears(SourceIndex: Integer;
  DestinationIndex: Integer): Integer;
var
  Year: Integer;
  Count: Integer;
begin
  Count := 0;
  for Year := FirstHistoricalYear to LastHistoricalYear do
    if YearAvailable(SourceIndex, DestinationIndex, Year) then
      Inc(Count);
  CountAvailableYears := Count;
end;

procedure SetDefaultYear;
var
  Year: Integer;
begin
  SelectedYear := 2025;
  for Year := 2025 downto FirstHistoricalYear do
    if YearAvailable(ResultSourceIndex, ResultDestinationIndex, Year) then
    begin
      SelectedYear := Year;
      Exit;
    end;
  if YearAvailable(ResultSourceIndex, ResultDestinationIndex, 2026) then
    SelectedYear := 2026;
end;

procedure OpenCurrencyPicker(Kind: TPickerKind);
begin
  PickerKind := Kind;
  if Kind = PickerSource then
    PickerSelection := ResultSourceIndex
  else
    PickerSelection := ResultDestinationIndex;
  CurrentScreen := ScreenCurrencyPicker;
  StatusText := '';
end;

procedure OpenYearPicker;
var
  Index: Integer;
begin
  BuildAvailableYearList;
  PickerSelection := 1;
  for Index := 1 to AvailableYearCount do
    if AvailableYears[Index] = SelectedYear then
      PickerSelection := Index;
  CurrentScreen := ScreenYearPicker;
  StatusText := '';
end;

procedure SelectCurrency(Index: Integer);
begin
  if PickerKind = PickerSource then
  begin
    ResultSourceIndex := Index;
    FocusControl := ControlSource;
  end
  else
  begin
    ResultDestinationIndex := Index;
    FocusControl := ControlDestination;
  end;
  SetDefaultYear;
  ResultVisible := False;
  StatusText := '';
  CurrentScreen := ScreenMain;
end;

procedure SelectYear(Index: Integer);
begin
  if (Index < 1) or (Index > AvailableYearCount) then
    Exit;
  SelectedYear := AvailableYears[Index];
  FocusControl := ControlYear;
  ResultVisible := False;
  StatusText := '';
  CurrentScreen := ScreenMain;
end;

procedure ResetResult;
begin
  ResultVisible := False;
  StatusText := '';
end;

procedure ClearForm;
begin
  AmountText := '';
  AmountCursor := 1;
  ResetResult;
  FocusControl := ControlAmount;
end;

procedure PerformConversion;
var
  SourceUnitsPerUSD: Double;
  DestinationUnitsPerUSD: Double;
  ErrorPosition: Integer;
begin
  SourceUnitsPerUSD := 0.0;
  DestinationUnitsPerUSD := 0.0;
  ErrorPosition := 0;
  Val(NormalizeNumber(AmountText), ResultInputAmount, ErrorPosition);
  if (ErrorPosition <> 0) or (ResultInputAmount <= 0.0) or
    (ResultInputAmount > MaximumAmount) then
  begin
    ResultVisible := False;
    StatusText := LocalizedText(tkTuiInvalidAmountShort, CurrentLanguage);
    Exit;
  end;
  if not GetHistoricalRate(ResultSourceIndex, SelectedYear,
    SourceUnitsPerUSD, ResultSourceKind) then
  begin
    ResultVisible := False;
    StatusText := LocalizedText(tkNoCommonYears, CurrentLanguage);
    Exit;
  end;
  if not GetHistoricalRate(ResultDestinationIndex, SelectedYear,
    DestinationUnitsPerUSD, ResultDestinationKind) then
  begin
    ResultVisible := False;
    StatusText := LocalizedText(tkNoCommonYears, CurrentLanguage);
    Exit;
  end;
  ResultOutputAmount := ResultInputAmount / SourceUnitsPerUSD *
    DestinationUnitsPerUSD;
  ResultYear := SelectedYear;
  ResultVisible := True;
  StatusText := LocalizedText(tkTuiConverted, CurrentLanguage);
end;

procedure ChangeLanguage(Language: TLanguage);
begin
  CurrentLanguage := Language;
  StatusText := '';
end;

procedure OpenLanguageSelector;
begin
  if CurrentLanguage = LanguageEnglish then
    SelectorChoice := 1
  else
    SelectorChoice := 2;
  CurrentScreen := ScreenLanguage;
  SetTUICursorVisible(False);
end;

procedure ConfirmSelectedLanguage;
begin
  if SelectorChoice = 1 then
    ChangeLanguage(LanguageEnglish)
  else
    ChangeLanguage(LanguageRussian);
  CurrentScreen := ScreenMain;
  FocusControl := ControlSource;
end;

procedure MoveFocus(Step: Integer);
var
  FocusNumber: Integer;
begin
  FocusNumber := Ord(FocusControl) + Step;
  if FocusNumber < Ord(ControlSource) then
    FocusNumber := Ord(ControlQuit);
  if FocusNumber > Ord(ControlQuit) then
    FocusNumber := Ord(ControlSource);
  FocusControl := TControl(FocusNumber);
end;

procedure HandleAmountKey(Event: TTUIEvent);
begin
  if Event.KeyCode = TUIKeyBackspace then
  begin
    if AmountCursor > 1 then
    begin
      Delete(AmountText, AmountCursor - 1, 1);
      Dec(AmountCursor);
    end;
    Exit;
  end;
  if Event.KeyCode = TUIKeyDelete then
  begin
    if AmountCursor <= Length(AmountText) then
      Delete(AmountText, AmountCursor, 1);
    Exit;
  end;
  if Event.KeyCode = TUIKeyLeft then
  begin
    if AmountCursor > 1 then
      Dec(AmountCursor);
    Exit;
  end;
  if Event.KeyCode = TUIKeyRight then
  begin
    if AmountCursor <= Length(AmountText) then
      Inc(AmountCursor);
    Exit;
  end;
  if Event.KeyCode = TUIKeyHome then
  begin
    AmountCursor := 1;
    Exit;
  end;
  if Event.KeyCode = TUIKeyEnd then
  begin
    AmountCursor := Length(AmountText) + 1;
    Exit;
  end;
  if (Event.Character >= '0') and (Event.Character <= '9') or
    (Event.Character = '.') or (Event.Character = ',') then
  begin
    if Length(AmountText) < 39 then
    begin
      Insert(Event.Character, AmountText, AmountCursor);
      Inc(AmountCursor);
    end;
  end;
end;

procedure ActivateControl;
begin
  case FocusControl of
    ControlSource: OpenCurrencyPicker(PickerSource);
    ControlDestination: OpenCurrencyPicker(PickerDestination);
    ControlYear: OpenYearPicker;
    ControlAmount: PerformConversion;
    ControlConvert: PerformConversion;
    ControlBack: ResetResult;
    ControlLanguage: OpenLanguageSelector;
    ControlClear: ClearForm;
    ControlQuit: Running := False;
  end;
end;

procedure HandleMainKey(Event: TTUIEvent);
begin
  if FocusControl = ControlAmount then
  begin
    if (Event.KeyCode = TUIKeyBackspace) or
      (Event.KeyCode = TUIKeyDelete) or (Event.KeyCode = TUIKeyLeft) or
      (Event.KeyCode = TUIKeyRight) or (Event.KeyCode = TUIKeyHome) or
      (Event.KeyCode = TUIKeyEnd) or
      ((Event.Character >= '0') and (Event.Character <= '9')) or
      (Event.Character = '.') or (Event.Character = ',') then
    begin
      HandleAmountKey(Event);
      Exit;
    end;
  end;

  if Event.KeyCode = TUIKeyTab then
  begin
    if Event.Shift then
      MoveFocus(-1)
    else
      MoveFocus(1);
    Exit;
  end;
  if Event.KeyCode = TUIKeyUp then
  begin
    MoveFocus(-1);
    Exit;
  end;
  if Event.KeyCode = TUIKeyDown then
  begin
    MoveFocus(1);
    Exit;
  end;
  if Event.KeyCode = TUIKeyLeft then
  begin
    MoveFocus(-1);
    Exit;
  end;
  if Event.KeyCode = TUIKeyRight then
  begin
    MoveFocus(1);
    Exit;
  end;
  if Event.KeyCode = TUIKeyEscape then
  begin
    ResetResult;
    Exit;
  end;
  if (Event.KeyCode = TUIKeyEnter) or (Event.KeyCode = TUIKeySpace) then
  begin
    ActivateControl;
    Exit;
  end;

  { Small number-key shortcuts keep the retro keyboard path quick. }
  case Event.Character of
    '1': begin FocusControl := ControlSource; OpenCurrencyPicker(PickerSource); end;
    '2': begin FocusControl := ControlDestination; OpenCurrencyPicker(PickerDestination); end;
    '3': begin FocusControl := ControlYear; OpenYearPicker; end;
    '4': FocusControl := ControlAmount;
    '5': begin FocusControl := ControlConvert; PerformConversion; end;
    '0': Running := False;
  end;
end;

procedure HandleMainMouse(Event: TTUIEvent);
var
  Control: TControl;
begin
  if RegionContains(LanguageEnglishRegion, Event.X, Event.Y) then
  begin
    ChangeLanguage(LanguageEnglish);
    Exit;
  end;
  if RegionContains(LanguageRussianRegion, Event.X, Event.Y) then
  begin
    ChangeLanguage(LanguageRussian);
    Exit;
  end;
  for Control := ControlSource to ControlQuit do
    if RegionContains(MainRegions[Control], Event.X, Event.Y) then
    begin
      FocusControl := Control;
      if Control = ControlAmount then
      begin
        AmountCursor := Event.X - 5;
        if AmountCursor < 1 then
          AmountCursor := 1;
        if AmountCursor > Length(AmountText) + 1 then
          AmountCursor := Length(AmountText) + 1;
      end;
      if Control <> ControlAmount then
        ActivateControl;
      Exit;
    end;
end;

procedure HandleLanguageKey(Event: TTUIEvent);
begin
  if Event.KeyCode = TUIKeyLeft then
    SelectorChoice := 1
  else if Event.KeyCode = TUIKeyRight then
    SelectorChoice := 2
  else if Event.KeyCode = TUIKeyTab then
  begin
    if SelectorChoice = 1 then
      SelectorChoice := 2
    else
      SelectorChoice := 1;
  end
  else if Event.Character = '1' then
    SelectorChoice := 1
  else if Event.Character = '2' then
    SelectorChoice := 2
  else if Event.KeyCode = TUIKeyEnter then
    ConfirmSelectedLanguage
  else if Event.KeyCode = TUIKeyEscape then
  begin
    if CurrentScreen = ScreenLanguage then
      Running := False;
  end;
end;

procedure HandleLanguageMouse(Event: TTUIEvent);
begin
  if RegionContains(LanguageEnglishRegion, Event.X, Event.Y) then
  begin
    SelectorChoice := 1;
    ConfirmSelectedLanguage;
  end
  else if RegionContains(LanguageRussianRegion, Event.X, Event.Y) then
  begin
    SelectorChoice := 2;
    ConfirmSelectedLanguage;
  end;
end;

procedure HandleCurrencyPickerKey(Event: TTUIEvent);
begin
  if Event.KeyCode = TUIKeyEscape then
  begin
    CurrentScreen := ScreenMain;
    Exit;
  end;
  if Event.KeyCode = TUIKeyEnter then
  begin
    SelectCurrency(PickerSelection);
    Exit;
  end;
  if Event.KeyCode = TUIKeyTab then
  begin
    CurrentScreen := ScreenMain;
    Exit;
  end;
  if Event.KeyCode = TUIKeyUp then
  begin
    if (PickerSelection <= 15) and (PickerSelection > 1) then
      Dec(PickerSelection)
    else if PickerSelection > 16 then
      Dec(PickerSelection);
    Exit;
  end;
  if Event.KeyCode = TUIKeyDown then
  begin
    if (PickerSelection < 15) or
      ((PickerSelection >= 16) and (PickerSelection < CurrencyCount)) then
      Inc(PickerSelection);
    Exit;
  end;
  if Event.KeyCode = TUIKeyLeft then
  begin
    if PickerSelection > 15 then
      Dec(PickerSelection, 15);
    Exit;
  end;
  if Event.KeyCode = TUIKeyRight then
  begin
    if PickerSelection <= 15 then
      Inc(PickerSelection, 15);
    Exit;
  end;
  if Event.KeyCode = TUIKeyPageUp then
  begin
    PickerSelection := PickerSelection - 15;
    if PickerSelection < 1 then
      PickerSelection := 1;
    Exit;
  end;
  if Event.KeyCode = TUIKeyPageDown then
  begin
    PickerSelection := PickerSelection + 15;
    if PickerSelection > CurrencyCount then
      PickerSelection := CurrencyCount;
  end;
end;

procedure HandleCurrencyPickerMouse(Event: TTUIEvent);
var
  Index: Integer;
begin
  if RegionContains(LanguageEnglishRegion, Event.X, Event.Y) then
  begin
    ChangeLanguage(LanguageEnglish);
    Exit;
  end;
  if RegionContains(LanguageRussianRegion, Event.X, Event.Y) then
  begin
    ChangeLanguage(LanguageRussian);
    Exit;
  end;
  if RegionContains(PickerBackRegion, Event.X, Event.Y) then
  begin
    CurrentScreen := ScreenMain;
    Exit;
  end;
  for Index := 1 to CurrencyCount do
    if RegionContains(CurrencyRegions[Index], Event.X, Event.Y) then
    begin
      PickerSelection := Index;
      SelectCurrency(Index);
      Exit;
    end;
end;

procedure HandleYearPickerKey(Event: TTUIEvent);
begin
  if Event.KeyCode = TUIKeyEscape then
  begin
    CurrentScreen := ScreenMain;
    Exit;
  end;
  if Event.KeyCode = TUIKeyEnter then
  begin
    SelectYear(PickerSelection);
    Exit;
  end;
  if Event.KeyCode = TUIKeyTab then
  begin
    CurrentScreen := ScreenMain;
    Exit;
  end;
  if AvailableYearCount = 0 then
    Exit;
  if Event.KeyCode = TUIKeyUp then
  begin
    if PickerSelection > 5 then
      Dec(PickerSelection, 5);
    Exit;
  end;
  if Event.KeyCode = TUIKeyDown then
  begin
    if PickerSelection + 5 <= AvailableYearCount then
      Inc(PickerSelection, 5)
    else
      PickerSelection := AvailableYearCount;
    Exit;
  end;
  if Event.KeyCode = TUIKeyLeft then
  begin
    if PickerSelection > 1 then
      Dec(PickerSelection);
    Exit;
  end;
  if Event.KeyCode = TUIKeyRight then
  begin
    if PickerSelection < AvailableYearCount then
      Inc(PickerSelection);
    Exit;
  end;
  if Event.KeyCode = TUIKeyHome then
    PickerSelection := 1
  else if Event.KeyCode = TUIKeyEnd then
    PickerSelection := AvailableYearCount
  else if Event.KeyCode = TUIKeyPageUp then
  begin
    Dec(PickerSelection, 10);
    if PickerSelection < 1 then
      PickerSelection := 1;
  end
  else if Event.KeyCode = TUIKeyPageDown then
  begin
    Inc(PickerSelection, 10);
    if PickerSelection > AvailableYearCount then
      PickerSelection := AvailableYearCount;
  end;
end;

procedure HandleYearPickerMouse(Event: TTUIEvent);
var
  Index: Integer;
begin
  if RegionContains(LanguageEnglishRegion, Event.X, Event.Y) then
  begin
    ChangeLanguage(LanguageEnglish);
    Exit;
  end;
  if RegionContains(LanguageRussianRegion, Event.X, Event.Y) then
  begin
    ChangeLanguage(LanguageRussian);
    Exit;
  end;
  if RegionContains(PickerBackRegion, Event.X, Event.Y) then
  begin
    CurrentScreen := ScreenMain;
    Exit;
  end;
  for Index := 1 to AvailableYearCount do
    if RegionContains(YearRegions[Index], Event.X, Event.Y) then
    begin
      PickerSelection := Index;
      SelectYear(Index);
      Exit;
    end;
end;

procedure HandleEvent(Event: TTUIEvent);
begin
  if Event.Kind = TUIEventResize then
    Exit;
  case CurrentScreen of
    ScreenLanguage:
      if Event.Kind = TUIEventMouseClick then
        HandleLanguageMouse(Event)
      else if Event.Kind = TUIEventKey then
        HandleLanguageKey(Event);
    ScreenMain:
      if Event.Kind = TUIEventMouseClick then
        HandleMainMouse(Event)
      else if Event.Kind = TUIEventKey then
        HandleMainKey(Event);
    ScreenCurrencyPicker:
      if Event.Kind = TUIEventMouseClick then
        HandleCurrencyPickerMouse(Event)
      else if Event.Kind = TUIEventKey then
        HandleCurrencyPickerKey(Event);
    ScreenYearPicker:
      if Event.Kind = TUIEventMouseClick then
        HandleYearPickerMouse(Event)
      else if Event.Kind = TUIEventKey then
        HandleYearPickerKey(Event);
  end;
end;

procedure RenderSmallConsole;
begin
  ClearTUI;
  WriteTUI(1, 1, LocalizedText(tkTuiSmallConsole1, CurrentLanguage),
    LightRed);
  WriteTUI(1, 2, LocalizedText(tkTuiSmallConsole2, CurrentLanguage), White);
  WriteTUI(1, 3, LocalizedText(tkTuiSmallConsole3, CurrentLanguage), White);
  WriteTUI(1, 5, LocalizedText(tkTuiResizeHint, CurrentLanguage),
    LightCyan);
  SetTUICursorVisible(False);
end;

procedure RenderCurrentScreen;
begin
  if ConsoleTooSmall then
  begin
    RenderSmallConsole;
    Exit;
  end;
  case CurrentScreen of
    ScreenLanguage: RenderLanguageSelector;
    ScreenMain: RenderMain;
    ScreenCurrencyPicker: RenderCurrencyPicker;
    ScreenYearPicker: RenderYearPicker;
  end;
end;

procedure UpdateConsoleSize;
var
  Width: Integer;
  Height: Integer;
begin
  if GetTUIConsoleSize(Width, Height) then
    ConsoleTooSmall := (Width < MinimumConsoleWidth) or
      (Height < MinimumConsoleHeight)
  else
    ConsoleTooSmall := False;
end;

procedure RenderGoodbye;
begin
  if ConsoleTooSmall then
    Exit;
  ClearTUI;
  WriteTUI(1, 1, HorizontalLine, LightCyan);
  WriteTUI(3, 2, FitText(LocalizedText(tkGoodbyeTitle,
    CurrentLanguage), 66), LightCyan);
  WriteTUI(1, 3, HorizontalLine, DarkGray);
  WriteTUI(3, 7, LocalizedText(tkThanks, CurrentLanguage), White);
  WriteTUI(3, 9, LocalizedText(tkClose, CurrentLanguage), DarkGray);
  SetTUICursorVisible(False);
end;

var
  Event: TTUIEvent;
begin
  TextBackground(Black);
  TextColor(White);
  InitializeCurrencies;
  InitializeHistoricalRates;
  ResultSourceIndex := 1;
  ResultDestinationIndex := 2;
  SelectedYear := 2025;
  AmountText := '';
  AmountCursor := 1;
  ResultVisible := False;
  StatusText := '';
  CurrentLanguage := LanguageEnglish;
  CurrentScreen := ScreenLanguage;
  SelectorChoice := 1;
  FocusControl := ControlSource;

  InitializeTUI(MouseAvailable);
  Running := True;
  while Running do
  begin
    UpdateConsoleSize;
    RenderCurrentScreen;
    if ReadTUIEvent(Event) then
    begin
      if ConsoleTooSmall then
      begin
        if (Event.Kind = TUIEventKey) and
          (Event.KeyCode = TUIKeyEscape) then
          Running := False;
      end;
      if not ConsoleTooSmall then
        HandleEvent(Event);
    end;
  end;
  UpdateConsoleSize;
  RenderGoodbye;
  if not ConsoleTooSmall then
    ReadTUIEvent(Event);
  FinalizeTUI;
end.
