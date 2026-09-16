namespace BradFullwood.ForNAV.Implementation.Sales;

using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using BradFullwood.ForNAV.Core;

/// <summary>
/// Sales-focused label sets provider.
/// Handles all sales document labeling and events.
/// </summary>
codeunit 77734 "BJF Sales Implementation" implements "I-BJF Direct Print Interface"
{
    Access = Internal;
    InherentPermissions = x;

    procedure GetProviderInfo(var Provider: Enum "BJF Direct Print Provider"; var Description: Text[100]; var DefaultActive: Boolean)
    begin
        Provider := Enum::"BJF Direct Print Provider"::Sales;
        Description := 'Sales Provider';
        DefaultActive := true;
    end;

    procedure RegisterReportSets(var Helper: Codeunit "BJF Interface Utils")
    begin
        Helper.RegisterReportSet('SALES', 'Sales', Database::"Sales Header");
        Helper.RegisterReportSet('SALES-POSTED', 'Sales Posted', Database::"Sales Invoice Header");
        Helper.RegisterReportSet('SALES-SHIPMENT-POSTED', 'Sales Shipment Posted', Database::"Sales Shipment Header");
    end;

    procedure RegisterTriggers(var Helper: Codeunit "BJF Interface Utils")
    begin
        Helper.AddTable(Database::"Sales Header");
        Helper.AddTable(Database::"Sales Invoice Header");
        Helper.RegisterTriggerWithTables('AFTER-POST-SALES-ORDER', 'After posting sales order');

        Helper.AddTable(Database::"Sales Header");
        Helper.AddTable(Database::"Sales Invoice Header");
        Helper.RegisterTriggerWithTables('AFTER-POST-SALES-INVOICE', 'After posting sales invoice');

        Helper.AddTable(Database::"Sales Shipment Header");
        Helper.RegisterTriggerWithTables('AFTER-POST-SALES-SHIPMENT', 'After posting sales shipment');
        // A reprint requested by a user or another extension, through "BJF Print Management".QueuePrintReports.
        Helper.AddTable(Database::"Sales Invoice Header");
        Helper.AddTable(Database::"Sales Shipment Header");
        Helper.RegisterTriggerWithTables('SALES-REPRINT', 'Manual reprint (sales)');
    end;
}
