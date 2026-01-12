namespace BradFullwood.ForNAV.Core;

/// <summary>
/// Codeunit for scheduling tasks for print buffer records.
/// </summary>
/// <remarks>
/// This codeunit is used to schedule tasks for print buffer records.
/// It is used to ensure that the tasks are scheduled for the print buffer records.
/// </remarks>
codeunit 77704 "BJF Task Scheduling"
{
    InherentPermissions = x;
    Access = Public;
    TableNo = "BJF Print Buffer";

    /// <summary>
    /// Schedule a task for a print buffer record.
    /// </summary>
    /// <remarks>
    /// This procedure is called by the OnAfterInsertEvent trigger in the Print Management codeunit.
    /// </remarks>
    /// <param name="Rec">The print buffer record to schedule the task for.</param>
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
            77704, // Failure codeunit - This codeunit will be called if the task fails via OnRun trigger.
            true, // IsReady
            CompanyName(),
            CurrentDateTime(), // Run immediately
            Rec.RecordId()
        );
    end;

    /// <summary>
    /// Trigger to mark a print buffer record as failed if the scheduling fails.
    /// </summary>
    /// <remarks>
    /// This trigger is only called by CreateTask in ScheduleTaskForPrintBuffer if the scheduling fails.
    /// </remarks>
    trigger OnRun()
    begin
        this.OnBeforeScheduleTask(Rec);

        this.SchedulingFailed(Rec);

        this.OnAfterScheduleTask(Rec);
    end;

    local procedure SchedulingFailed(var Rec: Record "BJF Print Buffer")
    begin
        this.OnScheduleTaskFailed(Rec);

        Rec.Status := Enum::"BJF Print Buffer Status"::Failed;
        Rec.Modify(false);
    end;

    /// <summary>
    /// Event raised before a task is scheduled.
    /// </summary>
    /// <param name="Rec">The print buffer record that is being scheduled.</param>
    [IntegrationEvent(false, false, true)]
    local procedure OnBeforeScheduleTask(var Rec: Record "BJF Print Buffer")
    begin
    end;

    /// <summary>
    /// Event raised after a task is scheduled.
    /// </summary>
    /// <param name="Rec">The print buffer record that was scheduled.</param>
    [IntegrationEvent(false, false, true)]
    local procedure OnAfterScheduleTask(var Rec: Record "BJF Print Buffer")
    begin
    end;

    /// <summary>
    /// Event raised if the task scheduling fails.
    /// </summary>
    /// <param name="Rec">The print buffer record that failed to be scheduled.</param>
    [IntegrationEvent(false, false, true)]
    local procedure OnScheduleTaskFailed(var Rec: Record "BJF Print Buffer")
    begin
    end;
}
