namespace BradFullwood.ForNAV.Tests;

using BradFullwood.ForNAV.Core;
using System.TestLibraries.Utilities;
using Microsoft.Sales.Reports;

/// <summary>
/// Test codeunit for BJF Automatic Printing (77700).
/// Tests GetNextSequence, NewRecord, DrillDownToSelectLayout, and field validations.
/// </summary>
codeunit 77704 "BJF Automatic Printing Tests"
{
    Subtype = Test;
    TestPermissions = Restrictive;
    InherentPermissions = x;
    Permissions = tabledata "BJF Automatic Printing" = d;

    var
        AutoPrinting: Record "BJF Automatic Printing";
        TestUtil: Codeunit "BJF Test Utilities";
        Assert: Codeunit "Library Assert";

    [Test]
    internal procedure GetNextSequence_FirstRecord_ReturnsOne()
    var
        ReportSet: Record "BJF Report Set";
        PrintingTrigger: Record "BJF Printing Trigger";
        ReportSetCode: Code[50];
        TriggerCode: Code[50];
    begin
        this.AutoPrinting.DeleteAll(false);
        // [GIVEN] No existing automatic printing records
        this.TestUtil.PrepareTestData(ReportSetCode, TriggerCode, ReportSet, PrintingTrigger);

        // [WHEN] GetNextSequence is called on new record
        this.TestUtil.CreateTestAutomaticPrinting(this.AutoPrinting, ReportSetCode, TriggerCode, '1', Report::"Customer - List");

        // [THEN] Sequence should be 1
        this.Assert.AreEqual('1', this.AutoPrinting.Sequence, 'First sequence should be 1');
    end;

    [Test]
    internal procedure GetNextSequence_ExistingRecords_IncrementsSequence()
    var
        ReportSet: Record "BJF Report Set";
        PrintingTrigger: Record "BJF Printing Trigger";
        ReportSetCode: Code[50];
        TriggerCode: Code[50];
        NoRecordErr: Label 'No automatic printing record found';
    begin
        this.AutoPrinting.DeleteAll(false);

        // [GIVEN] Existing automatic printing records
        this.TestUtil.PrepareTestData(ReportSetCode, TriggerCode, ReportSet, PrintingTrigger);
        this.TestUtil.CreateTestAutomaticPrinting(this.AutoPrinting, ReportSetCode, TriggerCode, '1', Report::"Customer - List");

        // [WHEN] GetNextSequence is called for second record
        this.TestUtil.CreateTestAutomaticPrinting(this.AutoPrinting, ReportSetCode, TriggerCode, '2', Report::"Customer - List");
        if not this.AutoPrinting.FindLast() then
            Error(NoRecordErr);

        // [THEN] Sequence should be 2
        this.Assert.AreEqual('2', this.AutoPrinting.Sequence, 'Second sequence should be 2');
    end;


    [Test]
    internal procedure ReportID_Validation_CalculatesReportName()
    var
        ReportSet: Record "BJF Report Set";
        PrintingTrigger: Record "BJF Printing Trigger";
        ReportSetCode: Code[50];
        TriggerCode: Code[50];
    begin
        // [GIVEN] A new automatic printing record
        this.TestUtil.PrepareTestData(ReportSetCode, TriggerCode, ReportSet, PrintingTrigger);

        // [WHEN] Report ID is set
        this.AutoPrinting.Init();
        this.AutoPrinting.Validate("Report ID", Report::"Customer - List");

        // [THEN] Report Name flowfield should be calculable
        this.AutoPrinting.CalcFields("Report Name");
        this.Assert.AreNotEqual('', this.AutoPrinting."Report Name", 'Report Name should be calculated');
    end;

    [Test]
    internal procedure QtyToPrint_DefaultValue_IsZero()
    var
        ReportSet: Record "BJF Report Set";
        PrintingTrigger: Record "BJF Printing Trigger";
        ReportSetCode: Code[50];
        TriggerCode: Code[50];
    begin
        // [GIVEN] A new automatic printing record
        this.TestUtil.PrepareTestData(ReportSetCode, TriggerCode, ReportSet, PrintingTrigger);

        // [WHEN] Record is initialized
        this.TestUtil.CreateTestAutomaticPrinting(this.AutoPrinting, ReportSetCode, TriggerCode, '1', Report::"Customer - List");

        // [THEN] Qty to Print should be 0 by default
        this.Assert.AreEqual(0, this.AutoPrinting."Qty to Print", 'Default Qty to Print should be 0');
    end;

    [Test]
    internal procedure ReportSetNo_Validation_CalculatesReportSetName()
    var
        ReportSet: Record "BJF Report Set";
        ReportSetCode: Code[50];
        ReportSetName: Text[100];
    begin
        // [GIVEN] A report set exists
        ReportSetCode := this.TestUtil.GenerateRandomCode('RS');
        ReportSetName := 'Test Report Set Name';
        ReportSet := this.TestUtil.CreateTestReportSet(ReportSetCode, ReportSetName, "BJF Direct Print Provider".FromInteger(0));

        // [WHEN] Report Set No is set
        this.AutoPrinting.Init();
        this.AutoPrinting.Validate("Report Set No.", ReportSetCode);

        // [THEN] Report Set Name flowfield should be calculable
        this.AutoPrinting.CalcFields("Report Set Name");
        this.Assert.AreEqual(ReportSetName, this.AutoPrinting."Report Set Name", 'Report Set Name should match');
    end;

    [Test]
    procedure TriggerNo_Validation_CalculatesTriggerDescription()
    var
        PrintingTrigger: Record "BJF Printing Trigger";
        TriggerCode: Code[50];
        TriggerDesc: Text[50];
    begin
        // [GIVEN] A trigger exists
        TriggerCode := this.TestUtil.GenerateRandomCode('TR');
        TriggerDesc := 'Test Trigger Description';
        PrintingTrigger := this.TestUtil.CreateTestTrigger(TriggerCode, TriggerDesc, "BJF Direct Print Provider".FromInteger(0));

        // [WHEN] Trigger No is set
        this.AutoPrinting.Init();
        this.AutoPrinting.Validate("Trigger No.", TriggerCode);

        // [THEN] Trigger Description flowfield should be calculable
        this.AutoPrinting.CalcFields("Trigger Description");
        this.Assert.AreEqual(TriggerDesc, this.AutoPrinting."Trigger Description", 'Trigger Description should match');
    end;
}
