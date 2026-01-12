namespace BradFullwood.ForNAV.Core;

/// <summary>
/// Table that represents a label set with its properties.
/// </summary>
/// <remarks>
/// Stores information about available label sets registered by providers.
/// </remarks>
table 77703 "BJF Label Groups"
{
    Caption = 'Label Groups';
    DataClassification = SystemMetadata;
    LookupPageId = "BJF Label Groups";
    DrillDownPageId = "BJF Label Groups";
    Extensible = false;

    fields
    {
        field(1; "No."; Code[50])
        {
            Caption = 'Label Set No.';
            ToolTip = 'Specifies the unique identifier for the label set.';
            NotBlank = true;
            AllowInCustomizations = Always;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of the label set.';
        }
        field(3; "Provider No."; Enum "BJF Direct Print Provider")
        {
            Caption = 'Provider ';
            ToolTip = 'Specifies the unique identifier for the label set provider.';
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
