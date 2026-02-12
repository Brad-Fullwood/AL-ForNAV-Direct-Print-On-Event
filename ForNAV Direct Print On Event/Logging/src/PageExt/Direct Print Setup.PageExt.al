namespace BradFullwood.ForNAV.Logging;

using BradFullwood.ForNAV.Core;

/// <summary>
/// Extends the Direct Print Setup page with logging navigation actions.
/// </summary>
pageextension 77720 "BJF Log Setup Actions" extends "BJF Direct Printing Setup"
{
    actions
    {
        addlast(Navigation)
        {
            group(LoggingGroup)
            {
                Caption = 'Logging';
                Image = Log;

                action(LogSetup)
                {
                    ApplicationArea = All;
                    Caption = 'Log Setup';
                    ToolTip = 'Configure logging settings for direct printing.';
                    Image = Setup;
                    RunObject = page "BJF Log Setup";
                }
                action(ViewLogEntries)
                {
                    ApplicationArea = All;
                    Caption = 'Log Entries';
                    ToolTip = 'View the direct print log entries.';
                    Image = Log;
                    RunObject = page "BJF Log Entries";
                }
            }
        }
        addlast(Promoted)
        {
            actionref(LogSetup_Promoted; LogSetup) { }
        }
    }
}
