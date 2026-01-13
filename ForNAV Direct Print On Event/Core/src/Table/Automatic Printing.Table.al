namespace BradFullwood.ForNAV.Core;

using System.Reflection;
using Microsoft.Foundation.Reporting;

/// <summary>
/// Table for storing report selections based on report sets.
/// </summary>
/// <remarks>
/// This table manages the configuration of which reports to print for specific report sets
/// and printing triggers, including customization for different line types and printing sequences.
/// </remarks>
table 77700 "BJF Automatic Printing"
{
    Caption = 'Report Selection - Automatic Printing';
    DataClassification = SystemMetadata;
    InherentPermissions = r;
    Extensible = false;

    fields
    {
        field(1; "Report Set No."; Code[50])
        {
            Caption = 'Report Set No.';
            ToolTip = 'Specifies the report set (what to print) associated with this report selection.';
            TableRelation = "BJF Report Set"."No.";
            Editable = false;
            ValidateTableRelation = false;
            AllowInCustomizations = Never;
            NotBlank = true;

            trigger OnValidate()
            begin
                this.CalcFields("Report Set Name");
            end;
        }
        field(2; "Trigger No."; Code[50])
        {
            Caption = 'Trigger No.';
            ToolTip = 'Specifies the printing trigger (when to print) associated with this report selection.';
            TableRelation = "BJF Printing Trigger"."No.";
            ValidateTableRelation = false;
            Editable = false;
            AllowInCustomizations = Never;
            NotBlank = true;

            trigger OnValidate()
            begin
                this.CalcFields("Trigger Description");
            end;
        }
        field(3; "Report Set Name"; Text[100])
        {
            Caption = 'Report Set Name';
            ToolTip = 'Specifies the name of the report set associated with this report selection.';
            CalcFormula = lookup("BJF Report Set"."Description" where("No." = field("Report Set No.")));
            FieldClass = FlowField;
            Editable = false;
            AllowInCustomizations = Always;
        }
        field(13; "Trigger Description"; Text[50])
        {
            Caption = 'Trigger Description';
            ToolTip = 'Specifies the description of the printing trigger associated with this report selection.';
            FieldClass = FlowField;
            CalcFormula = lookup("BJF Printing Trigger"."Description" where("No." = field("Trigger No.")));
            Editable = false;
        }
        field(14; Sequence; Code[10])
        {
            Caption = 'Sequence';
            Numeric = true;
            ToolTip = 'Specifies a number that indicates where this report is in the printing order.';
            NotBlank = true;
        }
        field(4; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            ToolTip = 'Specifies the object ID of the report.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Report));
            NotBlank = true;

            trigger OnValidate()
            begin
                this.CalcFields("Report Name");
            end;
        }
        field(5; "Report Name"; Text[250])
        {
            CalcFormula = lookup("Report Metadata".Caption where(ID = field("Report ID")));
            ToolTip = 'Specifies the name of the report that is used for this selection.';
            Caption = 'Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6; "Custom Report Layout Code"; Code[20])
        {
            Caption = 'Custom Report Layout Code';
            ToolTip = 'Specifies the custom report layout code that is used for this report selection.';
            Editable = false;
            TableRelation = "Custom Report Layout".Code where(Code = field("Custom Report Layout Code"), "Built-In" = const(false));
            AllowInCustomizations = Never;
        }
        field(7; "Report Layout Name"; Text[250])
        {
            Caption = 'Report Layout name';
            ToolTip = 'Specifies the name of the report layout that is used.';
            TableRelation = "Report Layout List".Name where("Report ID" = field("Report ID"));

            trigger OnLookup()
            var
                ReportLayoutList: Record "Report Layout List";
                ReportManagement: Codeunit ReportManagement;
                Handled: Boolean;
            begin
                ReportLayoutList.SetRange("Report ID", Rec."Report ID");
                ReportManagement.OnSelectReportLayout(ReportLayoutList, Handled);
                if not Handled then
                    exit;
                "Report Layout Name" := ReportLayoutList.Name;
                "Report Layout AppID" := ReportLayoutList."Application ID";
            end;

            trigger OnValidate()
            var
                ReportLayoutList: Record "Report Layout List";
            begin
                if "Report Layout Name" <> '' then begin
                    ReportLayoutList.SetRange(Name, "Report Layout Name");
                    ReportLayoutList.SetRange("Report ID", Rec."Report ID");
                    if not IsNullGuid("Report Layout AppID") then
                        ReportLayoutList.SetRange("Application ID", "Report Layout AppID");
                    if not ReportLayoutList.FindFirst() then begin
                        ReportLayoutList.SetRange("Application ID");
                        if ReportLayoutList.FindFirst() then; // catch error.
                    end;
                    if IsNullGuid("Report Layout AppID") then
                        Rec."Report Layout AppID" := ReportLayoutList."Application ID";
                end;
            end;
        }
        field(8; "Report Layout AppID"; Guid)
        {
            Caption = 'Report Layout App ID';
            Editable = false;
            AllowInCustomizations = Never;
        }
#pragma warning disable LC0001 // Standard Report Layout pages do this.
        field(9; "Report Layout Caption"; Text[250])
#pragma warning restore LC0001
        {
            Caption = 'Report Layout';
            ToolTip = 'Specifies the Name of the report layout that is used.';
            FieldClass = FlowField;
            CalcFormula = lookup("Report Layout List".Caption where("Report ID" = field("Report ID"), Name = field("Report Layout Name")));

            trigger OnLookup()
            var
                ReportLayoutList: Record "Report Layout List";
                ReportManagement: Codeunit ReportManagement;
                Handled: Boolean;
            begin
                ReportLayoutList.SetRange("Report ID", Rec."Report ID");
                ReportManagement.OnSelectReportLayout(ReportLayoutList, Handled);
                if not Handled then
                    exit;
                "Report Layout Name" := ReportLayoutList.Name;
                "Report Layout AppID" := ReportLayoutList."Application ID";
            end;
        }
        field(10; "Report Layout Publisher"; Text[250])
        {
            Caption = 'Report Layout Publisher';
            ToolTip = 'Specifies the publisher of the email Attachment layout that is used.';
            FieldClass = FlowField;
            CalcFormula = lookup("Report Layout List"."Layout Publisher" where("Report ID" = field("Report ID"), "Application ID" = field("Report Layout AppID")));
            Editable = false;
        }
        field(11; "Qty to Print"; Integer)
        {
            Caption = 'Qty to Print';
            ToolTip = 'Specifies the default number of copies to print for this report selection.';
            MinValue = 0;
            InitValue = 0;
        }
    }

    keys
    {
        key(PK; "Report Set No.", "Trigger No.", Sequence)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; Sequence, "Report ID", "Report Layout Name", "Report Layout Caption") { }
        fieldgroup(DropDown; Sequence, "Report ID", "Report Layout Name", "Report Layout Caption") { }
    }

    internal procedure NewRecord()
    var
        AutoPrintLookup: Record "BJF Automatic Printing";
    begin
        AutoPrintLookup.SetRange("Report Set No.", "Report Set No.");
        if AutoPrintLookup.FindLast() and (AutoPrintLookup.Sequence <> '') then
            this.Sequence := IncStr(AutoPrintLookup.Sequence)
        else
            this.Sequence := '1';
    end;

    internal procedure GetNextSequence()
    var
        AutoPrintLookup: Record "BJF Automatic Printing";
    begin
        AutoPrintLookup.SetRange("Report Set No.", "Report Set No.");
        AutoPrintLookup.SetRange("Trigger No.", "Trigger No.");
        if AutoPrintLookup.FindLast() and (AutoPrintLookup.Sequence <> '') then
            this.Sequence := IncStr(AutoPrintLookup.Sequence)
        else
            this.Sequence := '1';
    end;

    internal procedure DrillDownToSelectLayout(var SelectedLayoutName: Text[250]; var SelectedLayoutAppID: Guid)
    var
        ReportLayoutListSelection: Record "Report Layout List";
        ReportManagementCodeunit: Codeunit ReportManagement;
        IsReportLayoutSelected: Boolean;
    begin
        ReportLayoutListSelection.SetRange("Report ID", Rec."Report ID");
        ReportManagementCodeunit.OnSelectReportLayout(ReportLayoutListSelection, IsReportLayoutSelected);
        if IsReportLayoutSelected then begin
            SelectedLayoutName := ReportLayoutListSelection."Name";
            SelectedLayoutAppID := ReportLayoutListSelection."Application ID";
        end;
    end;

}
