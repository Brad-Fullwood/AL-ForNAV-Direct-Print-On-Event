namespace BradFullwood.ForNAV.Core;

/// <summary>
/// Codeunit for scheduling tasks for print buffer records.
/// </summary>
/// <remarks>
/// Subscribes to Print Buffer inserts and schedules background tasks via TaskScheduler.
/// Also serves as the failure codeunit — OnRun is called by the platform when the task runner fails.
/// </remarks>
codeunit 77704 "BJF Task Scheduling"
{
    InherentPermissions = x;
    Access = Public;
    TableNo = "BJF Print Buffer";

    [EventSubscriber(ObjectType::Table, Database::"BJF Print Buffer", OnAfterInsertEvent, '', false, false)]
    local procedure ScheduleTaskForPrintBuffer(var Rec: Record "BJF Print Buffer"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;

        if Rec.Status <> Enum::"BJF Print Buffer Status"::Pending then
            exit;

        // Wrapped in TryFunction so a scheduling failure never aborts the calling transaction
        if not TryCreateScheduledTask(Rec) then
            OnScheduleTaskFailed(Rec);
    end;

    [TryFunction]
    local procedure TryCreateScheduledTask(var PrintBuffer: Record "BJF Print Buffer")
    var
        TaskId: Guid;
    begin
        // Small delay (5 seconds) gives the posting transaction time to commit
        // before the task session tries to read the source record (batched insert safety)
        TaskId := TaskScheduler.CreateTask(
            Codeunit::"BJF Scheduled Task Runner",
            Codeunit::"BJF Task Scheduling", // This codeunit handles failures via OnRun
            true, // IsReady
            CompanyName(),
            CurrentDateTime() + 5000, // 5 second delay for transaction commit safety
            PrintBuffer.RecordId()
        );
    end;

    /// <summary>
    /// Failure handler — called by the platform when the Scheduled Task Runner fails.
    /// </summary>
    trigger OnRun()
    begin
        this.HandleTaskFailure(Rec);
    end;

    local procedure HandleTaskFailure(var PrintBuffer: Record "BJF Print Buffer")
    begin
        this.OnScheduleTaskFailed(PrintBuffer);

        PrintBuffer.Status := Enum::"BJF Print Buffer Status"::Failed;
        PrintBuffer."Error Message" := CopyStr(GetLastErrorText(), 1, MaxStrLen(PrintBuffer."Error Message"));
        PrintBuffer.Modify(false);
    end;

    /// <summary>
    /// Event raised if task scheduling or execution fails.
    /// </summary>
    /// <param name="Rec">The print buffer record that failed.</param>
    [IntegrationEvent(false, false, true)]
    local procedure OnScheduleTaskFailed(var Rec: Record "BJF Print Buffer")
    begin
    end;
}
