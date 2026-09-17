namespace BradFullwood.ForNAV.Core;

/// <summary>What a queued document is, so the printer service treats it right: a PDF to render, or raw Zebra (ZPL or EPL) sent to the printer as is.</summary>
enum 77504 "BJF Print Content Type"
{
    Extensible = false;

    value(0; PDF) { Caption = 'PDF'; }
    value(1; Zebra) { Caption = 'Zebra (ZPL or EPL)'; }
}
