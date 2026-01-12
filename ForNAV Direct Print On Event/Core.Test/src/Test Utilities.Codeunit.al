namespace BradFullwood.ForNAV.Tests;

/// <summary>
/// Test utilities codeunit for Core extension tests.
/// Provides helper methods for test data creation and common assertions.
/// </summary>
codeunit 77807 "BJF Test Utilities"
{
    Access = Internal;
    Permissions = tabledata "BJF Provider" = RIMD,
                 tabledata "BJF Label Groups" = RIMD,
                 tabledata "BJF Event" = RIMD,
                 tabledata "BJF Dataset" = RIMD,
                 tabledata "BJF Automatic Printing" = RIMD,
                 tabledata "BJF Print Buffer" = RIMD;

    var
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;

    /// <summary>
    /// Prepares test data for label group and event.
    /// </summary>
    /// <param name="LabelGroupCode">The code of the label group to create.</param>
    /// <param name="EventCode">The code of the event to create.</param>
    /// <param name="LabelGroup">The label group record to create.</param>
    /// <param name="EventRec">The event record to create.</param>
    procedure PrepareLabelTestData(var LabelGroupCode: Code[50]; var EventCode: Code[50]; LabelGroup: Record "BJF Label Groups"; EventRec: Record "BJF Event")
    begin
        LabelGroupCode := this.GenerateRandomCode('LG');
        EventCode := this.GenerateRandomCode('EV');
        LabelGroup := this.CreateTestLabelGroup(LabelGroupCode, 'Test Label', "BJF Direct Print Provider".FromInteger(0));
        EventRec := this.CreateTestEvent(EventCode, 'Test Event', "BJF Direct Print Provider".FromInteger(0));
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
    /// Creates a test label group.
    /// </summary>
    procedure CreateTestLabelGroup(LabelGroupNo: Code[50]; Description: Text[100]; ProviderNo: Enum "BJF Direct Print Provider"): Record "BJF Label Groups"
    var
        LabelGroup: Record "BJF Label Groups";
    begin
        LabelGroup.Init();
        LabelGroup."No." := LabelGroupNo;
        LabelGroup.Description := Description;
        LabelGroup."Provider No." := ProviderNo;
        LabelGroup.Insert(true);
        exit(LabelGroup);
    end;

    /// <summary>
    /// Creates a test event.
    /// </summary>
    procedure CreateTestEvent(EventNo: Code[50]; Description: Text[50]; ProviderNo: Enum "BJF Direct Print Provider"): Record "BJF Event"
    var
        EventRec: Record "BJF Event";
    begin
        EventRec.Init();
        EventRec."No." := EventNo;
        EventRec.Description := Description;
        EventRec."Provider No." := ProviderNo;
        EventRec.Insert(true);
        exit(EventRec);
    end;

    /// <summary>
    /// Creates a test dataset entry.
    /// </summary>
    procedure CreateTestDataset(ProviderNo: Enum "BJF Direct Print Provider"; EntityType: Enum "BJF Dataset Entity Type"; EntityCode: Code[50]; TableNo: Integer): Record "BJF Dataset"
    var
        Dataset: Record "BJF Dataset";
    begin
        Dataset.Init();
        Dataset."Provider No." := ProviderNo;
        Dataset."Entity Type" := EntityType;
        Dataset."Entity Code" := EntityCode;
        Dataset."Table No." := TableNo;
        Dataset.Insert(true);
        exit(Dataset);
    end;

    /// <summary>
    /// Creates a test automatic printing configuration.
    /// </summary>
    procedure CreateTestAutomaticPrinting(var AutoPrinting: Record "BJF Automatic Printing"; LabelGroupNo: Code[50]; EventNo: Code[50]; Sequence: Code[10]; ReportID: Integer): Record "BJF Automatic Printing"
    begin
        AutoPrinting.Init();
        AutoPrinting."Label Group No." := LabelGroupNo;
        AutoPrinting."Event No." := EventNo;
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
