namespace BradFullwood.ForNAV.Core;

page 77702 "BJF Label Event"
{
    ApplicationArea = All;
    Caption = 'BJF Label Event';
    PageType = List;
    SourceTable = "BJF Event";
    UsageCategory = None;
    InherentPermissions = x;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Description; Rec.Description) { }
            }
        }
    }
}
