namespace BradFullwood.ForNAV.Logging;

/// <summary>
/// Page for viewing log entries.
/// </summary>
page 77720 "BJF Log Entries"
{
    ApplicationArea = All;
    Caption = 'Log Entries';
    Extensible = false;
    PageType = List;
    SourceTable = "BJF Log Entry";
    UsageCategory = Lists;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Entries)
            {
                field("Entry No."; Rec."Entry No.") { }
                field("Date Time"; Rec."Date Time") { }
                field("Log Level"; Rec."Log Level")
                {
                    StyleExpr = this.LogLevelStyle;
                }
                field("Event Type"; Rec."Event Type") { }
                field("Message"; Rec."Message") { }
                field("Object Type"; Rec."Object Type")
                {
                    Visible = false;
                }
                field("Object ID"; Rec."Object ID")
                {
                    Visible = false;
                }
                field("Procedure Name"; Rec."Procedure Name")
                {
                    Visible = false;
                }
                field("User ID"; Rec."User ID") { }
                field("Error"; Rec."Error") { }
            }
        }
        area(FactBoxes)
        {
            part(Details; "BJF Log Entry Details")
            {
                SubPageLink = "Entry No." = field("Entry No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewDetails)
            {
                Caption = 'View Details';
                ToolTip = 'View the details of the log entry.';
                Image = View;

                trigger OnAction()
                var
                    LogEntryDetails: Page "BJF Log Entry Card";
                begin
                    LogEntryDetails.SetRecord(Rec);
                    LogEntryDetails.RunModal();
                end;
            }
            action(LogSetup)
            {
                Caption = 'Log Setup';
                ToolTip = 'View the log setup.';
                Image = Setup;
                RunObject = page "BJF Log Setup";
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        this.SetLogLevelStyle();
    end;

    var
        LogLevelStyle: Text;

    local procedure SetLogLevelStyle()
    begin
        case Rec."Log Level" of
            Rec."Log Level"::Error, Rec."Log Level"::Critical:
                this.LogLevelStyle := Format(PageStyle::Unfavorable);
            Rec."Log Level"::Warning:
                this.LogLevelStyle := Format(PageStyle::Ambiguous);
            Rec."Log Level"::Information:
                this.LogLevelStyle := Format(PageStyle::Favorable);
            else
                this.LogLevelStyle := Format(PageStyle::Standard);
        end;
    end;
}
