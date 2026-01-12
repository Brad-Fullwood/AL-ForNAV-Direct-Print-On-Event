namespace AdvaniaUK.ForNAV.LabelPrinting.Sales;

using AdvaniaUK.ForNAV.LabelPrinting;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Document;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;

codeunit 77722 "AUK Sales Print Events"
{
    Access = Internal;
    SingleInstance = true;
    InherentPermissions = x;

    var
        PrintMgmt: Codeunit "AUK Print Management";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterPostSalesDoc, '', false, false)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean; PreviewMode: Boolean)
    var
        RecRef: RecordRef;
    begin
        if PreviewMode then
            exit; // Skip printing in preview mode

        RecRef.GetTable(SalesHeader);
        RecRef.SetRecFilter();

        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
            this.PrintMgmt.QueuePrintLabels(RecRef, Format(Enum::"AUK Sales Label Sets"::Sales), Format(Enum::"AUK Sales Events"::AfterPostSalesOrder));

        if SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice then
            this.PrintMgmt.QueuePrintLabels(RecRef, Format(Enum::"AUK Sales Label Sets"::Sales), Format(Enum::"AUK Sales Events"::AfterPostSalesInvoice));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Header", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertPostedSalesInvoice(var Rec: Record "Sales Invoice Header"; RunTrigger: Boolean)
    var
        RecRef: RecordRef;
    begin
        if not RunTrigger then
            exit;
        RecRef.GetTable(Rec);
        RecRef.SetRecFilter();

        this.PrintMgmt.QueuePrintLabels(RecRef, Format(Enum::"AUK Sales Label Sets"::"Sales Posted"), Format(Enum::"AUK Sales Events"::AfterPostSalesInvoice));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Shipment Header", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertPostedSalesShipment(var Rec: Record "Sales Shipment Header"; RunTrigger: Boolean)
    var
        RecRef: RecordRef;
    begin
        if not RunTrigger then
            exit;
        RecRef.GetTable(Rec);
        RecRef.SetRecFilter();

        this.PrintMgmt.QueuePrintLabels(RecRef, Format(Enum::"AUK Sales Label Sets"::"Sales Shipment Posted"), Format(Enum::"AUK Sales Events"::OnAfterPostSalesShipment));
    end;

}
