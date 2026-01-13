namespace BradFullwood.ForNAV.Core;

permissionset 77700 Core
{
    Assignable = true;
    Caption = 'FNDP Core', MaxLength = 30, Locked = true;

    Permissions = tabledata "BJF Automatic Printing" = RIMD,
        tabledata "BJF Source Table Mapping" = RIMD,
        tabledata "BJF Printing Trigger" = RIMD,
        tabledata "BJF Report Set" = RIMD,
        tabledata "BJF Print Buffer" = RIMD,
        tabledata "BJF Provider" = RIMD,
        table "BJF Automatic Printing" = X,
        table "BJF Source Table Mapping" = X,
        table "BJF Printing Trigger" = X,
        table "BJF Report Set" = X,
        table "BJF Print Buffer" = X,
        table "BJF Provider" = X,
        codeunit "BJF Interface Utils" = X,
        codeunit "BJF Print Buffer Ret. Policy" = X,
        codeunit "BJF Print Management" = X,
        codeunit "BJF Scheduled Task Runner" = X,
        page "BJF Source Table Mappings" = X,
        page "BJF Direct Printing Setup" = X,
        page "BJF Printing Triggers" = X,
        page "BJF Report Sets" = X,
        page "BJF Report Selection" = X;
}
