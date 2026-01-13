namespace BradFullwood.ForNAV.Core;

/// <summary>
/// Interface for provider registration with focused, single-responsibility procedures.
/// </summary>
/// <remarks>
/// Each provider implements this interface to declare their identity, report sets, and triggers.
/// Providers simply return their configuration data rather than calling registration procedures.
/// </remarks>
interface "I-BJF Direct Print Interface"
{
    /// <summary>
    /// Gets the provider enum value, description, and default active status.
    /// </summary>
    /// <param name="Provider">The provider enum value.</param>
    /// <param name="Description">The description of the provider.</param>
    /// <param name="DefaultActive">The default active status of the provider.</param>
    procedure GetProviderInfo(var Provider: Enum "BJF Direct Print Provider"; var Description: Text[100]; var DefaultActive: Boolean)

    /// <summary>
    /// Registers all report sets for this provider using the provided helper.
    /// </summary>
    /// <param name="Helper">The helper codeunit to use for registration.</param>
    /// <remarks>
    /// Report sets define WHAT to print - the collection of reports/documents to output.
    /// </remarks>
    procedure RegisterReportSets(var Helper: Codeunit "BJF Interface Utils")

    /// <summary>
    /// Registers all printing triggers for this provider using the provided helper.
    /// </summary>
    /// <param name="Helper">The helper codeunit to use for registration.</param>
    /// <remarks>
    /// Printing triggers define WHEN to print - the business events that trigger printing.
    /// </remarks>
    procedure RegisterTriggers(var Helper: Codeunit "BJF Interface Utils")
}
