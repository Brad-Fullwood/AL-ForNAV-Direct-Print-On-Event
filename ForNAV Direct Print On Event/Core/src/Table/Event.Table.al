namespace BradFullwood.ForNAV.Core;

/// <summary>
/// Table for storing trigger assignments to label sets.
/// </summary>
table 77702 "BJF Event"
{
    Caption = 'Automatic Printing Events';
    DataClassification = CustomerContent;
    LookupPageId = "BJF Label Event";
    DrillDownPageId = "BJF Label Event";
    Extensible = false;

    fields
    {
        field(1; "No."; Code[50])
        {
            Caption = 'No.';
            ToolTip = 'Specifies the event trigger for the label set.';
            NotBlank = true;
            AllowInCustomizations = Always;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            ToolTip = 'Specifies a description of the label event.';
        }
        field(3; "Provider No."; Enum "BJF Direct Print Provider")
        {
            Caption = 'Provider';
            ToolTip = 'Specifies the  of the label provider.';
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
    }

    fieldgroups
    {
        fieldgroup(DropDown; Description, "No.")
        {
        }
        fieldgroup(Brick; Description, "No.")
        {
        }
    }
}
