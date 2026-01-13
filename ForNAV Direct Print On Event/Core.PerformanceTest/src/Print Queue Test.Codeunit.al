namespace BradFullwood.ForNAV.PerformanceTest;

using System.Tooling;

/// <summary>
/// BJF test for QueuePrintReports performance.
/// Simulates high-volume report printing operations.
/// </summary>
codeunit 77820 "BJF Print Queue Test" implements "BCPT Test Param. Provider"
{
    InherentPermissions = x;

    trigger OnRun()
    begin
        this.InitTest();
        this.QueuePrintReports();
    end;

    var
        BJFTestContext: Codeunit "BCPT Test Context";
        ReportSetCode: Code[50];
        TriggerCode: Code[50];
        ReportSetParamLbl: Label 'Report Set Code';
        TriggerParamLbl: Label 'Trigger Code';
        ParamValidationErr: Label 'Parameters not defined correctly. Expected format: "%1,%2"', Comment = '%1 = Report Set Param, %2 = Trigger Param';

    local procedure InitTest()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        ReportSet: Record "BJF Report Set";
        PrintingTrigger: Record "BJF Printing Trigger";
        AutoPrinting: Record "BJF Automatic Printing";
        Provider: Record "BJF Provider";
        SourceTableMapping: Record "BJF Source Table Mapping";
        Params: Text;
    begin
        // Get parameters
        Params := BJFTestContext.GetParameter('Parameters');
        if Params <> '' then
            this.ParseParameters(Params);

        // Setup test data if not exists
        if not Provider.Get("BJF Direct Print Provider"::FromInteger(0)) then begin
            Provider.Init();
            Provider."No." := "BJF Direct Print Provider"::FromInteger(0);
            Provider.Description := 'BJF Test Provider';
            Provider.Active := true;
            Provider.Insert(true);
        end;

        if ReportSetCode = '' then
            ReportSetCode := 'BJF_RS';

        if not ReportSet.Get(ReportSetCode) then begin
            ReportSet.Init();
            ReportSet."No." := ReportSetCode;
            ReportSet.Description := 'BJF Test Report Set';
            ReportSet."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
            ReportSet.Insert(true);
        end;

        if TriggerCode = '' then
            TriggerCode := 'BJF_TR';

        if not PrintingTrigger.Get(TriggerCode) then begin
            PrintingTrigger.Init();
            PrintingTrigger."No." := TriggerCode;
            PrintingTrigger.Description := 'BJF Test Trigger';
            PrintingTrigger."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
            PrintingTrigger.Insert(true);
        end;

        // Create source table mappings if not exist
        SourceTableMapping.SetRange("Provider No.", "BJF Direct Print Provider"::FromInteger(0));
        SourceTableMapping.SetRange("Mapping Type", "BJF Mapping Type"::"Report Set");
        SourceTableMapping.SetRange("Source Code", ReportSetCode);
        SourceTableMapping.SetRange("Table No.", Database::Customer);
        if SourceTableMapping.IsEmpty() then begin
            SourceTableMapping.Init();
            SourceTableMapping."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
            SourceTableMapping."Mapping Type" := "BJF Mapping Type"::"Report Set";
            SourceTableMapping."Source Code" := ReportSetCode;
            SourceTableMapping."Table No." := Database::Customer;
            SourceTableMapping.Insert(true);
        end;

        SourceTableMapping.SetRange("Mapping Type", "BJF Mapping Type"::"Trigger");
        SourceTableMapping.SetRange("Source Code", TriggerCode);
        if SourceTableMapping.IsEmpty() then begin
            SourceTableMapping.Init();
            SourceTableMapping."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
            SourceTableMapping."Mapping Type" := "BJF Mapping Type"::"Trigger";
            SourceTableMapping."Source Code" := TriggerCode;
            SourceTableMapping."Table No." := Database::Customer;
            SourceTableMapping.Insert(true);
        end;

        // Create automatic printing if not exists
        AutoPrinting.SetRange("Report Set No.", ReportSetCode);
        AutoPrinting.SetRange("Trigger No.", TriggerCode);
        if AutoPrinting.IsEmpty() then begin
            AutoPrinting.Init();
            AutoPrinting."Report Set No." := ReportSetCode;
            AutoPrinting."Trigger No." := TriggerCode;
            AutoPrinting.Sequence := '1';
            AutoPrinting."Report ID" := Report::"Customer - List";
            AutoPrinting."Qty to Print" := 1;
            AutoPrinting.Insert(true);
        end;
    end;

    local procedure QueuePrintReports()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        Customer: Record Customer;
        RecRef: RecordRef;
    begin
        // Get random customer
        if Customer.FindSet() then begin
            Customer.Next(BJFTestContext.GetRandom(Customer.Count()));
            RecRef.GetTable(Customer);

            // Queue print reports
            PrintMgmt.QueuePrintReports(RecRef, ReportSetCode, TriggerCode);

            // Commit to ensure buffer is persisted
            Commit();
        end;
    end;

    local procedure ParseParameters(Params: Text)
    var
        Parts: List of [Text];
        Delimiter: Text;
    begin
        Delimiter := ',';
        Parts := Params.Split(Delimiter);

        if Parts.Count() >= 1 then
            ReportSetCode := CopyStr(Parts.Get(1), 1, 50);

        if Parts.Count() >= 2 then
            TriggerCode := CopyStr(Parts.Get(2), 1, 50);
    end;

    procedure GetDefaultParameters(): Text[1000]
    begin
        exit(CopyStr(StrSubstNo('%1,%2', 'BJF_RS', 'BJF_TR'), 1, 1000));
    end;

    procedure ValidateParameters(Parameters: Text[1000])
    var
        Parts: List of [Text];
    begin
        Parts := Parameters.Split(',');
        if Parts.Count() < 2 then
            Error(ParamValidationErr, ReportSetParamLbl, TriggerParamLbl);
    end;
}
