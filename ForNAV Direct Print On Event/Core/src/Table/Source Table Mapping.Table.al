namespace BradFullwood.ForNAV.Core;

using System.Reflection;

/// <summary>
/// Table for mapping source tables to printing triggers and report sets.
/// </summary>
/// <remarks>
/// This table defines which Business Central tables can be used as data sources
/// for reports when a specific trigger fires or for a specific report set.
/// This is essential for report developers to know which dataset to use.
/// </remarks>
table 77701 "BJF Source Table Mapping"
{
    Caption = 'Source Table Mappings';
    Extensible = false;
    DataClassification = SystemMetadata;
    LookupPageId = "BJF Source Table Mappings";
    DrillDownPageId = "BJF Source Table Mappings";
    Permissions = tabledata "BJF Printing Trigger" = r,
                  tabledata "BJF Report Set" = r;

    fields
    {
        field(1; "Provider No."; Enum "BJF Direct Print Provider")
        {
            Caption = 'Provider';
            NotBlank = true;
            ToolTip = 'Specifies the provider that registered this mapping.';
            AllowInCustomizations = Always;
        }
        field(2; "Mapping Type"; Enum "BJF Mapping Type")
        {
            Caption = 'Type';
            NotBlank = true;
            ToolTip = 'Specifies whether this mapping is for a Trigger (when to print) or Report Set (what to print).';
            AllowInCustomizations = Always;
        }
        field(3; "Source Code"; Code[50])
        {
            Caption = 'Source Code';
            ToolTip = 'Specifies the code of the trigger or report set.';
            AllowInCustomizations = Always;

            trigger OnValidate()
            begin
                case Rec."Mapping Type" of
                    Enum::"BJF Mapping Type"::"Trigger":
                        if not this.TriggerExists() then
                            Error(this.SourceNotFoundErr, Rec."Source Code", 'Trigger');
                    Enum::"BJF Mapping Type"::"Report Set":
                        if not this.ReportSetExists() then
                            Error(this.SourceNotFoundErr, Rec."Source Code", 'Report Set');
                end;
            end;
        }
        field(4; "Source Description"; Text[250])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of the trigger or report set.';
            Editable = false;
        }
        field(7; Indentation; Integer)
        {
            Caption = 'Indentation';
            ToolTip = 'Specifies the indentation level for tree view display.';
            Editable = false;
        }
        field(5; "Table No."; Integer)
        {
            Caption = 'Table No.';
            ToolTip = 'Specifies the Business Central table number that can be used as a data source.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            AllowInCustomizations = Always;
        }
        field(6; "Source Table"; Text[250])
        {
            Caption = 'Source Table';
            ToolTip = 'Specifies the name of the table that can be used as a report data source. Use this when creating reports.';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Provider No.", "Mapping Type", "Source Code", "Table No.")
        {
            Clustered = true;
        }
        key(SourceLookup; "Mapping Type", "Source Code", "Table No.")
        {
        }
        key(TableLookup; "Table No.", "Mapping Type", "Source Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Mapping Type", "Source Code", "Table No.")
        {
        }
        fieldgroup(Brick; "Provider No.", "Mapping Type", "Source Code", "Table No.", "Source Table")
        {
        }
    }

    var
        SourceNotFoundErr: Label '%1 does not exist as a valid %2.', Comment = '%1 = Source Code, %2 = Mapping Type';

    local procedure TriggerExists(): Boolean
    var
        PrintingTrigger: Record "BJF Printing Trigger";
    begin
        PrintingTrigger.SetRange("Provider No.", "Provider No.");
        PrintingTrigger.SetRange("No.", "Source Code");
        exit(not PrintingTrigger.IsEmpty());
    end;

    local procedure ReportSetExists(): Boolean
    var
        ReportSet: Record "BJF Report Set";
    begin
        ReportSet.SetRange("Provider No.", "Provider No.");
        ReportSet.SetRange("No.", "Source Code");
        exit(not ReportSet.IsEmpty());
    end;
}
