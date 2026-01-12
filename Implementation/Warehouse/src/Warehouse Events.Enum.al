namespace BradFullwood.ForNAV.Implementation.Warehouse;

/// <summary>
/// Enum for warehouse events.
/// </summary>
enum 77750 "BJF Warehouse Events"
{
    Extensible = true;
    Caption = 'Warehouse Events';

    value(1; "AfterPostWhseShip")
    {
        Caption = 'After posting warehouse shipment';
    }
    value(2; "AfterPostWhseReceipt")
    {
        Caption = 'After posting warehouse receipt';
    }
}
