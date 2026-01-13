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

    procedure RegisterLabelGroups(var Helper: Codeunit "BJF Interface Utils")
    begin
        Helper.RegisterLabelGroup(Format(Enum::"BJF Warehouse Label Sets"::"Whse Shipment Posted "), 'Whse Shipment Posted', Database::"Posted Whse. Shipment Header");
        Helper.RegisterLabelGroup(Format(Enum::"BJF Warehouse Label Sets"::"Whse Receipt Posted"), 'Whse Receipt Posted', Database::"Posted Whse. Receipt Header");
    end;

    procedure RegisterEvents(var Helper: Codeunit "BJF Interface Utils")
    begin
        Helper.AddTable(Database::"Posted Whse. Shipment Header");
        Helper.RegisterEventWithTables(Format(Enum::"BJF Warehouse Events"::AfterPostWhseShip), 'After posting warehouse shipment');

        Helper.AddTable(Database::"Posted Whse. Receipt Header");
        Helper.RegisterEventWithTables(Format(Enum::"BJF Warehouse Events"::AfterPostWhseReceipt), 'After posting warehouse receipt');
    end;
}
