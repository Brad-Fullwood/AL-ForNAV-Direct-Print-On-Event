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

    procedure RegisterLabelGroups(var Helper: Codeunit "BJF Interface Utils")
    begin
        Helper.RegisterLabelGroup(Format(Enum::"BJF Sales Label Sets"::Sales), 'Sales', Database::"Sales Header");
        Helper.RegisterLabelGroup(Format(Enum::"BJF Sales Label Sets"::"Sales Posted"), 'Sales Posted', Database::"Sales Invoice Header");
        Helper.RegisterLabelGroup(Format(Enum::"BJF Sales Label Sets"::"Sales Shipment Posted"), 'Sales Shipment Posted', Database::"Sales Shipment Header");
    end;

    procedure RegisterEvents(var Helper: Codeunit "BJF Interface Utils")
    begin
        Helper.AddTable(Database::"Sales Header");
        Helper.AddTable(Database::"Sales Invoice Header");
        Helper.RegisterEventWithTables(Format(Enum::"BJF Sales Events"::AfterPostSalesOrder), 'After posting sales order');

        Helper.AddTable(Database::"Sales Header");
        Helper.AddTable(Database::"Sales Invoice Header");
        Helper.RegisterEventWithTables(Format(Enum::"BJF Sales Events"::AfterPostSalesInvoice), 'After posting sales invoice');

        Helper.AddTable(Database::"Sales Shipment Header");
        Helper.RegisterEventWithTables(Format(Enum::"BJF Sales Events"::OnAfterPostSalesShipment), 'After posting sales shipment');
    end;
}
