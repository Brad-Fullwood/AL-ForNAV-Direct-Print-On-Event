namespace BradFullwood.ForNAV.Core;

/// <summary>
/// Rules as an API, so a deployment script or another system can set up what prints when
/// without driving the Setup Reports worksheet. One rule is a report set, a trigger, a report
/// and a number of copies. POST creates, PATCH edits, DELETE removes.
/// </summary>
page 77508 "BJF Direct Print Rule API"
{
    PageType = API;
    APIPublisher = 'bradfullwood';
    APIGroup = 'directPrint';
    APIVersion = 'v1.0';
    EntityName = 'rule';
    EntitySetName = 'rules';
    EntityCaption = 'Direct Print Rule';
    EntitySetCaption = 'Direct Print Rules';
    SourceTable = "BJF Automatic Printing";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Rules)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(reportSetNo; Rec."Report Set No.")
                {
                    Caption = 'Report Set No.';
                }
                field(triggerNo; Rec."Trigger No.")
                {
                    Caption = 'Trigger No.';
                }
                field(sequence; Rec.Sequence)
                {
                    Caption = 'Sequence';
                }
                field(reportId; Rec."Report ID")
                {
                    Caption = 'Report ID';
                }
                field(reportName; Rec."Report Name")
                {
                    Caption = 'Report Name';
                    Editable = false;
                }
                field(reportLayoutName; Rec."Report Layout Name")
                {
                    Caption = 'Report Layout Name';
                }
                field(qtyToPrint; Rec."Qty to Print")
                {
                    Caption = 'Qty to Print';
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if Rec.Sequence = '' then
            Rec.GetNextSequence();
        if Rec."Qty to Print" = 0 then
            Rec."Qty to Print" := 1;
        exit(true);
    end;
}
