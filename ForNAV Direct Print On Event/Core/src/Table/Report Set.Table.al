namespace BradFullwood.ForNAV.Core;

/// <summary>
/// Table that represents a report set - a collection of reports that can be printed together.
/// </summary>
/// <remarks>
/// Stores information about available report sets registered by providers.
/// A report set defines WHAT to print when a trigger fires.
/// </remarks>
table 77703 "BJF Report Set"
{
    Caption = 'Report Sets';
    DataClassification = SystemMetadata;
    LookupPageId = "BJF Report Sets";
    DrillDownPageId = "BJF Report Sets";
    Extensible = false;

    fields
    {
        field(1; "No."; Code[50])
        {
            Caption = 'No.';
            ToolTip = 'Specifies the unique identifier for the report set.';
            NotBlank = true;
            AllowInCustomizations = Always;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies a description of what this report set produces (e.g., "Shipping Documents", "Product Labels").';
        }
        field(3; "Provider No."; Enum "BJF Direct Print Provider")
        {
            Caption = 'Provider';
            ToolTip = 'Specifies which provider registered this report set.';
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
