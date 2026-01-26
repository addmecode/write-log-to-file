codeunit 50110 "AMC Csv Log File Formatter" implements "AMC Log File Formatter"
{
    var
        StreamHelper: Codeunit "AMC Log File Stream Helper";
        GlobalDelimiter: Text;

    /// <summary>Initializes the formatter for writing a CSV log file.</summary>
    /// <param name="NewLineCharacter">New line character(s) to use between lines.</param>
    /// <param name="Delimiter">Delimiter to use for CSV.</param>
    procedure Initialize(NewLineCharacter: Text; Delimiter: Text)
    begin
        this.StreamHelper.Initialize(NewLineCharacter);
        this.SetDelimiter(Delimiter);
    end;

    local procedure SetDelimiter(Delimiter: Text)
    begin
        if Delimiter <> '' then
            this.GlobalDelimiter := Delimiter
        else
            this.GlobalDelimiter := this.GetDefaultDelimiter();
    end;

    local procedure GetDefaultDelimiter(): Text
    begin
        exit(';');
    end;

    /// <summary>Writes a CSV header row.</summary>
    /// <param name="Columns">Column captions.</param>
    procedure AddHeader(Columns: List of [Text])
    begin
        this.StreamHelper.WriteTextWithNewLine(this.FormatHeader(Columns));
    end;

    /// <summary>Writes a CSV data row.</summary>
    /// <param name="Values">Values to write.</param>
    procedure AddRow(Values: List of [Text])
    begin
        this.StreamHelper.WriteTextWithNewLine(this.FormatRow(Values));
    end;

    /// <summary>Writes raw text followed by a new line.</summary>
    /// <param name="LineText">Line text to write.</param>
    procedure AddPlaneTextWithNewLine(LineText: Text)
    begin
        this.StreamHelper.WriteTextWithNewLine(LineText);
    end;

    /// <summary>Writes raw text without a trailing new line.</summary>
    /// <param name="LineText">Line text to write.</param>
    procedure AddPlaneTextWithoutNewLine(LineText: Text)
    begin
        this.StreamHelper.WriteTextWithoutNewLine(LineText);
    end;

    /// <summary>Downloads the CSV file to the user.</summary>
    /// <param name="FileName">File name without extension or with a custom extension.</param>
    procedure Download(FileName: Text)
    begin
        this.StreamHelper.Download(FileName, this.GetFileExtension());
    end;

    /// <summary>Creates an instream with the current CSV content.</summary>
    /// <param name="InStream">Resulting instream.</param>
    procedure CreateInStream(var InStream: InStream)
    begin
        this.StreamHelper.CreateInStream(InStream);
    end;

    local procedure FormatHeader(Columns: List of [Text]): Text
    begin
        exit(this.FormatValues(Columns));
    end;

    local procedure FormatRow(Values: List of [Text]): Text
    begin
        exit(this.FormatValues(Values));
    end;

    local procedure GetFileExtension(): Text
    begin
        exit('csv');
    end;

    local procedure FormatValues(Values: List of [Text]): Text
    var
        First: Boolean;
        Result: Text;
        Value: Text;
    begin
        First := true;
        foreach Value in Values do begin
            if not First then
                Result += this.GlobalDelimiter;
            Result += this.EscapeValue(Value, this.GlobalDelimiter);
            First := false;
        end;

        exit(Result);
    end;

    local procedure EscapeValue(Value: Text; Delimiter: Text): Text
    var
        NeedsQuotes: Boolean;
    begin
        NeedsQuotes := (StrPos(Value, Delimiter) > 0) or (StrPos(Value, '"') > 0);
        Value := Value.Replace('"', '""');
        if NeedsQuotes then
            exit('"' + Value + '"');

        exit(Value);
    end;
}
