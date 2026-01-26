interface "AMC Log File Formatter"
{
    /// <summary>Formats the header row for a log file.</summary>
    /// <param name="Columns">Column captions.</param>
    /// <returns>The formatted header line.</returns>
    procedure FormatHeader(Columns: List of [Text]): Text

    /// <summary>Formats a data row for a log file.</summary>
    /// <param name="Values">Values to write.</param>
    /// <returns>The formatted row line.</returns>
    procedure FormatRow(Values: List of [Text]): Text

    /// <summary>Gets the file extension without a dot.</summary>
    /// <returns>The file extension.</returns>
    procedure GetFileExtension(): Text
}
