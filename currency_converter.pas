program CurrencyConverter;

{$mode TP}
{$APPTYPE CONSOLE}

{ A deliberately small, offline currency converter in a Turbo Pascal style. }
{ Every rate is UAH per one unit of the listed currency.                  }

uses
  Crt;

const
  ApplicationTitle = 'Turbo Pascal Currency Converter';
  SnapshotDate = '05.09.2026';
  CurrencyCount = 30;
  MaximumAmount = 1.0E12;

type
  TCurrency = record
    Code: String[3];
    Name: String[24];
    RateInUAH: Double;
  end;

var
  Currencies: array[1..CurrencyCount] of TCurrency;

function FitText(Value: String; Width: Integer): String;
begin
  while Length(Value) > Width do
    Delete(Value, Width + 1, Length(Value));
  while Length(Value) < Width do
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
  Str(Value: 0: 2, TextValue);
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

function CurrencyLine(Index: Integer): String;
var
  LabelText: String;
begin
  LabelText := NumberText(Index) + '. ' + Currencies[Index].Code + ' ' +
    Currencies[Index].Name;
  CurrencyLine := FitText(LabelText, 26) + ' ' +
    FitText(DecimalText(Currencies[Index].RateInUAH), 8);
end;

procedure InitializeCurrencies;
begin
  { Official NBU rates dated 05.09.2026, quoted as UAH for one unit. }
  Currencies[1].Code := 'UAH'; Currencies[1].Name := 'Hryvnia';
  Currencies[1].RateInUAH := 1.0;
  Currencies[2].Code := 'USD'; Currencies[2].Name := 'US Dollar';
  Currencies[2].RateInUAH := 44.73;
  Currencies[3].Code := 'EUR'; Currencies[3].Name := 'Euro';
  Currencies[3].RateInUAH := 51.94;
  Currencies[4].Code := 'GBP'; Currencies[4].Name := 'Pound Sterling';
  Currencies[4].RateInUAH := 60.36;
  Currencies[5].Code := 'CHF'; Currencies[5].Name := 'Swiss Franc';
  Currencies[5].RateInUAH := 55.30;
  Currencies[6].Code := 'JPY'; Currencies[6].Name := 'Japanese Yen';
  Currencies[6].RateInUAH := 0.29;
  Currencies[7].Code := 'CNY'; Currencies[7].Name := 'Chinese Yuan';
  Currencies[7].RateInUAH := 6.66;
  Currencies[8].Code := 'CAD'; Currencies[8].Name := 'Canadian Dollar';
  Currencies[8].RateInUAH := 32.43;
  Currencies[9].Code := 'AUD'; Currencies[9].Name := 'Australian Dollar';
  Currencies[9].RateInUAH := 32.17;
  Currencies[10].Code := 'NZD'; Currencies[10].Name := 'New Zealand Dollar';
  Currencies[10].RateInUAH := 26.26;
  Currencies[11].Code := 'PLN'; Currencies[11].Name := 'Polish Zloty';
  Currencies[11].RateInUAH := 12.00;
  Currencies[12].Code := 'CZK'; Currencies[12].Name := 'Czech Koruna';
  Currencies[12].RateInUAH := 2.14;
  Currencies[13].Code := 'HUF'; Currencies[13].Name := 'Hungarian Forint';
  Currencies[13].RateInUAH := 0.14;
  Currencies[14].Code := 'RON'; Currencies[14].Name := 'Romanian Leu';
  Currencies[14].RateInUAH := 9.89;
  { BGN is retained as a legacy conversion after Bulgaria adopted EUR. }
  Currencies[15].Code := 'BGN'; Currencies[15].Name := 'Bulgarian Lev old';
  Currencies[15].RateInUAH := 26.5565003093;
  Currencies[16].Code := 'SEK'; Currencies[16].Name := 'Swedish Krona';
  Currencies[16].RateInUAH := 4.67;
  Currencies[17].Code := 'NOK'; Currencies[17].Name := 'Norwegian Krone';
  Currencies[17].RateInUAH := 4.81;
  Currencies[18].Code := 'DKK'; Currencies[18].Name := 'Danish Krone';
  Currencies[18].RateInUAH := 6.95;
  Currencies[19].Code := 'TRY'; Currencies[19].Name := 'Turkish Lira';
  Currencies[19].RateInUAH := 0.93;
  Currencies[20].Code := 'ILS'; Currencies[20].Name := 'Israeli Shekel';
  Currencies[20].RateInUAH := 14.81;
  Currencies[21].Code := 'AED'; Currencies[21].Name := 'UAE Dirham';
  Currencies[21].RateInUAH := 12.18;
  Currencies[22].Code := 'SAR'; Currencies[22].Name := 'Saudi Riyal';
  Currencies[22].RateInUAH := 11.91;
  Currencies[23].Code := 'INR'; Currencies[23].Name := 'Indian Rupee';
  Currencies[23].RateInUAH := 0.47;
  Currencies[24].Code := 'KRW'; Currencies[24].Name := 'South Korean Won';
  Currencies[24].RateInUAH := 0.03;
  Currencies[25].Code := 'SGD'; Currencies[25].Name := 'Singapore Dollar';
  Currencies[25].RateInUAH := 35.27;
  Currencies[26].Code := 'HKD'; Currencies[26].Name := 'Hong Kong Dollar';
  Currencies[26].RateInUAH := 5.70;
  Currencies[27].Code := 'MXN'; Currencies[27].Name := 'Mexican Peso';
  Currencies[27].RateInUAH := 2.63;
  { BRL is derived from NBU EUR/UAH and ECB BRL/EUR for 04.09.2026. }
  Currencies[28].Code := 'BRL'; Currencies[28].Name := 'Brazilian Real';
  Currencies[28].RateInUAH := 8.7433717701;
  Currencies[29].Code := 'ZAR'; Currencies[29].Name := 'South African Rand';
  Currencies[29].RateInUAH := 2.79;
  Currencies[30].Code := 'THB'; Currencies[30].Name := 'Thai Baht';
  Currencies[30].RateInUAH := 1.36;
end;

procedure ShowHeader(SectionName: String);
begin
  ClrScr;
  TextColor(LightCyan);
  WriteLn('+------------------------------------------------------------+');
  WriteLn('| ', FitText(ApplicationTitle, 58), ' |');
  WriteLn('| ', FitText(SectionName, 58), ' |');
  WriteLn('+------------------------------------------------------------+');
  TextColor(White);
  WriteLn('Snapshot: ', SnapshotDate,
    ' | static rates | no network access');
  WriteLn;
end;

procedure ShowCurrencies;
var
  Row: Integer;
begin
  ShowHeader('Supported currencies');
  WriteLn('Rate column: UAH for 1 unit of the currency.');
  WriteLn;
  for Row := 1 to 15 do
    WriteLn(CurrencyLine(Row), '   ', CurrencyLine(Row + 15));
  WriteLn;
  WriteLn('BGN is shown as a legacy conversion after Bulgaria''s 2026 euro changeover.');
  WriteLn('Press 0 at a currency prompt to return to the main menu.');
  WriteLn;
  WriteLn('Rates are static and do not update automatically.');
  WriteLn;
  Write('Press ENTER to continue...');
  ReadLn;
end;

function AskCurrency(Prompt: String; var Choice: Integer): Boolean;
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

    WriteLn('Invalid currency number. Enter 1 to ', CurrencyCount,
      ', or 0 to cancel.');
  until False;
end;

function AskAmount(var Amount: Double): Boolean;
var
  Line: String;
  ErrorPosition: Integer;
begin
  repeat
    Write('Enter amount (positive, decimal point or comma): ');
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

    WriteLn('Invalid amount. Use a positive number up to 1,000,000,000,000.');
  until False;
end;

function AskMenuChoice(Minimum: Integer; Maximum: Integer;
  var Choice: Integer): Boolean;
var
  Line: String;
  ErrorPosition: Integer;
begin
  Write('Select: ');
  ReadLn(Line);
  Line := StripSpaces(Line);
  Choice := -1;
  Val(Line, Choice, ErrorPosition);
  if ErrorPosition <> 0 then
    Choice := -1;
  AskMenuChoice := (ErrorPosition = 0) and
    (Choice >= Minimum) and (Choice <= Maximum);
end;

procedure ShowConversionResult(SourceIndex: Integer; DestinationIndex: Integer;
  Amount: Double);
var
  ResultAmount: Double;
begin
  ResultAmount := Amount * Currencies[SourceIndex].RateInUAH /
    Currencies[DestinationIndex].RateInUAH;

  WriteLn;
  TextColor(LightGreen);
  WriteLn('+------------------------------------------------------------+');
  WriteLn('| RESULT                                                     |');
  WriteLn('+------------------------------------------------------------+');
  TextColor(White);
  WriteLn(DecimalText(Amount), ' ', Currencies[SourceIndex].Code,
    ' = ', DecimalText(ResultAmount), ' ',
    Currencies[DestinationIndex].Code);
  WriteLn;
  WriteLn('Formula: amount * source UAH rate / destination UAH rate.');
  TextColor(LightCyan);
  WriteLn('Rates are static and do not update automatically.');
  TextColor(White);
end;

procedure ConversionSession;
var
  SourceIndex: Integer;
  DestinationIndex: Integer;
  NextChoice: Integer;
  Amount: Double;
  ContinueSession: Boolean;
begin
  ContinueSession := True;
  while ContinueSession do
  begin
    ShowCurrencies;

    WriteLn;
    if not AskCurrency('Source currency number (0 = main menu): ', SourceIndex) then
      Exit;
    if not AskCurrency('Destination currency number (0 = main menu): ',
      DestinationIndex) then
      Exit;
    if not AskAmount(Amount) then
      Exit;

    ShowConversionResult(SourceIndex, DestinationIndex, Amount);
    WriteLn;
    WriteLn('1. Perform another conversion');
    WriteLn('2. Return to main menu');
    repeat
      if not AskMenuChoice(1, 2, NextChoice) then
        WriteLn('Invalid choice. Enter 1 or 2.');
    until (NextChoice = 1) or (NextChoice = 2);
    ContinueSession := NextChoice = 1;
  end;
end;

procedure ShowAbout;
begin
  ShowHeader('About this experiment');
  WriteLn('A small retro-style converter for modern Windows consoles.');
  WriteLn;
  WriteLn('Compiler: Free Pascal Compiler in Turbo Pascal mode.');
  WriteLn('The executable is native Windows code; DOSBox is not required.');
  WriteLn;
  WriteLn('The exchange-rate snapshot is frozen at ', SnapshotDate, '.');
  WriteLn('The application contains no HTTP, HTTPS, sockets, API calls,');
  WriteLn('downloads, telemetry, or automatic rate updates.');
  WriteLn;
  WriteLn('BGN is retained as a legacy conversion using the fixed');
  WriteLn('1.95583 BGN per EUR changeover rate. BRL uses the latest');
  WriteLn('ECB reference observation available for 04.09.2026.');
  WriteLn;
  WriteLn('Press ENTER to return to the main menu.');
  ReadLn;
end;

procedure ShowMainMenu;
begin
  ShowHeader('Main menu');
  WriteLn('1. Convert currencies');
  WriteLn('2. View supported currencies');
  WriteLn('3. About and rate notes');
  WriteLn('0. Exit');
  WriteLn;
end;

var
  MenuChoice: Integer;
begin
  InitializeCurrencies;
  TextBackground(Black);
  TextColor(White);

  repeat
    ShowMainMenu;
    if not AskMenuChoice(0, 3, MenuChoice) then
    begin
      WriteLn('Invalid menu choice. Enter 0, 1, 2, or 3.');
      WriteLn;
      Write('Press ENTER to try again...');
      ReadLn;
    end
    else
      case MenuChoice of
        1: ConversionSession;
        2: ShowCurrencies;
        3: ShowAbout;
      end;
  until MenuChoice = 0;

  ShowHeader('Goodbye');
  WriteLn('Thank you for using the converter.');
  WriteLn;
  Write('Press ENTER to close the program...');
  ReadLn;
  TextBackground(Black);
  TextColor(White);
  ClrScr;
end.
