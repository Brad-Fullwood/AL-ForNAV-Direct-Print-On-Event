namespace BradFullwood.ForNAV.PerformanceTest;

using System.Tooling;

/// <summary>
/// BJF test for provider registration performance.
/// Measures performance of RegisterAllProviders.
/// </summary>
codeunit 77822 "BJF Provider Registration Test" implements "BCPT Test Param. Provider"
{
    InherentPermissions = x;

    trigger OnRun()
    begin
        this.InitTest();
        this.RegisterProviders();
    end;

    var
        BJFTestContext: Codeunit "BCPT Test Context";
        CleanupBefore: Boolean;
        CleanupParamLbl: Label 'Cleanup Before';
        ParamValidationErr: Label 'Parameter not defined correctly. Expected format: "%1=true/false"', Comment = '%1 = Parameter Label';

    local procedure InitTest()
    var
        Params: Text;
    begin
        // Get parameters
        Params := BJFTestContext.GetParameter('Parameters');
        if Params <> '' then begin
            if not Evaluate(CleanupBefore, Params) then
                CleanupBefore := false;
        end else
            CleanupBefore := false;
    end;

    local procedure RegisterProviders()
    var
        InterfaceUtils: Codeunit "BJF Interface Utils";
    begin
        // Cleanup if requested
        if CleanupBefore then begin
            InterfaceUtils.ClearAllProviders();
            Commit();
        end;

        // Register all providers
        InterfaceUtils.RegisterAllProviders();

        Commit();
    end;

    procedure GetDefaultParameters(): Text[1000]
    begin
        exit('false');
    end;

    procedure ValidateParameters(Parameters: Text[1000])
    var
        TestValue: Boolean;
    begin
        if Parameters = '' then
            exit;

        if not Evaluate(TestValue, Parameters) then
            Error(ParamValidationErr, CleanupParamLbl);
    end;
}
