namespace BradFullwood.ForNAV.Logging;

/// <summary>
/// Enum for log levels.
/// </summary>
enum 77721 "BJF Log Level"
{
    Extensible = false;
    Caption = 'Log Level';

    value(1; "Trace")
    {
        Caption = 'Trace';
    }
    value(2; "Debug")
    {
        Caption = 'Debug';
    }
    value(3; "Information")
    {
        Caption = 'Information';
    }
    value(4; "Warning")
    {
        Caption = 'Warning';
    }
    value(5; "Error")
    {
        Caption = 'Error';
    }
    value(6; "Critical")
    {
        Caption = 'Critical';
    }
}
