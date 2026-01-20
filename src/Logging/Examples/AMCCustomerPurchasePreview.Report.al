report 50102 "AMC Customer Purchase Preview"
{
    Caption = 'Customer Purchase Preview';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            trigger OnPreDataItem()
            begin
                Customer.SetLoadFields("No.", Name, Blocked);
            end;

            trigger OnAfterGetRecord()
            var
                CustomerAmount: Decimal;
            begin
                CustomerAmount := CalculateCustomerAmount(Customer, StartDate, EndDate);
                if CustomerAmount < MinAmount then
                    HandleCustomer(Customer, CustomerAmount);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    field(StartDate; StartDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Start Date';
                    }
                    field(EndDate; EndDate)
                    {
                        ApplicationArea = All;
                        Caption = 'End Date';
                    }
                    field(MinAmount; MinAmount)
                    {
                        ApplicationArea = All;
                        Caption = 'Minimum Amount';
                    }
                    field(PreviewOnly; PreviewOnly)
                    {
                        ApplicationArea = All;
                        Caption = 'Preview Only';
                    }
                    field(LogFormat; LogFormat)
                    {
                        ApplicationArea = All;
                        Caption = 'Log Format';
                        Visible = PreviewOnly;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            InitializeRequestDefaults();
        end;
    }

    var
        StartDate: Date;
        EndDate: Date;
        MinAmount: Decimal;
        PreviewOnly: Boolean;
        LogFormat: Enum "AMC Log File Format";
        LogFileWriter: Codeunit "AMC Log File Writer";
        HeaderWritten: Boolean;
        BlockedCount: Integer;
        LogFileNameLbl: Label 'CustomerPurchasePreview', Locked = true;
        BlockedCustomersMsg: Label 'Blocked %1 customers based on %2 - %3 purchases.', Comment = '%1 = count, %2 = start date, %3 = end date';

    trigger OnPreReport()
    begin
        if (StartDate = 0D) or (EndDate = 0D) then
            EnsureDateDefaults();

        if PreviewOnly then begin
            LogFileWriter.Initialize(LogFormat);
            AddLogHeader();
        end;
    end;

    trigger OnPostReport()
    begin
        if PreviewOnly then
            LogFileWriter.Download(LogFileNameLbl);

        if (not PreviewOnly) and (BlockedCount > 0) then
            Message(BlockedCustomersMsg, BlockedCount, StartDate, EndDate);
    end;

    local procedure InitializeRequestDefaults()
    var
        DefaultStartDate: Date;
        DefaultEndDate: Date;
    begin
        PreviewOnly := true;
        LogFormat := LogFormat::Csv;
        GetPreviousMonthRange(DefaultStartDate, DefaultEndDate);

        if StartDate = 0D then
            StartDate := DefaultStartDate;
        if EndDate = 0D then
            EndDate := DefaultEndDate;
    end;

    local procedure EnsureDateDefaults()
    var
        DefaultStartDate: Date;
        DefaultEndDate: Date;
    begin
        GetPreviousMonthRange(DefaultStartDate, DefaultEndDate);

        if StartDate = 0D then
            StartDate := DefaultStartDate;
        if EndDate = 0D then
            EndDate := DefaultEndDate;
    end;

    local procedure GetPreviousMonthRange(var FromDate: Date; var ToDate: Date)
    var
        FirstOfThisMonth: Date;
        Year: Integer;
        Month: Integer;
    begin
        Month := Date2DMY(WorkDate(), 2);
        Year := Date2DMY(WorkDate(), 3);
        FirstOfThisMonth := DMY2DATE(1, Month, Year);

        ToDate := CalcDate('<-1D>', FirstOfThisMonth);
        FromDate := DMY2DATE(1, Date2DMY(ToDate, 2), Date2DMY(ToDate, 3));
    end;

    local procedure CalculateCustomerAmount(CustomerRecord: Record Customer; FromDate: Date; ToDate: Date): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Customer No.", CustomerRecord."No.");
        CustLedgerEntry.SetRange("Posting Date", FromDate, ToDate);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetLoadFields("Amount (LCY)");
        CustLedgerEntry.CalcSums("Amount (LCY)");
        exit(CustLedgerEntry."Amount (LCY)");
    end;

    local procedure HandleCustomer(var CustomerRecord: Record Customer; PurchaseAmount: Decimal)
    var
        Values: List of [Text];
    begin
        if PreviewOnly then begin
            Values.Add(CustomerRecord."No.");
            Values.Add(CustomerRecord.Name);
            Values.Add(Format(PurchaseAmount));
            Values.Add(Format(StartDate));
            Values.Add(Format(EndDate));
            LogFileWriter.AddRow(Values);
            exit;
        end;

        if CustomerRecord.Blocked = CustomerRecord.Blocked::" " then begin
            CustomerRecord.Blocked := CustomerRecord.Blocked::All;
            CustomerRecord.Modify(true);
            BlockedCount += 1;
        end;
    end;

    local procedure AddLogHeader()
    var
        Columns: List of [Text];
    begin
        if HeaderWritten then
            exit;

        Columns.Add('Customer No.');
        Columns.Add('Customer Name');
        Columns.Add('Amount (LCY)');
        Columns.Add('Start Date');
        Columns.Add('End Date');
        LogFileWriter.AddHeader(Columns);
        HeaderWritten := true;
    end;
}
