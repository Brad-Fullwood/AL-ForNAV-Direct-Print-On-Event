namespace BradFullwood.ForNAV.Core;

/// <summary>
/// FactBox page providing guidance on how automatic printing works.
/// </summary>
page 77705 "BJF Getting Started FactBox"
{
    Caption = 'Getting Started';
    PageType = CardPart;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(Overview)
            {
                Caption = 'Overview';
                ShowCaption = false;

                field(OverviewText; this.OverviewTxt)
                {
                    Caption = '';
                    ShowCaption = false;
                    MultiLine = true;
                    Style = Standard;
                    ToolTip = 'Overview of the automatic printing system.';
                }
            }
            group(Concepts)
            {
                Caption = 'Key Concepts';

                field(ReportSetsDesc; this.ReportSetsTxt)
                {
                    Caption = 'Report Sets';
                    Style = Strong;
                    MultiLine = true;
                    ToolTip = 'Report Sets define WHAT to print.';
                }
                field(TriggersDesc; this.TriggersTxt)
                {
                    Caption = 'Triggers';
                    Style = Strong;
                    MultiLine = true;
                    ToolTip = 'Triggers define WHEN to print.';
                }
                field(SourceTablesDesc; this.SourceTablesTxt)
                {
                    Caption = 'Source Tables';
                    Style = Favorable;
                    MultiLine = true;
                    ToolTip = 'Source Tables define the data available for reports.';
                }
            }
            group(ForReportDevelopers)
            {
                Caption = 'For Report Developers';

                field(ReportDevTip; this.ReportDevTipTxt)
                {
                    Caption = '';
                    ShowCaption = false;
                    MultiLine = true;
                    Style = Attention;
                    ToolTip = 'Tip for report developers.';
                }
            }
            group(GettingStartedSteps)
            {
                Caption = 'Quick Start';

                field(Step1; this.Step1Txt)
                {
                    Caption = '1.';
                    MultiLine = true;
                    ToolTip = 'First step to get started.';
                }
                field(Step2; this.Step2Txt)
                {
                    Caption = '2.';
                    MultiLine = true;
                    ToolTip = 'Second step to get started.';
                }
                field(Step3; this.Step3Txt)
                {
                    Caption = '3.';
                    MultiLine = true;
                    ToolTip = 'Third step to get started.';
                }
            }
        }
    }

    var
        OverviewTxt: Label 'This page shows registered providers and their source table mappings. Use this to understand which data is available for automatic printing.';
        ReportSetsTxt: Label 'Define WHAT to print (e.g., "Shipping Documents", "Product Labels")';
        TriggersTxt: Label 'Define WHEN to print (e.g., "Sales Shipment Posted", "Purchase Receipt")';
        SourceTablesTxt: Label 'The BC table containing data for reports. Look at the Source Table column when creating reports.';
        ReportDevTipTxt: Label 'When creating reports, use the Source Table shown here as your report''s main data item.';
        Step1Txt: Label 'Click "Register Providers" to load available report sets and triggers';
        Step2Txt: Label 'Click "Setup Reports" to configure which reports print for each combination';
        Step3Txt: Label 'Compatible triggers appear when selecting a report set';
}
