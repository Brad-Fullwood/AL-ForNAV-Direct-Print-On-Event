namespace AdvaniaUK.ForNAV.LabelPrinting.Purchase;

using AdvaniaUK.ForNAV.LabelPrinting;

enumextension 77700 "AUK Purchase Provider" extends "AUK Direct Print Provider"
{
    value(77700; "Purchase")
    {
        Caption = 'Purchase Provider';
        Implementation = "I-AUK Direct Print Interface" = "AUK Purchase Implementation";
    }

}
