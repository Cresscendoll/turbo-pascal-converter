unit TUI;

{$mode TP}
{$codepage utf8}

interface

const
  TUIWidth = 72;
  TUIHeight = 24;
  MinimumConsoleWidth = 72;
  MinimumConsoleHeight = 24;

  TUIKeyEnter = 13;
  TUIKeyEscape = 27;
  TUIKeyTab = 9;
  TUIKeyBackspace = 8;
  TUIKeyDelete = 46;
  TUIKeyLeft = 37;
  TUIKeyUp = 38;
  TUIKeyRight = 39;
  TUIKeyDown = 40;
  TUIKeyHome = 36;
  TUIKeyEnd = 35;
  TUIKeyPageUp = 33;
  TUIKeyPageDown = 34;
  TUIKeySpace = 32;

type
  TTUIEventKind = (TUIEventNone, TUIEventKey, TUIEventMouseClick,
    TUIEventResize);

  TTUIEvent = record
    Kind: TTUIEventKind;
    KeyCode: Integer;
    Character: Char;
    Shift: Boolean;
    X: Integer;
    Y: Integer;
  end;

  TTUIRegion = record
    X1: Integer;
    Y1: Integer;
    X2: Integer;
    Y2: Integer;
    Action: Integer;
  end;

procedure InitializeTUI(var MouseAvailable: Boolean);
procedure FinalizeTUI;
procedure ClearTUI;
procedure WriteTUI(X: Integer; Y: Integer; Value: String; Color: Byte);
procedure SetTUICursorPosition(X: Integer; Y: Integer);
procedure SetTUICursorVisible(Visible: Boolean);
function GetTUIConsoleSize(var Width: Integer; var Height: Integer): Boolean;
function RegionContains(Region: TTUIRegion; X: Integer; Y: Integer): Boolean;
function ReadTUIEvent(var Event: TTUIEvent): Boolean;

implementation

uses
  Crt, Windows;

const
  KEY_EVENT_RECORD_TYPE = 1;
  MOUSE_EVENT_RECORD_TYPE = 2;
  WINDOW_BUFFER_SIZE_EVENT_TYPE = 4;
  ENABLE_PROCESSED_INPUT_VALUE = $0001;
  ENABLE_WINDOW_INPUT_VALUE = $0008;
  ENABLE_MOUSE_INPUT_VALUE = $0010;
  ENABLE_QUICK_EDIT_MODE_VALUE = $0040;
  ENABLE_EXTENDED_FLAGS_VALUE = $0080;
  FROM_LEFT_1ST_BUTTON_PRESSED_VALUE = $0001;
  DOUBLE_CLICK_EVENT_VALUE = $0002;
  SHIFT_PRESSED_VALUE = $0010;

var
  InputHandle: THandle;
  OutputHandle: THandle;
  InputReady: Boolean;
  OutputReady: Boolean;
  MouseInputEnabled: Boolean;
  SavedInputMode: DWORD;
  SavedInputModeValid: Boolean;
  SavedOutputPosition: TCoord;
  SavedOutputAttributes: WORD;
  SavedOutputStateValid: Boolean;
  SavedCursorInfo: CONSOLE_CURSOR_INFO;
  SavedCursorInfoValid: Boolean;
  SavedInputCodePage: DWORD;
  SavedOutputCodePage: DWORD;
  SavedCodePagesValid: Boolean;

procedure InitializeTUI(var MouseAvailable: Boolean);
var
  NewMode: DWORD;
  OutputMode: DWORD;
  BufferInfo: CONSOLE_SCREEN_BUFFER_INFO;
begin
  InputHandle := GetStdHandle(STD_INPUT_HANDLE);
  OutputHandle := GetStdHandle(STD_OUTPUT_HANDLE);
  InputReady := False;
  OutputReady := False;
  MouseInputEnabled := False;
  SavedInputModeValid := False;
  SavedOutputStateValid := False;
  SavedCursorInfoValid := False;
  SavedCodePagesValid := False;

  OutputReady := GetConsoleMode(OutputHandle, OutputMode);
  if OutputReady and GetConsoleScreenBufferInfo(OutputHandle, BufferInfo) then
  begin
    SavedOutputPosition := BufferInfo.dwCursorPosition;
    SavedOutputAttributes := BufferInfo.wAttributes;
    SavedOutputStateValid := True;
  end;

  SavedInputCodePage := GetConsoleCP;
  SavedOutputCodePage := GetConsoleOutputCP;
  SavedCodePagesValid := (SavedInputCodePage <> 0) and
    (SavedOutputCodePage <> 0);
  SetConsoleCP(65001);
  SetConsoleOutputCP(65001);

  if GetConsoleMode(InputHandle, SavedInputMode) then
  begin
    SavedInputModeValid := True;
    InputReady := True;
    NewMode := (SavedInputMode or ENABLE_EXTENDED_FLAGS_VALUE or
      ENABLE_MOUSE_INPUT_VALUE or ENABLE_WINDOW_INPUT_VALUE) and
      not ENABLE_QUICK_EDIT_MODE_VALUE;
    if SetConsoleMode(InputHandle, NewMode) then
      MouseInputEnabled := True;
  end;

  if GetConsoleCursorInfo(OutputHandle, SavedCursorInfo) then
    SavedCursorInfoValid := True;

  SetTUICursorVisible(False);
  MouseAvailable := MouseInputEnabled;
end;

procedure FinalizeTUI;
begin
  if SavedInputModeValid then
    SetConsoleMode(InputHandle, SavedInputMode);
  if SavedCodePagesValid then
  begin
    SetConsoleCP(SavedInputCodePage);
    SetConsoleOutputCP(SavedOutputCodePage);
  end;
  if SavedOutputStateValid then
  begin
    SetConsoleTextAttribute(OutputHandle, SavedOutputAttributes);
    SetConsoleCursorPosition(OutputHandle, SavedOutputPosition);
  end;
  if SavedCursorInfoValid then
    SetConsoleCursorInfo(OutputHandle, SavedCursorInfo)
  else
    SetTUICursorVisible(True);
  if not OutputReady then
  begin
    TextBackground(Black);
    TextColor(White);
  end;
  InputReady := False;
  OutputReady := False;
  MouseInputEnabled := False;
end;

procedure ClearTUI;
var
  BufferInfo: CONSOLE_SCREEN_BUFFER_INFO;
  Origin: TCoord;
  CellCount: DWORD;
  Written: DWORD;
begin
  if OutputReady and GetConsoleScreenBufferInfo(OutputHandle, BufferInfo) then
  begin
    Origin.X := 0;
    Origin.Y := 0;
    CellCount := DWORD(BufferInfo.dwSize.X) * DWORD(BufferInfo.dwSize.Y);
    FillConsoleOutputCharacterW(OutputHandle, ' ', CellCount, Origin,
      Written);
    FillConsoleOutputAttribute(OutputHandle, Black, CellCount, Origin,
      Written);
    SetConsoleCursorPosition(OutputHandle, Origin);
  end
  else
    ClrScr;
end;

procedure WriteTUI(X: Integer; Y: Integer; Value: String; Color: Byte);
var
  Position: TCoord;
  WideValue: WideString;
  Written: DWORD;
begin
  if (X < 1) or (Y < 1) then
    Exit;
  if OutputReady then
  begin
    Position.X := X - 1;
    Position.Y := Y - 1;
    SetConsoleCursorPosition(OutputHandle, Position);
    SetConsoleTextAttribute(OutputHandle, Color);
    WideValue := WideString(Value);
    WriteConsoleW(OutputHandle, PWideChar(WideValue), Length(WideValue),
      Written, nil);
  end
  else
  begin
    GotoXY(X, Y);
    TextColor(Color);
    Write(Value);
  end;
end;

procedure SetTUICursorPosition(X: Integer; Y: Integer);
var
  Position: TCoord;
begin
  if (X < 1) or (Y < 1) then
    Exit;
  if OutputReady then
  begin
    Position.X := X - 1;
    Position.Y := Y - 1;
    SetConsoleCursorPosition(OutputHandle, Position);
  end
  else
    GotoXY(X, Y);
end;

procedure SetTUICursorVisible(Visible: Boolean);
var
  CursorInfo: CONSOLE_CURSOR_INFO;
begin
  if GetConsoleCursorInfo(OutputHandle, CursorInfo) then
  begin
    CursorInfo.bVisible := Visible;
    SetConsoleCursorInfo(OutputHandle, CursorInfo);
  end;
end;

function GetTUIConsoleSize(var Width: Integer; var Height: Integer): Boolean;
var
  BufferInfo: CONSOLE_SCREEN_BUFFER_INFO;
begin
  GetTUIConsoleSize := False;
  Width := 0;
  Height := 0;
  if not GetConsoleScreenBufferInfo(OutputHandle, BufferInfo) then
    Exit;
  Width := BufferInfo.srWindow.Right - BufferInfo.srWindow.Left + 1;
  Height := BufferInfo.srWindow.Bottom - BufferInfo.srWindow.Top + 1;
  GetTUIConsoleSize := True;
end;

function RegionContains(Region: TTUIRegion; X: Integer; Y: Integer): Boolean;
begin
  RegionContains := (X >= Region.X1) and (X <= Region.X2) and
    (Y >= Region.Y1) and (Y <= Region.Y2);
end;

procedure ClearEvent(var Event: TTUIEvent);
begin
  Event.Kind := TUIEventNone;
  Event.KeyCode := 0;
  Event.Character := #0;
  Event.Shift := False;
  Event.X := 0;
  Event.Y := 0;
end;

procedure TranslateReadKey(Key: Char; var Event: TTUIEvent);
var
  ExtendedKey: Char;
begin
  ClearEvent(Event);
  Event.Kind := TUIEventKey;
  Event.Character := Key;
  Event.KeyCode := Ord(Key);

  if (Key = #0) or (Key = #224) then
  begin
    ExtendedKey := ReadKey;
    Event.Character := #0;
    case Ord(ExtendedKey) of
      75: Event.KeyCode := TUIKeyLeft;
      72: Event.KeyCode := TUIKeyUp;
      77: Event.KeyCode := TUIKeyRight;
      80: Event.KeyCode := TUIKeyDown;
      71: Event.KeyCode := TUIKeyHome;
      79: Event.KeyCode := TUIKeyEnd;
      73: Event.KeyCode := TUIKeyPageUp;
      81: Event.KeyCode := TUIKeyPageDown;
      83: Event.KeyCode := TUIKeyDelete;
      15: begin Event.KeyCode := TUIKeyTab; Event.Shift := True; end;
    else
      Event.KeyCode := 0;
    end;
  end;
end;

function ReadFallbackEvent(var Event: TTUIEvent): Boolean;
var
  Key: Char;
begin
  Key := ReadKey;
  TranslateReadKey(Key, Event);
  ReadFallbackEvent := True;
end;

function ReadConsoleEvent(var Event: TTUIEvent): Boolean;
var
  InputRecord: INPUT_RECORD;
  EventsRead: DWORD;
  KeyCode: Integer;
begin
  ReadConsoleEvent := False;
  repeat
    EventsRead := 0;
    if not ReadConsoleInputA(InputHandle, InputRecord, 1, EventsRead) then
      Exit;
    if EventsRead = 0 then
      Continue;

    ClearEvent(Event);
    if InputRecord.EventType = KEY_EVENT_RECORD_TYPE then
    begin
      if not InputRecord.Event.KeyEvent.bKeyDown then
        Continue;
      Event.Kind := TUIEventKey;
      KeyCode := InputRecord.Event.KeyEvent.wVirtualKeyCode;
      Event.KeyCode := KeyCode;
      Event.Character := InputRecord.Event.KeyEvent.AsciiChar;
      Event.Shift := (InputRecord.Event.KeyEvent.dwControlKeyState and
        SHIFT_PRESSED_VALUE) <> 0;
      if (Event.Character = #0) and
        (Ord(InputRecord.Event.KeyEvent.UnicodeChar) < 128) then
        Event.Character := Char(Ord(InputRecord.Event.KeyEvent.UnicodeChar));
      ReadConsoleEvent := True;
      Exit;
    end;

    if InputRecord.EventType = MOUSE_EVENT_RECORD_TYPE then
    begin
      if (((InputRecord.Event.MouseEvent.dwEventFlags = 0) or
        (InputRecord.Event.MouseEvent.dwEventFlags = DOUBLE_CLICK_EVENT_VALUE)) and
        ((InputRecord.Event.MouseEvent.dwButtonState and
        FROM_LEFT_1ST_BUTTON_PRESSED_VALUE) <> 0)) then
      begin
        Event.Kind := TUIEventMouseClick;
        Event.X := InputRecord.Event.MouseEvent.dwMousePosition.X + 1;
        Event.Y := InputRecord.Event.MouseEvent.dwMousePosition.Y + 1;
        ReadConsoleEvent := True;
        Exit;
      end;
      Continue;
    end;

    if InputRecord.EventType = WINDOW_BUFFER_SIZE_EVENT_TYPE then
    begin
      Event.Kind := TUIEventResize;
      ReadConsoleEvent := True;
      Exit;
    end;
  until False;
end;

function ReadTUIEvent(var Event: TTUIEvent): Boolean;
var
  Success: Boolean;
begin
  if InputReady then
  begin
    Success := ReadConsoleEvent(Event);
    if not Success then
      Success := ReadFallbackEvent(Event);
  end
  else
    Success := ReadFallbackEvent(Event);
  ReadTUIEvent := Success;
end;

end.
