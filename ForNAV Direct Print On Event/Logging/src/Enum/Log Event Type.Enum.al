namespace BradFullwood.ForNAV.Logging;

/// <summary>
/// Enum for log event types.
/// </summary>
enum 77720 "BJF Log Event Type"
{
    Extensible = false;
    Caption = 'Log Event Type';

    value(1; "System Start")
    {
        Caption = 'System Start';
    }
    value(2; "Provider Registration")
    {
        Caption = 'Provider Registration';
    }
    value(3; "Print Job Started")
    {
        Caption = 'Print Job Started';
    }
    value(4; "Print Job Completed")
    {
        Caption = 'Print Job Completed';
    }
    value(5; "Print Job Failed")
    {
        Caption = 'Print Job Failed';
    }
    value(6; "Buffer Processing")
    {
        Caption = 'Buffer Processing';
    }
    value(7; "Event Triggered")
    {
        Caption = 'Event Triggered';
    }
    value(8; "Configuration Changed")
    {
        Caption = 'Configuration Changed';
    }
    value(9; "Validation")
    {
        Caption = 'Validation';
    }
    value(10; "General")
    {
        Caption = 'General';
    }
}
