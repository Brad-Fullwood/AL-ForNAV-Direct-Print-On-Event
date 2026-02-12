namespace BradFullwood.ForNAV.Logging;

using BradFullwood.ForNAV.Core;

codeunit 77720 "BJF Log Events"
{
    SingleInstance = true; // Prevent multiple instances of the codeunit from being created
    InherentPermissions = x;

    var
        LoggingManager: Codeunit "BJF Logging Manager";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"BJF Scheduled Task Runner", OnPrintJobCompleted, '', false, false)]
    local procedure OnPrintJobCompleted(ReportID: Integer; SourceRecordID: RecordId; Message: Text[250])
    begin
        this.LoggingManager.Log(
            Enum::"BJF Log Level"::Information,
            Enum::"BJF Log Event Type"::"Print Job Completed",
            Message,
            SourceRecordID
        );
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"BJF Scheduled Task Runner", OnPrintJobFailed, '', false, false)]
    local procedure OnPrintJobFailed(ReportID: Integer; SourceRecordID: RecordId; Message: Text[250]; ErrorDetails: Text)
    begin
        this.LoggingManager.LogError(
            Enum::"BJF Log Event Type"::"Print Job Failed",
            Message,
            ErrorDetails,
            SourceRecordID
        );
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"BJF Interface Utils", OnAfterRegisterAllProviders, '', false, false)]
    local procedure OnAfterRegisterAllProviders()
    begin
        this.LoggingManager.Log(Enum::"BJF Log Level"::Information, Enum::"BJF Log Event Type"::"Provider Registration", 'All providers registered successfully');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"BJF Interface Utils", OnAfterStartProviderRegistration, '', false, false)]
    local procedure OnAfterStartProviderRegistration(Provider: Enum "BJF Direct Print Provider"; Description: Text[100])
    var
        RegistrationMsg: Label 'Started registration for provider: %1 (%2)', Comment = '%1 = Provider, %2 = Description';
    begin
        this.LoggingManager.Log(Enum::"BJF Log Level"::Information, Enum::"BJF Log Event Type"::"Provider Registration", StrSubstNo(RegistrationMsg, Provider, Description));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"BJF Print Management", OnBeforeQueuePrintReports, '', false, false)]
    local procedure OnBeforeQueuePrintReports(RecRef: RecordRef; ReportSetNo: Code[50]; TriggerNo: Code[50])
    var
        PrintJobStartedMsg: Label 'Print job queued - Report Set: %1, Trigger: %2, Table: %3', Comment = '%1 = Report Set No, %2 = Trigger No, %3 = Table Name';
    begin
        this.LoggingManager.Log(Enum::"BJF Log Level"::Information, Enum::"BJF Log Event Type"::"Print Job Started",
                 StrSubstNo(PrintJobStartedMsg, ReportSetNo, TriggerNo, RecRef.Name()),
                 '', RecRef.RecordId(), '', 0, '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"BJF Print Management", OnAfterQueuePrintReports, '', false, false)]
    local procedure OnAfterQueuePrintReports(RecRef: RecordRef; ReportSetNo: Code[50]; TriggerNo: Code[50]; Success: Boolean; ErrorMessage: Text)
    var
        PrintJobCompletedMsg: Label 'Print job queued successfully - Report Set: %1, Trigger: %2', Comment = '%1 = Report Set No, %2 = Trigger No';
        PrintJobFailedMsg: Label 'Print job queue failed - Report Set: %1, Trigger: %2', Comment = '%1 = Report Set No, %2 = Trigger No';
    begin
        if Success then
            this.LoggingManager.Log(Enum::"BJF Log Level"::Information, Enum::"BJF Log Event Type"::"Print Job Completed",
                     StrSubstNo(PrintJobCompletedMsg, ReportSetNo, TriggerNo),
                     '', RecRef.RecordId(), '', 0, '')
        else
            this.LoggingManager.LogError(Enum::"BJF Log Event Type"::"Print Job Failed",
                         StrSubstNo(PrintJobFailedMsg, ReportSetNo, TriggerNo),
                         ErrorMessage, RecRef.RecordId());
    end;

    [EventSubscriber(ObjectType::Table, Database::"BJF Print Buffer", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertPrintBuffer(var Rec: Record "BJF Print Buffer"; RunTrigger: Boolean)
    var
        BufferCreatedMsg: Label 'Print buffer entry created - Report ID: %1, Status: %2', Comment = '%1 = Report ID, %2 = Status';
    begin
        if not RunTrigger then
            exit;

        this.LoggingManager.Log(
            Enum::"BJF Log Level"::Information,
            Enum::"BJF Log Event Type"::"Buffer Processing",
            StrSubstNo(BufferCreatedMsg, Rec."Report ID", Rec.Status),
            Rec."Source Record"
        );
    end;

    [EventSubscriber(ObjectType::Table, Database::"BJF Print Buffer", OnAfterDeleteEvent, '', false, false)]
    local procedure OnAfterDeletePrintBuffer(var Rec: Record "BJF Print Buffer"; RunTrigger: Boolean)
    var
        PrintBufferEntryProcessedMsg: Label 'Print buffer entry processed - Entry No: %1, Report ID: %2', Comment = '%1 = Entry No, %2 = Report ID';
    begin
        if not RunTrigger then
            exit;

        this.LoggingManager.Log(Enum::"BJF Log Level"::Information, Enum::"BJF Log Event Type"::"Buffer Processing",
                 StrSubstNo(PrintBufferEntryProcessedMsg, Rec."Entry No.", Rec."Report ID"),
                 '', Rec."Source Record", '', 0, '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"BJF Automatic Printing", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertAutomaticPrinting(var Rec: Record "BJF Automatic Printing"; RunTrigger: Boolean)
    var
        AutomaticPrintingConfigurationAddedMsg: Label 'Automatic printing configuration added - Report Set: %1, Trigger: %2, Report: %3', Comment = '%1 = Report Set No, %2 = Trigger No, %3 = Report ID';
    begin
        if not RunTrigger then
            exit;

        this.LoggingManager.Log(Enum::"BJF Log Level"::Information, Enum::"BJF Log Event Type"::"Configuration Changed",
                 StrSubstNo(AutomaticPrintingConfigurationAddedMsg, Rec."Report Set No.", Rec."Trigger No.", Rec."Report ID"),
                 '', Rec.RecordId(), '', 0, '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"BJF Automatic Printing", OnAfterModifyEvent, '', false, false)]
    local procedure OnAfterModifyAutomaticPrinting(var Rec: Record "BJF Automatic Printing"; var xRec: Record "BJF Automatic Printing"; RunTrigger: Boolean)
    var
        AutomaticPrintingConfigurationModifiedMsg: Label 'Automatic printing configuration modified - Report Set: %1, Trigger: %2, Report: %3', Comment = '%1 = Report Set No, %2 = Trigger No, %3 = Report ID';
    begin
        if not RunTrigger then
            exit;

        this.LoggingManager.Log(Enum::"BJF Log Level"::Information, Enum::"BJF Log Event Type"::"Configuration Changed",
                 StrSubstNo(AutomaticPrintingConfigurationModifiedMsg, Rec."Report Set No.", Rec."Trigger No.", Rec."Report ID"),
                 '', Rec.RecordId(), '', 0, '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"BJF Automatic Printing", OnAfterDeleteEvent, '', false, false)]
    local procedure OnAfterDeleteAutomaticPrinting(var Rec: Record "BJF Automatic Printing"; RunTrigger: Boolean)
    var
        AutomaticPrintingConfigurationDeletedMsg: Label 'Automatic printing configuration deleted - Report Set: %1, Trigger: %2, Report: %3', Comment = '%1 = Report Set No, %2 = Trigger No, %3 = Report ID';
    begin
        if not RunTrigger then
            exit;

        this.LoggingManager.Log(Enum::"BJF Log Level"::Information, Enum::"BJF Log Event Type"::"Configuration Changed",
                 StrSubstNo(AutomaticPrintingConfigurationDeletedMsg, Rec."Report Set No.", Rec."Trigger No.", Rec."Report ID"),
                 '', Rec.RecordId(), '', 0, '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"BJF Task Scheduling", OnScheduleTaskFailed, '', false, false)]
    local procedure OnScheduleTaskFailed(var Rec: Record "BJF Print Buffer")
    begin
        this.LoggingManager.Log(Enum::"BJF Log Level"::Warning, Enum::"BJF Log Event Type"::"Buffer Processing",
                 'Task scheduling failed for print buffer entry - Entry No: %1, Report ID: %2',
                 '', Rec.RecordId(), '', 0, '');
    end;
}
