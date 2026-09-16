namespace BradFullwood.ForNAV.Implementation.Warehouse;

using Microsoft.Warehouse.History;
using BradFullwood.ForNAV.Core;

/// <summary>
/// Warehouse-focused label sets provider.
/// Handles all warehouse document labeling and events.
/// </summary>
codeunit 77752 "BJF Warehouse Implementation" implements "I-BJF Direct Print Interface"
{
    Access = Internal;
    InherentPermissions = x;

    procedure GetProviderInfo(var Provider: Enum "BJF Direct Print Provider"; var Description: Text[100]; var DefaultActive: Boolean)
    begin
        Provider := Enum::"BJF Direct Print Provider"::Warehouse;
        Description := 'Warehouse Provider';
        DefaultActive := true;
    end;

    procedure RegisterReportSets(var Helper: Codeunit "BJF Interface Utils")
    begin
        Helper.RegisterReportSet('WHSE-SHIPMENT-POSTED', 'Whse Shipment Posted', Database::"Posted Whse. Shipment Header");
        Helper.RegisterReportSet('WHSE-RECEIPT-POSTED', 'Whse Receipt Posted', Database::"Posted Whse. Receipt Header");
    end;

    procedure RegisterTriggers(var Helper: Codeunit "BJF Interface Utils")
    begin
        Helper.AddTable(Database::"Posted Whse. Shipment Header");
        Helper.RegisterTriggerWithTables('AFTER-POST-WHSE-SHIPMENT', 'After posting warehouse shipment');

        Helper.AddTable(Database::"Posted Whse. Receipt Header");
        Helper.RegisterTriggerWithTables('AFTER-POST-WHSE-RECEIPT', 'After posting warehouse receipt');
        // A reprint requested by a user or another extension, through "BJF Print Management".QueuePrintReports.
        Helper.AddTable(Database::"Posted Whse. Shipment Header");
        Helper.AddTable(Database::"Posted Whse. Receipt Header");
        Helper.RegisterTriggerWithTables('WHSE-REPRINT', 'Manual reprint (warehouse)');
    end;
}
