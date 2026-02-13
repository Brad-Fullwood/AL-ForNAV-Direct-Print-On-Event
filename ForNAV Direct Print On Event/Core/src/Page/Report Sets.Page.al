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
                    ToolTip = 'Specifies which provider registered this report set.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies what this report set produces.';
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the unique code for the report set.';
                    Visible = false;
                }
            }
        }
        area(FactBoxes)
        {
            part(SourceTables; "BJF Trigger Source FactBox")
            {
                Caption = 'Source Tables';
                SubPageLink = "Mapping Type" = const("Report Set"), "Source Code" = field("No."), "Provider No." = field("Provider No.");
            }
        }
    }
}
