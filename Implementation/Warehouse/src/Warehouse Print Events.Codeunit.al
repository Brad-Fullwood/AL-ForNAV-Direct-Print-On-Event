namespace BradFullwood.ForNAV.Implementation.Warehouse;

using BradFullwood.ForNAV.Core;
using Microsoft.Warehouse.History;

codeunit 77753 "BJF Warehouse Print Events"
{
    Access = Internal;
    SingleInstance = true;
    InherentPermissions = x;

    var
        PrintMgmt: Codeunit "BJF Print Management";

    [EventSubscriber(ObjectType::Table, Database::"Posted Whse. Shipment Header", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertPostedWhseShipment(var Rec: Record "Posted Whse. Shipment Header"; RunTrigger: Boolean)
    var
        RecRef: RecordRef;
    begin
        if not RunTrigger then
            exit;
        RecRef.GetTable(Rec);
        RecRef.SetRecFilter();
        this.PrintMgmt.QueuePrintLabels(RecRef, Format(Enum::"BJF Warehouse Label Sets"::"Whse Shipment Posted "), Format(Enum::"BJF Warehouse Events"::AfterPostWhseShip));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Whse. Receipt Header", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertPostedWhseReceipt(var Rec: Record "Posted Whse. Receipt Header"; RunTrigger: Boolean)
    var
        RecRef: RecordRef;
    begin
        if not RunTrigger then
            exit;
        RecRef.GetTable(Rec);
        RecRef.SetRecFilter();
        this.PrintMgmt.QueuePrintLabels(RecRef, Format(Enum::"BJF Warehouse Label Sets"::"Whse Receipt Posted"), Format(Enum::"BJF Warehouse Events"::AfterPostWhseReceipt));
    end;
}
