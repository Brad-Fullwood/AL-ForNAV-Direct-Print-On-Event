namespace BradFullwood.ForNAV.Core;

using System.DataAdministration;
using Microsoft.Foundation.Company;
using System.Environment.Configuration;

/// <summary>
/// Retention Policy setup for Print Buffer table.
/// </summary>
/// <remarks>
/// Registers Print Buffer table with BC's built-in retention policy framework.
/// Allows automatic cleanup of old print buffer entries based on Created Date Time.
/// </remarks>
codeunit 77700 "BJF Print Buffer Ret. Policy"
{
    Access = Internal;
    Subtype = Install;
    InherentPermissions = x;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", OnBeforeOnRun, '', false, false)]
    local procedure AddAllowedTables()
    var
        SystemInitialization: Codeunit "System Initialization";
    begin
        if not SystemInitialization.IsInProgress() then
            exit;
        this.AddPrintBufferToRetentionPolicy();
    end;

    trigger OnInstallAppPerCompany()
    begin
        this.AddPrintBufferToRetentionPolicy();
    end;

    local procedure AddPrintBufferToRetentionPolicy()
    var
        PrintBuffer: Record "BJF Print Buffer";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        TableFilters: JsonArray;
        MandatoryMinimumRetentionDays: Integer;
        RetentionPolicyFiltering: Enum "Reten. Pol. Filtering";
        RetentionPolicyDeleting: Enum "Reten. Pol. Deleting";
    begin
        this.ApplyMandatoryFilters(RetenPolAllowedTables, TableFilters);
        this.ApplyOptionalFilters(RetenPolAllowedTables, TableFilters);

        MandatoryMinimumRetentionDays := 3;
        RetentionPolicyFiltering := RetentionPolicyFiltering::Default;
        RetentionPolicyDeleting := RetentionPolicyDeleting::Default;

        RetenPolAllowedTables.AddAllowedTable(
            Database::"BJF Print Buffer",
            PrintBuffer.FieldNo("Created Date Time"),
            MandatoryMinimumRetentionDays,
            RetentionPolicyFiltering,
            RetentionPolicyDeleting,
            TableFilters
        );
    end;

    local procedure ApplyMandatoryFilters(var RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables"; var TableFilters: JsonArray)
    var
        PrintBuffer: Record "BJF Print Buffer";
        RecRef: RecordRef;
        Enabled, Mandatory : Boolean;
        RetentionPeriod: Enum "Retention Period Enum";
    begin
        PrintBuffer.SetFilter(Status, '%1|%2', PrintBuffer.Status::Pending, PrintBuffer.Status::Processing);
        RecRef.GetTable(PrintBuffer);
        Enabled := true;
        Mandatory := true;
        RetentionPeriod := RetentionPeriod::"Never Delete";
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RetentionPeriod, PrintBuffer.FieldNo("Created Date Time"), Enabled, Mandatory, RecRef);
    end;

    local procedure ApplyOptionalFilters(var RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables"; var TableFilters: JsonArray)
    var
        PrintBuffer: Record "BJF Print Buffer";
        RecRef: RecordRef;
        Enabled, Mandatory : Boolean;
        RetentionPeriod: Enum "Retention Period Enum";
    begin
        PrintBuffer.SetFilter(Status, '%1|%2', PrintBuffer.Status::Completed, PrintBuffer.Status::Failed);
        RecRef.GetTable(PrintBuffer);
        Enabled := true;
        Mandatory := false;
        RetentionPeriod := RetentionPeriod::"1 Week";
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RetentionPeriod, PrintBuffer.FieldNo("Created Date Time"), Enabled, Mandatory, RecRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Apply Retention Policy", OnApplyRetentionPolicyIndirectPermissionRequired, '', false, false)]
    local procedure HandleIndirectPermission(var RecRef: RecordRef; var Handled: Boolean)
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        LogCategory: Enum "Retention Policy Log Category";
        LogErr: Label 'No filters set on table %1 %2', Comment = '%1 = Table ID, %2 = Table Name';
    begin
        if Handled then
            exit;

        if not (RecRef.Number() in [Database::"BJF Print Buffer"]) then
            exit;

        if (RecRef.GetFilters() = '') or (not RecRef.MarkedOnly()) then begin
            RetentionPolicyLog.LogError(LogCategory::"Retention Policy - Apply", StrSubstNo(LogErr, RecRef.Number(), RecRef.Name()));
            exit;
        end;

        RecRef.DeleteAll(true);
        Handled := true;
    end;
}
