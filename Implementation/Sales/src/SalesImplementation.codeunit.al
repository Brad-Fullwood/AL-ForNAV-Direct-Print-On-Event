namespace AdvaniaUK.ForNAV.LabelPrinting.Sales;

using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using AdvaniaUK.ForNAV.LabelPrinting;

/// <summary>
/// Sales-focused label sets provider.
/// Handles all sales document labeling and events.
/// </summary>
codeunit 77721 "AUK Sales Implementation" implements "I-AUK Direct Print Interface"
{
    Access = Internal;
    InherentPermissions = x;

    procedure GetProviderInfo(var Provider: Enum "AUK Direct Print Provider"; var Description: Text[100]; var DefaultActive: Boolean)
    begin
        Provider := Enum::"AUK Direct Print Provider"::Sales;
        Description := 'Sales Provider';
        DefaultActive := true;
    end;

    procedure RegisterLabelGroups(var Helper: Codeunit "AUK Interface Utils")
    begin
        Helper.RegisterLabelGroup(Format(Enum::"AUK Sales Label Sets"::Sales), 'Sales Labels', Database::"Sales Header");
        Helper.RegisterLabelGroup(Format(Enum::"AUK Sales Label Sets"::"Sales Posted"), 'Posted Sales Labels', Database::"Sales Invoice Header");
        Helper.RegisterLabelGroup(Format(Enum::"AUK Sales Label Sets"::"Sales Shipment Posted"), 'Posted Sales Shipment Labels', Database::"Sales Shipment Header");
    end;

    procedure RegisterEvents(var Helper: Codeunit "AUK Interface Utils")
    begin
        Helper.AddTable(Database::"Sales Header");
        Helper.AddTable(Database::"Sales Invoice Header");
        Helper.RegisterEventWithTables(Format(Enum::"AUK Sales Events"::AfterPostSalesOrder), 'After posting sales order');

        Helper.AddTable(Database::"Sales Header");
        Helper.AddTable(Database::"Sales Invoice Header");
        Helper.RegisterEventWithTables(Format(Enum::"AUK Sales Events"::AfterPostSalesInvoice), 'After posting sales invoice');

        Helper.AddTable(Database::"Sales Shipment Header");
        Helper.RegisterEventWithTables(Format(Enum::"AUK Sales Events"::OnAfterPostSalesShipment), 'After posting sales shipment');
    end;
}
