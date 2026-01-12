namespace AdvaniaUK.ForNAV.LabelPrinting.Warehouse;

using Microsoft.Warehouse.History;
using AdvaniaUK.ForNAV.LabelPrinting;

/// <summary>
/// Warehouse-focused label sets provider.
/// Handles all warehouse document labeling and events.
/// </summary>
codeunit 77725 "AUK Warehouse Implementation" implements "I-AUK Direct Print Interface"
{
    Access = Internal;
    InherentPermissions = x;

    procedure GetProviderInfo(var Provider: Enum "AUK Direct Print Provider"; var Description: Text[100]; var DefaultActive: Boolean)
    begin
        Provider := Enum::"AUK Direct Print Provider"::Warehouse;
        Description := 'Warehouse Provider';
        DefaultActive := true;
    end;

    procedure RegisterLabelGroups(var Helper: Codeunit "AUK Interface Utils")
    begin
        Helper.RegisterLabelGroup(Format(Enum::"AUK Warehouse Label Sets"::"Whse Shipment Posted "), 'Posted Warehouse Shipment Labels', Database::"Posted Whse. Shipment Header");
        Helper.RegisterLabelGroup(Format(Enum::"AUK Warehouse Label Sets"::"Whse Receipt Posted"), 'Posted Warehouse Receipt Labels', Database::"Posted Whse. Receipt Header");
    end;

    procedure RegisterEvents(var Helper: Codeunit "AUK Interface Utils")
    begin
        Helper.AddTable(Database::"Posted Whse. Shipment Header");
        Helper.RegisterEventWithTables(Format(Enum::"AUK Warehouse Events"::AfterPostWhseShip), 'After posting warehouse shipment');

        Helper.AddTable(Database::"Posted Whse. Receipt Header");
        Helper.RegisterEventWithTables(Format(Enum::"AUK Warehouse Events"::AfterPostWhseReceipt), 'After posting warehouse receipt');
    end;
}
