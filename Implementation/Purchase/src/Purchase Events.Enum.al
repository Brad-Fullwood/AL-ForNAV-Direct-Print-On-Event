namespace BradFullwood.ForNAV.Implementation.Purchase;

/// <summary>
/// Enum for purchase events.
/// </summary>
enum 77740 "BJF Purchase Events"
{
    Extensible = true;
    Caption = 'Purchase Events';

    value(1; "AfterPostPurchaseOrder")
    {
        Caption = 'After posting purchase order';
    }
    value(2; "AfterPostPurchaseInvoice")
    {
        Caption = 'After posting purchase invoice';
    }
    value(3; "AfterPostPurchaseReceipt")
    {
        Caption = 'After posting purchase receipt';
    }
}
