namespace BradFullwood.ForNAV.Implementation.Purchase;

/// <summary>
/// Enum for purchase label sets.
/// </summary>
enum 77741 "BJF Purchase Label Sets"
{
    Extensible = true;
    Caption = 'Purchase Label Sets';

    value(1; "Purchase")
    {
        Caption = 'Purchase Labels';
    }
    value(2; "Posted Purchase")
    {
        Caption = 'Posted Purchase Labels';
    }
    value(3; "Posted Purchase Receipt")
    {
        Caption = 'Posted Purchase Receipt Labels';
    }
}
