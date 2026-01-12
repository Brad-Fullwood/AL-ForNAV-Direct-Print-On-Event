namespace BradFullwood.ForNAV.Core;

/// <summary>
/// Utilities for registering label groups and events with the interface.
/// </summary>
/// <remarks>
/// This codeunit is used to register label groups and events with the interface.
/// It is used to ensure that the label groups and events are registered with the interface.
/// </remarks>
codeunit 77701 "BJF Interface Utils"
{
    Permissions = tabledata "BJF Provider" = rimd,
                  tabledata "BJF Label Groups" = rimd,
                  tabledata "BJF Event" = rimd,
                  tabledata "BJF Dataset" = rimd;

    var
        CurrentProvider: Enum "BJF Direct Print Provider";
        TableBuffer: List of [Integer];


    /// <summary>
    /// Register a label group with a single table.
    /// </summary>
    /// <param name="LabelGroupCode">The code of the label group.</param>
    /// <param name="LabelGroupName">The name of the label group.</param>
    /// <param name="TableID">The table ID of the label group.</param>
    procedure RegisterLabelGroup(LabelGroupCode: Code[50]; LabelGroupName: Text[100]; TableID: Integer)
    var
        TableList: List of [Integer];
    begin
        TableList.Add(TableID);
        this.RegisterLabelGroup(LabelGroupCode, LabelGroupName, TableList);
    end;

    /// <summary>
    /// Add a table to the buffer for the next event registration.
    /// </summary>
    /// <param name="TableID">The table ID to add to the buffer.</param>
    procedure AddTable(TableID: Integer)
    begin
        this.TableBuffer.Add(TableID);
    end;


    /// <summary>
    /// Register an event with all tables currently in the buffer, then clear the buffer.
    /// </summary>
    /// <param name="EventCode">The code of the event.</param>
    /// <param name="EventName">The name of the event.</param>
    procedure RegisterEventWithTables(EventCode: Code[50]; EventName: Text[50])
    var
        TableID: Integer;
    begin
        this.InsertEvent(this.CurrentProvider, EventCode, EventName);

        // Write to unified Dataset table
        foreach TableID in this.TableBuffer do
            this.InsertDataset(this.CurrentProvider, Enum::"BJF Dataset Entity Type"::"Event", EventCode, TableID);

        Clear(this.TableBuffer);
    end;

    internal procedure RegisterLabelGroup(LabelGroupCode: Code[50]; LabelGroupName: Text[100]; TableIDs: List of [Integer])
    var
        TableID: Integer;
    begin
        this.InsertLabelGroup(this.CurrentProvider, LabelGroupCode, LabelGroupName);

        // Write to unified Dataset table
        foreach TableID in TableIDs do
            this.InsertDataset(this.CurrentProvider, Enum::"BJF Dataset Entity Type"::"Label Group", LabelGroupCode, TableID);
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

            // Register label groups and events
            Helper := this;
            Interface.RegisterLabelGroups(Helper);
            Interface.RegisterEvents(Helper);
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


    local procedure InsertLabelGroup(Provider: Enum "BJF Direct Print Provider"; LabelGroupID: Code[50]; LabelGroupName: Text[100])
    var
        LabelGroup: Record "BJF Label Groups";
    begin
        LabelGroup.Init();
        LabelGroup."Provider No." := Provider;
        LabelGroup."No." := LabelGroupID;
        LabelGroup.Description := LabelGroupName;

        LabelGroup.SetRecFilter();
        if LabelGroup.IsEmpty() then
            LabelGroup.Insert(true)
        else
            LabelGroup.Modify(true);
    end;

    local procedure InsertEvent(Provider: Enum "BJF Direct Print Provider"; EventCode: Code[50]; EventDescription: Text[50])
    var
        EventRec: Record "BJF Event";
    begin
        EventRec.Init();
        EventRec."Provider No." := Provider;
        EventRec."No." := EventCode;
        EventRec."Description" := EventDescription;

        EventRec.SetRecFilter();
        if EventRec.IsEmpty() then
            EventRec.Insert(true)
        else
            EventRec.Modify(true);
    end;

    local procedure InsertDataset(Provider: Enum "BJF Direct Print Provider"; EntityType: Enum "BJF Dataset Entity Type"; EntityCode: Code[50]; TableID: Integer)
    var
        Dataset: Record "BJF Dataset";
    begin
        Dataset.Init();
        Dataset."Provider No." := Provider;
        Dataset."Entity Type" := EntityType;
        Dataset."Entity Code" := EntityCode;
        Dataset."Table No." := TableID;

        Dataset.SetRecFilter();
        if Dataset.IsEmpty() then
            Dataset.Insert(true)
        else
            Dataset.Modify(true);
    end;

    internal procedure ClearAllProviders()
    var
        Providers: Record "BJF Provider";
        Events: Record "BJF Event";
        Labels: Record "BJF Label Groups";
        Datasets: Record "BJF Dataset";
    begin
        if not Providers.IsEmpty() then
            Providers.DeleteAll(false);

        if not Events.IsEmpty() then
            Events.DeleteAll(false);

        if not Labels.IsEmpty() then
            Labels.DeleteAll(false);

        if not Datasets.IsEmpty() then
            Datasets.DeleteAll(false);
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
