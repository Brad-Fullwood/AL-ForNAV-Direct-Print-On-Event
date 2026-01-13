namespace BradFullwood.ForNAV.Core;

/// <summary>
/// Utilities for registering report sets and printing triggers with the interface.
/// </summary>
/// <remarks>
/// This codeunit handles the registration of providers, report sets, printing triggers,
/// and their associated source table mappings.
/// </remarks>
codeunit 77701 "BJF Interface Utils"
{
    Permissions = tabledata "BJF Provider" = rimd,
                  tabledata "BJF Report Set" = rimd,
                  tabledata "BJF Printing Trigger" = rimd,
                  tabledata "BJF Source Table Mapping" = rimd;

    var
        CurrentProvider: Enum "BJF Direct Print Provider";
        TableBuffer: List of [Integer];


    /// <summary>
    /// Register a report set with a single table.
    /// </summary>
    /// <param name="ReportSetCode">The code of the report set.</param>
    /// <param name="ReportSetName">The name of the report set.</param>
    /// <param name="TableID">The table ID for the report set.</param>
    procedure RegisterReportSet(ReportSetCode: Code[50]; ReportSetName: Text[100]; TableID: Integer)
    var
        TableList: List of [Integer];
    begin
        TableList.Add(TableID);
        this.RegisterReportSet(ReportSetCode, ReportSetName, TableList);
    end;

    /// <summary>
    /// Add a table to the buffer for the next trigger registration.
    /// </summary>
    /// <param name="TableID">The table ID to add to the buffer.</param>
    procedure AddTable(TableID: Integer)
    begin
        this.TableBuffer.Add(TableID);
    end;


    /// <summary>
    /// Register a printing trigger with all tables currently in the buffer, then clear the buffer.
    /// </summary>
    /// <param name="TriggerCode">The code of the printing trigger.</param>
    /// <param name="TriggerName">The name of the printing trigger.</param>
    procedure RegisterTriggerWithTables(TriggerCode: Code[50]; TriggerName: Text[50])
    var
        TableID: Integer;
    begin
        this.InsertTrigger(this.CurrentProvider, TriggerCode, TriggerName);

        // Write to Source Table Mapping table
        foreach TableID in this.TableBuffer do
            this.InsertSourceTableMapping(this.CurrentProvider, Enum::"BJF Mapping Type"::"Trigger", TriggerCode, TableID);

        Clear(this.TableBuffer);
    end;

    internal procedure RegisterReportSet(ReportSetCode: Code[50]; ReportSetName: Text[100]; TableIDs: List of [Integer])
    var
        TableID: Integer;
    begin
        this.InsertReportSet(this.CurrentProvider, ReportSetCode, ReportSetName);

        // Write to Source Table Mapping table
        foreach TableID in TableIDs do
            this.InsertSourceTableMapping(this.CurrentProvider, Enum::"BJF Mapping Type"::"Report Set", ReportSetCode, TableID);
    end;

    internal procedure RegisterAllProviders()
    var
        Helper: Codeunit "BJF Interface Utils";
        Interface: Interface "I-BJF Direct Print Interface";
        Providers: Enum "BJF Direct Print Provider";
        Provider: Enum "BJF Direct Print Provider";
        Description: Text[100];
        DefaultActive: Boolean;
        Ordinal: Integer;
    begin
        foreach Ordinal in Providers.Ordinals() do begin
            Interface := Enum::"BJF Direct Print Provider".FromInteger(Ordinal);

            // Get provider info
            Interface.GetProviderInfo(Provider, Description, DefaultActive);
            this.StartProviderRegistration(Provider, Description, DefaultActive);

            // Register report sets and triggers
            Helper := this;
            Interface.RegisterReportSets(Helper);
            Interface.RegisterTriggers(Helper);
        end;

        this.OnAfterRegisterAllProviders();
    end;

    local procedure StartProviderRegistration(Provider: Enum "BJF Direct Print Provider"; Description: Text[100]; DefaultActive: Boolean)
    var
        ProviderRec: Record "BJF Provider";
    begin
        this.CurrentProvider := Provider;

        ProviderRec.Init();
        ProviderRec."No." := Provider;
        ProviderRec.Description := Description;
        ProviderRec.Active := DefaultActive;

        ProviderRec.SetRecFilter();
        if ProviderRec.IsEmpty() then
            ProviderRec.Insert(true)
        else
            ProviderRec.Modify(true);

        this.OnAfterStartProviderRegistration(Provider, Description);
    end;


    local procedure InsertReportSet(Provider: Enum "BJF Direct Print Provider"; ReportSetID: Code[50]; ReportSetName: Text[100])
    var
        ReportSet: Record "BJF Report Set";
    begin
        ReportSet.Init();
        ReportSet."Provider No." := Provider;
        ReportSet."No." := ReportSetID;
        ReportSet.Description := ReportSetName;

        ReportSet.SetRecFilter();
        if ReportSet.IsEmpty() then
            ReportSet.Insert(true)
        else
            ReportSet.Modify(true);
    end;

    local procedure InsertTrigger(Provider: Enum "BJF Direct Print Provider"; TriggerCode: Code[50]; TriggerDescription: Text[50])
    var
        PrintingTrigger: Record "BJF Printing Trigger";
    begin
        PrintingTrigger.Init();
        PrintingTrigger."Provider No." := Provider;
        PrintingTrigger."No." := TriggerCode;
        PrintingTrigger."Description" := TriggerDescription;

        PrintingTrigger.SetRecFilter();
        if PrintingTrigger.IsEmpty() then
            PrintingTrigger.Insert(true)
        else
            PrintingTrigger.Modify(true);
    end;

    local procedure InsertSourceTableMapping(Provider: Enum "BJF Direct Print Provider"; MappingType: Enum "BJF Mapping Type"; SourceCode: Code[50]; TableID: Integer)
    var
        SourceTableMapping: Record "BJF Source Table Mapping";
    begin
        SourceTableMapping.Init();
        SourceTableMapping."Provider No." := Provider;
        SourceTableMapping."Mapping Type" := MappingType;
        SourceTableMapping."Source Code" := SourceCode;
        SourceTableMapping."Table No." := TableID;
        SourceTableMapping."Source Description" := this.GetSourceDescription(Provider, MappingType, SourceCode);
        SourceTableMapping.Indentation := 1; // Mapping rows are indented under their provider/type

        SourceTableMapping.SetRecFilter();
        if SourceTableMapping.IsEmpty() then
            SourceTableMapping.Insert(true)
        else
            SourceTableMapping.Modify(true);
    end;

    local procedure GetSourceDescription(Provider: Enum "BJF Direct Print Provider"; MappingType: Enum "BJF Mapping Type"; SourceCode: Code[50]): Text[250]
    var
        PrintingTrigger: Record "BJF Printing Trigger";
        ReportSet: Record "BJF Report Set";
    begin
        case MappingType of
            Enum::"BJF Mapping Type"::"Trigger":
                begin
                    PrintingTrigger.SetRange("Provider No.", Provider);
                    PrintingTrigger.SetRange("No.", SourceCode);
                    if PrintingTrigger.FindFirst() then
                        exit(PrintingTrigger.Description);
                end;
            Enum::"BJF Mapping Type"::"Report Set":
                begin
                    ReportSet.SetRange("Provider No.", Provider);
                    ReportSet.SetRange("No.", SourceCode);
                    if ReportSet.FindFirst() then
                        exit(ReportSet.Description);
                end;
        end;
        exit('');
    end;

    internal procedure ClearAllProviders()
    var
        Providers: Record "BJF Provider";
        Triggers: Record "BJF Printing Trigger";
        ReportSets: Record "BJF Report Set";
        Mappings: Record "BJF Source Table Mapping";
    begin
        if not Providers.IsEmpty() then
            Providers.DeleteAll(false);

        if not Triggers.IsEmpty() then
            Triggers.DeleteAll(false);

        if not ReportSets.IsEmpty() then
            ReportSets.DeleteAll(false);

        if not Mappings.IsEmpty() then
            Mappings.DeleteAll(false);
    end;

    /// <summary>
    /// Event raised after all providers have been registered.
    /// </summary>
    [IntegrationEvent(false, false, true)]
    local procedure OnAfterRegisterAllProviders()
    begin
    end;

    /// <summary>
    /// Event raised after a provider has been started.
    /// </summary>
    /// <param name="Provider">The provider that was started.</param>
    /// <param name="Description">The description of the provider.</param>
    [IntegrationEvent(false, false, true)]
    local procedure OnAfterStartProviderRegistration(Provider: Enum "BJF Direct Print Provider"; Description: Text[100])
    begin
    end;
}
