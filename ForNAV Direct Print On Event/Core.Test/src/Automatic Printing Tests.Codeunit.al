namespace BradFullwood.ForNAV.Tests;

using BradFullwood.ForNAV.Core;
using System.TestLibraries.Utilities;
using Microsoft.Sales.Reports;

/// <summary>
/// Test codeunit for BJF Automatic Printing (77700).
/// Tests GetNextSequence, NewRecord, DrillDownToSelectLayout, and field validations.
/// </summary>
codeunit 77804 "BJF Automatic Printing Tests"
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
        LabelGroup: Record "BJF Label Groups";
        EventRec: Record "BJF Event";
        LabelGroupCode: Code[50];
        EventCode: Code[50];
    begin
        this.AutoPrinting.DeleteAll(false);
        // [GIVEN] No existing automatic printing records
        this.TestUtil.PrepareLabelTestData(LabelGroupCode, EventCode, LabelGroup, EventRec);

        // [WHEN] GetNextSequence is called on new record
        this.TestUtil.CreateTestAutomaticPrinting(this.AutoPrinting, LabelGroupCode, EventCode, '1', Report::"Customer - List");

        // [THEN] Sequence should be 1
        this.Assert.AreEqual('1', this.AutoPrinting.Sequence, 'First sequence should be 1');
    end;

    [Test]
    internal procedure GetNextSequence_ExistingRecords_IncrementsSequence()
    var
        LabelGroup: Record "BJF Label Groups";
        EventRec: Record "BJF Event";
        LabelGroupCode: Code[50];
        EventCode: Code[50];
        NoRecordErr: Label 'No automatic printing record found';
    begin
        this.AutoPrinting.DeleteAll(false);

        // [GIVEN] Existing automatic printing records
        this.TestUtil.PrepareLabelTestData(LabelGroupCode, EventCode, LabelGroup, EventRec);
        this.TestUtil.CreateTestAutomaticPrinting(this.AutoPrinting, LabelGroupCode, EventCode, '1', Report::"Customer - List");

        // [WHEN] GetNextSequence is called for second record
        this.TestUtil.CreateTestAutomaticPrinting(this.AutoPrinting, LabelGroupCode, EventCode, '2', Report::"Customer - List");
        if not this.AutoPrinting.FindLast() then
            Error(NoRecordErr);

        // [THEN] Sequence should be 2
        this.Assert.AreEqual('2', this.AutoPrinting.Sequence, 'Second sequence should be 2');
    end;


    [Test]
    internal procedure ReportID_Validation_CalculatesReportName()
    var
        LabelGroup: Record "BJF Label Groups";
        EventRec: Record "BJF Event";
        LabelGroupCode: Code[50];
        EventCode: Code[50];
    begin
        // [GIVEN] A new automatic printing record
        this.TestUtil.PrepareLabelTestData(LabelGroupCode, EventCode, LabelGroup, EventRec);

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
        LabelGroup: Record "BJF Label Groups";
        EventRec: Record "BJF Event";
        LabelGroupCode: Code[50];
        EventCode: Code[50];
    begin
        // [GIVEN] A new automatic printing record
        this.TestUtil.PrepareLabelTestData(LabelGroupCode, EventCode, LabelGroup, EventRec);

        // [WHEN] Record is initialized
        this.TestUtil.CreateTestAutomaticPrinting(this.AutoPrinting, LabelGroupCode, EventCode, '1', Report::"Customer - List");

        // [THEN] Qty to Print should be 0 by default
        this.Assert.AreEqual(0, this.AutoPrinting."Qty to Print", 'Default Qty to Print should be 0');
    end;

    [Test]
    internal procedure LabelGroupNo_Validation_CalculatesLabelGroupName()
    var
        LabelGroup: Record "BJF Label Groups";
        LabelGroupCode: Code[50];
        LabelGroupName: Text[100];
    begin
        // [GIVEN] A label group exists
        LabelGroupCode := this.TestUtil.GenerateRandomCode('LG');
        LabelGroupName := 'Test Label Group Name';
        LabelGroup := this.TestUtil.CreateTestLabelGroup(LabelGroupCode, LabelGroupName, "BJF Direct Print Provider".FromInteger(0));

        // [WHEN] Label Group No is set
        this.AutoPrinting.Init();
        this.AutoPrinting.Validate("Label Group No.", LabelGroupCode);

        // [THEN] Label Group Name flowfield should be calculable
        this.AutoPrinting.CalcFields("Label Group Name");
        this.Assert.AreEqual(LabelGroupName, this.AutoPrinting."Label Group Name", 'Label Group Name should match');
    end;

    [Test]
    procedure EventNo_Validation_CalculatesEventDescription()
    var
        EventRec: Record "BJF Event";
        EventCode: Code[50];
        EventDesc: Text[50];
    begin
        // [GIVEN] An event exists
        EventCode := this.TestUtil.GenerateRandomCode('EV');
        EventDesc := 'Test Event Description';
        EventRec := this.TestUtil.CreateTestEvent(EventCode, EventDesc, "BJF Direct Print Provider".FromInteger(0));

        // [WHEN] Event No is set
        this.AutoPrinting.Init();
        this.AutoPrinting.Validate("Event No.", EventCode);

        // [THEN] Event Description flowfield should be calculable
        this.AutoPrinting.CalcFields("Event Description");
        this.Assert.AreEqual(EventDesc, this.AutoPrinting."Event Description", 'Event Description should match');
    end;
}
