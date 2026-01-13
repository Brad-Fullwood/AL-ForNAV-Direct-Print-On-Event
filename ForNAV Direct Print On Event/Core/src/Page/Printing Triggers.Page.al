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

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies when this trigger fires (e.g., "Sales Shipment Posted").';
                }
            }
        }
    }
}
