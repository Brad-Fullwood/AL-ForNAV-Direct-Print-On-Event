namespace BradFullwood.ForNAV.LabelPrinting.Purchase;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using BradFullwood.ForNAV.LabelPrinting;

/// <summary>
/// Purchase-focused label sets provider.
/// Handles all purchase document labeling and events.
/// </summary>
codeunit 77717 "BJF Purchase Implementation" implements "I-BJF Direct Print Interface"
{
    Access = Internal;
    InherentPermissions = x;

    procedure GetProviderInfo(var Provider: Enum "BJF Direct Print Provider"; var Description: Text[100]; var DefaultActive: Boolean)
    begin
        Provider := Enum::"BJF Direct Print Provider"::Purchase;
        Description := 'Purchase Provider';
        DefaultActive := true;
    end;

    procedure RegisterLabelGroups(var Helper: Codeunit "BJF Interface Utils")
    begin
        Helper.RegisterLabelGroup(Format(Enum::"BJF Purchase Label Sets"::Purchase), 'Purchase Labels', Database::"Purchase Header");
        Helper.RegisterLabelGroup(Format(Enum::"BJF Purchase Label Sets"::"Posted Purchase"), 'Posted Purchase Labels', Database::"Purch. Inv. Header");
        Helper.RegisterLabelGroup(Format(Enum::"BJF Purchase Label Sets"::"Posted Purchase Receipt"), 'Posted Purchase Receipt Labels', Database::"Purch. Rcpt. Header");
    end;

    procedure RegisterEvents(var Helper: Codeunit "BJF Interface Utils")
    begin
        Helper.AddTable(Database::"Purchase Header");
        Helper.AddTable(Database::"Purch. Inv. Header");
        Helper.RegisterEventWithTables(Format(Enum::"BJF Purchase Events"::AfterPostPurchaseOrder), 'After posting purchase order');

        Helper.AddTable(Database::"Purchase Header");
        Helper.AddTable(Database::"Purch. Inv. Header");
        Helper.RegisterEventWithTables(Format(Enum::"BJF Purchase Events"::AfterPostPurchaseInvoice), 'After posting purchase invoice');

        Helper.AddTable(Database::"Purch. Rcpt. Header");
        Helper.RegisterEventWithTables(Format(Enum::"BJF Purchase Events"::OnAfterPostPurchaseReceipt), 'After posting purchase receipt');
    end;
}
