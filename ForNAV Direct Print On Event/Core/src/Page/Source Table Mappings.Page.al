namespace BradFullwood.ForNAV.Core;

/// <summary>
/// Page for viewing registered source table mappings.
/// </summary>
/// <remarks>
/// Shows which Business Central tables are available as data sources for reports
/// when specific triggers fire or for specific report sets.
/// </remarks>
page 77700 "BJF Source Table Mappings"
{
    Caption = 'Source Table Mappings';
    PageType = ListPart;
    SourceTable = "BJF Source Table Mapping";
    SourceTableView = sorting("Provider No.", "Mapping Type", "Source Code", "Table No.");
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
                IndentationColumn = Rec.Indentation;
                IndentationControls = "Source Table";
                ShowAsTree = true;

                field("Provider No."; Rec."Provider No.")
                {
                    Style = Strong;
                    ToolTip = 'Specifies the provider that registered this mapping.';
                }
                field("Mapping Type"; Rec."Mapping Type")
                {
                    Style = Subordinate;
                    ToolTip = 'Specifies whether this is for a Trigger (when to print) or Report Set (what to print).';
                }
                field("Source Table"; Rec."Source Table")
                {
                    Style = Favorable;
                    ToolTip = 'The Business Central table that can be used as a report data source.';
                }
                field("Source Description"; Rec."Source Description")
                {
                    ToolTip = 'Description of the trigger or report set.';
                }
                field("Table No."; Rec."Table No.")
                {
                    Visible = false;
                    ToolTip = 'The internal table number.';
                }
                field("Source Code"; Rec."Source Code")
                {
                    Visible = false;
                    ToolTip = 'The internal code of the trigger or report set.';
                }
            }
        }
    }
}
