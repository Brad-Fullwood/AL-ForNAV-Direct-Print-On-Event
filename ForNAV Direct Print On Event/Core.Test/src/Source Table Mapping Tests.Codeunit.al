namespace BradFullwood.ForNAV.Tests;

using BradFullwood.ForNAV.Core;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;

/// <summary>
/// Test codeunit for BJF Source Table Mapping (77701).
/// Tests source code validation, TriggerExists, ReportSetExists, and table relations.
/// </summary>
codeunit 77705 "BJF Source Table Mapping Tests"
{
    Subtype = Test;
    TestPermissions = Restrictive;
    InherentPermissions = x;
    Permissions = tabledata "BJF Source Table Mapping" = RIMD,
                 tabledata "BJF Printing Trigger" = RIMD,
                 tabledata "BJF Report Set" = RIMD,
                 tabledata "BJF Provider" = RIMD,
                 tabledata Customer = R,
                 tabledata Vendor = R;

    var
        TestUtil: Codeunit "BJF Test Utilities";
        Assert: Codeunit "Library Assert";

    [Test]
    internal procedure SourceCodeValidation_ValidTrigger_Succeeds()
    var
        SourceTableMapping: Record "BJF Source Table Mapping";
        PrintingTrigger: Record "BJF Printing Trigger";
        Provider: Record "BJF Provider";
        TriggerCode: Code[50];
    begin
        // [GIVEN] A valid trigger exists
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        TriggerCode := this.TestUtil.GenerateRandomCode('TR');
        PrintingTrigger := this.TestUtil.CreateTestTrigger(TriggerCode, 'Test Trigger', "BJF Direct Print Provider"::FromInteger(0));

        // [WHEN] Source Table Mapping is created with valid trigger code
        SourceTableMapping.Init();
        SourceTableMapping."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
        SourceTableMapping."Mapping Type" := "BJF Mapping Type"::"Trigger";
        SourceTableMapping."Table No." := Database::Customer;
        SourceTableMapping.Validate("Source Code", TriggerCode);

        // [THEN] Validation should succeed
        this.Assert.AreEqual(TriggerCode, SourceTableMapping."Source Code", 'Source Code should be set');

    end;

    [Test]
    internal procedure SourceCodeValidation_InvalidTrigger_ThrowsError()
    var
        SourceTableMapping: Record "BJF Source Table Mapping";
        Provider: Record "BJF Provider";
        ErrorOccurred: Boolean;
    begin
        // [GIVEN] No trigger exists
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);

        // [WHEN] Source Table Mapping is validated with invalid trigger code
        SourceTableMapping.Init();
        SourceTableMapping."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
        SourceTableMapping."Mapping Type" := "BJF Mapping Type"::"Trigger";
        SourceTableMapping."Table No." := Database::Customer;

        ErrorOccurred := false;
        asserterror SourceTableMapping.Validate("Source Code", 'INVALID');
        ErrorOccurred := true;

        // [THEN] Should throw an error
        this.Assert.IsTrue(ErrorOccurred, 'Should throw error for invalid trigger');

    end;

    [Test]
    internal procedure SourceCodeValidation_ValidReportSet_Succeeds()
    var
        SourceTableMapping: Record "BJF Source Table Mapping";
        ReportSet: Record "BJF Report Set";
        Provider: Record "BJF Provider";
        ReportSetCode: Code[50];
    begin
        // [GIVEN] A valid report set exists
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        ReportSetCode := this.TestUtil.GenerateRandomCode('RS');
        ReportSet := this.TestUtil.CreateTestReportSet(ReportSetCode, 'Test Report Set', "BJF Direct Print Provider"::FromInteger(0));

        // [WHEN] Source Table Mapping is created with valid report set code
        SourceTableMapping.Init();
        SourceTableMapping."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
        SourceTableMapping."Mapping Type" := "BJF Mapping Type"::"Report Set";
        SourceTableMapping."Table No." := Database::Customer;
        SourceTableMapping.Validate("Source Code", ReportSetCode);

        // [THEN] Validation should succeed
        this.Assert.AreEqual(ReportSetCode, SourceTableMapping."Source Code", 'Source Code should be set');

    end;

    [Test]
    internal procedure SourceCodeValidation_InvalidReportSet_ThrowsError()
    var
        SourceTableMapping: Record "BJF Source Table Mapping";
        Provider: Record "BJF Provider";
        ErrorOccurred: Boolean;
    begin
        // [GIVEN] No report set exists
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);

        // [WHEN] Source Table Mapping is validated with invalid report set code
        SourceTableMapping.Init();
        SourceTableMapping."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
        SourceTableMapping."Mapping Type" := "BJF Mapping Type"::"Report Set";
        SourceTableMapping."Table No." := Database::Customer;

        ErrorOccurred := false;
        asserterror SourceTableMapping.Validate("Source Code", 'INVALID');
        ErrorOccurred := true;

        // [THEN] Should throw an error
        this.Assert.IsTrue(ErrorOccurred, 'Should throw error for invalid report set');

    end;

    [Test]
    internal procedure TableNo_ValidTable_Stored()
    var
        SourceTableMapping: Record "BJF Source Table Mapping";
        PrintingTrigger: Record "BJF Printing Trigger";
        Provider: Record "BJF Provider";
        TriggerCode: Code[50];
    begin
        // [GIVEN] A valid trigger
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        TriggerCode := this.TestUtil.GenerateRandomCode('TR');
        PrintingTrigger := this.TestUtil.CreateTestTrigger(TriggerCode, 'Test Trigger', "BJF Direct Print Provider"::FromInteger(0));

        // [WHEN] Source Table Mapping is created with table number
        SourceTableMapping := this.TestUtil.CreateTestSourceTableMapping(
            "BJF Direct Print Provider"::FromInteger(0),
            "BJF Mapping Type"::"Trigger",
            TriggerCode,
            Database::Customer
        );

        // [THEN] Table No should be stored correctly
        this.Assert.AreEqual(Database::Customer, SourceTableMapping."Table No.", 'Table No should be Customer');

        // [THEN] Source Table flowfield should be calculable
        SourceTableMapping.CalcFields("Source Table");
        this.Assert.AreNotEqual('', SourceTableMapping."Source Table", 'Source Table should be calculated');

    end;

    [Test]
    internal procedure PrimaryKey_UniqueCombination_AllowsInsert()
    var
        Mapping1: Record "BJF Source Table Mapping";
        Mapping2: Record "BJF Source Table Mapping";
        PrintingTrigger: Record "BJF Printing Trigger";
        Provider: Record "BJF Provider";
        TriggerCode: Code[50];
    begin
        // [GIVEN] A trigger with one mapping
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        TriggerCode := this.TestUtil.GenerateRandomCode('TR');
        PrintingTrigger := this.TestUtil.CreateTestTrigger(TriggerCode, 'Test Trigger', "BJF Direct Print Provider"::FromInteger(0));
        Mapping1 := this.TestUtil.CreateTestSourceTableMapping(
            "BJF Direct Print Provider"::FromInteger(0),
            "BJF Mapping Type"::"Trigger",
            TriggerCode,
            Database::Customer
        );

        // [WHEN] Another mapping is inserted with different table
        Mapping2 := this.TestUtil.CreateTestSourceTableMapping(
            "BJF Direct Print Provider"::FromInteger(0),
            "BJF Mapping Type"::"Trigger",
            TriggerCode,
            Database::Vendor
        );

        // [THEN] Both records should exist
        Mapping1.Get(
            "BJF Direct Print Provider"::FromInteger(0),
            "BJF Mapping Type"::"Trigger",
            TriggerCode,
            Database::Customer
        );
        Mapping2.Get(
            "BJF Direct Print Provider"::FromInteger(0),
            "BJF Mapping Type"::"Trigger",
            TriggerCode,
            Database::Vendor
        );

    end;

    [Test]
    internal procedure PrimaryKey_DuplicateCombination_ThrowsError()
    var
        Mapping1: Record "BJF Source Table Mapping";
        Mapping2: Record "BJF Source Table Mapping";
        PrintingTrigger: Record "BJF Printing Trigger";
        Provider: Record "BJF Provider";
        TriggerCode: Code[50];
        ErrorOccurred: Boolean;
    begin
        // [GIVEN] A trigger with one mapping
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        TriggerCode := this.TestUtil.GenerateRandomCode('TR');
        PrintingTrigger := this.TestUtil.CreateTestTrigger(TriggerCode, 'Test Trigger', "BJF Direct Print Provider"::FromInteger(0));
        Mapping1 := this.TestUtil.CreateTestSourceTableMapping(
            "BJF Direct Print Provider"::FromInteger(0),
            "BJF Mapping Type"::"Trigger",
            TriggerCode,
            Database::Customer
        );

        // [WHEN] Another mapping is inserted with same combination
        Mapping2.Init();
        Mapping2."Provider No." := "BJF Direct Print Provider"::FromInteger(0);
        Mapping2."Mapping Type" := "BJF Mapping Type"::"Trigger";
        Mapping2."Source Code" := TriggerCode;
        Mapping2."Table No." := Database::Customer;

        ErrorOccurred := false;
        asserterror Mapping2.Insert(true);
        ErrorOccurred := true;

        // [THEN] Should throw an error
        this.Assert.IsTrue(ErrorOccurred, 'Should throw error for duplicate primary key');

    end;

    [Test]
    internal procedure SourceDescription_Trigger_PopulatedCorrectly()
    var
        SourceTableMapping: Record "BJF Source Table Mapping";
        PrintingTrigger: Record "BJF Printing Trigger";
        Provider: Record "BJF Provider";
        TriggerCode: Code[50];
        TriggerDesc: Text[50];
    begin
        // [GIVEN] A trigger with description
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        TriggerCode := this.TestUtil.GenerateRandomCode('TR');
        TriggerDesc := 'Test Trigger Description';
        PrintingTrigger := this.TestUtil.CreateTestTrigger(TriggerCode, TriggerDesc, "BJF Direct Print Provider"::FromInteger(0));

        // [WHEN] Source Table Mapping is created
        SourceTableMapping := this.TestUtil.CreateTestSourceTableMapping(
            "BJF Direct Print Provider"::FromInteger(0),
            "BJF Mapping Type"::"Trigger",
            TriggerCode,
            Database::Customer
        );

        // [THEN] Source Description should be populated from trigger
        this.Assert.AreEqual(TriggerDesc, SourceTableMapping."Source Description", 'Source Description should match trigger description');
    end;

    [Test]
    internal procedure SourceDescription_ReportSet_PopulatedCorrectly()
    var
        SourceTableMapping: Record "BJF Source Table Mapping";
        ReportSet: Record "BJF Report Set";
        Provider: Record "BJF Provider";
        ReportSetCode: Code[50];
        ReportSetDesc: Text[100];
    begin
        // [GIVEN] A report set with description
        Provider := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Test Provider', true);
        ReportSetCode := this.TestUtil.GenerateRandomCode('RS');
        ReportSetDesc := 'Test Report Set Description';
        ReportSet := this.TestUtil.CreateTestReportSet(ReportSetCode, ReportSetDesc, "BJF Direct Print Provider"::FromInteger(0));

        // [WHEN] Source Table Mapping is created
        SourceTableMapping := this.TestUtil.CreateTestSourceTableMapping(
            "BJF Direct Print Provider"::FromInteger(0),
            "BJF Mapping Type"::"Report Set",
            ReportSetCode,
            Database::Customer
        );

        // [THEN] Source Description should be populated from report set
        this.Assert.AreEqual(ReportSetDesc, SourceTableMapping."Source Description", 'Source Description should match report set description');
    end;

    [Test]
    internal procedure MultipleProviders_DifferentMappings_IsolatedCorrectly()
    var
        Mapping1: Record "BJF Source Table Mapping";
        Mapping2: Record "BJF Source Table Mapping";
        Provider1: Record "BJF Provider";
        Provider2: Record "BJF Provider";
        Trigger1: Record "BJF Printing Trigger";
        Trigger2: Record "BJF Printing Trigger";
        TriggerCode: Code[50];
    begin
        // [GIVEN] Two providers with same trigger code but different providers
        Provider1 := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(0), 'Provider 1', true);
        Provider2 := this.TestUtil.CreateTestProvider("BJF Direct Print Provider"::FromInteger(1), 'Provider 2', true);

        TriggerCode := 'SAME_CODE';
        Trigger1 := this.TestUtil.CreateTestTrigger(TriggerCode, 'Trigger 1', "BJF Direct Print Provider"::FromInteger(0));
        Trigger2 := this.TestUtil.CreateTestTrigger(TriggerCode, 'Trigger 2', "BJF Direct Print Provider"::FromInteger(1));

        // [WHEN] Mappings are created for each provider
        Mapping1 := this.TestUtil.CreateTestSourceTableMapping(
            "BJF Direct Print Provider"::FromInteger(0),
            "BJF Mapping Type"::"Trigger",
            TriggerCode,
            Database::Customer
        );
        Mapping2 := this.TestUtil.CreateTestSourceTableMapping(
            "BJF Direct Print Provider"::FromInteger(1),
            "BJF Mapping Type"::"Trigger",
            TriggerCode,
            Database::Customer
        );

        // [THEN] Both mappings should exist independently
        Mapping1.Get("BJF Direct Print Provider"::FromInteger(0), "BJF Mapping Type"::"Trigger", TriggerCode, Database::Customer);
        Mapping2.Get("BJF Direct Print Provider"::FromInteger(1), "BJF Mapping Type"::"Trigger", TriggerCode, Database::Customer);

    end;
}
