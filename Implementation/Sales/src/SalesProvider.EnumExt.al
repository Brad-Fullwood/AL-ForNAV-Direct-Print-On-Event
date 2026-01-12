namespace AdvaniaUK.ForNAV.LabelPrinting.Sales;

using AdvaniaUK.ForNAV.LabelPrinting;

enumextension 77702 "AUK Sales Provider" extends "AUK Direct Print Provider"
{
    value(77701; "Sales")
    {
        Caption = 'Sales Provider';
        Implementation = "I-AUK Direct Print Interface" = "AUK Sales Implementation";
    }

}
