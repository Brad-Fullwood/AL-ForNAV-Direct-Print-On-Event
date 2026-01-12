namespace BradFullwood.ForNAV.Core;

using System.Reflection;

/// <summary>
/// Table for configuring Label Sets Providers.
/// </summary>
/// <remarks>
/// This table stores configuration for which label set providers are active and their order.
/// It acts as a registry for all available label set providers in the system.
/// </remarks>
table 77705 "BJF Provider"
{
    Caption = 'Automatic Printing Providers';
    DataClassification = SystemMetadata;
    Extensible = false;

    fields
    {
        field(1; "No."; Enum "BJF Direct Print Provider")
        {
            Caption = 'Provider ';
            ToolTip = 'Specifies the unique identifier for the label set provider.';
            NotBlank = true;
        }
        field(2; "Codeunit"; Integer)
        {
            Caption = 'Provider Codeunit';
            ToolTip = 'Specifies the object  of the codeunit that provides label set functionality.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Codeunit));
        }
        field(3; "Codeunit Caption"; Text[249])
        {
            Caption = 'Provider Codeunit Caption';
            ToolTip = 'Specifies the caption of the codeunit that provides label set functionality.';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Codeunit), "Object ID" = field("Codeunit")));
            Editable = false;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies a description for the label set provider.';
        }
        field(5; Active; Boolean)
        {
            Caption = 'Active';
            ToolTip = 'Specifies whether this label set provider is active.';
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
        fieldgroup(DropDown; "No.", "Codeunit", Description, Active) { }
        fieldgroup(Brick; "No.", "Codeunit", Description, Active) { }
    }
}
