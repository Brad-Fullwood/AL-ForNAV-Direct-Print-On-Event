namespace BradFullwood.ForNAV.Implementation.Purchase;

using BradFullwood.ForNAV.Core;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Document;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Purchases.History;

codeunit 77741 "BJF Purchase Print Events"
{
    Access = Internal;
    SingleInstance = true;
    InherentPermissions = x;

    var
        PrintMgmt: Codeunit "BJF Print Management";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterPostPurchaseDoc, '', false, false)]
    local procedure OnAfterPostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20]; CommitIsSupressed: Boolean)
    var
        RecRef: RecordRef;
    begin
        if CommitIsSupressed then
            exit; // Skip printing in preview mode or when commit is suppressed

        RecRef.GetTable(PurchaseHeader);
        RecRef.SetRecFilter();

        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then
            this.PrintMgmt.QueuePrintReports(RecRef, Format(Enum::"BJF Purchase Label Sets"::Purchase), Format(Enum::"BJF Purchase Events"::AfterPostPurchaseOrder));

        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Invoice then
            this.PrintMgmt.QueuePrintReports(RecRef, Format(Enum::"BJF Purchase Label Sets"::Purchase), Format(Enum::"BJF Purchase Events"::AfterPostPurchaseInvoice));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Header", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertPostedPurchaseInvoice(var Rec: Record "Purch. Inv. Header"; RunTrigger: Boolean)
    var
        RecRef: RecordRef;
    begin
        if not RunTrigger then
            exit;
        RecRef.GetTable(Rec);
        RecRef.SetRecFilter();
        this.PrintMgmt.QueuePrintReports(RecRef, Format(Enum::"BJF Purchase Label Sets"::"Posted Purchase"), Format(Enum::"BJF Purchase Events"::AfterPostPurchaseInvoice));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Rcpt. Header", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertPostedPurchReceipt(var Rec: Record "Purch. Rcpt. Header"; RunTrigger: Boolean)
    var
        RecRef: RecordRef;
    begin
        if not RunTrigger then
            exit;
        RecRef.GetTable(Rec);
        RecRef.SetRecFilter();
        this.PrintMgmt.QueuePrintReports(RecRef, Format(Enum::"BJF Purchase Label Sets"::"Posted Purchase Receipt"), Format(Enum::"BJF Purchase Events"::AfterPostPurchaseReceipt));
    end;
}
