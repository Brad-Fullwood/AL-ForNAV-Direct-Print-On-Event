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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"BJF Print Management", OnBeforeQueuePrintLabels, '', false, false)]
    local procedure OnBeforeQueuePrintLabels(RecRef: RecordRef; LabelGroupNo: Code[50]; EventNo: Code[50])
    var
        PrintJobStartedMsg: Label 'Print job queued - Label Group: %1, Event: %2, Table: %3', Comment = '%1 = Label Group No, %2 = Event No, %3 = Table Name';
    begin
        this.LoggingManager.Log(Enum::"BJF Log Level"::Information, Enum::"BJF Log Event Type"::"Print Job Started",
                 StrSubstNo(PrintJobStartedMsg, LabelGroupNo, EventNo, RecRef.Name()),
                 '', RecRef.RecordId(), '', 0, '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"BJF Print Management", OnAfterQueuePrintLabels, '', false, false)]
    local procedure OnAfterQueuePrintLabels(RecRef: RecordRef; LabelGroupNo: Code[50]; EventNo: Code[50]; Success: Boolean; ErrorMessage: Text)
    var
        PrintJobCompletedMsg: Label 'Print job queued successfully - Label Group: %1, Event: %2', Comment = '%1 = Label Group No, %2 = Event No';
        PrintJobFailedMsg: Label 'Print job queue failed - Label Group: %1, Event: %2', Comment = '%1 = Label Group No, %2 = Event No';
    begin
        if Success then
            this.LoggingManager.Log(Enum::"BJF Log Level"::Information, Enum::"BJF Log Event Type"::"Print Job Completed",
                     StrSubstNo(PrintJobCompletedMsg, LabelGroupNo, EventNo),
                     '', RecRef.RecordId(), '', 0, '')
        else
            this.LoggingManager.LogError(Enum::"BJF Log Event Type"::"Print Job Failed",
                         StrSubstNo(PrintJobFailedMsg, LabelGroupNo, EventNo),
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
        AutomaticPrintingConfigurationAddedMsg: Label 'Automatic printing configuration added - Label Group: %1, Event: %2, Report: %3', Comment = '%1 = Label Group No, %2 = Event No, %3 = Report ID';
    begin
        if not RunTrigger then
            exit;

        this.LoggingManager.Log(Enum::"BJF Log Level"::Information, Enum::"BJF Log Event Type"::"Configuration Changed",
                 StrSubstNo(AutomaticPrintingConfigurationAddedMsg, Rec."Label Group No.", Rec."Event No.", Rec."Report ID"),
                 '', Rec.RecordId(), '', 0, '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"BJF Automatic Printing", OnAfterModifyEvent, '', false, false)]
    local procedure OnAfterModifyAutomaticPrinting(var Rec: Record "BJF Automatic Printing"; var xRec: Record "BJF Automatic Printing"; RunTrigger: Boolean)
    var
        AutomaticPrintingConfigurationModifiedMsg: Label 'Automatic printing configuration modified - Label Group: %1, Event: %2, Report: %3', Comment = '%1 = Label Group No, %2 = Event No, %3 = Report ID';
    begin
        if not RunTrigger then
            exit;

        this.LoggingManager.Log(Enum::"BJF Log Level"::Information, Enum::"BJF Log Event Type"::"Configuration Changed",
                 StrSubstNo(AutomaticPrintingConfigurationModifiedMsg, Rec."Label Group No.", Rec."Event No.", Rec."Report ID"),
                 '', Rec.RecordId(), '', 0, '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"BJF Automatic Printing", OnAfterDeleteEvent, '', false, false)]
    local procedure OnAfterDeleteAutomaticPrinting(var Rec: Record "BJF Automatic Printing"; RunTrigger: Boolean)
    var
        AutomaticPrintingConfigurationDeletedMsg: Label 'Automatic printing configuration deleted - Label Group: %1, Event: %2, Report: %3', Comment = '%1 = Label Group No, %2 = Event No, %3 = Report ID';
    begin
        if not RunTrigger then
            exit;

        this.LoggingManager.Log(Enum::"BJF Log Level"::Information, Enum::"BJF Log Event Type"::"Configuration Changed",
                 StrSubstNo(AutomaticPrintingConfigurationDeletedMsg, Rec."Label Group No.", Rec."Event No.", Rec."Report ID"),
                 '', Rec.RecordId(), '', 0, '');
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"BJF Task Scheduling", OnBeforeScheduleTask, '', false, false)]
    local procedure OnBeforeScheduleTask(var Rec: Record "BJF Print Buffer")
    begin
        this.LoggingManager.Log(Enum::"BJF Log Level"::Information, Enum::"BJF Log Event Type"::"Buffer Processing",
                 'Scheduling task for print buffer entry - Entry No: %1, Report ID: %2',
                 '', Rec.RecordId(), '', 0, '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"BJF Task Scheduling", OnAfterScheduleTask, '', false, false)]
    local procedure OnAfterScheduleTask(var Rec: Record "BJF Print Buffer")
    begin
        this.LoggingManager.Log(Enum::"BJF Log Level"::Information, Enum::"BJF Log Event Type"::"Buffer Processing",
                 'Task scheduled for print buffer entry - Entry No: %1, Report ID: %2',
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
