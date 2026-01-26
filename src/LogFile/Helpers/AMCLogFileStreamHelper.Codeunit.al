codeunit 50112 "AMC Log File Stream Helper"
{
    var
        TempBlob: Codeunit "Temp Blob";
        IsInitialized: Boolean;
        OutStream: OutStream;
        GlobalNewLineCharacter: Text;

    /// <summary>Initializes the helper for writing a log file.</summary>
    /// <param name="NewLineCharacter">New line character(s) to use between lines.</param>
    procedure Initialize(NewLineCharacter: Text)
    begin
        Clear(this.TempBlob);
        Clear(this.OutStream);
        this.TempBlob.CreateOutStream(this.OutStream, TextEncoding::UTF8);
        this.SetLineCharacter(NewLineCharacter);
        this.IsInitialized := true;
    end;

    local procedure SetLineCharacter(NewLineCharacter: Text)
    begin
        if NewLineCharacter <> '' then
            this.GlobalNewLineCharacter := NewLineCharacter
        else
            this.GlobalNewLineCharacter := this.GetDefaultNewLineChar();
    end;

    local procedure GetDefaultNewLineChar(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.NewLine());
    end;

    /// <summary>Writes a line to the outstream including the line separator.</summary>
    /// <param name="LineText">Line text to write.</param>
    procedure WriteTextWithNewLine(LineText: Text)
    begin
        this.WriteTextWithoutNewLine(LineText);
        this.OutStream.WriteText(this.GlobalNewLineCharacter);
    end;

    /// <summary>Writes text to the outstream without a line separator.</summary>
    /// <param name="TextToWrite">Text to write.</param>
    procedure WriteTextWithoutNewLine(TextToWrite: Text)
    begin
        this.EnsureInitialized();
        this.OutStream.WriteText(TextToWrite);
    end;

    /// <summary>Creates an instream from the temp blob using UTF-8 encoding.</summary>
    /// <param name="InStream">Resulting instream.</param>
    procedure CreateInStream(var InStream: InStream)
    begin
        this.EnsureInitialized();
        this.TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
    end;

    /// <summary>Downloads the file to the user with the provided extension.</summary>
    /// <param name="FileName">File name without extension or with a custom extension.</param>
    /// <param name="Extension">File extension without a dot.</param>
    procedure Download(FileName: Text; Extension: Text)
    var
        InStream: InStream;
        FullFileName: Text;
    begin
        this.CreateInStream(InStream);
        FullFileName := this.EnsureExtension(FileName, Extension);
        DownloadFromStream(InStream, '', '', '', FullFileName);
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

    local procedure EnsureInitialized()
    var
        NotInitializedErr: Label 'Log file formatter is not initialized. Call Initialize before adding lines.';
    begin
        if not this.IsInitialized then
            Error(NotInitializedErr);
    end;
}
