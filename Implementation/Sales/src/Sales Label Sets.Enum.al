namespace BradFullwood.ForNAV.Implementation.Sales;

/// <summary>
/// Enum for sales label sets.
/// </summary>
enum 77731 "BJF Sales Label Sets"
{
    Extensible = true;
    Caption = 'Sales Label Sets';

    value(1; "Sales")
    {
        Caption = 'Sales Labels';
    }
    value(2; "Sales Posted")
    {
        Caption = 'Posted Sales Labels';
    }
    value(3; "Sales Shipment Posted")
    {
        Caption = 'Posted Sales Shipment Labels';
    }
}
