codeunit 50109 "AMC Log File Writer"
{
  var
    LogFileFormatterMgt: Codeunit "AMC Log File Formatter Mgt";
    TempBlob: Codeunit "Temp Blob";
    Formatter: Interface "AMC Log File Formatter";
    OutStream: OutStream;
    IsInitialized: Boolean;
    LineSeparator: Text;
    NotInitializedErr: Label 'Log file writer is not initialized. Call Initialize before adding lines.';

  /// <summary>Initializes the writer with the selected format.</summary>
  /// <param name="Format">Log file format.</param>
  procedure Initialize(Format: Enum "AMC Log File Format")
  begin
    Clear(TempBlob);
    Clear(Formatter);
    Clear(OutStream);
    TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
    Formatter := LogFileFormatterMgt.GetFormatter(Format);
    LineSeparator := '\r\n';
    IsInitialized := true;
  end;

  /// <summary>Writes a header row using the current format.</summary>
  /// <param name="Columns">Column captions.</param>
  procedure AddHeader(Columns: List of [Text])
  var
    LineText: Text;
  begin
    EnsureInitialized();
    LineText := Formatter.FormatHeader(Columns);
    WriteLine(LineText);
  end;

  /// <summary>Writes a data row using the current format.</summary>
  /// <param name="Values">Values to write.</param>
  procedure AddRow(Values: List of [Text])
  var
    LineText: Text;
  begin
    EnsureInitialized();
    LineText := Formatter.FormatRow(Values);
    WriteLine(LineText);
  end;

  /// <summary>Writes a raw line without formatting.</summary>
  /// <param name="LineText">Line text to write.</param>
  procedure AddLine(LineText: Text)
  begin
    EnsureInitialized();
    WriteLine(LineText);
  end;

  /// <summary>Downloads the file to the user with the formatter's extension.</summary>
  /// <param name="FileName">File name without extension or with a custom extension.</param>
  procedure Download(FileName: Text)
  var
    InStream: InStream;
    FullFileName: Text;
  begin
    EnsureInitialized();
    TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
    FullFileName := EnsureExtension(FileName, Formatter.GetFileExtension());
    DownloadFromStream(InStream, '', '', '', FullFileName);
  end;

  /// <summary>Creates an instream with the current file content.</summary>
  /// <param name="InStream">Resulting instream.</param>
  procedure CreateInStream(var InStream: InStream)
  begin
    EnsureInitialized();
    TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
  end;

  local procedure WriteLine(LineText: Text)
  begin
    OutStream.WriteText(LineText);
    OutStream.WriteText(LineSeparator);
  end;

  local procedure EnsureInitialized()
  begin
    if not IsInitialized then
      Error(NotInitializedErr);
  end;

  local procedure EnsureExtension(FileName: Text; Extension: Text): Text
  var
    ExtensionWithDot: Text;
  begin
    if Extension = '' then
      exit(FileName);

    ExtensionWithDot := '.' + Extension;
    if FileName.EndsWith(ExtensionWithDot) then
      exit(FileName);

    exit(FileName + ExtensionWithDot);
  end;
}
