namespace BradFullwood.ForNAV.Core;

using System.Reflection;

/// <summary>
/// Page for managing report selections for report sets.
/// </summary>
/// <remarks>
/// This page allows users to configure which reports should be printed for specific report sets
/// and printing triggers, with support for different line types and printing sequences.
/// </remarks>
page 77704 "BJF Report Selection"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Report Selection - Automatic Printing';
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "BJF Automatic Printing";
    UsageCategory = Administration;
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
                field("Trigger Description"; Rec."Trigger Description")
                {
                    Caption = 'Trigger';
                    ToolTip = 'Specifies the printing trigger (when to print).';
                    ShowMandatory = true;

                    trigger OnLookup(var Text: Text) Result: Boolean
                    var
                        PrintingTrigger: Record "BJF Printing Trigger";
                        ValidTableNos: List of [Integer];
                    begin
                        PrintingTrigger.Reset();

                        // Early exit if no report set selected
                        if this.LookUpReportSet = '' then
                            exit(this.ShowTriggerLookup(PrintingTrigger));

                        this.GetValidTableNumbers(ValidTableNos);

                        // Show all triggers if no valid tables found or if filtering would be too restrictive
                        if ValidTableNos.Count() = 0 then
                            exit(this.ShowTriggerLookup(PrintingTrigger));

                        // Only apply filtering if we have valid table numbers
                        this.MarkValidTriggers(PrintingTrigger, ValidTableNos);
                        PrintingTrigger.MarkedOnly := true;

                        Result := this.ShowTriggerLookup(PrintingTrigger);
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

    local procedure GetValidTableNumbers(var ValidTableNos: List of [Integer])
    var
        SourceTableMapping: Record "BJF Source Table Mapping";
    begin
        SourceTableMapping.Reset();
        SourceTableMapping.SetRange("Mapping Type", Enum::"BJF Mapping Type"::"Report Set");
        SourceTableMapping.SetRange("Source Code", this.LookUpReportSet);
        if not SourceTableMapping.FindSet() then
            exit;

        repeat
            ValidTableNos.Add(SourceTableMapping."Table No.");
        until SourceTableMapping.Next() = 0;
    end;

    local procedure MarkValidTriggers(var PrintingTrigger: Record "BJF Printing Trigger"; ValidTableNos: List of [Integer])
    begin
        if not PrintingTrigger.FindSet() then
            exit;

        repeat
            if this.IsTriggerValidForTables(PrintingTrigger, ValidTableNos) then
                PrintingTrigger.Mark := true;
        until PrintingTrigger.Next() = 0;
    end;

    local procedure IsTriggerValidForTables(PrintingTrigger: Record "BJF Printing Trigger"; ValidTableNos: List of [Integer]): Boolean
    var
        SourceTableMapping: Record "BJF Source Table Mapping";
    begin
        SourceTableMapping.Reset();
        SourceTableMapping.SetRange("Mapping Type", Enum::"BJF Mapping Type"::"Trigger");
        SourceTableMapping.SetRange("Source Code", PrintingTrigger."No.");
        SourceTableMapping.SetRange("Provider No.", PrintingTrigger."Provider No.");

        if not SourceTableMapping.FindSet() then
            exit(false);

        repeat
            if ValidTableNos.Contains(SourceTableMapping."Table No.") then
                exit(true);
        until SourceTableMapping.Next() = 0;

        exit(false);
    end;

    local procedure ShowTriggerLookup(var PrintingTrigger: Record "BJF Printing Trigger"): Boolean
    begin
        if not (Page.RunModal(Page::"BJF Printing Triggers", PrintingTrigger) = Action::LookupOK) then
            exit(false);

        Rec."Trigger No." := PrintingTrigger."No.";
        exit(true);
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
}
