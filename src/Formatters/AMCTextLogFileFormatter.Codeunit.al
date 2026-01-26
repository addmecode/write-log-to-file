codeunit 50111 "AMC Text Log File Formatter" implements "AMC Log File Formatter"
{
    /// <summary>Formats the header row as plain text.</summary>
    /// <param name="Columns">Column captions.</param>
    /// <returns>The header line.</returns>
    procedure FormatHeader(Columns: List of [Text]): Text
    begin
        exit(JoinValues(Columns));
    end;

    /// <summary>Formats a data row as plain text.</summary>
    /// <param name="Values">Values to write.</param>
    /// <returns>The row line.</returns>
    procedure FormatRow(Values: List of [Text]): Text
    begin
        exit(JoinValues(Values));
    end;

    /// <summary>Gets the TXT file extension.</summary>
    /// <returns>File extension.</returns>
    procedure GetFileExtension(): Text
    begin
        exit('txt');
    end;

    local procedure JoinValues(Values: List of [Text]): Text
    var
        First: Boolean;
        Result: Text;
        Separator: Text;
        Value: Text;
    begin
        Separator := ' | ';
        First := true;
        foreach Value in Values do begin
            if not First then
                Result += Separator;
            Result += Value;
            First := false;
        end;

        exit(Result);
    end;
}
