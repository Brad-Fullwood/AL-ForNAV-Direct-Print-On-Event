namespace BradFullwood.ForNAV.Core;

/// <summary>
/// Enum for Print Buffer Status values
/// </summary>
enum 77701 "BJF Print Buffer Status"
{
    Extensible = false;

    value(0; "")
    {
    }
    value(1; Pending)
    {
        Caption = 'Pending';
    }
    value(2; Processing)
    {
        Caption = 'Processing';
    }
    value(3; Completed)
    {
        Caption = 'Completed';
    }
    value(4; Failed)
    {
        Caption = 'Failed';
    }
}
