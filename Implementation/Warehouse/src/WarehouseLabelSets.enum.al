namespace AdvaniaUK.ForNAV.LabelPrinting.Warehouse;

/// <summary>
/// Enum for warehouse label sets.
/// </summary>
enum 77724 "AUK Warehouse Label Sets"
{
    Extensible = true;
    Caption = 'Warehouse Label Sets';

    value(1; "Whse Shipment Posted ")
    {
        Caption = 'Posted Warehouse Shipment Labels';
    }
    value(2; "Whse Receipt Posted")
    {
        Caption = 'Posted Warehouse Receipt Labels';
    }
}
