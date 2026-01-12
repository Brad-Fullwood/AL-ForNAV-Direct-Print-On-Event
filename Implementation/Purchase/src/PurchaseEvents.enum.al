namespace AdvaniaUK.ForNAV.LabelPrinting.Purchase;

/// <summary>
/// Enum for purchase events.
/// </summary>
enum 77715 "AUK Purchase Events"
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
    value(3; "OnAfterPostPurchaseReceipt")
    {
        Caption = 'After posting purchase receipt';
    }
}
