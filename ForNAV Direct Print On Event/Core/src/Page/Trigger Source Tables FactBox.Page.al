namespace BradFullwood.ForNAV.Core;

/// <summary>
/// FactBox showing source tables linked to the selected trigger or report set.
/// </summary>
page 77706 "BJF Trigger Source Tables FactBox"
{
    Caption = 'Source Tables';
    PageType = ListPart;
    SourceTable = "BJF Source Table Mapping";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Source Table"; Rec."Source Table")
                {
                    ToolTip = 'The Business Central table available as a data source for reports using this trigger.';
                }
            }
        }
    }
}
