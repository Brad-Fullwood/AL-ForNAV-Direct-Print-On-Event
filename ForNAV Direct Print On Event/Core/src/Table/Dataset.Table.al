namespace BradFullwood.ForNAV.Core;

using System.Reflection;

/// <summary>
/// Unified table for storing dataset configurations for both events and label sets.
/// </summary>
/// <remarks>
/// Replaces the previous separate Event Dataset and Label Group Dataset tables.
/// Stores table number mappings for both events and label sets in a single table,
/// eliminating the need for runtime compatibility matching.
/// </remarks>
table 77701 "BJF Dataset"
{
    Caption = 'Automatic Printing Datasets';
    Extensible = false;
    DataClassification = SystemMetadata;
    LookupPageId = "BJF Datasets";
    DrillDownPageId = "BJF Datasets";
    Permissions = tabledata "BJF Event" = r,
                  tabledata "BJF Label Groups" = r;

    fields
    {
        field(1; "Provider No."; Enum "BJF Direct Print Provider")
        {
            Caption = 'Provider No.';
            NotBlank = true;
            ToolTip = 'Specifies the provider that owns this dataset configuration.';
            AllowInCustomizations = Always;
        }
        field(2; "Entity Type"; Enum "BJF Dataset Entity Type")
        {
            Caption = 'Entity Type';
            NotBlank = true;
            ToolTip = 'Specifies whether this dataset is for an Event or a Label Group.';
            AllowInCustomizations = Always;
        }
        field(3; "Entity Code"; Code[50])
        {
            Caption = 'Entity Code';
            NotBlank = true;
            ToolTip = 'Specifies the code of the event or label set.';
            AllowInCustomizations = Always;

            trigger OnValidate()
            begin
                case Rec."Entity Type" of
                    Enum::"BJF Dataset Entity Type"::"Event":
                        if not this.EventExists() then
                            Error(this.EntityNotFoundErr, Rec."Entity Code", 'Event');
                    Enum::"BJF Dataset Entity Type"::"Label Group":
                        if not this.LabelGroupExists() then
                            Error(this.EntityNotFoundErr, Rec."Entity Code", 'Label Group');
                end;
            end;
        }
        field(4; "Entity Description"; Text[250])
        {
            Caption = 'Entity Description';
            ToolTip = 'Specifies the description of the event or label set.';
            FieldClass = FlowField;
            CalcFormula = lookup("BJF Event".Description where("Provider No." = field("Provider No."), "No." = field("Entity Code")));
            Editable = false;
        }
        field(5; "Table No."; Integer)
        {
            Caption = 'Table No.';
            NotBlank = true;
            ToolTip = 'Specifies the table number that this dataset relates to.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            AllowInCustomizations = Always;
        }
        field(6; "Table Name"; Text[250])
        {
            Caption = 'Table Name';
            ToolTip = 'Specifies the name of the table that this dataset relates to.';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Provider No.", "Entity Type", "Entity Code", "Table No.")
        {
            Clustered = true;
        }
        key(EntityLookup; "Entity Type", "Entity Code", "Table No.")
        {
        }
        key(TableLookup; "Table No.", "Entity Type", "Entity Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entity Type", "Entity Code", "Table No.")
        {
        }
        fieldgroup(Brick; "Provider No.", "Entity Type", "Entity Code", "Table No.", "Table Name")
        {
        }
    }

    var
        EntityNotFoundErr: Label '%1 does not exist as a valid %2.', Comment = '%1 = Entity Code, %2 = Entity Type';

    local procedure EventExists(): Boolean
    var
        EventRec: Record "BJF Event";
    begin
        EventRec.SetRange("Provider No.", "Provider No.");
        EventRec.SetRange("No.", "Entity Code");
        exit(not EventRec.IsEmpty());
    end;

    local procedure LabelGroupExists(): Boolean
    var
        LabelGroup: Record "BJF Label Groups";
    begin
        LabelGroup.SetRange("Provider No.", "Provider No.");
        LabelGroup.SetRange("No.", "Entity Code");
        exit(not LabelGroup.IsEmpty());
    end;
}
