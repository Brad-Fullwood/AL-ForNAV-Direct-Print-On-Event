namespace BradFullwood.ForNAV.Logging;

/// <summary>
/// Log entry table for tracking system events and operations.
/// </summary>
table 77720 "BJF Log Entry"
{
    Caption = 'Log Entry';
    DataClassification = SystemMetadata;
    InherentPermissions = rimdx;
    Extensible = true;
    LookupPageId = "BJF Log Entries";
    DrillDownPageId = "BJF Log Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            ToolTip = 'Specifies the entry number.';
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Date Time"; DateTime)
        {
            Caption = 'Date Time';
            ToolTip = 'Specifies when the log entry was created.';
            Editable = false;
        }
        field(3; "Log Level"; Enum "BJF Log Level")
        {
            Caption = 'Log Level';
            ToolTip = 'Specifies the severity level of the log entry.';
            Editable = false;
        }
        field(4; "Event Type"; Enum "BJF Log Event Type")
        {
            Caption = 'Event Type';
            ToolTip = 'Specifies the type of event that was logged.';
            Editable = false;
        }
        field(5; "Object Type"; Text[30])
        {
            Caption = 'Object Type';
            ToolTip = 'Specifies the object type where the event occurred.';
            Editable = false;
        }
        field(6; "Object ID"; Integer)
        {
            Caption = 'Object ID';
            ToolTip = 'Specifies the object ID where the event occurred.';
            Editable = false;
        }
        field(7; "Procedure Name"; Text[128])
        {
            Caption = 'Procedure Name';
            ToolTip = 'Specifies the procedure name where the event occurred.';
            Editable = false;
        }
        field(8; "Message"; Text[250])
        {
            Caption = 'Message';
            ToolTip = 'Specifies the main log message.';
            Editable = false;
        }
        field(9; "Details"; Blob)
        {
            Caption = 'Details';
            ToolTip = 'Specifies additional details for the log entry.';
            Subtype = Memo;
        }
        field(10; "Source Record ID"; RecordId)
        {
            Caption = 'Source Record ID';
            ToolTip = 'Specifies the related record ID.';
            Editable = false;
        }
        field(11; "User ID"; Code[50])
        {
            Caption = 'User ID';
            ToolTip = 'Specifies the user who triggered the event.';
            Editable = false;
        }
        field(12; "Session ID"; Integer)
        {
            Caption = 'Session ID';
            ToolTip = 'Specifies the session ID where the event occurred.';
            Editable = false;
        }
        field(13; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            ToolTip = 'Specifies the company where the event occurred.';
            Editable = false;
        }
        field(14; "Error"; Boolean)
        {
            Caption = 'Error';
            ToolTip = 'Specifies whether this log entry represents an error.';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(DateTime; "Date Time")
        {
        }
        key(LogLevel; "Log Level", "Date Time")
        {
        }
        key(EventType; "Event Type", "Date Time")
        {
        }
        key(Error; "Error", "Date Time")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "Entry No.", "Date Time", "Log Level", "Event Type", "Message") { }
        fieldgroup(DropDown; "Entry No.", "Date Time", "Log Level", "Message") { }
    }

    trigger OnDelete()
    begin
        Error(this.CannotDeleteLogEntryErr);
    end;

    var
        CannotDeleteLogEntryErr: Label 'Log entries cannot be deleted manually. Use the cleanup functionality instead.';

    /// <summary>
    /// Gets the details text from the blob field.
    /// </summary>
    /// <returns>The details text content.</returns>
    procedure GetDetails(): Text
    var
        LocalDetails: Text;
        InStream: InStream;
    begin
        if not this.Details.HasValue() then
            exit('');

        this.CalcFields(Details);
        this.Details.CreateInStream(InStream, TextEncoding::UTF8);
        InStream.ReadText(LocalDetails);
        exit(LocalDetails);
    end;

    /// <summary>
    /// Sets the details text into the blob field.
    /// </summary>
    /// <param name="DetailsText">The details text to store.</param>
    procedure SetDetails(DetailsText: Text)
    var
        OutStream: OutStream;
    begin
        this.Details.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(DetailsText);
    end;
}
