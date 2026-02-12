namespace BradFullwood.ForNAV.Core;

using Microsoft.Foundation.Reporting;
using System.Device;
using System.Utilities;
using System.Reflection;

/// <summary>
/// TaskScheduler Codeunit for processing individual print buffer entries.
/// </summary>
/// <remarks>
/// Processes a single print job from the buffer table.
/// Designed to be run as scheduled tasks via TaskScheduler for invisible background processing.
/// </remarks>
codeunit 77703 "BJF Scheduled Task Runner"
{
    Access = Public;
    TableNo = "BJF Print Buffer";
    Permissions = tabledata "Printer Selection" = r,
                  tabledata "ForNAV DirPrt Queue" = rimd,
                  tabledata "ForNAV Local Printer" = r,
                  tabledata "Report Layout Selection" = r,
                  tabledata "Custom Report Layout" = r,
                  tabledata "BJF Print Buffer" = rimd;
    trigger OnRun()
    begin
        this.OnBeforeProcessPrintJob(Rec);

        this.ProcessPrintJob(Rec);

        this.OnAfterProcessPrintJob(Rec);
    end;

    local procedure ProcessPrintJob(var PrintBuffer: Record "BJF Print Buffer")
    var
        Success: Boolean;
        PrintJobFailedMsg: Label 'Print job failed for Report %1', Comment = '%1 = Report ID';
    begin
        // Concurrency guard: lock, re-read, and verify status before proceeding
        PrintBuffer.LockTable();
        if not PrintBuffer.Get(PrintBuffer."Entry No.") then
            exit;
        if PrintBuffer.Status <> Enum::"BJF Print Buffer Status"::Pending then
            exit;

        PrintBuffer.Status := Enum::"BJF Print Buffer Status"::Processing;
        PrintBuffer.Modify(false);
        Commit();

        // Attempt processing
        Success := this.TryProcessPrintRequest(PrintBuffer);

        // Reload to get latest version
        if not PrintBuffer.Get(PrintBuffer."Entry No.") then
            exit;

        // Update final status
        if Success then begin
            PrintBuffer.Status := Enum::"BJF Print Buffer Status"::Completed;
            PrintBuffer."Processed Date Time" := CurrentDateTime();
            PrintBuffer."Error Message" := '';
            PrintBuffer.Modify(false);
        end else begin
            PrintBuffer.Status := Enum::"BJF Print Buffer Status"::Failed;
            PrintBuffer."Processed Date Time" := CurrentDateTime();
            PrintBuffer."Error Message" := CopyStr(GetLastErrorText(), 1, MaxStrLen(PrintBuffer."Error Message"));
            PrintBuffer."Retry Count" += 1;
            PrintBuffer.Modify(false);

            this.OnPrintJobFailed(
                PrintBuffer."Report ID",
                PrintBuffer."Source Record",
                CopyStr(StrSubstNo(PrintJobFailedMsg, PrintBuffer."Report ID"), 1, 250),
                GetLastErrorText()
            );
        end;
    end;

    [TryFunction]
    local procedure TryProcessPrintRequest(var PrintBuffer: Record "BJF Print Buffer")
    var
        PrinterSelections: Record "Printer Selection";
        ForNavLocalPrinter: Record "ForNAV Local Printer";
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        InvalidSourceRecordErr: Label 'Invalid source record for print buffer';
        NoPrinterFoundErr: Label 'No printer found for report %1 and user %2', Comment = '%1 = Report ID, %2 = User ID';
        SourceRecordNotFoundErr: Label 'Source record not found for print buffer %1', Comment = '%1 = Source Record';
        SuccessMsg: Label 'Successfully queued Report %1 to ForNAV', Comment = '%1 = Report ID';
    begin
        if PrintBuffer."Source Record".TableNo() = 0 then
            Error(InvalidSourceRecordErr);

        // Use User ID from buffer instead of UserId() for Job Queue context
        if not PrinterSelections.Get(PrintBuffer."User ID", PrintBuffer."Report ID") then
            if not PrinterSelections.Get('', PrintBuffer."Report ID") then // Fallback to default
                Error(NoPrinterFoundErr, PrintBuffer."Report ID", PrintBuffer."User ID");

        if not ForNavLocalPrinter.Get(PrinterSelections."Printer Name") then
            Error(NoPrinterFoundErr, PrintBuffer."Report ID", PrintBuffer."User ID");

        if not RecRef.Get(PrintBuffer."Source Record") then
            Error(SourceRecordNotFoundErr, PrintBuffer."Source Record");

        this.RenderReportToPdf(
            PrintBuffer."Report ID", RecRef.RecordId(),
            PrintBuffer."Custom Report Layout Code",
            PrintBuffer."Report Layout Name", PrintBuffer."Report Layout App ID",
            TempBlob);

        this.CreatePrintQueueEntryFromStream(
            PrintBuffer."Report ID",
            ForNavLocalPrinter."Cloud Printer Name",
            ForNavLocalPrinter."Local Printer Name",
            TempBlob,
            PrintBuffer."Qty to Print"
        );

        this.OnPrintJobCompleted(
            PrintBuffer."Report ID",
            PrintBuffer."Source Record",
            CopyStr(StrSubstNo(SuccessMsg, PrintBuffer."Report ID"), 1, 250)
        );
    end;

    local procedure RenderReportToPdf(ReportID: Integer; RecordId: RecordId; CustomReportLayoutCode: Code[20]; ReportLayoutName: Text[250]; ReportLayoutAppID: Guid; var TempBlob: Codeunit "Temp Blob")
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomReportLayout: Record "Custom Report Layout";
        RecRef: RecordRef;
        OutStr: OutStream;
        LayoutCode: Code[20];
    begin
        LayoutCode := CustomReportLayoutCode;

        // If a named layout is specified, look up its custom report layout code
        if (LayoutCode = '') and (ReportLayoutName <> '') then begin
            CustomReportLayout.SetRange("Report ID", ReportID);
            CustomReportLayout.SetRange(Description, CopyStr(ReportLayoutName, 1, MaxStrLen(CustomReportLayout.Description)));
            if CustomReportLayout.FindFirst() then
                LayoutCode := CustomReportLayout.Code;
        end;

        if LayoutCode <> '' then
            ReportLayoutSelection.SetTempLayoutSelected(LayoutCode);

        RecRef.Get(RecordId);
        TempBlob.CreateOutStream(OutStr);
        Report.SaveAs(ReportID, '', ReportFormat::Pdf, OutStr, RecRef);
    end;

    local procedure CreatePrintQueueEntryFromStream(ReportId: Integer; CloudPrinterName: Text; LocalPrinterName: Text[250]; var DocumentBlob: Codeunit "Temp Blob"; QtyToPrint: Integer)
    var
        ForNavPrintQueue: Record "ForNAV DirPrt Queue";
        AllObjWithCaption: Record AllObjWithCaption;
        ReportLbl: Label 'Report %1', Comment = '%1 = Report ID';
        InStr: InStream;
        PrinterSettings: Text;
        ReportName: Text;
    begin
        if (CloudPrinterName = '') or (LocalPrinterName = '') then
            exit;

        if QtyToPrint <= 0 then
            exit;

        DocumentBlob.CreateInStream(InStr);

        PrinterSettings := this.CreatePrinterSettings(CloudPrinterName, QtyToPrint);

        // Get the report name
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Report);
        AllObjWithCaption.SetRange("Object ID", ReportId);
        if AllObjWithCaption.FindFirst() then
            ReportName := AllObjWithCaption."Object Caption"
        else
            ReportName := StrSubstNo(ReportLbl, ReportId);

        ForNavPrintQueue.Create(ReportId, CloudPrinterName, LocalPrinterName, InStr, PrinterSettings, ReportName, ForNavPrintQueue.ContentType::PDF);
    end;

    local procedure CreatePrinterSettings(CloudPrinterName: Text; QtyToPrint: Integer): Text
    var
        LocalPrinter: Record "ForNAV Local Printer";
        JsonPrinterSettings: JsonObject;
        PrinterSettings: Text;
        LocalPrinterErr: Label 'No local printer found for %1', Comment = '%1 = Cloud Printer Name';
    begin
        if not LocalPrinter.Get(CloudPrinterName) then
            Error(LocalPrinterErr, CloudPrinterName);

        JsonPrinterSettings := LocalPrinter.PrinterSetting();
        if JsonPrinterSettings.Contains('Copies') then
            JsonPrinterSettings.Replace('Copies', QtyToPrint)
        else
            JsonPrinterSettings.Add('Copies', QtyToPrint);

        JsonPrinterSettings.WriteTo(PrinterSettings);
        exit(PrinterSettings);
    end;

    /// <summary>
    /// Raised when a print job completes successfully.
    /// </summary>
    /// <param name="ReportID">The report ID that was printed.</param>
    /// <param name="SourceRecordID">The source record that was printed.</param>
    /// <param name="Message">Success message.</param>
    [IntegrationEvent(false, false, true)]
    local procedure OnPrintJobCompleted(ReportID: Integer; SourceRecordID: RecordId; Message: Text[250])
    begin
    end;

    /// <summary>
    /// Raised when a print job fails.
    /// </summary>
    /// <param name="ReportID">The report ID that failed to print.</param>
    /// <param name="SourceRecordID">The source record that was being printed.</param>
    /// <param name="Message">Error message.</param>
    /// <param name="ErrorDetails">Detailed error information.</param>
    [IntegrationEvent(false, false, true)]
    local procedure OnPrintJobFailed(ReportID: Integer; SourceRecordID: RecordId; Message: Text[250]; ErrorDetails: Text)
    begin
    end;

    /// <summary>
    /// Event raised before a print job is processed.
    /// </summary>
    /// <param name="PrintBuffer">The print buffer record that is being processed.</param>
    [IntegrationEvent(false, false, true)]
    local procedure OnBeforeProcessPrintJob(var PrintBuffer: Record "BJF Print Buffer")
    begin
    end;

    /// <summary>
    /// Event raised after a print job is processed.
    /// </summary>
    /// <param name="PrintBuffer">The print buffer record that was processed.</param>
    [IntegrationEvent(false, false, true)]
    local procedure OnAfterProcessPrintJob(var PrintBuffer: Record "BJF Print Buffer")
    begin
    end;
}
