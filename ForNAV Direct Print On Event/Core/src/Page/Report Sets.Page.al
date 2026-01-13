namespace BradFullwood.ForNAV.Core;

/// <summary>
/// Page for viewing and selecting report sets.
/// </summary>
/// <remarks>
/// Report sets define what reports/documents to print when a trigger fires.
/// </remarks>
page 77703 "BJF Report Sets"
{
    ApplicationArea = All;
    Caption = 'Report Sets';
    PageType = List;
    SourceTable = "BJF Report Set";
    UsageCategory = None;
    InherentPermissions = x;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the unique identifier for the report set.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies what this report set produces.';
                }
                field("Provider No."; Rec."Provider No.")
                {
                    ToolTip = 'Specifies which provider registered this report set.';
                }
            }
        }
    }
}
