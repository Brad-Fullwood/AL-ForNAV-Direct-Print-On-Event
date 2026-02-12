namespace BradFullwood.ForNAV.Logging;

/// <summary>
/// Central logging manager for the ForNAV Direct Label Printing framework.
/// Provides event-driven logging with minimal coupling to other components.
/// </summary>
codeunit 77721 "BJF Logging Manager"
{
    Access = Public;
    SingleInstance = true;
    InherentPermissions = x;

    var
        IsLoggingEnabled: Boolean;
        MinimumLogLevel: Enum "BJF Log Level";
        IsInitialized: Boolean;

    /// <summary>
    /// Manual log procedure that can be called from events or critical operations.
    /// </summary>
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
    procedure Log(LogLevel: Enum "BJF Log Level"; EventType: Enum "BJF Log Event Type"; Message: Text[250])
    var
        EmptyRec: Record "BJF Log Entry";
    begin
        this.Log(LogLevel, EventType, Message, '', EmptyRec.RecordId(), '', 0, '');
    end;

    /// <summary>
    /// Log procedure with source record information.
    /// </summary>
    procedure Log(LogLevel: Enum "BJF Log Level"; EventType: Enum "BJF Log Event Type"; Message: Text[250]; SourceRecordID: RecordId)
    begin
        this.Log(LogLevel, EventType, Message, '', SourceRecordID, '', 0, '');
    end;

    /// <summary>
    /// Log an error with exception details.
    /// </summary>
    procedure LogError(EventType: Enum "BJF Log Event Type"; Message: Text[250]; ErrorDetails: Text; SourceRecordID: RecordId)
    var
        LogEntry: Record "BJF Log Entry";
    begin
        if not this.ShouldLog(Enum::"BJF Log Level"::Error) then
            exit;

        this.CreateLogEntry(LogEntry, Enum::"BJF Log Level"::Error, EventType, Message, ErrorDetails, SourceRecordID, '', 0, '', true);
    end;

    local procedure CreateLogEntry(var LogEntry: Record "BJF Log Entry"; LogLevel: Enum "BJF Log Level"; EventType: Enum "BJF Log Event Type"; Message: Text[250]; Details: Text; SourceRecordID: RecordId; ObjectType: Text[30]; ObjectID: Integer; ProcedureName: Text[128]; IsError: Boolean)
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

        LogEntry.Insert(false);
    end;

    local procedure ShouldLog(LogLevel: Enum "BJF Log Level"): Boolean
    begin
        this.EnsureInitialized();
        exit(this.IsLoggingEnabled and (LogLevel.AsInteger() >= this.MinimumLogLevel.AsInteger()));
    end;

    local procedure EnsureInitialized()
    var
        LogSetup: Record "BJF Log Setup";
    begin
        if this.IsInitialized then
            exit;

        if LogSetup.Get('') then begin
            this.IsLoggingEnabled := LogSetup."Logging Enabled";
            this.MinimumLogLevel := LogSetup."Minimum Log Level";
        end else begin
            this.IsLoggingEnabled := true;
            this.MinimumLogLevel := Enum::"BJF Log Level"::Information;
        end;

        this.IsInitialized := true;
    end;

    /// <summary>
    /// Force re-read of settings from database. Call after changing Log Setup.
    /// </summary>
    procedure RefreshSettings()
    begin
        this.IsInitialized := false;
    end;

    /// <summary>
    /// Clean Up old log entries based on retention policy.
    /// </summary>
    procedure CleanUpOldEntries(RetentionDays: Integer)
    var
        LogEntry: Record "BJF Log Entry";
        CutoffDate: DateTime;
    begin
        if RetentionDays <= 0 then
            exit;

        CutoffDate := CurrentDateTime() - (RetentionDays * 24 * 60 * 60 * 1000);
        LogEntry.SetFilter("Date Time", '<%1', CutoffDate);

        if not LogEntry.IsEmpty() then
            LogEntry.DeleteAll(false);
    end;
}
