namespace BradFullwood.ForNAV.Logging;

permissionset 77720 Logging
{
    Assignable = true;
    Caption = 'FNDP Logging', Locked = true;
    Permissions = tabledata "BJF Log Entry" = RIMD,
        tabledata "BJF Log Setup" = RIMD,
        table "BJF Log Entry" = X,
        table "BJF Log Setup" = X,
        codeunit "BJF Log Events" = X,
        codeunit "BJF Logging Manager" = X,
        page "BJF Log Entries" = X,
        page "BJF Log Entry Card" = X,
        page "BJF Log Entry Details" = X,
        page "BJF Log Setup" = X;
}
