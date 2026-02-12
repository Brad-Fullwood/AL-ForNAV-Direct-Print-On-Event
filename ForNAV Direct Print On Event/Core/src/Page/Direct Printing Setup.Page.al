namespace BradFullwood.ForNAV.Core;

using System.Utilities;

/// <summary>
/// Page for viewing and managing automatic printing configuration.
/// </summary>
/// <remarks>
/// Shows registered providers, report sets, and printing triggers with their 
/// compatible source tables for report development.
/// </remarks>
page 77701 "BJF Direct Printing Setup"
{
    ApplicationArea = All;
    Caption = 'Direct Print Setup';
    PageType = Card;
    UsageCategory = Tasks;
    Editable = false;
    Extensible = true;

    layout
    {
        area(Content)
        {
            group(SourceTables)
            {
                Caption = 'Source Table Mappings';
                part(SourceTableMappings; "BJF Source Table Mappings") { }
            }
        }
        area(FactBoxes)
        {
            part(GettingStarted; "BJF Getting Started FactBox")
            {
                Caption = 'Getting Started';
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            actionref(SetupReports_Promoted; SetupReports) { }
            group(Register)
            {
                Caption = 'Refresh';
                ShowAs = SplitButton;
                Image = Register;
                actionref(RefreshData_Promoted; RefreshData) { }
                actionref(RegisterProviders_Promoted; RegisterProviders) { }
            }
        }
        area(Processing)
        {
            action(SetupReports)
            {
                ApplicationArea = All;
                Caption = 'Setup Reports';
                ToolTip = 'Configure which reports to print for each report set and trigger combination.';
                Image = Setup;
                RunObject = page "BJF Report Selection";
            }
            action(RefreshData)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                ToolTip = 'Refresh the source table mappings.';
                Image = Refresh;

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                end;
            }
            action(RegisterProviders)
            {
                ApplicationArea = All;
                Caption = 'Register Providers';
                ToolTip = 'Register all available providers and create source table mappings.';
                Image = Register;

                trigger OnAction()
                var
                    InterfaceUtils: Codeunit "BJF Interface Utils";
                begin
                    InterfaceUtils.RegisterAllProviders();

                    Message('Providers registered successfully. Report sets, triggers, and source table mappings have been created.');
                    CurrPage.Update(false);
                end;
            }
            action(ClearProviders)
            {
                ApplicationArea = All;
                Caption = 'Clear Providers';
                ToolTip = 'Clear all registered providers.';
                Image = Delete;

                trigger OnAction()
                var
                    InterfaceUtils: Codeunit "BJF Interface Utils";
                    ConfirmMgmt: Codeunit "Confirm Management";
                    ConfirmQst: Label 'Are you sure you want to clear all registered providers? This action cannot be undone.';
                begin
                    if not ConfirmMgmt.GetResponseOrDefault(ConfirmQst, false) then
                        exit;

                    InterfaceUtils.ClearAllProviders();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(ViewSourceTables)
            {
                ApplicationArea = All;
                Caption = 'View Source Tables';
                ToolTip = 'Open the source table mappings in a separate window.';
                Image = Database;
                RunObject = page "BJF Source Table Mappings";
            }
        }
    }
}
