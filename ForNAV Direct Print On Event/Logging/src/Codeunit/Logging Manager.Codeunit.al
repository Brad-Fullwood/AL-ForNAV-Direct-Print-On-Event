namespace BradFullwood.ForNAV.Logging;

/// <summary>
/// Central logging manager for the ForNAV Direct Label Printing framework.
/// Provides event-driven logging with minimal coupling to other components.
/// </summary>
codeunit 77721 "BJF Logging Manager"
{
    Access = Public;
    InherentPermissions = x;

    var
        IsLoggingEnabled: Boolean;
        MinimumLogLevel: Enum "BJF Log Level";

    /// <summary>
    /// Manual log procedure that can be called from events or critical operations.
    /// </summary>
    /// <param name="LogLevel">The severity level of the log entry.</param>
    /// <param name="EventType">The type of event being logged.</param>
    /// <param name="Message">The main log message.</param>
    /// <param name="Details">Additional details (optional).</param>
    /// <param name="SourceRecordID">Related record ID (optional).</param>
    /// <param name="ObjectType">The object type where logging is called from (optional).</param>
    /// <param name="ObjectID">The object ID where logging is called from (optional).</param>
    /// <param name="ProcedureName">The procedure name where logging is called from (optional).</param>
    procedure Log(LogLevel: Enum "BJF Log Level"; EventType: Enum "BJF Log Event Type"; Message: Text[250]; Details: Text; SourceRecordID: RecordId; ObjectType: Text[30]; ObjectID: Integer; ProcedureName: Text[128])
    var
        LogEntry: Record "BJF Log Entry";
    begin
        if not this.ShouldLog(LogLevel) then
            exit;

        this.CreateLogEntry(LogEntry, LogLevel, EventType, Message, Details, SourceRecordID, ObjectType, ObjectID, ProcedureName, false);
    end;

    /// <summary>
    /// Simplified log procedure for basic logging scenarios.
    /// </summary>
    /// <param name="LogLevel">The severity level of the log entry.</param>
    /// <param name="EventType">The type of event being logged.</param>
    /// <param name="Message">The main log message.</param>
    procedure Log(LogLevel: Enum "BJF Log Level"; EventType: Enum "BJF Log Event Type"; Message: Text[250])
    var
        EmptyRec: Record "BJF Log Entry";
    begin
        this.Log(LogLevel, EventType, Message, '', EmptyRec.RecordId(), '', 0, '');
    end;

    /// <summary>
    /// Log procedure with source record information.
    /// </summary>
    /// <param name="LogLevel">The severity level of the log entry.</param>
    /// <param name="EventType">The type of event being logged.</param>
    /// <param name="Message">The main log message.</param>
    /// <param name="SourceRecordID">Related record ID.</param>
    procedure Log(LogLevel: Enum "BJF Log Level"; EventType: Enum "BJF Log Event Type"; Message: Text[250]; SourceRecordID: RecordId)
    begin
        this.Log(LogLevel, EventType, Message, '', SourceRecordID, '', 0, '');
    end;

    /// <summary>
    /// Log an error with exception details.
    /// </summary>
    /// <param name="EventType">The type of event being logged.</param>
    /// <param name="Message">The main error message.</param>
    /// <param name="ErrorDetails">Error details or stack trace.</param>
    /// <param name="SourceRecordID">Related record ID (optional).</param>
    procedure LogError(EventType: Enum "BJF Log Event Type"; Message: Text[250]; ErrorDetails: Text; SourceRecordID: RecordId)
    var
        LogEntry: Record "BJF Log Entry";
    begin
        if not this.ShouldLog(Enum::"BJF Log Level"::Error) then
            exit;

        this.CreateLogEntry(LogEntry, Enum::"BJF Log Level"::Error, EventType, Message, ErrorDetails, SourceRecordID, '', 0, '', true);
    end;

    local procedure CreateLogEntry(var LogEntry: Record "BJF Log Entry"; LogLevel: Enum "BJF Log Level"; EventType: Enum "BJF Log Event Type"; Message: Text[250]; Details: Text; SourceRecordID: RecordId; ObjectType: Text[30]; ObjectID: Integer; ProcedureName: Text[128]; IsError: Boolean)
    var
        InsertSuccess: Boolean;
    begin
        LogEntry.Init();
        LogEntry."Date Time" := CurrentDateTime();
        LogEntry."Log Level" := LogLevel;
        LogEntry."Event Type" := EventType;
        LogEntry."Object Type" := ObjectType;
        LogEntry."Object ID" := ObjectID;
        LogEntry."Procedure Name" := ProcedureName;
        LogEntry.Message := Message;
        LogEntry."Source Record ID" := SourceRecordID;
        LogEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(LogEntry."User ID"));
        LogEntry."Session ID" := SessionId();
        LogEntry."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(LogEntry."Company Name"));
        LogEntry.Error := IsError;

        if Details <> '' then
            LogEntry.SetDetails(Details);

        InsertSuccess := LogEntry.Insert(true);

        // Only log insert failures if we're not already in an error logging scenario
        if not InsertSuccess and not IsError then
            this.Log(Enum::"BJF Log Level"::Error, Enum::"BJF Log Event Type"::General,
                     'Failed to create log entry', 'Insert operation failed', SourceRecordID, '', 0, '');
    end;

    local procedure ShouldLog(LogLevel: Enum "BJF Log Level"): Boolean
    begin
        this.InitializeSettings();
        exit(this.IsLoggingEnabled and (LogLevel.AsInteger() >= this.MinimumLogLevel.AsInteger()));
    end;

    local procedure InitializeSettings()
    var
        LogSetup: Record "BJF Log Setup";
    begin
        if LogSetup.Get() then begin
            this.IsLoggingEnabled := LogSetup."Logging Enabled";
            this.MinimumLogLevel := LogSetup."Minimum Log Level";
        end else begin
            this.IsLoggingEnabled := true;
            this.MinimumLogLevel := Enum::"BJF Log Level"::Information;
        end;
    end;

    /// <summary>
    /// Clean Up old log entries based on retention policy.
    /// </summary>
    /// <param name="RetentionDays">Number of days to retain logs.</param>
    procedure CleanUpOldEntries(RetentionDays: Integer)
    var
        LogEntry: Record "BJF Log Entry";
        CutoffDate: DateTime;
        DeletedCount: Integer;
        CleanupMsg: Label 'Cleaned up %1 old log entries (older than %2 days)', Comment = '%1 = Deleted Count, %2 = Retention Days';
    begin
        if RetentionDays <= 0 then
            exit;

        CutoffDate := CurrentDateTime() - (RetentionDays * 24 * 60 * 60 * 1000);
        LogEntry.SetFilter("Date Time", '<%1', CutoffDate);

        if LogEntry.FindSet() then begin
            repeat
                LogEntry.Delete(false);
                DeletedCount += 1;
            until LogEntry.Next() = 0;

            this.Log(Enum::"BJF Log Level"::Information, Enum::"BJF Log Event Type"::General,
                     StrSubstNo(CleanupMsg, DeletedCount, RetentionDays),
                     '', LogEntry.RecordId(), '', 0, '');
        end;
    end;
}
