namespace BradFullwood.ForNAV.Core;

using System.Device;

/// <summary>
/// Codeunit for handling print-related utilities in the automatic printing system.
/// </summary>
/// <remarks>
/// Provides functionality for populating print buffers and managing print operations.
/// </remarks>
codeunit 77702 "BJF Print Management"
{
    Access = Public;
    Permissions = tabledata "Printer Selection" = r,
                  tabledata "BJF Automatic Printing" = r,
                  tabledata "BJF Report Set" = r,
                  tabledata "BJF Printing Trigger" = r;

    /// <summary>
    /// Queue reports for printing for a given record reference, report set, and trigger.
    /// </summary>
    /// <param name="RecRef">The record reference to queue reports for.</param>
    /// <param name="ReportSetNo">The report set (what to print).</param>
    /// <param name="TriggerNo">The printing trigger (when to print).</param>
    procedure QueuePrintReports(RecRef: RecordRef; ReportSetNo: Code[50]; TriggerNo: Code[50])
    var
        Success: Boolean;
        ErrorMessage: Text;
    begin
        this.OnBeforeQueuePrintReports(RecRef, ReportSetNo, TriggerNo);

        Success := true;
        ErrorMessage := '';

        if not this.TryQueuePrintReports(RecRef, ReportSetNo, TriggerNo, ErrorMessage) then begin
            Success := false;
            if ErrorMessage = '' then
                ErrorMessage := GetLastErrorText();
        end;

        this.OnAfterQueuePrintReports(RecRef, ReportSetNo, TriggerNo, Success, ErrorMessage);
    end;

    local procedure TryQueuePrintReports(RecRef: RecordRef; ReportSetNo: Code[50]; TriggerNo: Code[50]; var ErrorMessage: Text): Boolean
    var
        AutoPrinting: Record "BJF Automatic Printing";
        PrintBuffer: Record "BJF Print Buffer";
        NoReportsConfiguredErr: Label 'No reports configured for report set %1', Comment = '%1 = Report Set';
        TriggerNotEnabledErr: Label 'Trigger %1 is not enabled for report set %2', Comment = '%1 = Trigger, %2 = Report Set';
    begin
        // Check if the trigger is enabled for this report set
        if not this.IsTriggerEnabledForReportSet(ReportSetNo, TriggerNo) then begin
            ErrorMessage := StrSubstNo(TriggerNotEnabledErr, TriggerNo, ReportSetNo);
            exit(false);
        end;

        // Get report selections
        AutoPrinting.Reset();
        AutoPrinting.SetRange("Report Set No.", ReportSetNo);
        AutoPrinting.SetFilter("Report ID", '<>0');

        if AutoPrinting.IsEmpty() then begin
            ErrorMessage := StrSubstNo(NoReportsConfiguredErr, ReportSetNo);
            exit(false);
        end;

        // Populate buffer with context information
        this.PopulateBufferWithContext(AutoPrinting, PrintBuffer, RecRef.RecordId());
        exit(true);
    end;

    local procedure PopulateBufferWithContext(var AutoPrinting: Record "BJF Automatic Printing"; var PrintBuffer: Record "BJF Print Buffer"; SourceRecordID: RecordId)
    begin
        if not AutoPrinting.FindSet() then
            exit;

        repeat
            PrintBuffer.Init();
            PrintBuffer."Source Record" := SourceRecordID;

            // Direct field-to-field assignment (type-safe, compile-time checked, performant)
            PrintBuffer."Report ID" := AutoPrinting."Report ID";
            AutoPrinting.CalcFields("Report Name");
            PrintBuffer."Report Caption" := AutoPrinting."Report Name";
            PrintBuffer."Custom Report Layout Code" := AutoPrinting."Custom Report Layout Code";
            PrintBuffer."Report Layout Name" := AutoPrinting."Report Layout Name";
            PrintBuffer."Report Layout App ID" := AutoPrinting."Report Layout AppID";
            AutoPrinting.CalcFields("Report Layout Caption");
            PrintBuffer."Report Layout Caption" := AutoPrinting."Report Layout Caption";
            AutoPrinting.CalcFields("Report Layout Publisher");
            PrintBuffer."Report Layout Publisher" := AutoPrinting."Report Layout Publisher";
            PrintBuffer."Qty to Print" := AutoPrinting."Qty to Print";

            PrintBuffer.Insert(true);
        until AutoPrinting.Next() = 0;
    end;

    internal procedure IsTriggerEnabledForReportSet(ReportSetNo: Code[50]; TriggerNo: Code[50]): Boolean
    var
        ReportSet: Record "BJF Report Set";
        AutoPrinting: Record "BJF Automatic Printing";
        ReportSetNotFoundErr: Label 'Report Set %1 not found', Comment = '%1 = Report Set';
    begin
        // Validate that the report set exists
        if not ReportSet.Get(ReportSetNo) then
            Error(ReportSetNotFoundErr, ReportSetNo);

        // Check if the trigger is enabled for this report set
        AutoPrinting.SetRange("Report Set No.", ReportSetNo);
        AutoPrinting.SetRange("Trigger No.", TriggerNo);
        exit(not AutoPrinting.IsEmpty());
    end;

    // Isolated events to avoid logging holding database locks
    [IntegrationEvent(false, false, true)]
    local procedure OnBeforeQueuePrintReports(RecRef: RecordRef; ReportSetNo: Code[50]; TriggerNo: Code[50])
    begin
    end;

    // Isolated events to avoid logging holding database locks
    [IntegrationEvent(false, false, true)]
    local procedure OnAfterQueuePrintReports(RecRef: RecordRef; ReportSetNo: Code[50]; TriggerNo: Code[50]; Success: Boolean; ErrorMessage: Text)
    begin
    end;

}
