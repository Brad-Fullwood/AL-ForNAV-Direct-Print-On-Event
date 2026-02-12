namespace BradFullwood.ForNAV.Logging;

/// <summary>
/// Card page for viewing detailed log entry information.
/// </summary>
page 77721 "BJF Log Entry Card"
{
    ApplicationArea = All;
    UsageCategory = None;
    Extensible = false;
    Caption = 'Direct Print Log Entry';
    PageType = Card;
    SourceTable = "BJF Log Entry";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Information';
                field("Entry No."; Rec."Entry No.") { }
                field("Date Time"; Rec."Date Time") { }
                field("Log Level"; Rec."Log Level") { }
                field("Event Type"; Rec."Event Type") { }
                field("Error"; Rec."Error") { }
            }
            group(Context)
            {
                Caption = 'Context Information';
                field("User ID"; Rec."User ID") { }
                field("Session ID"; Rec."Session ID") { }
                field("Source Record ID"; Rec."Source Record ID") { }
            }
            group(Technical)
            {
                Caption = 'Technical Information';
                field("Object Type"; Rec."Object Type") { }
                field("Object ID"; Rec."Object ID") { }
                field("Procedure Name"; Rec."Procedure Name") { }
            }
            group(Message)
            {
                Caption = 'Message';
                field(MessageField; Rec.Message)
                {
                    Caption = 'Message';
                    MultiLine = true;
                    ShowCaption = false;
                }
            }
            group(Details)
            {
                Caption = 'Additional Details';
                Visible = this.HasDetails;
                field(DetailsField; this.DetailsText)
                {
                    Caption = 'Details';
                    MultiLine = true;
                    ShowCaption = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CopyToClipboard)
            {
                ApplicationArea = All;
                Caption = 'Copy to Clipboard';
                Image = Copy;
                ToolTip = 'Copy the log entry details to clipboard.';

                trigger OnAction()
                var
                    LogDetails: Text;
                begin
                    LogDetails := this.FormatLogEntryForClipboard();
                    Message('Log entry details copied to clipboard:\%1', LogDetails);
                end;
            }
        }
        area(Navigation)
        {
            action(PreviousEntry)
            {
                ApplicationArea = All;
                Caption = 'Previous Entry';
                Image = PreviousRecord;
                ToolTip = 'Go to the previous log entry.';

                trigger OnAction()
                begin
                    if Rec.Next(-1) <> 0 then
                        CurrPage.Update(false);
                end;
            }
            action(NextEntry)
            {
                ApplicationArea = All;
                Caption = 'Next Entry';
                Image = NextRecord;
                ToolTip = 'Go to the next log entry.';

                trigger OnAction()
                begin
                    if Rec.Next() <> 0 then
                        CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        this.UpdateDetailsText();
        this.UpdateVisibility();
    end;

    var
        DetailsText: Text;
        HasDetails: Boolean;

    local procedure UpdateDetailsText()
    begin
        this.DetailsText := Rec.GetDetails();
    end;

    local procedure UpdateVisibility()
    begin
        this.HasDetails := this.DetailsText <> '';
    end;

    local procedure FormatLogEntryForClipboard(): Text
    var
        TextBuilder: TextBuilder;
        LogDetailsMsg: Label 'Entry No: %1\Date Time: %2\Log Level: %3\Event Type: %4\Message: %5\User: %6\Session: %7\Company: %8', Comment = '%1 = Entry No, %2 = Date Time, %3 = Log Level, %4 = Event Type, %5 = Message, %6 = User, %7 = Session, %8 = Company';
        LogDetailsObjMsg: Label 'Object: %1 %2', Comment = '%1 = Object Type, %2 = Object ID';
        LogDetailsProcedureMsg: Label 'Procedure: %1', Comment = '%1 = Procedure Name';
        LogDetailsDetailsMsg: Label 'Details: %1', Comment = '%1 = Details';
    begin
        TextBuilder.Append(StrSubstNo(LogDetailsMsg,
                                     Rec."Entry No.", Rec."Date Time", Rec."Log Level", Rec."Event Type",
                                     Rec.Message, Rec."User ID", Rec."Session ID", Rec."Company Name"));

        if Rec."Object Type" <> '' then
            TextBuilder.Append(StrSubstNo(LogDetailsObjMsg, Rec."Object Type", Rec."Object ID"));

        if Rec."Procedure Name" <> '' then
            TextBuilder.Append(StrSubstNo(LogDetailsProcedureMsg, Rec."Procedure Name"));

        if this.DetailsText <> '' then
            TextBuilder.Append(StrSubstNo(LogDetailsDetailsMsg, this.DetailsText));

        exit(TextBuilder.ToText());
    end;
}
