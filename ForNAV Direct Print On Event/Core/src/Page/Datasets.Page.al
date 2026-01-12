namespace BradFullwood.ForNAV.Core;

/// <summary>
/// Page for viewing and managing dataset configurations.
/// </summary>
page 77700 "BJF Datasets"
{
    Caption = 'Datasets';
    PageType = ListPart;
    SourceTable = "BJF Dataset";
    InsertAllowed = false;
    ModifyAllowed = false;
    Editable = false;
    Extensible = false;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Provider No."; Rec."Provider No.") { }
                field("Entity Type"; Rec."Entity Type") { }
                field("Entity Code"; Rec."Entity Code") { }
                field("Entity Description"; Rec."Entity Description") { }
                field("Table No."; Rec."Table No.") { }
                field("Table Name"; Rec."Table Name") { }
            }
        }
    }
}
