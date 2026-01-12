namespace AdvaniaUK.ForNAV.LabelPrinting.Purchase;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using AdvaniaUK.ForNAV.LabelPrinting;

/// <summary>
/// Purchase-focused label sets provider.
/// Handles all purchase document labeling and events.
/// </summary>
codeunit 77717 "AUK Purchase Implementation" implements "I-AUK Direct Print Interface"
{
    Access = Internal;
    InherentPermissions = x;

    procedure GetProviderInfo(var Provider: Enum "AUK Direct Print Provider"; var Description: Text[100]; var DefaultActive: Boolean)
    begin
        Provider := Enum::"AUK Direct Print Provider"::Purchase;
        Description := 'Purchase Provider';
        DefaultActive := true;
    end;

    procedure RegisterLabelGroups(var Helper: Codeunit "AUK Interface Utils")
    begin
        Helper.RegisterLabelGroup(Format(Enum::"AUK Purchase Label Sets"::Purchase), 'Purchase Labels', Database::"Purchase Header");
        Helper.RegisterLabelGroup(Format(Enum::"AUK Purchase Label Sets"::"Posted Purchase"), 'Posted Purchase Labels', Database::"Purch. Inv. Header");
        Helper.RegisterLabelGroup(Format(Enum::"AUK Purchase Label Sets"::"Posted Purchase Receipt"), 'Posted Purchase Receipt Labels', Database::"Purch. Rcpt. Header");
    end;

    procedure RegisterEvents(var Helper: Codeunit "AUK Interface Utils")
    begin
        Helper.AddTable(Database::"Purchase Header");
        Helper.AddTable(Database::"Purch. Inv. Header");
        Helper.RegisterEventWithTables(Format(Enum::"AUK Purchase Events"::AfterPostPurchaseOrder), 'After posting purchase order');

        Helper.AddTable(Database::"Purchase Header");
        Helper.AddTable(Database::"Purch. Inv. Header");
        Helper.RegisterEventWithTables(Format(Enum::"AUK Purchase Events"::AfterPostPurchaseInvoice), 'After posting purchase invoice');

        Helper.AddTable(Database::"Purch. Rcpt. Header");
        Helper.RegisterEventWithTables(Format(Enum::"AUK Purchase Events"::OnAfterPostPurchaseReceipt), 'After posting purchase receipt');
    end;
}
