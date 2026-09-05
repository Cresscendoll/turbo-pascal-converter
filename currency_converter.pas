program CurrencyConverter;

{$mode TP}
{$codepage utf8}
{$APPTYPE CONSOLE}

{ A deliberately small, offline historical converter in a Turbo Pascal style. }
{ Every embedded value is the number of currency units per one US dollar.     }

uses
  Crt, Windows, Localization, Historical_Rates;

const
  SnapshotDate = '05.09.2026';
  CurrencyCount = 30;
  MaximumAmount = 1.0E15;

type
  TCurrency = record
    Code: String[3];
  end;

var
  Currencies: array[1..CurrencyCount] of TCurrency;

function Utf8CharLength(Value: String; Position: Integer): Integer;
var
  ByteValue: Integer;
  CharacterLength: Integer;
begin
  ByteValue := Ord(Value[Position]);
  if ByteValue < 128 then
    CharacterLength := 1
  else if ByteValue < 224 then
    CharacterLength := 2
  else if ByteValue < 240 then
    CharacterLength := 3
  else
    CharacterLength := 4;

  if Position + CharacterLength - 1 > Length(Value) then
    CharacterLength := 1;
  Utf8CharLength := CharacterLength;
end;

function Utf8VisualLength(Value: String): Integer;
var
  Position: Integer;
  CharacterCount: Integer;
begin
  Position := 1;
  CharacterCount := 0;
  while Position <= Length(Value) do
  begin
    Position := Position + Utf8CharLength(Value, Position);
    Inc(CharacterCount);
  end;
  Utf8VisualLength := CharacterCount;
end;

procedure DeleteLastUtf8Char(var Value: String);
var
  Position: Integer;
begin
  Position := Length(Value);
  while (Position > 1) and (Ord(Value[Position]) >= 128) and
    (Ord(Value[Position]) <= 191) do
    Dec(Position);
  if Position > 0 then
    Delete(Value, Position, Length(Value) - Position + 1);
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

procedure ConfigureUtf8Console;
begin
  { Windows console APIs are used only to make the local Cyrillic UI legible. }
  SetConsoleCP(65001);
  SetConsoleOutputCP(65001);
end;

procedure InitializeCurrencies;
var
  I: Integer;
begin
  for I := 1 to CurrencyCount do
    Currencies[I].Code := CurrencyCode(I);
end;

procedure ShowHeader(SectionName: String; Language: TLanguage);
begin
  ClrScr;
  TextColor(LightCyan);
  WriteLn('+------------------------------------------------------------+');
  WriteLn('| ', FitText(LocalizedText(tkApplicationTitle, Language), 58), ' |');
  WriteLn('| ', FitText(SectionName, 58), ' |');
  WriteLn('+------------------------------------------------------------+');
  TextColor(White);
  WriteLn(LocalizedText(tkSnapshotLabel, Language), ': ', SnapshotDate,
    ' | ', LocalizedText(tkStaticData, Language), ' | ',
    LocalizedText(tkNoNetwork, Language));
  WriteLn(LocalizedText(tkCoverageLabel, Language), ': 1992-2026; ',
    LocalizedText(tkYtdThrough, Language), ' 05.09.2026.');
  WriteLn;
end;

procedure ShowLanguageSelector(Selection: Integer);
begin
  ClrScr;
  TextColor(LightCyan);
  WriteLn('+------------------------------------------------------------+');
  WriteLn('| ', FitText(LocalizedText(tkLanguageSelectorTitle,
    LanguageEnglish), 58), ' |');
  WriteLn('+------------------------------------------------------------+');
  TextColor(White);
  WriteLn;
  if Selection = 1 then
    WriteLn('  < ', LanguageLabel(LanguageEnglish), ' >       ',
      LanguageLabel(LanguageRussian))
  else
    WriteLn('      ', LanguageLabel(LanguageEnglish), '       < ',
      LanguageLabel(LanguageRussian), ' >');
  WriteLn;
  WriteLn('  ', LocalizedText(tkLanguageSelectorHelp, LanguageEnglish));
  WriteLn('  ', LocalizedText(tkLanguageSelectorHelp, LanguageRussian));
end;

procedure SelectLanguage(var Language: TLanguage);
var
  Selection: Integer;
  Key: Char;
begin
  Selection := 1;
  if Language = LanguageRussian then
    Selection := 2;

  repeat
    ShowLanguageSelector(Selection);
    Key := ReadKey;

    { Crt returns an extended-key prefix before arrow scan codes. }
    if (Key = #0) or (Key = #224) then
    begin
      Key := ReadKey;
      case Ord(Key) of
        75: Selection := 1;
        77: Selection := 2;
      end;
    end
    else if Key = '1' then
      Selection := 1
    else if Key = '2' then
      Selection := 2
    else if Key = #13 then
    begin
      if Selection = 1 then
        Language := LanguageEnglish
      else
        Language := LanguageRussian;
      Exit;
    end;
  until False;
end;

function CurrencyLine(Index: Integer; Language: TLanguage): String;
var
  LabelText: String;
begin
  LabelText := NumberText(Index) + '. ' + Currencies[Index].Code + ' ' +
    CurrencyName(Index, Language);
  CurrencyLine := FitText(LabelText, 27);
end;

procedure ShowCurrencies(PauseAtEnd: Boolean; Language: TLanguage);
var
  Row: Integer;
begin
  ShowHeader(LocalizedText(tkCurrenciesTitle, Language), Language);
  WriteLn(LocalizedText(tkCurrencyIntro1, Language));
  WriteLn(LocalizedText(tkCurrencyIntro2, Language));
  WriteLn;
  for Row := 1 to 15 do
    WriteLn(CurrencyLine(Row, Language), '   ',
      CurrencyLine(Row + 15, Language));
  WriteLn;
  WriteLn(LocalizedText(tkCurrencyNote1, Language));
  WriteLn(LocalizedText(tkCurrencyNote2, Language));
  if PauseAtEnd then
  begin
    WriteLn;
    WriteLn(LocalizedText(tkCancelHint, Language));
    WriteLn(LocalizedText(tkPressEnter, Language));
    ReadLn;
  end;
end;

function AskCurrency(Prompt: String; Language: TLanguage;
  var Choice: Integer): Boolean;
var
  Line: String;
  ErrorPosition: Integer;
  Number: Integer;
begin
  repeat
    Write(Prompt);
    ReadLn(Line);
    Line := StripSpaces(Line);
    Number := -1;
    Val(Line, Number, ErrorPosition);

    if (ErrorPosition = 0) and (Number = 0) then
    begin
      Choice := 0;
      AskCurrency := False;
      Exit;
    end;

    if (ErrorPosition = 0) and (Number >= 1) and
      (Number <= CurrencyCount) then
    begin
      Choice := Number;
      AskCurrency := True;
      Exit;
    end;

    WriteLn(LocalizedText(tkInvalidCurrency, Language));
  until False;
end;

function AskAmount(Language: TLanguage; var Amount: Double): Boolean;
var
  Line: String;
  ErrorPosition: Integer;
begin
  repeat
    Write(LocalizedText(tkAmountPrompt, Language));
    ReadLn(Line);
    Line := NormalizeNumber(Line);
    Amount := 0.0;
    Val(Line, Amount, ErrorPosition);

    if (ErrorPosition = 0) and (Amount > 0.0) and
      (Amount <= MaximumAmount) then
    begin
      AskAmount := True;
      Exit;
    end;

    WriteLn(LocalizedText(tkInvalidAmount, Language));
  until False;
end;

function AskMenuChoice(Minimum: Integer; Maximum: Integer;
  Language: TLanguage; var Choice: Integer): Boolean;
var
  Line: String;
  ErrorPosition: Integer;
begin
  Write(LocalizedText(tkSelectPrompt, Language));
  ReadLn(Line);
  Line := StripSpaces(Line);
  Choice := -1;
  Val(Line, Choice, ErrorPosition);
  if ErrorPosition <> 0 then
    Choice := -1;
  AskMenuChoice := (ErrorPosition = 0) and
    (Choice >= Minimum) and (Choice <= Maximum);
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

function AskHistoricalYear(SourceIndex: Integer; DestinationIndex: Integer;
  Language: TLanguage; var Year: Integer): Boolean;
var
  Line: String;
  ErrorPosition: Integer;
begin
  repeat
    Write(LocalizedText(tkYearPrompt, Language));
    ReadLn(Line);
    Line := StripSpaces(Line);
    Year := -1;
    Val(Line, Year, ErrorPosition);

    if (ErrorPosition = 0) and (Year = 0) then
    begin
      AskHistoricalYear := False;
      Exit;
    end;

    if (ErrorPosition = 0) and YearAvailable(SourceIndex, DestinationIndex,
      Year) then
    begin
      AskHistoricalYear := True;
      Exit;
    end;

    WriteLn(LocalizedText(tkUnavailableYear, Language),
      AvailableYearsText(SourceIndex, DestinationIndex));
  until False;
end;

procedure ShowConversionResult(SourceIndex: Integer; DestinationIndex: Integer;
  Year: Integer; Amount: Double; Language: TLanguage);
var
  SourceUnitsPerUSD: Double;
  DestinationUnitsPerUSD: Double;
  SourceKind: Integer;
  DestinationKind: Integer;
  ResultAmount: Double;
begin
  GetHistoricalRate(SourceIndex, Year, SourceUnitsPerUSD, SourceKind);
  GetHistoricalRate(DestinationIndex, Year, DestinationUnitsPerUSD,
    DestinationKind);
  ResultAmount := Amount / SourceUnitsPerUSD * DestinationUnitsPerUSD;

  ShowHeader(LocalizedText(tkResultTitle, Language), Language);
  TextColor(LightGreen);
  WriteLn('+------------------------------------------------------------+');
  WriteLn('| ', FitText(LocalizedText(tkResultWord, Language), 58), ' |');
  WriteLn('+------------------------------------------------------------+');
  TextColor(White);
  WriteLn(LocalizedText(tkYearLabel, Language), ': ', Year);
  WriteLn(DecimalText(Amount), ' ', CurrencyCode(SourceIndex), ' (',
    HistoricalAmountName(SourceIndex, Year, Language), ') = ',
    DecimalText(ResultAmount), ' ', CurrencyCode(DestinationIndex), ' (',
    HistoricalAmountName(DestinationIndex, Year, Language), ')');
  WriteLn;
  WriteLn(LocalizedText(tkPivotSource, Language),
    DecimalText(SourceUnitsPerUSD), ' ', CurrencyCode(SourceIndex));
  WriteLn(LocalizedText(tkPivotDestination, Language),
    DecimalText(DestinationUnitsPerUSD), ' ', CurrencyCode(DestinationIndex));
  WriteLn(LocalizedText(tkSourceUnit, Language), ': ',
    HistoricalUnit(SourceIndex, Year, Language));
  WriteLn(LocalizedText(tkDestinationUnit, Language), ': ',
    HistoricalUnit(DestinationIndex, Year, Language));
  WriteLn(LocalizedText(tkRateType, Language), ':');
  WriteLn('  ', CurrencyCode(SourceIndex), ': ',
    RateKindText(SourceKind, Language));
  WriteLn('  ', CurrencyCode(DestinationIndex), ': ',
    RateKindText(DestinationKind, Language));
  WriteLn;
  TextColor(LightCyan);
  WriteLn(LocalizedText(tkStaticNotice, Language));
  TextColor(White);
end;

procedure ShowHistoricalNotes(Language: TLanguage);
begin
  ShowHeader(LocalizedText(tkNotesTitle, Language), Language);
  WriteLn(LocalizedText(tkNotesRateConvention, Language));
  WriteLn(LocalizedText(tkNotesCalculationModel, Language));
  WriteLn;
  WriteLn(LocalizedText(tkNotesUAH1, Language));
  WriteLn(LocalizedText(tkNotesUAH2, Language));
  WriteLn(LocalizedText(tkNotesNaturalBoundaries, Language));
  WriteLn;
  WriteLn(LocalizedText(tkNotesRedenomTitle, Language));
  WriteLn(LocalizedText(tkNotesRedenom1, Language));
  WriteLn(LocalizedText(tkNotesRedenom2, Language));
  WriteLn(LocalizedText(tkNotesRedenom3, Language));
  WriteLn;
  WriteLn(LocalizedText(tkNotesYtd1, Language));
  WriteLn(LocalizedText(tkNotesYtd2, Language));
  WriteLn(LocalizedText(tkNotesYtd3, Language));
  WriteLn;
  WriteLn(LocalizedText(tkNotesSources, Language));
  WriteLn(LocalizedText(tkPressEnter, Language));
  ReadLn;
end;

procedure ConversionSession(Language: TLanguage);
var
  SourceIndex: Integer;
  DestinationIndex: Integer;
  NextChoice: Integer;
  Year: Integer;
  Amount: Double;
  ContinueSession: Boolean;
begin
  ContinueSession := True;
  while ContinueSession do
  begin
    ShowCurrencies(False, Language);
    WriteLn;
    if not AskCurrency(LocalizedText(tkSourcePrompt, Language), Language,
      SourceIndex) then
      Exit;
    if not AskCurrency(LocalizedText(tkDestinationPrompt, Language), Language,
      DestinationIndex) then
      Exit;

    if CountAvailableYears(SourceIndex, DestinationIndex) = 0 then
    begin
      WriteLn(LocalizedText(tkNoCommonYears, Language));
      WriteLn(LocalizedText(tkReturnMainPrompt, Language));
      ReadLn;
      Exit;
    end;

    ShowHeader(LocalizedText(tkYearTitle, Language), Language);
    WriteLn(LocalizedText(tkPairLabel, Language), ': ',
      CurrencyCode(SourceIndex), ' -> ', CurrencyCode(DestinationIndex));
    WriteLn(LocalizedText(tkAvailableYearsLabel, Language), ': ',
      AvailableYearsText(SourceIndex, DestinationIndex));
    WriteLn(LocalizedText(tkYearInstruction, Language));
    WriteLn;
    if not AskHistoricalYear(SourceIndex, DestinationIndex, Language, Year) then
      Exit;
    if not AskAmount(Language, Amount) then
      Exit;

    ShowConversionResult(SourceIndex, DestinationIndex, Year, Amount, Language);
    WriteLn;
    WriteLn(LocalizedText(tkAnotherConversion, Language));
    WriteLn(LocalizedText(tkReturnMainMenu, Language));
    repeat
      if not AskMenuChoice(1, 2, Language, NextChoice) then
        WriteLn(LocalizedText(tkInvalidRepeatChoice, Language));
    until (NextChoice = 1) or (NextChoice = 2);
    ContinueSession := NextChoice = 1;
  end;
end;

procedure ShowMainMenu(Language: TLanguage);
begin
  ShowHeader(LocalizedText(tkMainMenuTitle, Language), Language);
  WriteLn(LocalizedText(tkMainConvert, Language));
  WriteLn(LocalizedText(tkMainCurrencies, Language));
  WriteLn(LocalizedText(tkMainNotes, Language));
  WriteLn(LocalizedText(tkMainLanguage, Language));
  WriteLn(LocalizedText(tkMainExit, Language));
  WriteLn;
end;

var
  MenuChoice: Integer;
  CurrentLanguage: TLanguage;
begin
  TextBackground(Black);
  TextColor(White);
  ConfigureUtf8Console;
  CurrentLanguage := LanguageEnglish;
  InitializeCurrencies;
  InitializeHistoricalRates;
  SelectLanguage(CurrentLanguage);

  repeat
    ShowMainMenu(CurrentLanguage);
    if not AskMenuChoice(0, 4, CurrentLanguage, MenuChoice) then
    begin
      WriteLn(LocalizedText(tkInvalidMenu, CurrentLanguage));
      WriteLn;
      WriteLn(LocalizedText(tkPressEnter, CurrentLanguage));
      ReadLn;
    end
    else
      case MenuChoice of
        1: ConversionSession(CurrentLanguage);
        2: ShowCurrencies(True, CurrentLanguage);
        3: ShowHistoricalNotes(CurrentLanguage);
        4: SelectLanguage(CurrentLanguage);
      end;
  until MenuChoice = 0;

  ShowHeader(LocalizedText(tkGoodbyeTitle, CurrentLanguage),
    CurrentLanguage);
  WriteLn(LocalizedText(tkThanks, CurrentLanguage));
  WriteLn;
  WriteLn(LocalizedText(tkClose, CurrentLanguage));
  ReadLn;
  TextBackground(Black);
  TextColor(White);
  ClrScr;
end.
