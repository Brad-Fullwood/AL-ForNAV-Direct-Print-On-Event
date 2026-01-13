namespace BradFullwood.ForNAV.Core;

/// <summary>
/// Table representing a printing trigger - when to print.
/// </summary>
/// <remarks>
/// Printing triggers define business events that initiate automatic printing.
/// When combined with a Report Set, they create a complete print automation rule.
/// Examples: "Sales Order Posted", "Purchase Receipt Created", "Item Movement"
/// </remarks>
table 77702 "BJF Printing Trigger"
{
    Caption = 'Printing Triggers';
    DataClassification = SystemMetadata;
    LookupPageId = "BJF Printing Triggers";
    DrillDownPageId = "BJF Printing Triggers";
    Extensible = false;

    fields
    {
        field(1; "No."; Code[50])
        {
            Caption = 'No.';
            ToolTip = 'Specifies the unique identifier for the printing trigger.';
            NotBlank = true;
            AllowInCustomizations = Always;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            ToolTip = 'Specifies a description of when this trigger fires (e.g., "Sales Order Posted").';
        }
        field(3; "Provider No."; Enum "BJF Direct Print Provider")
        {
            Caption = 'Provider';
            ToolTip = 'Specifies which provider registered this printing trigger.';
            TableRelation = "BJF Provider"."No.";
            AllowInCustomizations = Always;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Description; Description)
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Description) { }
        fieldgroup(Brick; "Provider No.", "No.", Description) { }
    }
}
