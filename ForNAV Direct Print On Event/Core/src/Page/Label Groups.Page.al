namespace BradFullwood.ForNAV.Core;

page 77703 "BJF Label Groups"
{
    ApplicationArea = All;
    Caption = 'Label Groups';
    PageType = List;
    SourceTable = "BJF Label Groups";
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
