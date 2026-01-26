codeunit 50110 "AMC Csv Log File Formatter" implements "AMC Log File Formatter"
{
    /// <summary>Formats the header row as CSV.</summary>
    /// <param name="Columns">Column captions.</param>
    /// <returns>The CSV header line.</returns>
    procedure FormatHeader(Columns: List of [Text]): Text
    begin
        exit(FormatValues(Columns));
    end;

    /// <summary>Formats a data row as CSV.</summary>
    /// <param name="Values">Values to write.</param>
    /// <returns>The CSV row line.</returns>
    procedure FormatRow(Values: List of [Text]): Text
    begin
        exit(FormatValues(Values));
    end;

    /// <summary>Gets the CSV file extension.</summary>
    /// <returns>File extension.</returns>
    procedure GetFileExtension(): Text
    begin
        exit('csv');
    end;

    local procedure FormatValues(Values: List of [Text]): Text
    var
        First: Boolean;
        Result: Text;
        Value: Text;
        Delimiter: Text[1];
    begin
        Delimiter := GetDelimiter();
        First := true;
        foreach Value in Values do begin
            if not First then
                Result += Delimiter;
            Result += EscapeValue(Value, Delimiter);
            First := false;
        end;

        exit(Result);
    end;

    local procedure EscapeValue(Value: Text; Delimiter: Text[1]): Text
    var
        NeedsQuotes: Boolean;
    begin
        NeedsQuotes := (StrPos(Value, Delimiter) > 0) or (StrPos(Value, '"') > 0);
        Value := Value.Replace('"', '""');
        if NeedsQuotes then
            exit('"' + Value + '"');

        exit(Value);
    end;

    local procedure GetDelimiter(): Text[1]
    var
        CsvDelimiter: Text[1];
    begin
        CsvDelimiter := ';';
        OnGetCsvDelimiter(CsvDelimiter);
        if CsvDelimiter = '' then
            CsvDelimiter := ';';

        exit(CsvDelimiter);
    end;

    /// <summary>Allows extensions to override the CSV delimiter.</summary>
    /// <param name="CsvDelimiter">Current delimiter.</param>
    [IntegrationEvent(false, false)]
    procedure OnGetCsvDelimiter(var CsvDelimiter: Text[1])
    begin
    end;
}
