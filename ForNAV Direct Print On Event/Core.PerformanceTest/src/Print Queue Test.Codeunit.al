namespace BradFullwood.ForNAV.PerformanceTest;

using System.Tooling;

/// <summary>
/// BJF test for QueuePrintLabels performance.
/// Simulates high-volume label printing operations.
/// </summary>
codeunit 77820 "BJF Print Queue Test" implements "BCPT Test Param. Provider"
{
    InherentPermissions = x;

    trigger OnRun()
    begin
        this.InitTest();
        this.QueuePrintLabels();
    end;

    var
        BJFTestContext: Codeunit "BCPT Test Context";
        LabelGroupCode: Code[50];
        EventCode: Code[50];
        LabelGroupParamLbl: Label 'Label Group Code';
        EventParamLbl: Label 'Event Code';
        ParamValidationErr: Label 'Parameters not defined correctly. Expected format: "%1,%2"', Comment = '%1 = Label Group Param, %2 = Event Param';

    local procedure InitTest()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        LabelGroup: Record "BJF Label Groups";
        EventRec: Record "BJF Event";
        AutoPrinting: Record "BJF Automatic Printing";
        Provider: Record "BJF Provider";
        Dataset: Record "BJF Dataset";
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

        if LabelGroupCode = '' then
            LabelGroupCode := 'BJF_LG';

        if not LabelGroup.Get(LabelGroupCode) then begin
            LabelGroup.Init();
            LabelGroup."No." := LabelGroupCode;
            LabelGroup.Description := 'BJF Test Label Group';
            LabelGroup."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
            LabelGroup.Insert(true);
        end;

        if EventCode = '' then
            EventCode := 'BJF_EV';

        if not EventRec.Get(EventCode) then begin
            EventRec.Init();
            EventRec."No." := EventCode;
            EventRec.Description := 'BJF Test Event';
            EventRec."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
            EventRec.Insert(true);
        end;

        // Create datasets if not exist
        Dataset.SetRange("Provider No.", "BJF Direct Print Provider"::FromInteger(0));
        Dataset.SetRange("Entity Type", "BJF Dataset Entity Type"::"Label Group");
        Dataset.SetRange("Entity Code", LabelGroupCode);
        Dataset.SetRange("Table No.", Database::Customer);
        if Dataset.IsEmpty() then begin
            Dataset.Init();
            Dataset."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
            Dataset."Entity Type" := "BJF Dataset Entity Type"::"Label Group";
            Dataset."Entity Code" := LabelGroupCode;
            Dataset."Table No." := Database::Customer;
            Dataset.Insert(true);
        end;

        Dataset.SetRange("Entity Type", "BJF Dataset Entity Type"::"Event");
        Dataset.SetRange("Entity Code", EventCode);
        if Dataset.IsEmpty() then begin
            Dataset.Init();
            Dataset."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
            Dataset."Entity Type" := "BJF Dataset Entity Type"::"Event";
            Dataset."Entity Code" := EventCode;
            Dataset."Table No." := Database::Customer;
            Dataset.Insert(true);
        end;

        // Create automatic printing if not exists
        AutoPrinting.SetRange("Label Group No.", LabelGroupCode);
        AutoPrinting.SetRange("Event No.", EventCode);
        if AutoPrinting.IsEmpty() then begin
            AutoPrinting.Init();
            AutoPrinting."Label Group No." := LabelGroupCode;
            AutoPrinting."Event No." := EventCode;
            AutoPrinting.Sequence := '1';
            AutoPrinting."Report ID" := Report::"Customer - List";
            AutoPrinting."Qty to Print" := 1;
            AutoPrinting.Insert(true);
        end;
    end;

    local procedure QueuePrintLabels()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        Customer: Record Customer;
        RecRef: RecordRef;
    begin
        // Get random customer
        if Customer.FindSet() then begin
            Customer.Next(BJFTestContext.GetRandom(Customer.Count()));
            RecRef.GetTable(Customer);

            // Queue print labels
            PrintMgmt.QueuePrintLabels(RecRef, LabelGroupCode, EventCode);

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
            LabelGroupCode := CopyStr(Parts.Get(1), 1, 50);

        if Parts.Count() >= 2 then
            EventCode := CopyStr(Parts.Get(2), 1, 50);
    end;

    procedure GetDefaultParameters(): Text[1000]
    begin
        exit(CopyStr(StrSubstNo('%1,%2', 'BJF_LG', 'BJF_EV'), 1, 1000));
    end;

    procedure ValidateParameters(Parameters: Text[1000])
    var
        Parts: List of [Text];
    begin
        Parts := Parameters.Split(',');
        if Parts.Count() < 2 then
            Error(ParamValidationErr, LabelGroupParamLbl, EventParamLbl);
    end;
}
