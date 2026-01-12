namespace BradFullwood.ForNAV.Tests;

using BradFullwood.ForNAV.Core;
using Microsoft.Sales.Reports;

/// <summary>
/// Test codeunit for BJF Print Management (77702).
/// Tests QueuePrintLabels, PopulateBufferWithContext, IsEventEnabledForLabelGroup, and event subscribers.
/// </summary>
codeunit 77800 "BJF Print Management Tests"
{
    Subtype = Test;
    TestPermissions = Restrictive;
    InherentPermissions = x;
    Permissions = tabledata "BJF Label Groups" = RIMD,
                 tabledata "BJF Event" = RIMD,
                 tabledata "BJF Automatic Printing" = RIMD,
                 tabledata "BJF Print Buffer" = RIMD,
                 tabledata "BJF Dataset" = RIMD,
                 tabledata Customer = R;
    var
        TestUtil: Codeunit "BJF Test Utilities";
        Assert: Codeunit "Library Assert";

    [Test]
    internal procedure QueuePrintLabels_ValidEvent_CreatesBufferEntry()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        LabelGroup: Record "BJF Label Groups";
        EventRec: Record "BJF Event";
        AutoPrinting: Record "BJF Automatic Printing";
        PrintBuffer: Record "BJF Print Buffer";
        Customer: Record Customer;
        RecRef: RecordRef;
        LabelGroupCode: Code[50];
        EventCode: Code[50];
    begin
        // [GIVEN] A valid label group, event, and automatic printing configuration
        LabelGroupCode := this.TestUtil.GenerateRandomCode('LG');
        EventCode := this.TestUtil.GenerateRandomCode('EV');

        LabelGroup := this.TestUtil.CreateTestLabelGroup(LabelGroupCode, 'Test Label Group', "BJF Direct Print Provider"::FromInteger(0));
        EventRec := this.TestUtil.CreateTestEvent(EventCode, 'Test Event', "BJF Direct Print Provider"::FromInteger(0));
        this.TestUtil.CreateTestDataset("BJF Direct Print Provider"::FromInteger(0), "BJF Dataset Entity Type"::"Label Group", LabelGroupCode, Database::Customer);
        this.TestUtil.CreateTestDataset("BJF Direct Print Provider"::FromInteger(0), "BJF Dataset Entity Type"::"Event", EventCode, Database::Customer);
        AutoPrinting := this.TestUtil.CreateTestAutomaticPrinting(LabelGroupCode, EventCode, '1', Report::"Standard Sales - Invoice");

        Customer.FindFirst();
        RecRef.GetTable(Customer);

        // [WHEN] QueuePrintLabels is called
        PrintMgmt.QueuePrintLabels(RecRef, LabelGroupCode, EventCode);

        // [THEN] A print buffer entry should be created
        PrintBuffer.SetRange("Report ID", Report::"Standard Sales - Invoice");
        this.Assert.RecordIsNotEmpty(PrintBuffer);
        this.Assert.AreEqual(1, PrintBuffer.Count(), 'Expected 1 print buffer entry');
    end;

    [Test]
    internal procedure QueuePrintLabels_EventNotEnabled_ReturnsError()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        LabelGroup: Record "BJF Label Groups";
        EventRec: Record "BJF Event";
        Customer: Record Customer;
        RecRef: RecordRef;
        LabelGroupCode: Code[50];
        EventCode: Code[50];
        ErrorOccurred: Boolean;
    begin
        // [GIVEN] A label group without enabled event
        LabelGroupCode := this.TestUtil.GenerateRandomCode('LG');
        EventCode := this.TestUtil.GenerateRandomCode('EV');

        LabelGroup := this.TestUtil.CreateTestLabelGroup(LabelGroupCode, 'Test Label Group', "BJF Direct Print Provider"::FromInteger(0));
        EventRec := this.TestUtil.CreateTestEvent(EventCode, 'Test Event', "BJF Direct Print Provider"::FromInteger(0));
        // Note: No AutoPrinting record = event not enabled for this label group

        Customer.FindFirst();
        RecRef.GetTable(Customer);

        // [WHEN] QueuePrintLabels is called
        ErrorOccurred := false;
        ClearLastError();
        PrintMgmt.QueuePrintLabels(RecRef, LabelGroupCode, EventCode);

        // [THEN] Should handle the error gracefully (via OnAfterQueuePrintLabels event)
        // No exception should be thrown to the caller
        this.Assert.AreEqual('', GetLastError(), 'No error should be raised to caller');

    end;

    [Test]
    internal procedure QueuePrintLabels_NoReportsConfigured_ReturnsError()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        LabelGroup: Record "BJF Label Groups";
        EventRec: Record "BJF Event";
        AutoPrinting: Record "BJF Automatic Printing";
        Customer: Record Customer;
        RecRef: RecordRef;
        LabelGroupCode: Code[50];
        EventCode: Code[50];
    begin
        // [GIVEN] A label group with event but no report configured
        LabelGroupCode := this.TestUtil.GenerateRandomCode('LG');
        EventCode := this.TestUtil.GenerateRandomCode('EV');

        LabelGroup := this.TestUtil.CreateTestLabelGroup(LabelGroupCode, 'Test Label Group', "BJF Direct Print Provider"::FromInteger(0));
        EventRec := this.TestUtil.CreateTestEvent(EventCode, 'Test Event', "BJF Direct Print Provider"::FromInteger(0));
        this.TestUtil.CreateTestDataset("BJF Direct Print Provider"::FromInteger(0), "BJF Dataset Entity Type"::"Label Group", LabelGroupCode, Database::Customer);

        // Create AutoPrinting without Report ID
        AutoPrinting.Init();
        AutoPrinting."Label Group No." := LabelGroupCode;
        AutoPrinting."Event No." := EventCode;
        AutoPrinting.Sequence := '1';
        AutoPrinting."Report ID" := 0; // No report
        AutoPrinting.Insert(true);

        Customer.FindFirst();
        RecRef.GetTable(Customer);

        // [WHEN] QueuePrintLabels is called
        PrintMgmt.QueuePrintLabels(RecRef, LabelGroupCode, EventCode);

        // [THEN] Should handle the error gracefully (via OnAfterQueuePrintLabels event)
        this.Assert.AreEqual('', GetLastError(), 'No error should be raised to caller');

    end;

    [Test]
    internal procedure QueuePrintLabels_MultipleReports_CreatesMultipleBufferEntries()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        LabelGroup: Record "BJF Label Groups";
        EventRec: Record "BJF Event";
        PrintBuffer: Record "BJF Print Buffer";
        Customer: Record Customer;
        RecRef: RecordRef;
        LabelGroupCode: Code[50];
        EventCode: Code[50];
    begin
        // [GIVEN] A label group with multiple reports configured
        LabelGroupCode := this.TestUtil.GenerateRandomCode('LG');
        EventCode := this.TestUtil.GenerateRandomCode('EV');

        LabelGroup := this.TestUtil.CreateTestLabelGroup(LabelGroupCode, 'Test Label Group', "BJF Direct Print Provider"::FromInteger(0));
        EventRec := this.TestUtil.CreateTestEvent(EventCode, 'Test Event', "BJF Direct Print Provider"::FromInteger(0));
        this.TestUtil.CreateTestDataset("BJF Direct Print Provider"::FromInteger(0), "BJF Dataset Entity Type"::"Label Group", LabelGroupCode, Database::Customer);
        this.TestUtil.CreateTestDataset("BJF Direct Print Provider"::FromInteger(0), "BJF Dataset Entity Type"::"Event", EventCode, Database::Customer);

        // Create multiple AutoPrinting records
        this.TestUtil.CreateTestAutomaticPrinting(LabelGroupCode, EventCode, '1', Report::"Standard Sales - Invoice");
        this.TestUtil.CreateTestAutomaticPrinting(LabelGroupCode, EventCode, '2', Report::"Standard Sales - Quote");
        this.TestUtil.CreateTestAutomaticPrinting(LabelGroupCode, EventCode, '3', Report::"Customer - List");

        Customer.FindFirst();
        RecRef.GetTable(Customer);

        // [WHEN] QueuePrintLabels is called
        PrintMgmt.QueuePrintLabels(RecRef, LabelGroupCode, EventCode);

        // [THEN] Multiple print buffer entries should be created
        PrintBuffer.Reset();
        this.Assert.AreEqual(3, PrintBuffer.Count(), 'Expected 3 print buffer entries');

    end;

    [Test]
    internal procedure IsEventEnabledForLabelGroup_EnabledEvent_ReturnsTrue()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        LabelGroup: Record "BJF Label Groups";
        EventRec: Record "BJF Event";
        LabelGroupCode: Code[50];
        EventCode: Code[50];
        IsEnabled: Boolean;
    begin
        // [GIVEN] A label group with an enabled event
        LabelGroupCode := this.TestUtil.GenerateRandomCode('LG');
        EventCode := this.TestUtil.GenerateRandomCode('EV');

        LabelGroup := this.TestUtil.CreateTestLabelGroup(LabelGroupCode, 'Test Label Group', "BJF Direct Print Provider"::FromInteger(0));
        EventRec := this.TestUtil.CreateTestEvent(EventCode, 'Test Event', "BJF Direct Print Provider"::FromInteger(0));
        this.TestUtil.CreateTestAutomaticPrinting(LabelGroupCode, EventCode, '1', Report::"Standard Sales - Invoice");

        // [WHEN] IsEventEnabledForLabelGroup is called
        IsEnabled := PrintMgmt.IsEventEnabledForLabelGroup(LabelGroupCode, EventCode);

        // [THEN] Should return true
        this.Assert.IsTrue(IsEnabled, 'Event should be enabled for label group');

    end;

    [Test]
    internal procedure IsEventEnabledForLabelGroup_DisabledEvent_ReturnsFalse()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        LabelGroup: Record "BJF Label Groups";
        EventRec: Record "BJF Event";
        LabelGroupCode: Code[50];
        EventCode: Code[50];
        IsEnabled: Boolean;
    begin
        // [GIVEN] A label group without the event configured
        LabelGroupCode := this.TestUtil.GenerateRandomCode('LG');
        EventCode := this.TestUtil.GenerateRandomCode('EV');

        LabelGroup := this.TestUtil.CreateTestLabelGroup(LabelGroupCode, 'Test Label Group', "BJF Direct Print Provider"::FromInteger(0));
        EventRec := this.TestUtil.CreateTestEvent(EventCode, 'Test Event', "BJF Direct Print Provider"::FromInteger(0));
        // No AutoPrinting record

        // [WHEN] IsEventEnabledForLabelGroup is called
        IsEnabled := PrintMgmt.IsEventEnabledForLabelGroup(LabelGroupCode, EventCode);

        // [THEN] Should return false
        this.Assert.IsFalse(IsEnabled, 'Event should not be enabled for label group');

    end;

    [Test]
    internal procedure IsEventEnabledForLabelGroup_InvalidLabelGroup_ThrowsError()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        EventRec: Record "BJF Event";
        EventCode: Code[50];
        ErrorOccurred: Boolean;
    begin
        // [GIVEN] An event but no label group
        EventCode := this.TestUtil.GenerateRandomCode('EV');
        EventRec := this.TestUtil.CreateTestEvent(EventCode, 'Test Event', "BJF Direct Print Provider"::FromInteger(0));

        // [WHEN] IsEventEnabledForLabelGroup is called with invalid label group
        ErrorOccurred := false;
        asserterror PrintMgmt.IsEventEnabledForLabelGroup('INVALID', EventCode);
        ErrorOccurred := true;

        // [THEN] Should throw an error
        this.Assert.IsTrue(ErrorOccurred, 'Should throw error for invalid label group');

    end;

    [Test]
    internal procedure PopulateBufferWithContext_ValidData_CreatesCorrectBuffer()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        LabelGroup: Record "BJF Label Groups";
        EventRec: Record "BJF Event";
        AutoPrinting: Record "BJF Automatic Printing";
        PrintBuffer: Record "BJF Print Buffer";
        Customer: Record Customer;
        RecRef: RecordRef;
        LabelGroupCode: Code[50];
        EventCode: Code[50];
    begin
        // [GIVEN] Configured automatic printing with custom layout
        LabelGroupCode := this.TestUtil.GenerateRandomCode('LG');
        EventCode := this.TestUtil.GenerateRandomCode('EV');

        LabelGroup := this.TestUtil.CreateTestLabelGroup(LabelGroupCode, 'Test Label Group', "BJF Direct Print Provider"::FromInteger(0));
        EventRec := this.TestUtil.CreateTestEvent(EventCode, 'Test Event', "BJF Direct Print Provider"::FromInteger(0));
        this.TestUtil.CreateTestDataset("BJF Direct Print Provider"::FromInteger(0), "BJF Dataset Entity Type"::"Label Group", LabelGroupCode, Database::Customer);
        this.TestUtil.CreateTestDataset("BJF Direct Print Provider"::FromInteger(0), "BJF Dataset Entity Type"::"Event", EventCode, Database::Customer);

        AutoPrinting := this.TestUtil.CreateTestAutomaticPrinting(LabelGroupCode, EventCode, '1', Report::"Standard Sales - Invoice");
        AutoPrinting."Qty to Print" := 5;
        AutoPrinting.Modify(true);

        Customer.FindFirst();
        RecRef.GetTable(Customer);

        // [WHEN] QueuePrintLabels is called
        PrintMgmt.QueuePrintLabels(RecRef, LabelGroupCode, EventCode);

        // [THEN] Buffer entry should have correct values
        PrintBuffer.SetRange("Report ID", Report::"Standard Sales - Invoice");
        PrintBuffer.FindFirst();
        this.Assert.AreEqual(Report::"Standard Sales - Invoice", PrintBuffer."Report ID", 'Report ID mismatch');
        this.Assert.AreEqual(5, PrintBuffer."Qty to Print", 'Qty to Print mismatch');
        this.Assert.AreEqual(Customer.RecordId, PrintBuffer."Source Record", 'Source Record mismatch');

    end;
}
