report 50102 "AMC Customer Purchase Preview"
{
    ApplicationArea = All;
    Caption = 'Customer Purchase Preview';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;

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
            area(Content)
            {
                group(Options)
                {
                    field(StartDateField; StartDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Start Date';
                        ToolTip = 'Specifies the value of the Start Date field.';
                    }
                    field(EndDateField; EndDate)
                    {
                        ApplicationArea = All;
                        Caption = 'End Date';
                        ToolTip = 'Specifies the value of the End Date field.';
                    }
                    field(MinAmountField; MinAmount)
                    {
                        ApplicationArea = All;
                        Caption = 'Minimum Amount';
                        ToolTip = 'Specifies the value of the Minimum Amount field.';
                    }
                    field(PreviewOnlyField; PreviewOnly)
                    {
                        ApplicationArea = All;
                        Caption = 'Preview Only';
                        ToolTip = 'Specifies the value of the Preview Only field.';
                    }
                    field(LogFormatField; LogFormat)
                    {
                        ApplicationArea = All;
                        Caption = 'Log Format';
                        ToolTip = 'Specifies the value of the Log Format field.';
                        Enabled = PreviewOnly;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            InitializeRequestDefaults();
        end;
    }

    trigger OnPreReport()
    begin
        if (StartDate = 0D) or (EndDate = 0D) then
            EnsureDateDefaults();

        if PreviewOnly then begin
            LogFileFormatter := LogFormat;
            LogFileFormatter.Initialize('', '');
            AddLogHeader();
        end;
    end;

    trigger OnPostReport()
    var
        BlockedCustomersMsg: Label 'Blocked %1 customers based on %2 - %3 purchases.', Comment = '%1 = count, %2 = start date, %3 = end date';
        LogFileNameLbl: Label 'CustomerPurchasePreview', Locked = true;
    begin
        if PreviewOnly then
            LogFileFormatter.Download(LogFileNameLbl);

        if (not PreviewOnly) and (BlockedCount > 0) then
            Message(BlockedCustomersMsg, BlockedCount, StartDate, EndDate);
    end;

    var
        PreviewOnly: Boolean;
        EndDate: Date;
        StartDate: Date;
        MinAmount: Decimal;
        LogFormat: Enum "AMC Log File Format";
        BlockedCount: Integer;
        LogFileFormatter: Interface "AMC Log File Formatter";

    local procedure EnsureDateDefaults()
    var
        DefaultEndDate: Date;
        DefaultStartDate: Date;
    begin
        if (StartDate <> 0D) and (EndDate <> 0D) then
            exit;
        GetPreviousMonthRange(DefaultStartDate, DefaultEndDate);

        if StartDate = 0D then
            StartDate := DefaultStartDate;
        if EndDate = 0D then
            EndDate := DefaultEndDate;
    end;

    local procedure GetPreviousMonthRange(var FromDate: Date; var ToDate: Date)
    begin
        ToDate := CalcDate('<-CM-1D>', WorkDate());
        FromDate := CalcDate('<-CM>', ToDate);
    end;

    local procedure AddLogHeader()
    var
        Columns: List of [Text];
    begin
        Columns.Add('Customer No.');
        Columns.Add('Customer Name');
        Columns.Add('Amount (LCY)');
        Columns.Add('Start Date');
        Columns.Add('End Date');
        LogFileFormatter.AddHeader(Columns);
    end;

    local procedure InitializeRequestDefaults()
    begin
        PreviewOnly := true;
        LogFormat := LogFormat::Csv;
        GetPreviousMonthRange(StartDate, EndDate);
    end;

    local procedure CalculateCustomerAmount(CustomerRecord: Record Customer; FromDate: Date; ToDate: Date): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        AmountSum: Decimal;
    begin
        CustLedgerEntry.SetRange("Customer No.", CustomerRecord."No.");
        CustLedgerEntry.SetRange("Posting Date", FromDate, ToDate);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetAutoCalcFields("Amount (LCY)");
        if CustLedgerEntry.FindSet() then
            repeat
                AmountSum += CustLedgerEntry."Amount (LCY)";
            until CustLedgerEntry.Next() = 0;

        exit(AmountSum);
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
            LogFileFormatter.AddRow(Values);
            exit;
        end;

        if CustomerRecord.Blocked = CustomerRecord.Blocked::" " then begin
            CustomerRecord.Blocked := CustomerRecord.Blocked::All;
            CustomerRecord.Modify(true);
            BlockedCount += 1;
        end;
    end;
}
