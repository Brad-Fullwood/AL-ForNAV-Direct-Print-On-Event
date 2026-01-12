namespace BradFullwood.ForNAV.Tests;

using BradFullwood.ForNAV.Core;

/// <summary>
/// Test codeunit for BJF Interface Utils (77701).
/// Tests provider registration, label group registration, event registration, and dataset management.
/// </summary>
codeunit 77801 "BJF Interface Utils Tests"
{
    Subtype = Test;
    TestPermissions = Restrictive;
    InherentPermissions = x;
    Permissions = tabledata "BJF Provider" = RIMD,
                 tabledata "BJF Label Groups" = RIMD,
                 tabledata "BJF Event" = RIMD,
                 tabledata "BJF Dataset" = RIMD,
                 tabledata Customer = R,
                 tabledata Vendor = R,
                 tabledata Item = R,
                 tabledata "Sales Header" = R;
    var
        TestUtil: Codeunit "BJF Test Utilities";
        Assert: Codeunit "Library Assert";

    [Test]
    internal procedure RegisterLabelGroup_SingleTable_CreatesCorrectRecords()
    var
        InterfaceUtils: Codeunit "BJF Interface Utils";
        LabelGroup: Record "BJF Label Groups";
        Dataset: Record "BJF Dataset";
        Provider: Record "BJF Provider";
        LabelGroupCode: Code[50];
    begin
        // [GIVEN] A provider is set up
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        LabelGroupCode := this.TestUtil.GenerateRandomCode('LG');

        // [WHEN] RegisterLabelGroup is called with single table
        InterfaceUtils.RegisterLabelGroup(LabelGroupCode, 'Test Label Group', Database::Customer);

        // [THEN] Label group and dataset should be created
        LabelGroup.SetRange("No.", LabelGroupCode);
        this.Assert.RecordIsNotEmpty(LabelGroup);

        Dataset.SetRange("Entity Type", "BJF Dataset Entity Type"::"Label Group");
        Dataset.SetRange("Entity Code", LabelGroupCode);
        Dataset.SetRange("Table No.", Database::Customer);
        this.Assert.RecordIsNotEmpty(Dataset);

    end;

    [Test]
    internal procedure AddTable_MultipleTables_BuffersCorrectly()
    var
        InterfaceUtils: Codeunit "BJF Interface Utils";
        Provider: Record "BJF Provider";
        EventRec: Record "BJF Event";
        Dataset: Record "BJF Dataset";
        EventCode: Code[50];
    begin
        // [GIVEN] A provider is set up
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        EventCode := this.TestUtil.GenerateRandomCode('EV');

        // [WHEN] Multiple tables are added and event is registered
        InterfaceUtils.AddTable(Database::Customer);
        InterfaceUtils.AddTable(Database::Vendor);
        InterfaceUtils.AddTable(Database::Item);
        InterfaceUtils.RegisterEventWithTables(EventCode, 'Test Event');

        // [THEN] Event and all datasets should be created
        EventRec.SetRange("No.", EventCode);
        this.Assert.RecordIsNotEmpty(EventRec);

        Dataset.SetRange("Entity Type", "BJF Dataset Entity Type"::"Event");
        Dataset.SetRange("Entity Code", EventCode);
        this.Assert.AreEqual(3, Dataset.Count(), 'Expected 3 dataset entries');

        Dataset.SetRange("Table No.", Database::Customer);
        this.Assert.RecordIsNotEmpty(Dataset);
        Dataset.SetRange("Table No.", Database::Vendor);
        this.Assert.RecordIsNotEmpty(Dataset);
        Dataset.SetRange("Table No.", Database::Item);
        this.Assert.RecordIsNotEmpty(Dataset);

    end;

    [Test]
    internal procedure RegisterEventWithTables_ValidData_CreatesEventAndDatasets()
    var
        InterfaceUtils: Codeunit "BJF Interface Utils";
        Provider: Record "BJF Provider";
        EventRec: Record "BJF Event";
        Dataset: Record "BJF Dataset";
        EventCode: Code[50];
    begin
        // [GIVEN] A provider with tables added to buffer
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        EventCode := this.TestUtil.GenerateRandomCode('EV');

        InterfaceUtils.AddTable(Database::Customer);
        InterfaceUtils.AddTable(Database::"Sales Header");

        // [WHEN] RegisterEventWithTables is called
        InterfaceUtils.RegisterEventWithTables(EventCode, 'Sales Event');

        // [THEN] Event should be created with correct datasets
        EventRec.SetRange("No.", EventCode);
        EventRec.FindFirst();
        this.Assert.AreEqual('Sales Event', EventRec.Description, 'Event description mismatch');

        Dataset.SetRange("Entity Type", "BJF Dataset Entity Type"::"Event");
        Dataset.SetRange("Entity Code", EventCode);
        this.Assert.AreEqual(2, Dataset.Count(), 'Expected 2 dataset entries');

        // [THEN] Buffer should be cleared
        // Next registration should not include previous tables
        InterfaceUtils.RegisterEventWithTables(this.TestUtil.GenerateRandomCode('EV2'), 'Empty Event');
        Dataset.Reset();
        Dataset.SetRange("Entity Type", "BJF Dataset Entity Type"::"Event");
        Dataset.SetRange("Entity Code", EventCode);
        this.Assert.AreEqual(2, Dataset.Count(), 'Buffer should be cleared after registration');

    end;

    [Test]
    internal procedure ClearAllProviders_WithData_DeletesAllRecords()
    var
        InterfaceUtils: Codeunit "BJF Interface Utils";
        Provider: Record "BJF Provider";
        LabelGroup: Record "BJF Label Groups";
        EventRec: Record "BJF Event";
        Dataset: Record "BJF Dataset";
    begin
        // [GIVEN] Multiple providers, label groups, events, and datasets exist
        this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Provider 1', true);
        this.TestUtil.CreateTestLabelGroup('LG1', 'Label Group 1', "BJF Direct Print Provider"::FromInteger(0));
        this.TestUtil.CreateTestEvent('EV1', 'Event 1', "BJF Direct Print Provider"::FromInteger(0));
        this.TestUtil.CreateTestDataset("BJF Direct Print Provider"::FromInteger(0), "BJF Dataset Entity Type"::"Label Group", 'LG1', Database::Customer);

        // [WHEN] ClearAllProviders is called
        InterfaceUtils.ClearAllProviders();

        // [THEN] All records should be deleted
        this.Assert.RecordIsEmpty(Provider);
        this.Assert.RecordIsEmpty(LabelGroup);
        this.Assert.RecordIsEmpty(EventRec);
        this.Assert.RecordIsEmpty(Dataset);

    end;

    [Test]
    internal procedure RegisterLabelGroup_DuplicateCode_UpdatesExisting()
    var
        InterfaceUtils: Codeunit "BJF Interface Utils";
        LabelGroup: Record "BJF Label Groups";
        Provider: Record "BJF Provider";
        LabelGroupCode: Code[50];
    begin
        // [GIVEN] A label group already exists
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        LabelGroupCode := 'EXISTING';
        this.TestUtil.CreateTestLabelGroup(LabelGroupCode, 'Original Description', "BJF Direct Print Provider"::FromInteger(0));

        // [WHEN] RegisterLabelGroup is called with same code
        InterfaceUtils.RegisterLabelGroup(LabelGroupCode, 'Updated Description', Database::Customer);

        // [THEN] Existing record should be updated
        LabelGroup.Get(LabelGroupCode);
        this.Assert.AreEqual('Updated Description', LabelGroup.Description, 'Description should be updated');

        LabelGroup.SetRange("No.", LabelGroupCode);
        this.Assert.AreEqual(1, LabelGroup.Count(), 'Should only have 1 record');

    end;

    [Test]
    internal procedure RegisterLabelGroup_MultipleTablesOverload_CreatesAllDatasets()
    var
        InterfaceUtils: Codeunit "BJF Interface Utils";
        Dataset: Record "BJF Dataset";
        Provider: Record "BJF Provider";
        TableList: List of [Integer];
        LabelGroupCode: Code[50];
    begin
        // [GIVEN] A provider with list of tables
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        LabelGroupCode := this.TestUtil.GenerateRandomCode('LG');

        TableList.Add(Database::Customer);
        TableList.Add(Database::Vendor);
        TableList.Add(Database::Item);

        // [WHEN] RegisterLabelGroup is called with table list
        InterfaceUtils.RegisterLabelGroup(LabelGroupCode, 'Multi-Table Label', TableList);

        // [THEN] All datasets should be created
        Dataset.SetRange("Entity Type", "BJF Dataset Entity Type"::"Label Group");
        Dataset.SetRange("Entity Code", LabelGroupCode);
        this.Assert.AreEqual(3, Dataset.Count(), 'Expected 3 dataset entries');

    end;

    [Test]
    internal procedure RegisterEventWithTables_NoTablesInBuffer_CreatesEventOnly()
    var
        InterfaceUtils: Codeunit "BJF Interface Utils";
        EventRec: Record "BJF Event";
        Dataset: Record "BJF Dataset";
        Provider: Record "BJF Provider";
        EventCode: Code[50];
    begin
        // [GIVEN] A provider with empty table buffer
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        EventCode := this.TestUtil.GenerateRandomCode('EV');

        // [WHEN] RegisterEventWithTables is called without adding tables
        InterfaceUtils.RegisterEventWithTables(EventCode, 'Empty Event');

        // [THEN] Event should be created without datasets
        EventRec.SetRange("No.", EventCode);
        this.Assert.RecordIsNotEmpty(EventRec);

        Dataset.SetRange("Entity Type", "BJF Dataset Entity Type"::"Event");
        Dataset.SetRange("Entity Code", EventCode);
        this.Assert.RecordIsEmpty(Dataset);

    end;

    [Test]
    internal procedure RegisterLabelGroup_EmptyCode_ThrowsError()
    var
        InterfaceUtils: Codeunit "BJF Interface Utils";
        Provider: Record "BJF Provider";
        ErrorOccurred: Boolean;
    begin
        // [GIVEN] A provider exists
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);

        // [WHEN] RegisterLabelGroup is called with empty code
        ErrorOccurred := false;
        asserterror InterfaceUtils.RegisterLabelGroup('', 'Test', Database::Customer);
        ErrorOccurred := true;

        // [THEN] Should throw an error
        this.Assert.IsTrue(ErrorOccurred, 'Should throw error for empty code');

    end;
}
