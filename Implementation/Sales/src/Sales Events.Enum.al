namespace BradFullwood.ForNAV.Implementation.Sales;

/// <summary>
/// Enum for sales events.
/// </summary>
enum 77730 "BJF Sales Events"
{
    Extensible = true;
    Caption = 'Sales Events';

    value(1; "AfterPostSalesOrder")
    {
        Caption = 'After posting sales order';
    }
    value(2; "AfterPostSalesInvoice")
    {
        Caption = 'After posting sales invoice';
    }
    value(3; "OnAfterPostSalesShipment")
    {
        Caption = 'After posting sales shipment';
    }
}
