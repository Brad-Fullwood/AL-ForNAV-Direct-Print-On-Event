namespace BradFullwood.ForNAV.Implementation.Purchase;

using BradFullwood.ForNAV.Core;

enumextension 77740 "BJF Purchase Provider" extends "BJF Direct Print Provider"
{
    value(77745; "Purchase")
    {
        Caption = 'Purchase Provider';
        Implementation = "I-BJF Direct Print Interface" = "BJF Purchase Implementation";
    }

}
