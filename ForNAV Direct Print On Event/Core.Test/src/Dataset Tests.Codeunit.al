namespace BradFullwood.ForNAV.Tests;

using BradFullwood.ForNAV.Core;

/// <summary>
/// Test codeunit for BJF Dataset (77701).
/// Tests entity code validation, EventExists, LabelGroupExists, and table relations.
/// </summary>
codeunit 77805 "BJF Dataset Tests"
{
    Subtype = Test;
    TestPermissions = Restrictive;
    InherentPermissions = x;
    Permissions = tabledata "BJF Dataset" = RIMD,
                 tabledata "BJF Event" = RIMD,
                 tabledata "BJF Label Groups" = RIMD,
                 tabledata "BJF Provider" = RIMD,
                 tabledata Customer = R,
                 tabledata Vendor = R;

    var
        TestUtil: Codeunit "BJF Test Utilities";
        Assert: Codeunit "Library Assert";

    [Test]
    internal procedure EntityCodeValidation_ValidEvent_Succeeds()
    var
        Dataset: Record "BJF Dataset";
        EventRec: Record "BJF Event";
        Provider: Record "BJF Provider";
        EventCode: Code[50];
    begin
        // [GIVEN] A valid event exists
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        EventCode := this.TestUtil.GenerateRandomCode('EV');
        EventRec := this.TestUtil.CreateTestEvent(EventCode, 'Test Event', "BJF Direct Print Provider"::FromInteger(0));

        // [WHEN] Dataset is created with valid event code
        Dataset.Init();
        Dataset."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
        Dataset."Entity Type" := "BJF Dataset Entity Type"::"Event";
        Dataset."Table No." := Database::Customer;
        Dataset.Validate("Entity Code", EventCode);

        // [THEN] Validation should succeed
        this.Assert.AreEqual(EventCode, Dataset."Entity Code", 'Entity Code should be set');

    end;

    [Test]
    internal procedure EntityCodeValidation_InvalidEvent_ThrowsError()
    var
        Dataset: Record "BJF Dataset";
        Provider: Record "BJF Provider";
        ErrorOccurred: Boolean;
    begin
        // [GIVEN] No event exists
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);

        // [WHEN] Dataset is validated with invalid event code
        Dataset.Init();
        Dataset."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
        Dataset."Entity Type" := "BJF Dataset Entity Type"::"Event";
        Dataset."Table No." := Database::Customer;

        ErrorOccurred := false;
        asserterror Dataset.Validate("Entity Code", 'INVALID');
        ErrorOccurred := true;

        // [THEN] Should throw an error
        this.Assert.IsTrue(ErrorOccurred, 'Should throw error for invalid event');

    end;

    [Test]
    internal procedure EntityCodeValidation_ValidLabelGroup_Succeeds()
    var
        Dataset: Record "BJF Dataset";
        LabelGroup: Record "BJF Label Groups";
        Provider: Record "BJF Provider";
        LabelGroupCode: Code[50];
    begin
        // [GIVEN] A valid label group exists
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        LabelGroupCode := this.TestUtil.GenerateRandomCode('LG');
        LabelGroup := this.TestUtil.CreateTestLabelGroup(LabelGroupCode, 'Test Label', "BJF Direct Print Provider"::FromInteger(0));

        // [WHEN] Dataset is created with valid label group code
        Dataset.Init();
        Dataset."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
        Dataset."Entity Type" := "BJF Dataset Entity Type"::"Label Group";
        Dataset."Table No." := Database::Customer;
        Dataset.Validate("Entity Code", LabelGroupCode);

        // [THEN] Validation should succeed
        this.Assert.AreEqual(LabelGroupCode, Dataset."Entity Code", 'Entity Code should be set');

    end;

    [Test]
    internal procedure EntityCodeValidation_InvalidLabelGroup_ThrowsError()
    var
        Dataset: Record "BJF Dataset";
        Provider: Record "BJF Provider";
        ErrorOccurred: Boolean;
    begin
        // [GIVEN] No label group exists
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);

        // [WHEN] Dataset is validated with invalid label group code
        Dataset.Init();
        Dataset."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
        Dataset."Entity Type" := "BJF Dataset Entity Type"::"Label Group";
        Dataset."Table No." := Database::Customer;

        ErrorOccurred := false;
        asserterror Dataset.Validate("Entity Code", 'INVALID');
        ErrorOccurred := true;

        // [THEN] Should throw an error
        this.Assert.IsTrue(ErrorOccurred, 'Should throw error for invalid label group');

    end;

    [Test]
    internal procedure TableNo_ValidTable_Stored()
    var
        Dataset: Record "BJF Dataset";
        EventRec: Record "BJF Event";
        Provider: Record "BJF Provider";
        EventCode: Code[50];
    begin
        // [GIVEN] A valid event
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        EventCode := this.TestUtil.GenerateRandomCode('EV');
        EventRec := this.TestUtil.CreateTestEvent(EventCode, 'Test Event', "BJF Direct Print Provider"::FromInteger(0));

        // [WHEN] Dataset is created with table number
        Dataset := this.TestUtil.CreateTestDataset(
            "BJF Direct Print Provider"::FromInteger(0),
            "BJF Dataset Entity Type"::"Event",
            EventCode,
            Database::Customer
        );

        // [THEN] Table No should be stored correctly
        this.Assert.AreEqual(Database::Customer, Dataset."Table No.", 'Table No should be Customer');

        // [THEN] Table Name flowfield should be calculable
        Dataset.CalcFields("Table Name");
        this.Assert.AreNotEqual('', Dataset."Table Name", 'Table Name should be calculated');

    end;

    [Test]
    internal procedure PrimaryKey_UniqueCombination_AllowsInsert()
    var
        Dataset1: Record "BJF Dataset";
        Dataset2: Record "BJF Dataset";
        EventRec: Record "BJF Event";
        Provider: Record "BJF Provider";
        EventCode: Code[50];
    begin
        // [GIVEN] An event with one dataset
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        EventCode := this.TestUtil.GenerateRandomCode('EV');
        EventRec := this.TestUtil.CreateTestEvent(EventCode, 'Test Event', "BJF Direct Print Provider"::FromInteger(0));
        Dataset1 := this.TestUtil.CreateTestDataset(
            "BJF Direct Print Provider"::FromInteger(0),
            "BJF Dataset Entity Type"::"Event",
            EventCode,
            Database::Customer
        );

        // [WHEN] Another dataset is inserted with different table
        Dataset2 := this.TestUtil.CreateTestDataset(
            "BJF Direct Print Provider"::FromInteger(0),
            "BJF Dataset Entity Type"::"Event",
            EventCode,
            Database::Vendor
        );

        // [THEN] Both records should exist
        Dataset1.Get(
            "BJF Direct Print Provider"::FromInteger(0),
            "BJF Dataset Entity Type"::"Event",
            EventCode,
            Database::Customer
        );
        Dataset2.Get(
            "BJF Direct Print Provider"::FromInteger(0),
            "BJF Dataset Entity Type"::"Event",
            EventCode,
            Database::Vendor
        );

    end;

    [Test]
    internal procedure PrimaryKey_DuplicateCombination_ThrowsError()
    var
        Dataset1: Record "BJF Dataset";
        Dataset2: Record "BJF Dataset";
        EventRec: Record "BJF Event";
        Provider: Record "BJF Provider";
        EventCode: Code[50];
        ErrorOccurred: Boolean;
    begin
        // [GIVEN] An event with one dataset
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        EventCode := this.TestUtil.GenerateRandomCode('EV');
        EventRec := this.TestUtil.CreateTestEvent(EventCode, 'Test Event', "BJF Direct Print Provider"::FromInteger(0));
        Dataset1 := this.TestUtil.CreateTestDataset(
            "BJF Direct Print Provider"::FromInteger(0),
            "BJF Dataset Entity Type"::"Event",
            EventCode,
            Database::Customer
        );

        // [WHEN] Another dataset is inserted with same combination
        Dataset2.Init();
        Dataset2."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
        Dataset2."Entity Type" := "BJF Dataset Entity Type"::"Event";
        Dataset2."Entity Code" := EventCode;
        Dataset2."Table No." := Database::Customer;

        ErrorOccurred := false;
        asserterror Dataset2.Insert(true);
        ErrorOccurred := true;

        // [THEN] Should throw an error
        this.Assert.IsTrue(ErrorOccurred, 'Should throw error for duplicate primary key');

    end;

    [Test]
    internal procedure EntityDescriptionFlowfield_Event_CalculatesCorrectly()
    var
        Dataset: Record "BJF Dataset";
        EventRec: Record "BJF Event";
        Provider: Record "BJF Provider";
        EventCode: Code[50];
        EventDesc: Text[50];
    begin
        // [GIVEN] An event with description
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        EventCode := this.TestUtil.GenerateRandomCode('EV');
        EventDesc := 'Test Event Description';
        EventRec := this.TestUtil.CreateTestEvent(EventCode, EventDesc, "BJF Direct Print Provider"::FromInteger(0));
        Dataset := this.TestUtil.CreateTestDataset(
            "BJF Direct Print Provider"::FromInteger(0),
            "BJF Dataset Entity Type"::"Event",
            EventCode,
            Database::Customer
        );

        // [WHEN] Entity Description flowfield is calculated
        Dataset.CalcFields("Entity Description");

        // [THEN] Should show event description
        this.Assert.AreEqual(EventDesc, Dataset."Entity Description", 'Entity Description should match event description');

    end;

    [Test]
    internal procedure MultipleProviders_DifferentDatasets_IsolatedCorrectly()
    var
        Dataset1: Record "BJF Dataset";
        Dataset2: Record "BJF Dataset";
        Provider1: Record "BJF Provider";
        Provider2: Record "BJF Provider";
        EventRec1: Record "BJF Event";
        EventRec2: Record "BJF Event";
        EventCode: Code[50];
    begin
        // [GIVEN] Two providers with same event code but different providers
        Provider1 := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Provider 1', true);
        Provider2 := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(1), 'Provider 2', true);

        EventCode := 'SAME_CODE';
        EventRec1 := this.TestUtil.CreateTestEvent(EventCode, 'Event 1', "BJF Direct Print Provider"::FromInteger(0));
        EventRec2 := this.TestUtil.CreateTestEvent(EventCode, 'Event 2', "BJF Direct Print Provider"::FromInteger(1));

        // [WHEN] Datasets are created for each provider
        Dataset1 := this.TestUtil.CreateTestDataset(
            "BJF Direct Print Provider"::FromInteger(0),
            "BJF Dataset Entity Type"::"Event",
            EventCode,
            Database::Customer
        );
        Dataset2 := this.TestUtil.CreateTestDataset(
            "BJF Direct Print Provider"::FromInteger(1),
            "BJF Dataset Entity Type"::"Event",
            EventCode,
            Database::Customer
        );

        // [THEN] Both datasets should exist independently
        Dataset1.Get("BJF Direct Print Provider"::FromInteger(0), "BJF Dataset Entity Type"::"Event", EventCode, Database::Customer);
        Dataset2.Get("BJF Direct Print Provider"::FromInteger(1), "BJF Dataset Entity Type"::"Event", EventCode, Database::Customer);

    end;
}
