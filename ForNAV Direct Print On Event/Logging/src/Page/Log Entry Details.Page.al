namespace BradFullwood.ForNAV.Logging;

/// <summary>
/// FactBox page for displaying log entry details.
/// </summary>
page 77722 "BJF Log Entry Details"
{
    ApplicationArea = All;
    Caption = 'Log Entry Details';
    PageType = CardPart;
    SourceTable = "BJF Log Entry";
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Entry No."; Rec."Entry No.") { }
                field("Date Time"; Rec."Date Time") { }
                field("Log Level"; Rec."Log Level") { }
                field("Event Type"; Rec."Event Type") { }
                field("User ID"; Rec."User ID") { }
            }
            group(Technical)
            {
                Caption = 'Technical Details';
                field("Object Type"; Rec."Object Type") { }
                field("Object ID"; Rec."Object ID") { }
                field("Procedure Name"; Rec."Procedure Name") { }
                field("Session ID"; Rec."Session ID") { }
                field("Company Name"; Rec."Company Name") { }
            }
            group("Message")
            {
                Caption = 'Message';
                field(MessageField; Rec.Message)
                {
                    MultiLine = true;
                }
            }
            group(DetailsGroup)
            {
                Caption = 'Additional Details';
                Visible = this.HasDetails;
                field(DetailsField; this.DetailsText)
                {
                    MultiLine = true;
                    ShowCaption = false;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        this.UpdateDetailsText();
    end;

    var
        DetailsText: Text;
        HasDetails: Boolean;

    local procedure UpdateDetailsText()
    begin
        this.DetailsText := Rec.GetDetails();
        this.HasDetails := this.DetailsText <> '';
    end;
}
