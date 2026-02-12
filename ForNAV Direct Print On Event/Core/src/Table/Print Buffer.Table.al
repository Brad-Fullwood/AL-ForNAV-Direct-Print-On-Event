namespace BradFullwood.ForNAV.Core;

using System.Security.AccessControl;

/// <summary>
/// Generic buffer table for label printing operations.
/// </summary>
/// <remarks>
/// Intermediary storage during label printing processes.
/// Stores report information and settings that will be used for printing.
/// </remarks>
table 77704 "BJF Print Buffer"
{
    Caption = 'Automatic Printing Print Buffer';
    DataClassification = CustomerContent;
    InherentPermissions = rimdx;
    Extensible = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
            AutoIncrement = true;
        }
        field(2; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            Editable = false;
        }
        field(3; "Report Caption"; Text[250])
        {
            Caption = 'Report Caption';
            Editable = false;
        }
        field(4; "Custom Report Layout Code"; Code[20])
        {
            Caption = 'Custom Report Layout Code';
            Editable = false;
        }
        field(5; "Report Layout Name"; Text[250])
        {
            Caption = 'Report Layout Name';
            Editable = false;
        }
        field(6; "Report Layout App ID"; Guid)
        {
            Caption = 'Report Layout App ID';
            Editable = false;
        }
        field(7; "Report Layout Caption"; Text[250])
        {
            Caption = 'Report Layout Caption';
            Editable = false;
        }
        field(8; "Report Layout Publisher"; Text[250])
        {
            Caption = 'Report Layout Publisher';
            Editable = false;
        }
        field(9; "Qty to Print"; Integer)
        {
            Caption = 'Qty to Print';
            InitValue = 1;
            MinValue = 0;
        }
        field(10; "Source Record"; RecordId)
        {
            Caption = 'Source Record ID';
        }
        field(11; Status; Enum "BJF Print Buffer Status")
        {
            Caption = 'Status';
            Editable = false;
            InitValue = Pending;
        }
        field(12; "Error Message"; Text[2048])
        {
            Caption = 'Error Message';
            Editable = false;
        }
        field(13; "Created Date Time"; DateTime)
        {
            Caption = 'Created Date Time';
            Editable = false;
        }
        field(14; "Processed Date Time"; DateTime)
        {
            Caption = 'Processed Date Time';
            Editable = false;
        }
        field(15; "Retry Count"; Integer)
        {
            Caption = 'Retry Count';
            Editable = false;
            InitValue = 0;
            MinValue = 0;
        }
        field(16; "User ID"; Code[50])
        {
            Caption = 'User ID';
            Editable = false;
            TableRelation = User."User Name";
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(StatusKey; Status, "Created Date Time")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "Entry No.", "Report ID", "Report Caption", "Custom Report Layout Code", "Report Layout Name", "Report Layout App ID", "Report Layout Caption", "Report Layout Publisher", "Qty to Print") { }
        fieldgroup(DropDown; "Report ID", "Report Caption") { }
    }

    trigger OnInsert()
    begin
        if "Created Date Time" = 0DT then
            "Created Date Time" := CurrentDateTime();
        if "User ID" = '' then
            "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
    end;
}
