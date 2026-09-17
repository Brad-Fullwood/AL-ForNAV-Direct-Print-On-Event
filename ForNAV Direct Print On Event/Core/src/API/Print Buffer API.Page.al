namespace BradFullwood.ForNAV.Core;

/// <summary>
/// The print buffer as a read-only API, so a deployment script can see whether a queued job
/// rendered and reached ForNAV, and read the error when it did not.
/// </summary>
page 77509 "BJF Print Buffer API"
{
    PageType = API;
    APIPublisher = 'bradfullwood';
    APIGroup = 'directPrint';
    APIVersion = 'v1.0';
    EntityName = 'printBufferEntry';
    EntitySetName = 'printBufferEntries';
    EntityCaption = 'Print Buffer Entry';
    EntitySetCaption = 'Print Buffer Entries';
    SourceTable = "BJF Print Buffer";
    ODataKeyFields = SystemId;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Entries)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; }
                field(entryNo; Rec."Entry No.") { Caption = 'Entry No.'; }
                field(reportId; Rec."Report ID") { Caption = 'Report ID'; }
                field(reportCaption; Rec."Report Caption") { Caption = 'Report Caption'; }
                field(sourceRecord; Format(Rec."Source Record")) { Caption = 'Source Record'; }
                field(status; Rec.Status) { Caption = 'Status'; }
                field(errorMessage; Rec."Error Message") { Caption = 'Error Message'; }
                field(createdDateTime; Rec."Created Date Time") { Caption = 'Created Date Time'; }
                field(processedDateTime; Rec."Processed Date Time") { Caption = 'Processed Date Time'; }
                field(retryCount; Rec."Retry Count") { Caption = 'Retry Count'; }
                field(userId; Rec."User ID") { Caption = 'User ID'; }
            }
        }
    }
}
