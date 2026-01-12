namespace BradFullwood.ForNAV.Core;

using System.Utilities;

/// <summary>
/// Page for viewing compatible label sets and events based on dataset mappings.
/// </summary>
page 77701 "BJF Direct Printing Setup"
{
    ApplicationArea = All;
    Caption = 'Direct Printing Setup';
    PageType = Card;
    UsageCategory = Tasks;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(Information)
            {
                Caption = 'Information';
                label(InfoText)
                {
                    Caption = 'This page shows the registered providers, label sets, and events for direct label printing.';
                    Style = StandardAccent;
                }
                label(InfoText2)
                {
                    Caption = 'If labels or events that you expect are missing use the "Register Providers" action to register all available providers.';
                    Style = StandardAccent;
                }
            }

            group(ProviderDetails)
            {
                Caption = 'Registered Datasets';
                part(Datasets; "BJF Datasets") { }
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
                ToolTip = 'Configure reports for label sets.';
                Image = Setup;
                RunObject = page "BJF Report Selection";
            }
            action(RefreshData)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                ToolTip = 'Refresh the provider list.';
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
                ToolTip = 'Register all available label set providers and setup dataset mappings.';
                Image = Register;

                trigger OnAction()
                var
                    InterfaceUtils: Codeunit "BJF Interface Utils";
                begin
                    InterfaceUtils.RegisterAllProviders();

                    Message('Providers registered successfully. Label sets, events, and dataset mappings have been created.');
                    CurrPage.Update(false);
                end;
            }
            action(ClearProviders)
            {
                ApplicationArea = All;
                Caption = 'Clear Providers';
                ToolTip = 'Clear all registered label set providers.';
                Image = Delete;

                trigger OnAction()
                var
                    InterfaceUtils: Codeunit "BJF Interface Utils";
                    ConfirmMgmt: Codeunit "Confirm Management";
                    ConfirmQst: Label 'Are you sure you want to clear all registered label set providers? This action cannot be undone.';
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
            action(ViewDatasets)
            {
                ApplicationArea = All;
                Caption = 'View Datasets';
                ToolTip = 'Open the datasets page.';
                Image = Database;
                RunObject = page "BJF Datasets";
            }
        }
    }


}
