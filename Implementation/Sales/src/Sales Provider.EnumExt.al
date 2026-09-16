namespace BradFullwood.ForNAV.Implementation.Sales;

using BradFullwood.ForNAV.Core;

enumextension 77532 "BJF Sales Provider" extends "BJF Direct Print Provider"
{
    value(77533; "Sales")
    {
        Caption = 'Sales Provider';
        Implementation = "I-BJF Direct Print Interface" = "BJF Sales Implementation";
    }

}
