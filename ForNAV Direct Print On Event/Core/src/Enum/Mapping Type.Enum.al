namespace BradFullwood.ForNAV.Core;

/// <summary>
/// Enum for Source Table Mapping types.
/// </summary>
/// <remarks>
/// Specifies whether a source table mapping is associated with a 
/// Printing Trigger (when to print) or a Report Set (what to print).
/// </remarks>
enum 77702 "BJF Mapping Type"
{
    Extensible = true;

    value(0; "")
    {
    }
    value(1; "Trigger")
    {
        Caption = 'Trigger';
    }
    value(2; "Report Set")
    {
        Caption = 'Report Set';
    }
}
