namespace BradFullwood.ForNAV.Core;

/// <summary>
/// Interface for provider registration with focused, single-responsibility procedures.
/// </summary>
/// <remarks>
/// Each provider implements this interface to declare their identity, label groups, and events.
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
    /// Registers all label groups for this provider using the provided helper.
    /// </summary>
    /// <param name="Helper">The helper codeunit to use for registration.</param>
    procedure RegisterLabelGroups(var Helper: Codeunit "BJF Interface Utils")

    /// <summary>
    /// Registers all events for this provider using the provided helper.
    /// </summary>
    /// <param name="Helper">The helper codeunit to use for registration.</param>
    procedure RegisterEvents(var Helper: Codeunit "BJF Interface Utils")
}
