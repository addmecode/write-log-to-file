interface "AMC Log File Formatter"
{
    /// <summary>Initializes the formatter for writing a log file.</summary>
    /// <param name="NewLineCharacter">New line character(s) to use between lines.</param>
    /// <param name="Delimiter">Delimiter used by the formatter when applicable.</param>
    procedure Initialize(NewLineCharacter: Text; Delimiter: Text)

    /// <summary>Writes a header row using the formatter.</summary>
    /// <param name="Columns">Column captions.</param>
    procedure AddHeader(Columns: List of [Text])

    /// <summary>Writes a data row using the formatter.</summary>
    /// <param name="Values">Values to write.</param>
    procedure AddRow(Values: List of [Text])

    /// <summary>Writes raw text followed by a new line.</summary>
    /// <param name="LineText">Line text to write.</param>
    procedure AddPlaneTextWithNewLine(LineText: Text)

    /// <summary>Writes raw text without a trailing new line.</summary>
    /// <param name="LineText">Line text to write.</param>
    procedure AddPlaneTextWithoutNewLine(LineText: Text)

    /// <summary>Downloads the file to the user with the formatter's extension.</summary>
    /// <param name="FileName">File name without extension or with a custom extension.</param>
    procedure Download(FileName: Text)

    /// <summary>Creates an instream with the current file content.</summary>
    /// <param name="InStream">Resulting instream.</param>
    procedure CreateInStream(var InStream: InStream)
}
