# ForNAV Direct Print On Event

> **UNTESTED -- This project is currently untested and under active development. It has not been validated in a production or sandbox environment. Use at your own risk.**

An AL extension for Microsoft Business Central that provides **automatic direct printing of ForNAV reports triggered by business events**. This solution eliminates manual intervention by automatically printing reports when specific business events occur, such as posting sales orders, purchase receipts, or warehouse shipments.

## Modular Architecture - Install Only What You Need

**Key Design Principle**: This extension follows a **highly modular architecture** where you can install only the components required for your business needs. The Core module provides the essential functionality, while all other modules (including Logging) are completely optional and can be installed independently.

- **Core Module** (Required): Essential print management and event system
- **Logging Module** (Optional): Comprehensive audit trail and debugging - can be omitted entirely
- **Implementation Modules** (Optional): Domain-specific providers (Sales, Purchase, Warehouse) - install only what you use

## Project Overview

This extension enables seamless integration between Business Central business events and ForNAV report printing, providing:

- **Event-Driven Architecture**: Automatic printing triggered by business events
- **Background Processing**: Print operations run in separate sessions via TaskScheduler, preventing table locks during posting
- **Batched Insert Safety**: 5-second task delay ensures posted records are committed before the print task reads them
- **Modular Design**: Install only the modules you need
- **Provider Interface**: Extensible architecture for custom implementations
- **Comprehensive Logging**: Full audit trail and debugging capabilities (optional module)

## Architecture

```
ForNAV Direct Print On Event/
+-- Core/                    # REQUIRED - Core functionality (ID: 77700-77719)
|   +-- Print Management     # Main print orchestration and queuing
|   +-- Print Buffer         # Job queuing with status tracking
|   +-- Task Scheduling      # Background processing via BC Task Scheduler
|   +-- Scheduled Task Runner # PDF rendering and ForNAV queue integration
|   +-- Provider Interface   # Extensible provider framework
|   +-- Source Table Mapping  # Table-to-provider mapping
|   +-- Retention Policy     # Automatic cleanup integration
|   +-- Setup & Configuration # User interface for management
+-- Logging/                # OPTIONAL - Logging module (ID: 77720-77729)
|   +-- Logging Manager      # Centralized logging system (SingleInstance, cached)
|   +-- Log Events           # Business event audit trail
|   +-- Log Setup            # Configuration and statistics
+-- Implementation/         # OPTIONAL - Domain-specific providers
    +-- Sales/              # Sales events (ID: 77730-77739)
    +-- Purchase/           # Purchase events (ID: 77740-77749)
    +-- Warehouse/          # Warehouse events (ID: 77750-77759)
```

## How It Works

### Print Flow

1. A business event fires (e.g., `Sales-Post` completes)
2. An implementation subscriber calls `PrintMgmt.QueuePrintReports(RecRef, ReportSetNo, TriggerNo)`
3. Print Management inserts lightweight records into the `BJF Print Buffer` table
4. The `OnAfterInsertEvent` on the buffer schedules a background task via `TaskScheduler.CreateTask()`
5. After a 5-second delay (for transaction commit safety), the Scheduled Task Runner:
   - Locks and claims the buffer record (concurrency guard)
   - Renders the report to PDF via `Report.SaveAs()`
   - Creates a ForNAV DirPrt Queue entry for the configured printer
6. The buffer record status is updated to Completed or Failed

### Key Design Decisions

- **TaskScheduler isolation**: Print rendering runs in a separate session, so posting tables are never locked by print operations
- **Buffer pattern**: The posting transaction only does fast inserts into custom tables, adding negligible overhead
- **TryFunction wrapping**: Task scheduling failures never abort the calling posting transaction
- **Concurrency guard**: `LockTable()` + status check prevents duplicate processing if multiple tasks target the same buffer record
- **Isolated integration events**: Logging and other subscribers cannot hold locks in the caller's transaction

## Technical Stack

- **Language**: AL (Application Language) for Microsoft Business Central
- **Platform**: Business Central 26.0.0.0 (Spring 2024)
- **Runtime**: AL Runtime 15.2
- **Dependencies**:
  - ForNAV Core 7.4.0.1 (Label printing engine)
  - Customizable Report Pack 7.2.0.0 (Report layouts and customization)

## Getting Started

### Prerequisites
- Microsoft Business Central (version 26.0+)
- ForNAV Core extension installed
- ForNAV Customizable Report Pack installed
- Visual Studio Code with AL Language extension

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Brad-Fullwood/AL-ForNAV-Direct-Print-On-Event.git
   ```

2. **Open in VS Code** and download symbols

3. **Compile and deploy** each module you need (Core first, then optional modules)

### Configuration

1. **Register Providers**: Navigate to "Direct Printing Setup" and click "Register Providers"
2. **Configure Reports**: Use the "Report Selection - Automatic Printing" page to map reports to report sets and triggers
3. **Set Up Printers**: Ensure ForNAV Local Printers are configured in Business Central's Printer Selection

## Provider Interface

Each implementation module implements `I-BJF Direct Print Interface` with three methods:

1. **GetProviderInfo**: Returns provider identity and default activation status
2. **RegisterReportSets**: Declares available report sets (WHAT to print) and their associated tables
3. **RegisterTriggers**: Specifies business events (WHEN to print) and their associated tables

### Custom Provider Implementation

To add a custom provider for your business domain:

1. Create an enum extension on `BJF Direct Print Provider`
2. Create a codeunit implementing `I-BJF Direct Print Interface`
3. Create an event subscriber codeunit that calls `QueuePrintReports`

```al
// 1. Enum extension
enumextension 50100 "My Provider" extends "BJF Direct Print Provider"
{
    value(50100; "Custom")
    {
        Caption = 'Custom Provider';
        Implementation = "I-BJF Direct Print Interface" = "My Custom Implementation";
    }
}

// 2. Interface implementation
codeunit 50100 "My Custom Implementation" implements "I-BJF Direct Print Interface"
{
    procedure GetProviderInfo(var Provider: Enum "BJF Direct Print Provider"; var Description: Text[100]; var DefaultActive: Boolean)
    begin
        Provider := Enum::"BJF Direct Print Provider"::Custom;
        Description := 'Custom Provider';
        DefaultActive := true;
    end;

    procedure RegisterReportSets(var Helper: Codeunit "BJF Interface Utils")
    begin
        Helper.RegisterReportSet('MY_REPORT_SET', 'My Reports', Database::"My Table");
    end;

    procedure RegisterTriggers(var Helper: Codeunit "BJF Interface Utils")
    begin
        Helper.AddTable(Database::"My Table");
        Helper.RegisterTriggerWithTables('MY_TRIGGER', 'My Custom Event');
    end;
}

// 3. Event subscriber
codeunit 50101 "My Custom Print Events"
{
    var
        PrintMgmt: Codeunit "BJF Print Management";

    [EventSubscriber(ObjectType::Table, Database::"My Table", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertMyTable(var Rec: Record "My Table"; RunTrigger: Boolean)
    var
        RecRef: RecordRef;
    begin
        if not RunTrigger then exit;
        RecRef.GetTable(Rec);
        RecRef.SetRecFilter();
        PrintMgmt.QueuePrintReports(RecRef, 'MY_REPORT_SET', 'MY_TRIGGER');
    end;
}
```

## Supported Business Events

**Sales Module:**
- After posting sales order
- After posting sales invoice
- After posting sales shipment

**Purchase Module:**
- After posting purchase order
- After posting purchase invoice
- After posting purchase receipt

**Warehouse Module:**
- After posting warehouse shipment
- After posting warehouse receipt

## Object ID Ranges

| Module | Range |
|--------|-------|
| Core | 77700-77719 |
| Logging | 77720-77729 |
| Sales | 77730-77739 |
| Purchase | 77740-77749 |
| Warehouse | 77750-77759 |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
