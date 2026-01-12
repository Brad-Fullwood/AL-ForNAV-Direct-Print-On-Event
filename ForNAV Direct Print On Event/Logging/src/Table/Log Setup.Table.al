namespace BradFullwood.ForNAV.Logging;

/// <summary>
/// Setup table for logging configuration.
/// </summary>
table 77721 "BJF Log Setup"
{
    Caption = 'Log Setup';
    DataClassification = SystemMetadata;
    InherentPermissions = rimdx;
    Extensible = true;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            NotBlank = true;
            AllowInCustomizations = Never;
            ToolTip = 'Specifies the primary key for the log setup record.';
        }
        field(2; "Logging Enabled"; Boolean)
        {
            Caption = 'Logging Enabled';
            InitValue = true;
            ToolTip = 'Specifies whether logging is enabled.';
        }
        field(3; "Minimum Log Level"; Enum "BJF Log Level")
        {
            Caption = 'Minimum Log Level';
            InitValue = Information;
            ToolTip = 'Specifies the minimum log level to record.';
        }
        field(4; "Auto Cleanup Enabled"; Boolean)
        {
            Caption = 'Auto Clean up Enabled';
            InitValue = true;
            ToolTip = 'Specifies whether automatic cleanup of old log entries is enabled.';
        }
        field(5; "Retention Days"; Integer)
        {
            Caption = 'Retention Days';
            InitValue = 30;
            MinValue = 1;
            MaxValue = 365;
            ToolTip = 'Specifies the number of days to retain log entries.';
        }
        field(6; "Max Entries"; Integer)
        {
            Caption = 'Max Entries';
            InitValue = 100000;
            MinValue = 1000;
            ToolTip = 'Specifies the maximum number of log entries to keep.';
        }
        field(7; "Debug Mode"; Boolean)
        {
            Caption = 'Debug Mode';
            InitValue = false;
            ToolTip = 'Specifies whether debug mode is enabled for detailed logging.';
        }
        field(8; "Total Log Entries"; Integer)
        {
            Caption = 'Total Log Entries';
            FieldClass = FlowField;
            CalcFormula = count("BJF Log Entry");
            Editable = false;
            ToolTip = 'Specifies the total number of log entries.';
        }
        field(9; "Error Log Entries"; Integer)
        {
            Caption = 'Error Log Entries';
            FieldClass = FlowField;
            CalcFormula = count("BJF Log Entry" where(Error = const(true)));
            Editable = false;
            ToolTip = 'Specifies the number of error log entries.';
        }
        field(10; "Today Log Entries"; Integer)
        {
            Caption = 'Today''s Log Entries';
            FieldClass = FlowField;
            CalcFormula = count("BJF Log Entry" where("Date Time" = field("Today Filter")));
            Editable = false;
            ToolTip = 'Specifies the number of log entries for today.';
        }
        field(11; "Today Filter"; DateTime)
        {
            Caption = 'Today Filter';
            FieldClass = FlowFilter;
            ToolTip = 'Specifies the today filter for the log entries.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        this.TestField("Primary Key", '');
    end;

    /// <summary>
    /// Gets the singleton setup record, creating it if it doesn't exist.
    /// </summary>
    /// <returns>The setup record.</returns>
    procedure GetSetup(): Record "BJF Log Setup"
    var
        LogSetup: Record "BJF Log Setup";
    begin
        if not LogSetup.Get('') then begin
            LogSetup.Init();
            LogSetup."Primary Key" := '';
            LogSetup.Insert(true);
        end;
        exit(LogSetup);
    end;
}
