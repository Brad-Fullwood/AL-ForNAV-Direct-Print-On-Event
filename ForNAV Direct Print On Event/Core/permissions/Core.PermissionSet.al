namespace BradFullwood.ForNAV.Core;

permissionset 77700 Core
{
    Assignable = true;
    Caption = 'FNDP Core', MaxLength = 30, Locked = true;

    Permissions = tabledata "BJF Automatic Printing" = RIMD,
        tabledata "BJF Dataset" = RIMD,
        tabledata "BJF Event" = RIMD,
        tabledata "BJF Label Groups" = RIMD,
        tabledata "BJF Print Buffer" = RIMD,
        tabledata "BJF Provider" = RIMD,
        table "BJF Automatic Printing" = X,
        table "BJF Dataset" = X,
        table "BJF Event" = X,
        table "BJF Label Groups" = X,
        table "BJF Print Buffer" = X,
        table "BJF Provider" = X,
        codeunit "BJF Interface Utils" = X,
        codeunit "BJF Print Buffer Ret. Policy" = X,
        codeunit "BJF Print Management" = X,
        codeunit "BJF Scheduled Task Runner" = X,
        page "BJF Datasets" = X,
        page "BJF Direct Printing Setup" = X,
        page "BJF Label Event" = X,
        page "BJF Label Groups" = X,
        page "BJF Report Selection" = X;
}
