namespace BradFullwood.ForNAV.Core;

using System.Reflection;

/// <summary>
/// Page for managing report selections for report sets.
/// </summary>
/// <remarks>
/// This page allows users to configure which reports should be printed for specific report sets
/// and printing triggers, with support for different line types and printing sequences.
/// </remarks>
page 77504 "BJF Report Selection"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Report Selection - Automatic Printing';
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "BJF Automatic Printing";
    UsageCategory = None;
    Extensible = false;
    SourceTableView = sorting("Report Set No.", "Trigger No.", Sequence) order(ascending);
    Permissions = tabledata "BJF Printing Trigger" = r,
                  tabledata "BJF Report Set" = r,
                  tabledata "BJF Source Table Mapping" = r;

    layout
    {
        area(Content)
        {
            group(Filters)
            {
                Caption = 'Filters';
                field("Report Set"; this.ReportSetDescription)
                {
                    Caption = 'Report Set';
                    ToolTip = 'Specifies the Report Set (what to print).';
                    TableRelation = "BJF Report Set".Description;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ReportSet: Record "BJF Report Set";
                    begin
                        ReportSet.Reset();
                        if not (Page.RunModal(Page::"BJF Report Sets", ReportSet) = Action::LookupOK) then
                            exit;
                        this.LookUpReportSet := ReportSet."No.";
                        this.ReportSetDescription := ReportSet.Description;
                        this.SetUsageFilter();
                    end;
                }
            }

            repeater(Control1)
            {
                FreezeColumn = "Report Name";
                ShowCaption = false;

                field(Sequence; Rec.Sequence)
                {
                    Caption = 'Sequence';
                    ToolTip = 'Specifies the printing sequence order.';
                    Editable = Rec."Report Set No." <> '';
                }

                field("Report ID"; Rec."Report ID")
                {
                    Editable = Rec."Report Set No." <> '';
                    LookupPageId = Objects;
                    ShowMandatory = true;
                }
                field("Report Name"; Rec."Report Name")
                {
                    DrillDown = false;
                    LookupPageId = Objects;
                }
                field("Trigger No."; Rec."Trigger No.")
                {
                    Caption = 'Trigger';
                    ToolTip = 'Specifies the printing trigger (when to print). The lookup lists the triggers whose source tables match the report set.';
                    ShowMandatory = true;
                    Editable = Rec."Report Set No." <> '';

                    // A lookup on this code field, not on the description FlowField: the web
                    // client renders a FlowField as a drilldown to its source record, so a
                    // lookup trigger there never runs and the drilldown filters on the blank code.
                    trigger OnLookup(var Text: Text) Result: Boolean
                    var
                        PrintingTrigger: Record "BJF Printing Trigger";
                    begin
                        this.FilterValidTriggers(PrintingTrigger);
                        if not (Page.RunModal(Page::"BJF Printing Triggers", PrintingTrigger) = Action::LookupOK) then
                            exit(false);
                        this.InsertTriggersFromSelection(PrintingTrigger);
                        Text := Rec."Trigger No.";
                        CurrPage.Update(false);
                        exit(true);
                    end;

                    trigger OnValidate()
                    var
                        PrintingTrigger: Record "BJF Printing Trigger";
                    begin
                        if Rec."Trigger No." = '' then
                            exit;
                        this.FilterValidTriggers(PrintingTrigger);
                        PrintingTrigger.SetRange("No.", Rec."Trigger No.");
                        if PrintingTrigger.IsEmpty() then
                            Error(this.TriggerNotValidErr, Rec."Trigger No.", Rec."Report Set No.");
                    end;
                }
                field("Trigger Description"; Rec."Trigger Description")
                {
                    Caption = 'Trigger Description';
                    ToolTip = 'Specifies the description of the printing trigger.';
                    DrillDown = false;
                    Editable = false;
                }
                field(ReportLayoutName; Rec."Report Layout Name")
                {
                    Visible = false;
                }
                field(ReportLayoutCaption; Rec."Report Layout Caption")
                {
                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownToSelectLayout(Rec."Report Layout Name", Rec."Report Layout AppID");
                        CurrPage.Update(false);
                    end;

                }
                field("Report Layout Publisher"; Rec."Report Layout Publisher") { }
                field("Qty to Print"; Rec."Qty to Print")
                {
                    Editable = Rec."Report Set No." <> '';
                }
            }
        }
        area(FactBoxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ClearAllSelections)
            {
                Caption = 'Delete all report selections.';
                ToolTip = 'Deletes all report selections for all report sets.';
                Image = Delete;

                trigger OnAction()
                var
                    AutoPrintDelete: Record "BJF Automatic Printing";
                begin
                    if AutoPrintDelete.IsEmpty() then
                        exit;
                    AutoPrintDelete.DeleteAll(false);
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        this.InitUsageFilter();
        this.SetUsageFilter();
        this.IsInitialized := true;
    end;

    trigger OnNewRecord(BelowRec: Boolean)
    begin
        Rec.Validate("Report Set No.", this.LookUpReportSet);
        Rec.NewRecord();
    end;

    var
        LookUpReportSet: Code[50];
        ReportSetDescription: Text[100];
        IsInitialized: Boolean;

    local procedure InitUsageFilter()
    var
        ReportSet: Record "BJF Report Set";
    begin
        if Rec.GetFilter("Report Set No.") = '' then
            exit;
        if not ReportSet.Get(CopyStr(Rec.GetFilter("Report Set No."), 1, MaxStrLen(ReportSet."No."))) then
            exit;
        this.LookUpReportSet := ReportSet."No.";
        this.ReportSetDescription := ReportSet.Description;

        // Ensure the current record is properly initialized
        if Rec."Report Set No." = '' then
            Rec.Validate("Report Set No.", this.LookUpReportSet);
    end;

    /// <summary>Filters the triggers to the report set's provider and to those whose source tables match it.</summary>
    local procedure FilterValidTriggers(var PrintingTrigger: Record "BJF Printing Trigger")
    var
        ReportSet: Record "BJF Report Set";
        TriggerFilter: Text;
    begin
        PrintingTrigger.Reset();
        if (this.LookUpReportSet = '') or not ReportSet.Get(this.LookUpReportSet) then
            exit;
        PrintingTrigger.SetRange("Provider No.", ReportSet."Provider No.");
        TriggerFilter := this.BuildValidTriggerFilter(ReportSet."Provider No.");
        if TriggerFilter <> '' then
            PrintingTrigger.SetFilter("No.", TriggerFilter);
    end;

    local procedure BuildValidTriggerFilter(ProviderNo: Enum "BJF Direct Print Provider"): Text
    var
        ReportSetMapping: Record "BJF Source Table Mapping";
        TriggerMapping: Record "BJF Source Table Mapping";
        ValidTableNos: List of [Integer];
        AddedTriggers: List of [Code[50]];
        TriggerFilter: Text;
        TableNo: Integer;
    begin
        ReportSetMapping.SetRange("Mapping Type", Enum::"BJF Mapping Type"::"Report Set");
        ReportSetMapping.SetRange("Provider No.", ProviderNo);
        ReportSetMapping.SetRange("Source Code", this.LookUpReportSet);
        if not ReportSetMapping.FindSet() then
            exit('');

        repeat
            ValidTableNos.Add(ReportSetMapping."Table No.");
        until ReportSetMapping.Next() = 0;

        foreach TableNo in ValidTableNos do begin
            TriggerMapping.Reset();
            TriggerMapping.SetRange("Mapping Type", Enum::"BJF Mapping Type"::"Trigger");
            TriggerMapping.SetRange("Provider No.", ProviderNo);
            TriggerMapping.SetRange("Table No.", TableNo);
            if TriggerMapping.FindSet() then
                repeat
                    if not AddedTriggers.Contains(TriggerMapping."Source Code") then begin
                        AddedTriggers.Add(TriggerMapping."Source Code");
                        if TriggerFilter <> '' then
                            TriggerFilter += '|';
                        TriggerFilter += TriggerMapping."Source Code";
                    end;
                until TriggerMapping.Next() = 0;
        end;

        exit(TriggerFilter);
    end;

    local procedure InsertTriggersFromSelection(var PrintingTrigger: Record "BJF Printing Trigger")
    var
        AutoPrint: Record "BJF Automatic Printing";
        IsFirst: Boolean;
    begin
        IsFirst := true;
        PrintingTrigger.MarkedOnly(true);

        if PrintingTrigger.FindSet() then begin
            repeat
                if IsFirst then begin
                    Rec."Trigger No." := PrintingTrigger."No.";
                    Rec.GetNextSequence();
                    IsFirst := false;
                end else begin
                    AutoPrint.Init();
                    AutoPrint."Report Set No." := Rec."Report Set No.";
                    AutoPrint."Trigger No." := PrintingTrigger."No.";
                    AutoPrint."Report ID" := Rec."Report ID";
                    AutoPrint.GetNextSequence();
                    AutoPrint."Qty to Print" := Rec."Qty to Print";
                    AutoPrint."Report Layout Name" := Rec."Report Layout Name";
                    AutoPrint."Report Layout AppID" := Rec."Report Layout AppID";
                    AutoPrint.Insert(true);
                end;
            until PrintingTrigger.Next() = 0;
        end else begin
            // Single selection (no multi-select marks)
            PrintingTrigger.MarkedOnly(false);
            Rec."Trigger No." := PrintingTrigger."No.";
            Rec.GetNextSequence();
        end;
    end;

    local procedure SetUsageFilter()
    var
        ReportSet: Record "BJF Report Set";
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Report Set No.", this.LookUpReportSet);

        // Update the page caption with the report set name
        if (this.LookUpReportSet <> '') and (ReportSet.Get(this.LookUpReportSet)) then
            CurrPage.Caption := StrSubstNo('%1 - %2', CurrPage.Caption(), ReportSet.Description);

        Rec.FilterGroup(0);

        // Ensure the current record has the report set number set
        if (this.LookUpReportSet <> '') and (Rec."Report Set No." = '') then
            Rec.Validate("Report Set No.", this.LookUpReportSet);

        if this.IsInitialized then
            CurrPage.Update(true);
    end;

    var
        TriggerNotValidErr: Label 'Trigger %1 is not valid for report set %2: none of its source tables matches the report set.', Comment = '%1 = trigger code, %2 = report set code';
}
