codeunit 50108 "AMC Log File Formatter Mgt"
{
    /// <summary>Resolves a formatter implementation for the requested format.</summary>
    /// <param name="Format">Log file format.</param>
    /// <returns>The formatter implementation.</returns>
    procedure GetFormatter(Format: Enum "AMC Log File Format"): Interface "AMC Log File Formatter"
    var
        Formatter: Interface "AMC Log File Formatter";
        IsHandled: Boolean;
        UnsupportedFormatErr: Label 'Unsupported log file format: %1.', Comment = '%1 = format';
        CsvLogFileFormatter: Codeunit "AMC Csv Log File Formatter";
        TextLogFileFormatter: Codeunit "AMC Text Log File Formatter";
    begin
        OnResolveFormatter(Format, Formatter, IsHandled);
        if IsHandled then
            exit(Formatter);

        case Format of
            Format::Csv:
                Formatter := CsvLogFileFormatter;
            Format::Text:
                Formatter := TextLogFileFormatter;
            else
                Error(UnsupportedFormatErr, Format);
        end;

        exit(Formatter);
    end;

    /// <summary>Allows extensions to resolve custom log file formatters.</summary>
    /// <param name="Format">Requested log file format.</param>
    /// <param name="Formatter">Resolved formatter implementation.</param>
    /// <param name="IsHandled">Set to true if the format is handled.</param>
    [IntegrationEvent(false, false)]
    procedure OnResolveFormatter(Format: Enum "AMC Log File Format"; var Formatter: Interface "AMC Log File Formatter"; var IsHandled: Boolean)
    begin
    end;
}
