namespace BradFullwood.ForNAV.Core;

using System.Reflection;

/// <summary>
/// Page for managing report selections for label sets.
/// </summary>
/// <remarks>
/// This page allows users to configure which reports should be printed for specific label sets and levels,
/// with support for different line types and printing sequences.
/// </remarks>
page 77704 "BJF Report Selection"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Report Selection - Automatic Label Printing';
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "BJF Automatic Printing";
    UsageCategory = Administration;
    Extensible = false;
    SourceTableView = sorting("Label Group No.", "Event No.", Sequence) order(descending);
    Permissions = tabledata "BJF Event" = r,
                  tabledata "BJF Label Groups" = r,
                  tabledata "BJF Dataset" = r;

    layout
    {
        area(Content)
        {
            group(Filters)
            {
                Caption = 'Filters';
                field("Label Group"; this.LabelSetDescription)
                {
                    Caption = 'Label Group';
                    ToolTip = 'Specifies the Label Group.';
                    TableRelation = "BJF Label Groups".Description;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        LabelSet: Record "BJF Label Groups";
                    begin
                        LabelSet.Reset();
                        if not (Page.RunModal(Page::"BJF Label Groups", LabelSet) = Action::LookupOK) then
                            exit;
                        this.LookUpLabelSet := LabelSet."No.";
                        this.LabelSetDescription := LabelSet.Description;
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
                    Editable = Rec."Label Group No." <> '';
                }

                field("Report ID"; Rec."Report ID")
                {
                    Editable = Rec."Label Group No." <> '';
                    LookupPageId = Objects;
                    ShowMandatory = true;
                }
                field("Report Name"; Rec."Report Name")
                {
                    DrillDown = false;
                    LookupPageId = Objects;
                }
                field("Event Description"; Rec."Event Description")
                {
                    ShowMandatory = true;

                    trigger OnLookup(var Text: Text) Result: Boolean
                    var
                        LabelEvent: Record "BJF Event";
                        ValidTableNos: List of [Integer];
                    begin
                        LabelEvent.Reset();

                        // Early exit if no label set selected
                        if this.LookUpLabelSet = '' then
                            exit(this.ShowEventLookup(LabelEvent));

                        this.GetValidTableNumbers(ValidTableNos);

                        // Show all events if no valid tables found or if filtering would be too restrictive
                        if ValidTableNos.Count() = 0 then
                            exit(this.ShowEventLookup(LabelEvent));

                        // Only apply filtering if we have valid table numbers
                        this.MarkValidEvents(LabelEvent, ValidTableNos);
                        LabelEvent.MarkedOnly := true;

                        Result := this.ShowEventLookup(LabelEvent);
                        if not Result then
                            exit;
                        Rec.GetNextSequence();
                        CurrPage.Update(false);
                    end;
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
                    Editable = Rec."Label Group No." <> '';
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
                Caption = 'Delete all report selections for label sets.';
                ToolTip = 'Deletes all report selections for label sets.';
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
        Rec.Validate("Label Group No.", this.LookUpLabelSet);
        Rec.NewRecord();
    end;

    var
        LookUpLabelSet: Code[50];
        LabelSetDescription: Text[100];
        IsInitialized: Boolean;

    local procedure InitUsageFilter()
    var
        LabelSet: Record "BJF Label Groups";
    begin
        if Rec.GetFilter("Label Group No.") = '' then
            exit;
        if not LabelSet.Get(CopyStr(Rec.GetFilter("Label Group No."), 1, MaxStrLen(LabelSet."No."))) then
            exit;
        this.LookUpLabelSet := LabelSet."No.";
        this.LabelSetDescription := LabelSet.Description;

        // Ensure the current record is properly initialized
        if Rec."Label Group No." = '' then
            Rec.Validate("Label Group No.", this.LookUpLabelSet);
    end;

    local procedure GetValidTableNumbers(var ValidTableNos: List of [Integer])
    var
        Dataset: Record "BJF Dataset";
    begin
        Dataset.Reset();
        Dataset.SetRange("Entity Type", Enum::"BJF Dataset Entity Type"::"Label Group"); // 1 = LabelSet
        Dataset.SetRange("Entity Code", this.LookUpLabelSet);
        if not Dataset.FindSet() then
            exit;

        repeat
            ValidTableNos.Add(Dataset."Table No.");
        until Dataset.Next() = 0;
    end;

    local procedure MarkValidEvents(var LabelEvent: Record "BJF Event"; ValidTableNos: List of [Integer])
    begin
        if not LabelEvent.FindSet() then
            exit;

        repeat
            if this.IsEventValidForTables(LabelEvent, ValidTableNos) then
                LabelEvent.Mark := true;
        until LabelEvent.Next() = 0;
    end;

    local procedure IsEventValidForTables(LabelEvent: Record "BJF Event"; ValidTableNos: List of [Integer]): Boolean
    var
        Dataset: Record "BJF Dataset";
    begin
        Dataset.Reset();
        Dataset.SetRange("Entity Type", Enum::"BJF Dataset Entity Type"::"Event");
        Dataset.SetRange("Entity Code", LabelEvent."No.");
        Dataset.SetRange("Provider No.", LabelEvent."Provider No.");

        if not Dataset.FindSet() then
            exit(false);

        repeat
            if ValidTableNos.Contains(Dataset."Table No.") then
                exit(true);
        until Dataset.Next() = 0;

        exit(false);
    end;

    local procedure ShowEventLookup(var LabelEvent: Record "BJF Event"): Boolean
    begin
        if not (Page.RunModal(Page::"BJF Label Event", LabelEvent) = Action::LookupOK) then
            exit(false);

        Rec."Event No." := LabelEvent."No.";
        exit(true);
    end;

    local procedure SetUsageFilter()
    var
        LabelSet: Record "BJF Label Groups";
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Label Group No.", this.LookUpLabelSet);

        // Update the page caption with the label set name
        if (this.LookUpLabelSet <> '') and (LabelSet.Get(this.LookUpLabelSet)) then
            CurrPage.Caption := StrSubstNo('%1 - %2', CurrPage.Caption(), LabelSet.Description);

        Rec.FilterGroup(0);

        // Ensure the current record has the label set number set
        if (this.LookUpLabelSet <> '') and (Rec."Label Group No." = '') then
            Rec.Validate("Label Group No.", this.LookUpLabelSet);

        if this.IsInitialized then
            CurrPage.Update(true);
    end;
}
