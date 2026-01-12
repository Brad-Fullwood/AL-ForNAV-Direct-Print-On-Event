namespace BradFullwood.ForNAV.Implementation.Sales;

using BradFullwood.ForNAV.Core;

enumextension 77732 "BJF Sales Provider" extends "BJF Direct Print Provider"
{
    value(77733; "Sales")
    {
        Caption = 'Sales Provider';
        Implementation = "I-BJF Direct Print Interface" = "BJF Sales Implementation";
    }

}
