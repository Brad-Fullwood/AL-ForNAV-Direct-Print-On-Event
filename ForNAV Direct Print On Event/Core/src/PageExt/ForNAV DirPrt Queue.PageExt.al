namespace BradFullwood.ForNAV.Core;

pageextension 77700 "BJF ForNAV DirPrt Queue" extends "ForNAV DirPrt Queue"
{
    actions
    {
        addfirst(Processing)
        {
            action("BJF View Settings")
            {
                Caption = 'View Settings';
                ToolTip = 'View the settings for this label printing queue.';
                ApplicationArea = All;
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    InStream: InStream;
                    SettingsText: text;
                begin
                    Clear(SettingsText);
                    Rec.CalcFields(Settings);
                    if Rec.Settings.HasValue() then begin
                        Rec.Settings.CreateInStream(InStream);
                        InStream.Read(SettingsText);
                        Message(SettingsText);
                    end;
                end;

            }
        }
    }
}
