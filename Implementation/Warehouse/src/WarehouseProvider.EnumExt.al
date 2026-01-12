namespace AdvaniaUK.ForNAV.LabelPrinting.Warehouse;

using AdvaniaUK.ForNAV.LabelPrinting;

enumextension 77701 "AUK Warehouse Provider" extends "AUK Direct Print Provider"
{
    value(77702; "Warehouse")
    {
        Caption = 'Warehouse Provider';
        Implementation = "I-AUK Direct Print Interface" = "AUK Warehouse Implementation";
    }

}
