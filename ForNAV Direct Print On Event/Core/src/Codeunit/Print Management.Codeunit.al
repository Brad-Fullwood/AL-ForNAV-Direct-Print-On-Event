namespace BradFullwood.ForNAV.Core;

using System.Device;

/// <summary>
/// Codeunit for handling print-related utilities in the label printing system.
/// </summary>
/// <remarks>
/// Provides functionality for populating label print buffers and managing print operations.
/// </remarks>
codeunit 77702 "BJF Print Management"
{
    Access = Public;
    Permissions = tabledata "Printer Selection" = r,
                  tabledata "BJF Automatic Printing" = r,
                  tabledata "BJF Label Groups" = r,
                  tabledata "BJF Event" = r;

    /// <summary>
    /// Queue print labels for a given record reference, label group, and event.
    /// </summary>
    /// <param name="RecRef">The record reference to queue print labels for.</param>
    /// <param name="LabelGroupNo">The label group to queue print labels for.</param>
    /// <param name="EventNo">The event to queue print labels for.</param>
    procedure QueuePrintLabels(RecRef: RecordRef; LabelGroupNo: Code[50]; EventNo: Code[50])
    var
        Success: Boolean;
        ErrorMessage: Text;
    begin
        this.OnBeforeQueuePrintLabels(RecRef, LabelGroupNo, EventNo);

        Success := true;
        ErrorMessage := '';

        if not this.TryQueuePrintLabels(RecRef, LabelGroupNo, EventNo, ErrorMessage) then begin
            Success := false;
            if ErrorMessage = '' then
                ErrorMessage := GetLastErrorText();
        end;

        this.OnAfterQueuePrintLabels(RecRef, LabelGroupNo, EventNo, Success, ErrorMessage);
    end;

    local procedure TryQueuePrintLabels(RecRef: RecordRef; LabelGroupNo: Code[50]; EventNo: Code[50]; var ErrorMessage: Text): Boolean
    var
        AutoPrinting: Record "BJF Automatic Printing";
        LabelPrintBuffer: Record "BJF Print Buffer";
        NoReportsConfiguredErr: Label 'No reports configured for label group %1', Comment = '%1 = Label Group';
        EventNotEnabledErr: Label 'Event %1 is not enabled for label group %2', Comment = '%1 = Event, %2 = Label Group';
    begin
        // Check if the event is enabled for this label group
        if not this.IsEventEnabledForLabelGroup(LabelGroupNo, EventNo) then begin
            ErrorMessage := StrSubstNo(EventNotEnabledErr, EventNo, LabelGroupNo);
            exit(false);
        end;

        // Get report selections
        AutoPrinting.Reset();
        AutoPrinting.SetRange("Label Group No.", LabelGroupNo);
        AutoPrinting.SetFilter("Report ID", '<>0');

        if AutoPrinting.IsEmpty() then begin
            ErrorMessage := StrSubstNo(NoReportsConfiguredErr, LabelGroupNo);
            exit(false);
        end;

        // Populate buffer with context information
        this.PopulateBufferWithContext(AutoPrinting, LabelPrintBuffer, RecRef.RecordId());
        exit(true);
    end;

    local procedure PopulateBufferWithContext(var AutoPrinting: Record "BJF Automatic Printing"; var LabelPrintBuffer: Record "BJF Print Buffer"; SourceRecordID: RecordId)
    begin
        if not AutoPrinting.FindSet() then
            exit;

        repeat
            LabelPrintBuffer.Init();
            LabelPrintBuffer."Source Record" := SourceRecordID;

            // Direct field-to-field assignment (type-safe, compile-time checked, performant)
            LabelPrintBuffer."Report ID" := AutoPrinting."Report ID";
            AutoPrinting.CalcFields("Report Name");
            LabelPrintBuffer."Report Caption" := AutoPrinting."Report Name";
            LabelPrintBuffer."Custom Report Layout Code" := AutoPrinting."Custom Report Layout Code";
            LabelPrintBuffer."Report Layout Name" := AutoPrinting."Report Layout Name";
            LabelPrintBuffer."Report Layout App ID" := AutoPrinting."Report Layout AppID";
            AutoPrinting.CalcFields("Report Layout Caption");
            LabelPrintBuffer."Report Layout Caption" := AutoPrinting."Report Layout Caption";
            AutoPrinting.CalcFields("Report Layout Publisher");
            LabelPrintBuffer."Report Layout Publisher" := AutoPrinting."Report Layout Publisher";
            LabelPrintBuffer."Qty to Print" := AutoPrinting."Qty to Print";

            LabelPrintBuffer.Insert(true);
        until AutoPrinting.Next() = 0;
    end;

    internal procedure IsEventEnabledForLabelGroup(LabelGroupNo: Code[50]; EventNo: Code[50]): Boolean
    var
        LabelGroup: Record "BJF Label Groups";
        AutoPrinting: Record "BJF Automatic Printing";
        LabelGroupNotFoundErr: Label 'Label Group %1 not found', Comment = '%1 = Label Group';
    begin
        // Validate that the label group exists
        if not LabelGroup.Get(LabelGroupNo) then
            Error(LabelGroupNotFoundErr, LabelGroupNo);

        // Check if the event is enabled for this label group
        AutoPrinting.SetRange("Label Group No.", LabelGroupNo);
        AutoPrinting.SetRange("Event No.", EventNo);
        exit(not AutoPrinting.IsEmpty());
    end;

    /// <summary>
    /// Event subscriber to schedule individual task for each Print Buffer insert.
    /// </summary>
    /// <remarks>
    /// Uses TaskScheduler for invisible background processing with automatic retry.
    /// </remarks>
    /// <param name="Rec">The record that was inserted.</param>
    /// <param name="RunTrigger">Whether the trigger was run.</param>
    [EventSubscriber(ObjectType::Table, Database::"BJF Print Buffer", OnAfterInsertEvent, '', false, false)]
    local procedure ScheduleTaskForPrintBuffer(var Rec: Record "BJF Print Buffer"; RunTrigger: Boolean)
    var
        TaskId: Guid;
    begin
        if not RunTrigger then
            exit;

        // Skip if already processing or completed
        if Rec.Status <> Enum::"BJF Print Buffer Status"::Pending then
            exit;

        // Schedule task to run immediately
        // TaskScheduler automatically handles retries (up to 99 times in BC Online)
        TaskId := TaskScheduler.CreateTask(
            Codeunit::"BJF Scheduled Task Runner",
            0, // No failure codeunit - let TaskScheduler handle retries
            true, // IsReady
            CompanyName(),
            CurrentDateTime(), // Run immediately
            Rec.RecordId()
        );
    end;

    // Isolated events to avoid logging holding database locks
    [IntegrationEvent(false, false, true)]
    local procedure OnBeforeQueuePrintLabels(RecRef: RecordRef; LabelGroupNo: Code[50]; EventNo: Code[50])
    begin
    end;

    // Isolated events to avoid logging holding database locks
    [IntegrationEvent(false, false, true)]
    local procedure OnAfterQueuePrintLabels(RecRef: RecordRef; LabelGroupNo: Code[50]; EventNo: Code[50]; Success: Boolean; ErrorMessage: Text)
    begin
    end;

}
