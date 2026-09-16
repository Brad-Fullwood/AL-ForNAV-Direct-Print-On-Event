namespace BradFullwood.ForNAV.Implementation.Purchase;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using BradFullwood.ForNAV.Core;

/// <summary>
/// Purchase-focused label sets provider.
/// Handles all purchase document labeling and events.
/// </summary>
codeunit 77540 "BJF Purchase Implementation" implements "I-BJF Direct Print Interface"
{
    Access = Internal;
    InherentPermissions = x;

    procedure GetProviderInfo(var Provider: Enum "BJF Direct Print Provider"; var Description: Text[100]; var DefaultActive: Boolean)
    begin
        Provider := Enum::"BJF Direct Print Provider"::Purchase;
        Description := 'Purchase Provider';
        DefaultActive := true;
    end;

    procedure RegisterReportSets(var Helper: Codeunit "BJF Interface Utils")
    begin
        Helper.RegisterReportSet('PURCHASE', 'Purchase', Database::"Purchase Header");
        Helper.RegisterReportSet('PURCHASE-POSTED', 'Purchase Posted', Database::"Purch. Inv. Header");
        Helper.RegisterReportSet('PURCHASE-RECEIPT-POSTED', 'Purchase Receipt Posted', Database::"Purch. Rcpt. Header");
    end;

    procedure RegisterTriggers(var Helper: Codeunit "BJF Interface Utils")
    begin
        Helper.AddTable(Database::"Purchase Header");
        Helper.AddTable(Database::"Purch. Inv. Header");
        Helper.RegisterTriggerWithTables('AFTER-POST-PURCHASE-ORDER', 'After posting purchase order');

        Helper.AddTable(Database::"Purchase Header");
        Helper.AddTable(Database::"Purch. Inv. Header");
        Helper.RegisterTriggerWithTables('AFTER-POST-PURCHASE-INVOICE', 'After posting purchase invoice');

        Helper.AddTable(Database::"Purch. Rcpt. Header");
        Helper.RegisterTriggerWithTables('AFTER-POST-PURCHASE-RECEIPT', 'After posting purchase receipt');
        // A reprint requested by a user or another extension, through "BJF Print Management".QueuePrintReports.
        Helper.AddTable(Database::"Purch. Inv. Header");
        Helper.AddTable(Database::"Purch. Rcpt. Header");
        Helper.RegisterTriggerWithTables('PURCHASE-REPRINT', 'Manual reprint (purchase)');
    end;
}
