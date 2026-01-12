namespace AdvaniaUK.ForNAV.LabelPrinting.Warehouse;

/// <summary>
/// Enum for warehouse events.
/// </summary>
enum 77723 "AUK Warehouse Events"
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
