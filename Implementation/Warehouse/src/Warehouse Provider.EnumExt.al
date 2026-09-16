namespace BradFullwood.ForNAV.Implementation.Warehouse;

using BradFullwood.ForNAV.Core;

enumextension 77554 "BJF Warehouse Provider" extends "BJF Direct Print Provider"
{
    value(77555; "Warehouse")
    {
        Caption = 'Warehouse Provider';
        Implementation = "I-BJF Direct Print Interface" = "BJF Warehouse Implementation";
    }

}
