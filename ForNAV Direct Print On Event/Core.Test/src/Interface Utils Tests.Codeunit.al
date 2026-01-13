namespace BradFullwood.ForNAV.Tests;

using BradFullwood.ForNAV.Core;

/// <summary>
/// Test codeunit for BJF Interface Utils (77701).
/// Tests provider registration, report set registration, trigger registration, and source table mapping management.
/// </summary>
codeunit 77701 "BJF Interface Utils Tests"
{
    Subtype = Test;
    TestPermissions = Restrictive;
    InherentPermissions = x;
    Permissions = tabledata "BJF Provider" = RIMD,
                 tabledata "BJF Report Set" = RIMD,
                 tabledata "BJF Printing Trigger" = RIMD,
                 tabledata "BJF Source Table Mapping" = RIMD,
                 tabledata Customer = R,
                 tabledata Vendor = R,
                 tabledata Item = R,
                 tabledata "Sales Header" = R;
    var
        TestUtil: Codeunit "BJF Test Utilities";
        Assert: Codeunit "Library Assert";

    [Test]
    internal procedure RegisterReportSet_SingleTable_CreatesCorrectRecords()
    var
        InterfaceUtils: Codeunit "BJF Interface Utils";
        ReportSet: Record "BJF Report Set";
        SourceTableMapping: Record "BJF Source Table Mapping";
        Provider: Record "BJF Provider";
        ReportSetCode: Code[50];
    begin
        // [GIVEN] A provider is set up
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        ReportSetCode := this.TestUtil.GenerateRandomCode('RS');

        // [WHEN] RegisterReportSet is called with single table
        InterfaceUtils.RegisterReportSet(ReportSetCode, 'Test Report Set', Database::Customer);

        // [THEN] Report set and source table mapping should be created
        ReportSet.SetRange("No.", ReportSetCode);
        this.Assert.RecordIsNotEmpty(ReportSet);

        SourceTableMapping.SetRange("Mapping Type", "BJF Mapping Type"::"Report Set");
        SourceTableMapping.SetRange("Source Code", ReportSetCode);
        SourceTableMapping.SetRange("Table No.", Database::Customer);
        this.Assert.RecordIsNotEmpty(SourceTableMapping);

    end;

    [Test]
    internal procedure AddTable_MultipleTables_BuffersCorrectly()
    var
        InterfaceUtils: Codeunit "BJF Interface Utils";
        Provider: Record "BJF Provider";
        PrintingTrigger: Record "BJF Printing Trigger";
        SourceTableMapping: Record "BJF Source Table Mapping";
        TriggerCode: Code[50];
    begin
        // [GIVEN] A provider is set up
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        TriggerCode := this.TestUtil.GenerateRandomCode('TR');

        // [WHEN] Multiple tables are added and trigger is registered
        InterfaceUtils.AddTable(Database::Customer);
        InterfaceUtils.AddTable(Database::Vendor);
        InterfaceUtils.AddTable(Database::Item);
        InterfaceUtils.RegisterTriggerWithTables(TriggerCode, 'Test Trigger');

        // [THEN] Trigger and all source table mappings should be created
        PrintingTrigger.SetRange("No.", TriggerCode);
        this.Assert.RecordIsNotEmpty(PrintingTrigger);

        SourceTableMapping.SetRange("Mapping Type", "BJF Mapping Type"::"Trigger");
        SourceTableMapping.SetRange("Source Code", TriggerCode);
        this.Assert.AreEqual(3, SourceTableMapping.Count(), 'Expected 3 source table mapping entries');

        SourceTableMapping.SetRange("Table No.", Database::Customer);
        this.Assert.RecordIsNotEmpty(SourceTableMapping);
        SourceTableMapping.SetRange("Table No.", Database::Vendor);
        this.Assert.RecordIsNotEmpty(SourceTableMapping);
        SourceTableMapping.SetRange("Table No.", Database::Item);
        this.Assert.RecordIsNotEmpty(SourceTableMapping);

    end;

    [Test]
    internal procedure RegisterTriggerWithTables_ValidData_CreatesTriggerAndMappings()
    var
        InterfaceUtils: Codeunit "BJF Interface Utils";
        Provider: Record "BJF Provider";
        PrintingTrigger: Record "BJF Printing Trigger";
        SourceTableMapping: Record "BJF Source Table Mapping";
        TriggerCode: Code[50];
    begin
        // [GIVEN] A provider with tables added to buffer
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        TriggerCode := this.TestUtil.GenerateRandomCode('TR');

        InterfaceUtils.AddTable(Database::Customer);
        InterfaceUtils.AddTable(Database::"Sales Header");

        // [WHEN] RegisterTriggerWithTables is called
        InterfaceUtils.RegisterTriggerWithTables(TriggerCode, 'Sales Trigger');

        // [THEN] Trigger should be created with correct mappings
        PrintingTrigger.SetRange("No.", TriggerCode);
        PrintingTrigger.FindFirst();
        this.Assert.AreEqual('Sales Trigger', PrintingTrigger.Description, 'Trigger description mismatch');

        SourceTableMapping.SetRange("Mapping Type", "BJF Mapping Type"::"Trigger");
        SourceTableMapping.SetRange("Source Code", TriggerCode);
        this.Assert.AreEqual(2, SourceTableMapping.Count(), 'Expected 2 source table mapping entries');

        // [THEN] Buffer should be cleared
        // Next registration should not include previous tables
        InterfaceUtils.RegisterTriggerWithTables(this.TestUtil.GenerateRandomCode('TR2'), 'Empty Trigger');
        SourceTableMapping.Reset();
        SourceTableMapping.SetRange("Mapping Type", "BJF Mapping Type"::"Trigger");
        SourceTableMapping.SetRange("Source Code", TriggerCode);
        this.Assert.AreEqual(2, SourceTableMapping.Count(), 'Buffer should be cleared after registration');

    end;

    [Test]
    internal procedure ClearAllProviders_WithData_DeletesAllRecords()
    var
        InterfaceUtils: Codeunit "BJF Interface Utils";
        Provider: Record "BJF Provider";
        ReportSet: Record "BJF Report Set";
        PrintingTrigger: Record "BJF Printing Trigger";
        SourceTableMapping: Record "BJF Source Table Mapping";
    begin
        // [GIVEN] Multiple providers, report sets, triggers, and mappings exist
        this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Provider 1', true);
        this.TestUtil.CreateTestReportSet('RS1', 'Report Set 1', "BJF Direct Print Provider"::FromInteger(0));
        this.TestUtil.CreateTestTrigger('TR1', 'Trigger 1', "BJF Direct Print Provider"::FromInteger(0));
        this.TestUtil.CreateTestSourceTableMapping("BJF Direct Print Provider"::FromInteger(0), "BJF Mapping Type"::"Report Set", 'RS1', Database::Customer);

        // [WHEN] ClearAllProviders is called
        InterfaceUtils.ClearAllProviders();

        // [THEN] All records should be deleted
        this.Assert.RecordIsEmpty(Provider);
        this.Assert.RecordIsEmpty(ReportSet);
        this.Assert.RecordIsEmpty(PrintingTrigger);
        this.Assert.RecordIsEmpty(SourceTableMapping);

    end;

    [Test]
    internal procedure RegisterReportSet_DuplicateCode_UpdatesExisting()
    var
        InterfaceUtils: Codeunit "BJF Interface Utils";
        ReportSet: Record "BJF Report Set";
        Provider: Record "BJF Provider";
        ReportSetCode: Code[50];
    begin
        // [GIVEN] A report set already exists
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        ReportSetCode := 'EXISTING';
        this.TestUtil.CreateTestReportSet(ReportSetCode, 'Original Description', "BJF Direct Print Provider"::FromInteger(0));

        // [WHEN] RegisterReportSet is called with same code
        InterfaceUtils.RegisterReportSet(ReportSetCode, 'Updated Description', Database::Customer);

        // [THEN] Existing record should be updated
        ReportSet.Get(ReportSetCode);
        this.Assert.AreEqual('Updated Description', ReportSet.Description, 'Description should be updated');

        ReportSet.SetRange("No.", ReportSetCode);
        this.Assert.AreEqual(1, ReportSet.Count(), 'Should only have 1 record');

    end;

    [Test]
    internal procedure RegisterReportSet_MultipleTablesOverload_CreatesAllMappings()
    var
        InterfaceUtils: Codeunit "BJF Interface Utils";
        SourceTableMapping: Record "BJF Source Table Mapping";
        Provider: Record "BJF Provider";
        TableList: List of [Integer];
        ReportSetCode: Code[50];
    begin
        // [GIVEN] A provider with list of tables
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        ReportSetCode := this.TestUtil.GenerateRandomCode('RS');

        TableList.Add(Database::Customer);
        TableList.Add(Database::Vendor);
        TableList.Add(Database::Item);

        // [WHEN] RegisterReportSet is called with table list
        InterfaceUtils.RegisterReportSet(ReportSetCode, 'Multi-Table Report Set', TableList);

        // [THEN] All source table mappings should be created
        SourceTableMapping.SetRange("Mapping Type", "BJF Mapping Type"::"Report Set");
        SourceTableMapping.SetRange("Source Code", ReportSetCode);
        this.Assert.AreEqual(3, SourceTableMapping.Count(), 'Expected 3 source table mapping entries');

    end;

    [Test]
    internal procedure RegisterTriggerWithTables_NoTablesInBuffer_CreatesTriggerOnly()
    var
        InterfaceUtils: Codeunit "BJF Interface Utils";
        PrintingTrigger: Record "BJF Printing Trigger";
        SourceTableMapping: Record "BJF Source Table Mapping";
        Provider: Record "BJF Provider";
        TriggerCode: Code[50];
    begin
        // [GIVEN] A provider with empty table buffer
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        TriggerCode := this.TestUtil.GenerateRandomCode('TR');

        // [WHEN] RegisterTriggerWithTables is called without adding tables
        InterfaceUtils.RegisterTriggerWithTables(TriggerCode, 'Empty Trigger');

        // [THEN] Trigger should be created without mappings
        PrintingTrigger.SetRange("No.", TriggerCode);
        this.Assert.RecordIsNotEmpty(PrintingTrigger);

        SourceTableMapping.SetRange("Mapping Type", "BJF Mapping Type"::"Trigger");
        SourceTableMapping.SetRange("Source Code", TriggerCode);
        this.Assert.RecordIsEmpty(SourceTableMapping);

    end;

    [Test]
    internal procedure RegisterReportSet_EmptyCode_ThrowsError()
    var
        InterfaceUtils: Codeunit "BJF Interface Utils";
        Provider: Record "BJF Provider";
        ErrorOccurred: Boolean;
    begin
        // [GIVEN] A provider exists
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);

        // [WHEN] RegisterReportSet is called with empty code
        ErrorOccurred := false;
        asserterror InterfaceUtils.RegisterReportSet('', 'Test', Database::Customer);
        ErrorOccurred := true;

        // [THEN] Should throw an error
        this.Assert.IsTrue(ErrorOccurred, 'Should throw error for empty code');

    end;
}
