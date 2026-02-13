namespace BradFullwood.ForNAV.Core;

/// <summary>
/// Page for viewing and selecting printing triggers.
/// </summary>
/// <remarks>
/// Printing triggers represent business events that can initiate automatic printing.
/// </remarks>
page 77702 "BJF Printing Triggers"
{
    ApplicationArea = All;
    Caption = 'Printing Triggers';
    PageType = List;
    SourceTable = "BJF Printing Trigger";
    UsageCategory = None;
    InherentPermissions = x;
    Extensible = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Provider No."; Rec."Provider No.")
                {
                    ToolTip = 'Specifies which provider registered this trigger.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies when this trigger fires (e.g., "Sales Shipment Posted").';
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the unique code for this trigger.';
                    Visible = false;
                }
            }
        }
        area(FactBoxes)
        {
            part(SourceTables; "BJF Trigger Source FactBox")
            {
                Caption = 'Source Tables';
                SubPageLink = "Mapping Type" = const(Trigger), "Source Code" = field("No."), "Provider No." = field("Provider No.");
            }
        }
    }
}
