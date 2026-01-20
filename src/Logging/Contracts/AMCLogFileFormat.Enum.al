enum 50101 "AMC Log File Format" implements "AMC Log File Formatter"
{
    Extensible = true;

    value(0; Csv)
    {
        Caption = 'CSV';
        Implementation = "AMC Log File Formatter" = "AMC Csv Log File Formatter";
    }

    value(1; Text)
    {
        Caption = 'Text';
        Implementation = "AMC Log File Formatter" = "AMC Text Log File Formatter";
    }
}
