namespace BradFullwood.ForNAV.Tests;

using BradFullwood.ForNAV.Core;
using Microsoft.Sales.Reports;

/// <summary>
/// Test codeunit for BJF Print Management (77702).
/// Tests QueuePrintReports, PopulateBufferWithContext, IsTriggerEnabledForReportSet, and event subscribers.
/// </summary>
codeunit 77700 "BJF Print Management Tests"
{
    Subtype = Test;
    TestPermissions = Restrictive;
    InherentPermissions = x;
    Permissions = tabledata "BJF Report Set" = RIMD,
                 tabledata "BJF Printing Trigger" = RIMD,
                 tabledata "BJF Automatic Printing" = RIMD,
                 tabledata "BJF Print Buffer" = RIMD,
                 tabledata "BJF Source Table Mapping" = RIMD,
                 tabledata Customer = R;
    var
        TestUtil: Codeunit "BJF Test Utilities";
        Assert: Codeunit "Library Assert";

    [Test]
    internal procedure QueuePrintReports_ValidTrigger_CreatesBufferEntry()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        ReportSet: Record "BJF Report Set";
        PrintingTrigger: Record "BJF Printing Trigger";
        AutoPrinting: Record "BJF Automatic Printing";
        PrintBuffer: Record "BJF Print Buffer";
        Customer: Record Customer;
        RecRef: RecordRef;
        ReportSetCode: Code[50];
        TriggerCode: Code[50];
    begin
        // [GIVEN] A valid report set, trigger, and automatic printing configuration
        ReportSetCode := this.TestUtil.GenerateRandomCode('RS');
        TriggerCode := this.TestUtil.GenerateRandomCode('TR');

        ReportSet := this.TestUtil.CreateTestReportSet(ReportSetCode, 'Test Report Set', "BJF Direct Print Provider"::FromInteger(0));
        PrintingTrigger := this.TestUtil.CreateTestTrigger(TriggerCode, 'Test Trigger', "BJF Direct Print Provider"::FromInteger(0));
        this.TestUtil.CreateTestSourceTableMapping("BJF Direct Print Provider"::FromInteger(0), "BJF Mapping Type"::"Report Set", ReportSetCode, Database::Customer);
        this.TestUtil.CreateTestSourceTableMapping("BJF Direct Print Provider"::FromInteger(0), "BJF Mapping Type"::"Trigger", TriggerCode, Database::Customer);
        AutoPrinting := this.TestUtil.CreateTestAutomaticPrinting(ReportSetCode, TriggerCode, '1', Report::"Standard Sales - Invoice");

        Customer.FindFirst();
        RecRef.GetTable(Customer);

        // [WHEN] QueuePrintReports is called
        PrintMgmt.QueuePrintReports(RecRef, ReportSetCode, TriggerCode);

        // [THEN] A print buffer entry should be created
        PrintBuffer.SetRange("Report ID", Report::"Standard Sales - Invoice");
        this.Assert.RecordIsNotEmpty(PrintBuffer);
        this.Assert.AreEqual(1, PrintBuffer.Count(), 'Expected 1 print buffer entry');
    end;

    [Test]
    internal procedure QueuePrintReports_TriggerNotEnabled_ReturnsError()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        ReportSet: Record "BJF Report Set";
        PrintingTrigger: Record "BJF Printing Trigger";
        Customer: Record Customer;
        RecRef: RecordRef;
        ReportSetCode: Code[50];
        TriggerCode: Code[50];
        ErrorOccurred: Boolean;
    begin
        // [GIVEN] A report set without enabled trigger
        ReportSetCode := this.TestUtil.GenerateRandomCode('RS');
        TriggerCode := this.TestUtil.GenerateRandomCode('TR');

        ReportSet := this.TestUtil.CreateTestReportSet(ReportSetCode, 'Test Report Set', "BJF Direct Print Provider"::FromInteger(0));
        PrintingTrigger := this.TestUtil.CreateTestTrigger(TriggerCode, 'Test Trigger', "BJF Direct Print Provider"::FromInteger(0));
        // Note: No AutoPrinting record = trigger not enabled for this report set

        Customer.FindFirst();
        RecRef.GetTable(Customer);

        // [WHEN] QueuePrintReports is called
        ErrorOccurred := false;
        ClearLastError();
        PrintMgmt.QueuePrintReports(RecRef, ReportSetCode, TriggerCode);

        // [THEN] Should handle the error gracefully (via OnAfterQueuePrintReports event)
        // No exception should be thrown to the caller
        this.Assert.AreEqual('', GetLastError(), 'No error should be raised to caller');

    end;

    [Test]
    internal procedure QueuePrintReports_NoReportsConfigured_ReturnsError()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        ReportSet: Record "BJF Report Set";
        PrintingTrigger: Record "BJF Printing Trigger";
        AutoPrinting: Record "BJF Automatic Printing";
        Customer: Record Customer;
        RecRef: RecordRef;
        ReportSetCode: Code[50];
        TriggerCode: Code[50];
    begin
        // [GIVEN] A report set with trigger but no report configured
        ReportSetCode := this.TestUtil.GenerateRandomCode('RS');
        TriggerCode := this.TestUtil.GenerateRandomCode('TR');

        ReportSet := this.TestUtil.CreateTestReportSet(ReportSetCode, 'Test Report Set', "BJF Direct Print Provider"::FromInteger(0));
        PrintingTrigger := this.TestUtil.CreateTestTrigger(TriggerCode, 'Test Trigger', "BJF Direct Print Provider"::FromInteger(0));
        this.TestUtil.CreateTestSourceTableMapping("BJF Direct Print Provider"::FromInteger(0), "BJF Mapping Type"::"Report Set", ReportSetCode, Database::Customer);

        // Create AutoPrinting without Report ID
        AutoPrinting.Init();
        AutoPrinting."Report Set No." := ReportSetCode;
        AutoPrinting."Trigger No." := TriggerCode;
        AutoPrinting.Sequence := '1';
        AutoPrinting."Report ID" := 0; // No report
        AutoPrinting.Insert(true);

        Customer.FindFirst();
        RecRef.GetTable(Customer);

        // [WHEN] QueuePrintReports is called
        PrintMgmt.QueuePrintReports(RecRef, ReportSetCode, TriggerCode);

        // [THEN] Should handle the error gracefully (via OnAfterQueuePrintReports event)
        this.Assert.AreEqual('', GetLastError(), 'No error should be raised to caller');

    end;

    [Test]
    internal procedure QueuePrintReports_MultipleReports_CreatesMultipleBufferEntries()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        ReportSet: Record "BJF Report Set";
        PrintingTrigger: Record "BJF Printing Trigger";
        PrintBuffer: Record "BJF Print Buffer";
        Customer: Record Customer;
        RecRef: RecordRef;
        ReportSetCode: Code[50];
        TriggerCode: Code[50];
    begin
        // [GIVEN] A report set with multiple reports configured
        ReportSetCode := this.TestUtil.GenerateRandomCode('RS');
        TriggerCode := this.TestUtil.GenerateRandomCode('TR');

        ReportSet := this.TestUtil.CreateTestReportSet(ReportSetCode, 'Test Report Set', "BJF Direct Print Provider"::FromInteger(0));
        PrintingTrigger := this.TestUtil.CreateTestTrigger(TriggerCode, 'Test Trigger', "BJF Direct Print Provider"::FromInteger(0));
        this.TestUtil.CreateTestSourceTableMapping("BJF Direct Print Provider"::FromInteger(0), "BJF Mapping Type"::"Report Set", ReportSetCode, Database::Customer);
        this.TestUtil.CreateTestSourceTableMapping("BJF Direct Print Provider"::FromInteger(0), "BJF Mapping Type"::"Trigger", TriggerCode, Database::Customer);

        // Create multiple AutoPrinting records
        this.TestUtil.CreateTestAutomaticPrinting(ReportSetCode, TriggerCode, '1', Report::"Standard Sales - Invoice");
        this.TestUtil.CreateTestAutomaticPrinting(ReportSetCode, TriggerCode, '2', Report::"Standard Sales - Quote");
        this.TestUtil.CreateTestAutomaticPrinting(ReportSetCode, TriggerCode, '3', Report::"Customer - List");

        Customer.FindFirst();
        RecRef.GetTable(Customer);

        // [WHEN] QueuePrintReports is called
        PrintMgmt.QueuePrintReports(RecRef, ReportSetCode, TriggerCode);

        // [THEN] Multiple print buffer entries should be created
        PrintBuffer.Reset();
        this.Assert.AreEqual(3, PrintBuffer.Count(), 'Expected 3 print buffer entries');

    end;

    [Test]
    internal procedure IsTriggerEnabledForReportSet_EnabledTrigger_ReturnsTrue()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        ReportSet: Record "BJF Report Set";
        PrintingTrigger: Record "BJF Printing Trigger";
        ReportSetCode: Code[50];
        TriggerCode: Code[50];
        IsEnabled: Boolean;
    begin
        // [GIVEN] A report set with an enabled trigger
        ReportSetCode := this.TestUtil.GenerateRandomCode('RS');
        TriggerCode := this.TestUtil.GenerateRandomCode('TR');

        ReportSet := this.TestUtil.CreateTestReportSet(ReportSetCode, 'Test Report Set', "BJF Direct Print Provider"::FromInteger(0));
        PrintingTrigger := this.TestUtil.CreateTestTrigger(TriggerCode, 'Test Trigger', "BJF Direct Print Provider"::FromInteger(0));
        this.TestUtil.CreateTestAutomaticPrinting(ReportSetCode, TriggerCode, '1', Report::"Standard Sales - Invoice");

        // [WHEN] IsTriggerEnabledForReportSet is called
        IsEnabled := PrintMgmt.IsTriggerEnabledForReportSet(ReportSetCode, TriggerCode);

        // [THEN] Should return true
        this.Assert.IsTrue(IsEnabled, 'Trigger should be enabled for report set');

    end;

    [Test]
    internal procedure IsTriggerEnabledForReportSet_DisabledTrigger_ReturnsFalse()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        ReportSet: Record "BJF Report Set";
        PrintingTrigger: Record "BJF Printing Trigger";
        ReportSetCode: Code[50];
        TriggerCode: Code[50];
        IsEnabled: Boolean;
    begin
        // [GIVEN] A report set without the trigger configured
        ReportSetCode := this.TestUtil.GenerateRandomCode('RS');
        TriggerCode := this.TestUtil.GenerateRandomCode('TR');

        ReportSet := this.TestUtil.CreateTestReportSet(ReportSetCode, 'Test Report Set', "BJF Direct Print Provider"::FromInteger(0));
        PrintingTrigger := this.TestUtil.CreateTestTrigger(TriggerCode, 'Test Trigger', "BJF Direct Print Provider"::FromInteger(0));
        // No AutoPrinting record

        // [WHEN] IsTriggerEnabledForReportSet is called
        IsEnabled := PrintMgmt.IsTriggerEnabledForReportSet(ReportSetCode, TriggerCode);

        // [THEN] Should return false
        this.Assert.IsFalse(IsEnabled, 'Trigger should not be enabled for report set');

    end;

    [Test]
    internal procedure IsTriggerEnabledForReportSet_InvalidReportSet_ThrowsError()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        PrintingTrigger: Record "BJF Printing Trigger";
        TriggerCode: Code[50];
        ErrorOccurred: Boolean;
    begin
        // [GIVEN] A trigger but no report set
        TriggerCode := this.TestUtil.GenerateRandomCode('TR');
        PrintingTrigger := this.TestUtil.CreateTestTrigger(TriggerCode, 'Test Trigger', "BJF Direct Print Provider"::FromInteger(0));

        // [WHEN] IsTriggerEnabledForReportSet is called with invalid report set
        ErrorOccurred := false;
        asserterror PrintMgmt.IsTriggerEnabledForReportSet('INVALID', TriggerCode);
        ErrorOccurred := true;

        // [THEN] Should throw an error
        this.Assert.IsTrue(ErrorOccurred, 'Should throw error for invalid report set');

    end;

    [Test]
    internal procedure PopulateBufferWithContext_ValidData_CreatesCorrectBuffer()
    var
        PrintMgmt: Codeunit "BJF Print Management";
        ReportSet: Record "BJF Report Set";
        PrintingTrigger: Record "BJF Printing Trigger";
        AutoPrinting: Record "BJF Automatic Printing";
        PrintBuffer: Record "BJF Print Buffer";
        Customer: Record Customer;
        RecRef: RecordRef;
        ReportSetCode: Code[50];
        TriggerCode: Code[50];
    begin
        // [GIVEN] Configured automatic printing with custom layout
        ReportSetCode := this.TestUtil.GenerateRandomCode('RS');
        TriggerCode := this.TestUtil.GenerateRandomCode('TR');

        ReportSet := this.TestUtil.CreateTestReportSet(ReportSetCode, 'Test Report Set', "BJF Direct Print Provider"::FromInteger(0));
        PrintingTrigger := this.TestUtil.CreateTestTrigger(TriggerCode, 'Test Trigger', "BJF Direct Print Provider"::FromInteger(0));
        this.TestUtil.CreateTestSourceTableMapping("BJF Direct Print Provider"::FromInteger(0), "BJF Mapping Type"::"Report Set", ReportSetCode, Database::Customer);
        this.TestUtil.CreateTestSourceTableMapping("BJF Direct Print Provider"::FromInteger(0), "BJF Mapping Type"::"Trigger", TriggerCode, Database::Customer);

        AutoPrinting := this.TestUtil.CreateTestAutomaticPrinting(ReportSetCode, TriggerCode, '1', Report::"Standard Sales - Invoice");
        AutoPrinting."Qty to Print" := 5;
        AutoPrinting.Modify(true);

        Customer.FindFirst();
        RecRef.GetTable(Customer);

        // [WHEN] QueuePrintReports is called
        PrintMgmt.QueuePrintReports(RecRef, ReportSetCode, TriggerCode);

        // [THEN] Buffer entry should have correct values
        PrintBuffer.SetRange("Report ID", Report::"Standard Sales - Invoice");
        PrintBuffer.FindFirst();
        this.Assert.AreEqual(Report::"Standard Sales - Invoice", PrintBuffer."Report ID", 'Report ID mismatch');
        this.Assert.AreEqual(5, PrintBuffer."Qty to Print", 'Qty to Print mismatch');
        this.Assert.AreEqual(Customer.RecordId, PrintBuffer."Source Record", 'Source Record mismatch');

    end;
}
