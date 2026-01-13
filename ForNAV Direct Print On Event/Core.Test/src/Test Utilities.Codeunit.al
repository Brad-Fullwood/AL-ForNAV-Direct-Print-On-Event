namespace BradFullwood.ForNAV.Tests;

using BradFullwood.ForNAV.Core;

/// <summary>
/// Test utilities codeunit for Core extension tests.
/// Provides helper methods for test data creation and common assertions.
/// </summary>
codeunit 77707 "BJF Test Utilities"
{
    Access = Internal;
    Permissions = tabledata "BJF Provider" = RIMD,
                 tabledata "BJF Report Set" = RIMD,
                 tabledata "BJF Printing Trigger" = RIMD,
                 tabledata "BJF Source Table Mapping" = RIMD,
                 tabledata "BJF Automatic Printing" = RIMD,
                 tabledata "BJF Print Buffer" = RIMD;

    var
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;

    /// <summary>
    /// Prepares test data for report set and trigger.
    /// </summary>
    /// <param name="ReportSetCode">The code of the report set to create.</param>
    /// <param name="TriggerCode">The code of the trigger to create.</param>
    /// <param name="ReportSet">The report set record to create.</param>
    /// <param name="PrintingTrigger">The printing trigger record to create.</param>
    procedure PrepareTestData(var ReportSetCode: Code[50]; var TriggerCode: Code[50]; ReportSet: Record "BJF Report Set"; PrintingTrigger: Record "BJF Printing Trigger")
    begin
        ReportSetCode := this.GenerateRandomCode('RS');
        TriggerCode := this.GenerateRandomCode('TR');
        ReportSet := this.CreateTestReportSet(ReportSetCode, 'Test Report Set', "BJF Direct Print Provider".FromInteger(0));
        PrintingTrigger := this.CreateTestTrigger(TriggerCode, 'Test Trigger', "BJF Direct Print Provider".FromInteger(0));
    end;

    /// <summary>
    /// Creates a test provider and returns its enum value.
    /// </summary>
    procedure CreateTestProvider(ProviderNo: Enum "BJF Direct Print Provider"; Description: Text[100]; Active: Boolean): Record "BJF Provider"
    var
        Provider: Record "BJF Provider";
    begin
        Provider.Init();
        Provider."No." := ProviderNo;
        Provider.Description := Description;
        Provider.Active := Active;
        Provider.Insert(true);
        exit(Provider);
    end;

    /// <summary>
    /// Creates a test report set.
    /// </summary>
    procedure CreateTestReportSet(ReportSetNo: Code[50]; Description: Text[100]; ProviderNo: Enum "BJF Direct Print Provider"): Record "BJF Report Set"
    var
        ReportSet: Record "BJF Report Set";
    begin
        ReportSet.Init();
        ReportSet."No." := ReportSetNo;
        ReportSet.Description := Description;
        ReportSet."Provider No." := ProviderNo;
        ReportSet.Insert(true);
        exit(ReportSet);
    end;

    /// <summary>
    /// Creates a test printing trigger.
    /// </summary>
    procedure CreateTestTrigger(TriggerNo: Code[50]; Description: Text[50]; ProviderNo: Enum "BJF Direct Print Provider"): Record "BJF Printing Trigger"
    var
        PrintingTrigger: Record "BJF Printing Trigger";
    begin
        PrintingTrigger.Init();
        PrintingTrigger."No." := TriggerNo;
        PrintingTrigger.Description := Description;
        PrintingTrigger."Provider No." := ProviderNo;
        PrintingTrigger.Insert(true);
        exit(PrintingTrigger);
    end;

    /// <summary>
    /// Creates a test source table mapping entry.
    /// </summary>
    procedure CreateTestSourceTableMapping(ProviderNo: Enum "BJF Direct Print Provider"; MappingType: Enum "BJF Mapping Type"; SourceCode: Code[50]; TableNo: Integer): Record "BJF Source Table Mapping"
    var
        SourceTableMapping: Record "BJF Source Table Mapping";
    begin
        SourceTableMapping.Init();
        SourceTableMapping."Provider No." := ProviderNo;
        SourceTableMapping."Mapping Type" := MappingType;
        SourceTableMapping."Source Code" := SourceCode;
        SourceTableMapping."Table No." := TableNo;
        SourceTableMapping."Source Description" := this.GetSourceDescription(ProviderNo, MappingType, SourceCode);
        SourceTableMapping.Indentation := 1;
        SourceTableMapping.Insert(true);
        exit(SourceTableMapping);
    end;

    local procedure GetSourceDescription(Provider: Enum "BJF Direct Print Provider"; MappingType: Enum "BJF Mapping Type"; SourceCode: Code[50]): Text[250]
    var
        PrintingTrigger: Record "BJF Printing Trigger";
        ReportSet: Record "BJF Report Set";
    begin
        case MappingType of
            Enum::"BJF Mapping Type"::"Trigger":
                begin
                    PrintingTrigger.SetRange("Provider No.", Provider);
                    PrintingTrigger.SetRange("No.", SourceCode);
                    if PrintingTrigger.FindFirst() then
                        exit(PrintingTrigger.Description);
                end;
            Enum::"BJF Mapping Type"::"Report Set":
                begin
                    ReportSet.SetRange("Provider No.", Provider);
                    ReportSet.SetRange("No.", SourceCode);
                    if ReportSet.FindFirst() then
                        exit(ReportSet.Description);
                end;
        end;
        exit('');
    end;

    /// <summary>
    /// Creates a test automatic printing configuration.
    /// </summary>
    procedure CreateTestAutomaticPrinting(var AutoPrinting: Record "BJF Automatic Printing"; ReportSetNo: Code[50]; TriggerNo: Code[50]; Sequence: Code[10]; ReportID: Integer): Record "BJF Automatic Printing"
    begin
        AutoPrinting.Init();
        AutoPrinting."Report Set No." := ReportSetNo;
        AutoPrinting."Trigger No." := TriggerNo;
        AutoPrinting.Sequence := Sequence;
        AutoPrinting."Report ID" := ReportID;
        AutoPrinting."Qty to Print" := 1;
        AutoPrinting.Insert(true);
        exit(AutoPrinting);
    end;

    /// <summary>
    /// Creates a test print buffer entry.
    /// </summary>
    procedure CreateTestPrintBuffer(ReportID: Integer; SourceRecordID: RecordId): Record "BJF Print Buffer"
    var
        PrintBuffer: Record "BJF Print Buffer";
    begin
        PrintBuffer.Init();
        PrintBuffer."Report ID" := ReportID;
        PrintBuffer."Source Record" := SourceRecordID;
        PrintBuffer."Report Caption" := 'Test Report';
        PrintBuffer."Qty to Print" := 1;
        PrintBuffer.Insert(true);
        exit(PrintBuffer);
    end;

    /// <summary>
    /// Generates a random code with prefix.
    /// </summary>
    procedure GenerateRandomCode(Prefix: Text[10]): Code[50]
    begin
        exit(CopyStr(Prefix + Format(Any.IntegerInRange(1000, 9999)), 1, 50));
    end;

    /// <summary>
    /// Gets the Assert library instance.
    /// </summary>
    procedure GetAssert(): Codeunit "Library Assert"
    begin
        exit(Assert);
    end;

    /// <summary>
    /// Gets the Any library instance.
    /// </summary>
    procedure GetAny(): Codeunit Any
    begin
        exit(Any);
    end;
}
