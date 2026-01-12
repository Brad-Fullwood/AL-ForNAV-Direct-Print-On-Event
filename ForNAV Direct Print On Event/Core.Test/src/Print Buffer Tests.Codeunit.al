namespace BradFullwood.ForNAV.Tests;

using BradFullwood.ForNAV.Core;
using Microsoft.Sales.Reports;

/// <summary>
/// Test codeunit for BJF Print Buffer (77704).
/// Tests OnInsert trigger, field validations, and status transitions.
/// </summary>
codeunit 77803 "BJF Print Buffer Tests"
{
    Subtype = Test;
    TestPermissions = Restrictive;
    InherentPermissions = x;
    Permissions = tabledata "BJF Print Buffer" = RIMD,
                 tabledata Customer = R;

    var
        TestUtil: Codeunit "BJF Test Utilities";
        Assert: Codeunit "Library Assert";

    [Test]
    internal procedure OnInsert_AutoPopulatesCreatedDateTime()
    var
        PrintBuffer: Record "BJF Print Buffer";
        Customer: Record Customer;
        BeforeInsert: DateTime;
        AfterInsert: DateTime;
    begin
        // [GIVEN] A print buffer record
        Customer.FindFirst();
        BeforeInsert := CurrentDateTime();

        // [WHEN] Record is inserted
        PrintBuffer.Init();
        PrintBuffer."Report ID" := Report::"Customer - List";
        PrintBuffer."Source Record" := Customer.RecordId();
        PrintBuffer.Insert(true);
        AfterInsert := CurrentDateTime();

        // [THEN] Created Date Time should be set automatically
        this.Assert.IsTrue(PrintBuffer."Created Date Time" >= BeforeInsert, 'Created Date Time should be >= before insert time');
        this.Assert.IsTrue(PrintBuffer."Created Date Time" <= AfterInsert, 'Created Date Time should be <= after insert time');

    end;

    [Test]
    internal procedure OnInsert_AutoPopulatesUserID()
    var
        PrintBuffer: Record "BJF Print Buffer";
        Customer: Record Customer;
    begin
        // [GIVEN] A print buffer record
        Customer.FindFirst();

        // [WHEN] Record is inserted
        PrintBuffer.Init();
        PrintBuffer."Report ID" := Report::"Customer - List";
        PrintBuffer."Source Record" := Customer.RecordId();
        PrintBuffer.Insert(true);

        // [THEN] User ID should be set automatically
        this.Assert.AreNotEqual('', PrintBuffer."User ID", 'User ID should be populated');
        this.Assert.AreEqual(CopyStr(UserId(), 1, 50), PrintBuffer."User ID", 'User ID should match current user');

    end;

    [Test]
    internal procedure QtyToPrint_DefaultValue_IsOne()
    var
        PrintBuffer: Record "BJF Print Buffer";
        Customer: Record Customer;
    begin
        // [GIVEN] A new print buffer record
        Customer.FindFirst();

        // [WHEN] Record is initialized
        PrintBuffer.Init();
        PrintBuffer."Report ID" := Report::"Customer - List";
        PrintBuffer."Source Record" := Customer.RecordId();
        PrintBuffer.Insert(true);

        // [THEN] Qty to Print should default to 1
        this.Assert.AreEqual(1, PrintBuffer."Qty to Print", 'Default Qty to Print should be 1');

    end;

    [Test]
    internal procedure Status_DefaultValue_IsPending()
    var
        PrintBuffer: Record "BJF Print Buffer";
        Customer: Record Customer;
    begin
        // [GIVEN] A new print buffer record
        Customer.FindFirst();

        // [WHEN] Record is created
        PrintBuffer.Init();
        PrintBuffer."Report ID" := Report::"Customer - List";
        PrintBuffer."Source Record" := Customer.RecordId();
        PrintBuffer.Insert(true);

        // [THEN] Status should be Pending
        this.Assert.AreEqual(Enum::"BJF Print Buffer Status"::Pending, PrintBuffer.Status, 'Default status should be Pending');

    end;

    [Test]
    internal procedure StatusTransition_PendingToProcessing_Succeeds()
    var
        PrintBuffer: Record "BJF Print Buffer";
        Customer: Record Customer;
    begin
        // [GIVEN] A print buffer in Pending status
        Customer.FindFirst();
        PrintBuffer := this.TestUtil.CreateTestPrintBuffer(Report::"Customer - List", Customer.RecordId());

        // [WHEN] Status is changed to Processing
        PrintBuffer.Status := Enum::"BJF Print Buffer Status"::Processing;
        PrintBuffer.Modify(false);

        // [THEN] Status should be Processing
        PrintBuffer.Get(PrintBuffer."Entry No.");
        this.Assert.AreEqual(Enum::"BJF Print Buffer Status"::Processing, PrintBuffer.Status, 'Status should be Processing');

    end;

    [Test]
    internal procedure StatusTransition_ProcessingToCompleted_UpdatesProcessedDateTime()
    var
        PrintBuffer: Record "BJF Print Buffer";
        Customer: Record Customer;
        BeforeUpdate: DateTime;
    begin
        // [GIVEN] A print buffer in Processing status
        Customer.FindFirst();
        PrintBuffer := this.TestUtil.CreateTestPrintBuffer(Report::"Customer - List", Customer.RecordId());
        PrintBuffer.Status := Enum::"BJF Print Buffer Status"::Processing;
        PrintBuffer.Modify(false);

        BeforeUpdate := CurrentDateTime();

        // [WHEN] Status is changed to Completed with timestamp
        PrintBuffer.Status := Enum::"BJF Print Buffer Status"::Completed;
        PrintBuffer."Processed Date Time" := CurrentDateTime();
        PrintBuffer.Modify(false);

        // [THEN] Processed Date Time should be set
        PrintBuffer.Get(PrintBuffer."Entry No.");
        this.Assert.AreEqual(Enum::"BJF Print Buffer Status"::Completed, PrintBuffer.Status, 'Status should be Completed');
        this.Assert.IsTrue(PrintBuffer."Processed Date Time" >= BeforeUpdate, 'Processed Date Time should be set');

    end;

    [Test]
    internal procedure StatusTransition_ProcessingToFailed_SetsErrorMessage()
    var
        PrintBuffer: Record "BJF Print Buffer";
        Customer: Record Customer;
        ErrorMsg: Text[2048];
    begin
        // [GIVEN] A print buffer in Processing status
        Customer.FindFirst();
        PrintBuffer := this.TestUtil.CreateTestPrintBuffer(Report::"Customer - List", Customer.RecordId());
        PrintBuffer.Status := Enum::"BJF Print Buffer Status"::Processing;
        PrintBuffer.Modify(false);

        ErrorMsg := 'Test error message';

        // [WHEN] Status is changed to Failed with error message
        PrintBuffer.Status := Enum::"BJF Print Buffer Status"::Failed;
        PrintBuffer."Error Message" := ErrorMsg;
        PrintBuffer."Processed Date Time" := CurrentDateTime();
        PrintBuffer."Retry Count" += 1;
        PrintBuffer.Modify(false);

        // [THEN] Error message and retry count should be set
        PrintBuffer.Get(PrintBuffer."Entry No.");
        this.Assert.AreEqual(Enum::"BJF Print Buffer Status"::Failed, PrintBuffer.Status, 'Status should be Failed');
        this.Assert.AreEqual(ErrorMsg, PrintBuffer."Error Message", 'Error message should be set');
        this.Assert.AreEqual(1, PrintBuffer."Retry Count", 'Retry count should be 1');

    end;

    [Test]
    internal procedure RetryCount_DefaultValue_IsZero()
    var
        PrintBuffer: Record "BJF Print Buffer";
        Customer: Record Customer;
    begin
        // [GIVEN] A new print buffer record
        Customer.FindFirst();

        // [WHEN] Record is created
        PrintBuffer.Init();
        PrintBuffer."Report ID" := Report::"Customer - List";
        PrintBuffer."Source Record" := Customer.RecordId();
        PrintBuffer.Insert(true);

        // [THEN] Retry Count should be 0
        this.Assert.AreEqual(0, PrintBuffer."Retry Count", 'Default retry count should be 0');

    end;

    [Test]
    internal procedure EntryNo_AutoIncrement_GeneratesUniqueNumbers()
    var
        PrintBuffer1: Record "BJF Print Buffer";
        PrintBuffer2: Record "BJF Print Buffer";
        Customer: Record Customer;
    begin
        // [GIVEN] Multiple print buffer records
        Customer.FindFirst();

        // [WHEN] Multiple records are inserted
        PrintBuffer1 := this.TestUtil.CreateTestPrintBuffer(Report::"Customer - List", Customer.RecordId());
        PrintBuffer2 := this.TestUtil.CreateTestPrintBuffer(Report::"Customer - List", Customer.RecordId());

        // [THEN] Entry numbers should be unique and incremented
        this.Assert.AreNotEqual(PrintBuffer1."Entry No.", PrintBuffer2."Entry No.", 'Entry numbers should be unique');
        this.Assert.IsTrue(PrintBuffer2."Entry No." > PrintBuffer1."Entry No.", 'Entry numbers should increment');

    end;

    [Test]
    internal procedure SourceRecord_ValidRecordId_Stored()
    var
        PrintBuffer: Record "BJF Print Buffer";
        Customer: Record Customer;
        StoredRecordId: RecordId;
    begin
        // [GIVEN] A customer record
        Customer.FindFirst();

        // [WHEN] Print buffer is created with source record
        PrintBuffer := this.TestUtil.CreateTestPrintBuffer(Report::"Customer - List", Customer.RecordId());

        // [THEN] Source Record should match
        StoredRecordId := PrintBuffer."Source Record";
        this.Assert.AreEqual(Customer.RecordId(), StoredRecordId, 'Source Record should match customer RecordId');
        this.Assert.AreEqual(Database::Customer, StoredRecordId.TableNo(), 'TableNo should be Customer table');

    end;
}
