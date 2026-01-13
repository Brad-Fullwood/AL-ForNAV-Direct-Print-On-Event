namespace BradFullwood.ForNAV.PerformanceTest;

using System.Tooling;

/// <summary>
/// BJF test for mixed print management operations.
/// Simulates realistic usage patterns with queue, process, and cleanup operations.
/// </summary>
codeunit 77823 "BJF Print Management Test" implements "BCPT Test Param. Provider"
{
    InherentPermissions = x;

    trigger OnRun()
    begin
        this.InitTest();
        this.ExecuteMixedOperations();
    end;

    var
        BJFTestContext: Codeunit "BCPT Test Context";
        OperationMix: Text[30];
        OperationMixParamLbl: Label 'Operation Mix';
        ParamValidationErr: Label 'Parameter not defined correctly. Expected format: "%1=queue/process/cleanup"', Comment = '%1 = Parameter Label';

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
            OperationMix := CopyStr(Params, 1, 30)
        else
            OperationMix := 'queue'; // Default to queue operation

        // Setup test data if not exists
        if not Provider.Get("BJF Direct Print Provider"::FromInteger(0)) then begin
            Provider.Init();
            Provider."No." := "BJF Direct Print Provider"::FromInteger(0);
            Provider.Description := 'BJF Test Provider';
            Provider.Active := true;
            Provider.Insert(true);
        end;

        if not ReportSet.Get('BJF_MIX') then begin
            ReportSet.Init();
            ReportSet."No." := 'BJF_MIX';
            ReportSet.Description := 'BJF Mixed Operations';
            ReportSet."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
            ReportSet.Insert(true);
        end;

        if not PrintingTrigger.Get('BJF_MIX_TR') then begin
            PrintingTrigger.Init();
            PrintingTrigger."No." := 'BJF_MIX_TR';
            PrintingTrigger.Description := 'BJF Mixed Trigger';
            PrintingTrigger."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
            PrintingTrigger.Insert(true);
        end;

        // Create source table mappings
        SourceTableMapping.SetRange("Provider No.", "BJF Direct Print Provider"::FromInteger(0));
        SourceTableMapping.SetRange("Mapping Type", "BJF Mapping Type"::"Report Set");
        SourceTableMapping.SetRange("Source Code", 'BJF_MIX');
        if SourceTableMapping.IsEmpty() then begin
            SourceTableMapping.Init();
            SourceTableMapping."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
            SourceTableMapping."Mapping Type" := "BJF Mapping Type"::"Report Set";
            SourceTableMapping."Source Code" := 'BJF_MIX';
            SourceTableMapping."Table No." := Database::Customer;
            SourceTableMapping.Insert(true);

            SourceTableMapping.Init();
            SourceTableMapping."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
            SourceTableMapping."Mapping Type" := "BJF Mapping Type"::"Trigger";
            SourceTableMapping."Source Code" := 'BJF_MIX_TR';
            SourceTableMapping."Table No." := Database::Customer;
            SourceTableMapping.Insert(true);
        end;

        // Create automatic printing
        AutoPrinting.SetRange("Report Set No.", 'BJF_MIX');
        AutoPrinting.SetRange("Trigger No.", 'BJF_MIX_TR');
        if AutoPrinting.IsEmpty() then begin
            AutoPrinting.Init();
            AutoPrinting."Report Set No." := 'BJF_MIX';
            AutoPrinting."Trigger No." := 'BJF_MIX_TR';
            AutoPrinting.Sequence := '1';
            AutoPrinting."Report ID" := Report::"Customer - List";
            AutoPrinting."Qty to Print" := 1;
            AutoPrinting.Insert(true);
        end;

        Commit();
    end;

    local procedure ExecuteMixedOperations()
    begin
        case LowerCase(OperationMix) of
            'queue':
                this.QueueOperation();
            'process':
                this.ProcessOperation();
            'cleanup':
                this.CleanupOperation();
            else
                this.QueueOperation(); // Default
        end;
    end;

    local procedure QueueOperation()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        Customer: Record Customer;
        RecRef: RecordRef;
    begin
        if Customer.FindSet() then begin
            Customer.Next(BJFTestContext.GetRandom(Customer.Count()));
            RecRef.GetTable(Customer);
            PrintMgmt.QueuePrintReports(RecRef, 'BJF_MIX', 'BJF_MIX_TR');
            Commit();
        end;
    end;

    local procedure ProcessOperation()
    var
        PrintBuffer: Record "BJF Print Buffer";
    begin
        PrintBuffer.SetRange(Status, "BJF Print Buffer Status"::Pending);
        if PrintBuffer.FindFirst() then begin
            PrintBuffer.Status := "BJF Print Buffer Status"::Processing;
            PrintBuffer.Modify(false);

            PrintBuffer.Status := "BJF Print Buffer Status"::Completed;
            PrintBuffer."Processed Date Time" := CurrentDateTime();
            PrintBuffer.Modify(false);

            Commit();
        end;
    end;

    local procedure CleanupOperation()
    var
        PrintBuffer: Record "BJF Print Buffer";
        DaysOld: Integer;
    begin
        DaysOld := 7;

        // Mark old completed/failed records for deletion
        PrintBuffer.SetFilter(Status, '%1|%2', "BJF Print Buffer Status"::Completed, "BJF Print Buffer Status"::Failed);
        PrintBuffer.SetFilter("Created Date Time", '<%1', CreateDateTime(CalcDate(StrSubstNo('-%1D', DaysOld), Today()), 0T));

        if PrintBuffer.FindSet(true) then
            repeat
                PrintBuffer.Delete(false);
            until PrintBuffer.Next() = 0;

        Commit();
    end;

    procedure GetDefaultParameters(): Text[1000]
    begin
        exit('queue');
    end;

    procedure ValidateParameters(Parameters: Text[1000])
    var
        ValidOperations: List of [Text];
    begin
        ValidOperations.Add('queue');
        ValidOperations.Add('process');
        ValidOperations.Add('cleanup');

        if not ValidOperations.Contains(LowerCase(Parameters)) then
            Error(ParamValidationErr, OperationMixParamLbl);
    end;
}
