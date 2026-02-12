namespace BradFullwood.ForNAV.Logging;

/// <summary>
/// Setup page for logging configuration.
/// </summary>
page 77723 "BJF Log Setup"
{
    ApplicationArea = All;
    Caption = 'Log Setup';
    PageType = Card;
    SourceTable = "BJF Log Setup";
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Settings';
                field("Logging Enabled"; Rec."Logging Enabled") { }
                field("Minimum Log Level"; Rec."Minimum Log Level") { }
                field("Debug Mode"; Rec."Debug Mode") { }
            }
            group(Retention)
            {
                Caption = 'Data Retention';
                field("Auto Cleanup Enabled"; Rec."Auto Cleanup Enabled") { }
                field("Retention Days"; Rec."Retention Days")
                {
                    Enabled = Rec."Auto Cleanup Enabled";
                }
                field("Max Entries"; Rec."Max Entries") { }
            }

            group(Statistics)
            {
                Caption = 'Statistics';
                field("Total Log Entries"; Rec."Total Log Entries") { }
                field("Error Log Entries"; Rec."Error Log Entries") { }
                field("Today Log Entries"; Rec."Today Log Entries") { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewLogEntries)
            {
                ApplicationArea = All;
                Caption = 'View Log Entries';
                Image = List;
                ToolTip = 'Open the log entries page.';
                RunObject = page "BJF Log Entries";
            }
            group(Maintenance)
            {
                Caption = 'Maintenance';
                action(CleanUpOldEntries)
                {
                    ApplicationArea = All;
                    Caption = 'Clean Up Old Entries';
                    Image = Delete;
                    ToolTip = 'Delete old log entries based on retention policy.';

                    trigger OnAction()
                    var
                        LoggingManager: Codeunit "BJF Logging Manager";
                    begin
                        if not Dialog.Confirm('Do you want to delete log entries older than %1 days?', false, Rec."Retention Days") then
                            exit;

                        LoggingManager.CleanUpOldEntries(Rec."Retention Days");
                        CurrPage.Update(false);
                        Message('Old log entries have been cleaned up.');
                    end;
                }
                action(ClearAllEntries)
                {
                    ApplicationArea = All;
                    Caption = 'Clear All Entries';
                    Image = ClearLog;
                    ToolTip = 'Delete all log entries.';

                    trigger OnAction()
                    var
                        LogEntry: Record "BJF Log Entry";
                    begin
                        if not Dialog.Confirm('Are you sure you want to delete ALL log entries? This action cannot be undone.') then
                            exit;

                        LogEntry.DeleteAll(false);
                        CurrPage.Update(false);
                        Message('All log entries have been deleted.');
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get('') then begin
            Rec.Init();
            Rec."Primary Key" := '';
            Rec.Insert(true);
        end;
        Rec.SetFilter("Today Filter", '%1..%2', CreateDateTime(Today(), 0T), CreateDateTime(Today(), 235959T));
    end;
}
