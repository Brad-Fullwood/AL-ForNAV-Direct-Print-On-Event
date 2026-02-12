# ForNAV Direct Print On Event

> **UNTESTED -- This project is currently untested and under active development. It has not been validated in a production or sandbox environment. Use at your own risk.**

An AL extension for Microsoft Business Central that **automatically prints ForNAV reports when business events occur**. Post a sales order and the shipping labels print themselves. Receive a purchase order and the goods-in labels appear at the printer. No manual intervention required.

## Modules - Install Only What You Need

| Module | Required? | Description |
|--------|-----------|-------------|
| **Core** | Yes | Print management, buffering, task scheduling, provider framework |
| **Logging** | No | Audit trail, error diagnostics, log setup (adds buttons to Core setup page) |
| **Sales** | No | Triggers for sales order posting, invoice posting, shipment posting |
| **Purchase** | No | Triggers for purchase order posting, invoice posting, receipt posting |
| **Warehouse** | No | Triggers for warehouse shipment posting, warehouse receipt posting |

Install Core first, then whichever optional modules match your business needs.

## Prerequisites

- Microsoft Business Central 27.0+
- ForNAV Core extension (7.4.0.1+)
- ForNAV Customizable Report Pack (7.2.0.0+)
- ForNAV Local Printers configured (at least one cloud/local printer pair)
- BC Printer Selections configured to map your reports to ForNAV printers

## Setup Guide (Functional)

Everything is accessed from one page: search for **"Direct Print Setup"** in Business Central.

### Step 1: Install and Deploy

1. Deploy the **Core** module first
2. Deploy any optional modules you need (Sales, Purchase, Warehouse, Logging)

### Step 2: Register Providers

1. Open **Direct Print Setup** (search for it in the BC search bar)
2. Click **Register Providers** in the action bar
3. You should see a confirmation message and the Source Table Mappings tree view will populate, showing your installed providers and their report sets, triggers, and source tables

### Step 3: Configure Printer Selections

Before reports can print, Business Central needs to know which printer to use for each report.

1. Search for **Printer Selections** in Business Central
2. For each report you want to auto-print, add a row:
   - **User ID**: Leave blank for all users, or enter a specific user
   - **Report ID**: The report object ID (e.g., your ForNAV label report)
   - **Printer Name**: Select a ForNAV Local Printer

### Step 4: Set Up Report Selections

1. From **Direct Print Setup**, click **Setup Reports**
2. Select a **Report Set** from the dropdown (e.g., "Sales", "Purchase Receipt Posted")
   - Report Sets define **what** to print — they represent a category of documents
3. In the worksheet, add a row for each report you want to print:
   - **Trigger**: Click the lookup to choose **when** to print (e.g., "After posting sales order"). The lookup automatically filters to triggers compatible with your selected report set
   - **Report ID**: Select the ForNAV report to print
   - **Report Layout**: Optionally select a specific report layout
   - **Qty to Print**: Number of copies (defaults to 1)
4. Repeat for each report set / trigger combination you need

### Step 5: Test

1. Perform the business action (e.g., post a sales order)
2. The report should automatically render and appear in the **ForNAV DirPrt Queue**
3. ForNAV picks it up from there and sends it to the physical printer

### Understanding Report Sets vs Triggers

- **Report Set** = WHAT to print. A category like "Sales" or "Purchase Receipt Posted". Each report set is linked to specific source tables (the data your report reads from).
- **Trigger** = WHEN to print. A business event like "After posting sales order" or "After posting purchase receipt".
- **Source Tables** = The BC table containing data for your reports. Visible in the tree view on the setup page. When creating ForNAV reports, use these as your main data item.

You combine a Report Set + Trigger + Report ID to create a rule: *"When this event happens, print this report using data from this table."*

### Optional: Logging Setup

If you installed the Logging module, two extra buttons appear on the Direct Print Setup page:

1. Click **Log Setup** to configure:
   - **Logging Enabled**: Turn logging on/off
   - **Minimum Log Level**: Filter noise (Information, Warning, Error, Critical)
   - **Debug Mode**: Verbose logging for troubleshooting
   - **Auto Cleanup / Retention Days**: Automatic old entry cleanup
2. Click **Log Entries** to view the log and diagnose issues

### Troubleshooting

| Problem | Check |
|---------|-------|
| Nothing prints | Is there a row in Setup Reports for this report set + trigger + report? |
| "No printer found" error | Check Printer Selections — is there a ForNAV printer mapped to the report ID? |
| "Source record not found" | The posted record may not exist yet — this is handled by the 5-second task delay, but check if the record actually committed |
| Print buffer stuck on "Processing" | The background task may have failed — check Log Entries (if Logging module installed) |
| Reports printing duplicates | Check you don't have duplicate rows in Setup Reports for the same trigger |

---

## Architecture

```
ForNAV Direct Print/
+-- Core/                     # REQUIRED (ID: 77700-77719)
|   +-- Print Management      # Public API: QueuePrintReports()
|   +-- Print Buffer          # Job queue with status tracking (Pending > Processing > Completed/Failed)
|   +-- Task Scheduling       # Schedules background tasks on buffer insert
|   +-- Scheduled Task Runner # Renders PDF, creates ForNAV queue entry
|   +-- Provider Interface    # Extensible enum + interface framework
|   +-- Source Table Mapping  # Tree view of providers, report sets, triggers, tables
|   +-- Retention Policy      # BC retention policy integration for buffer cleanup
|   +-- Setup Page            # Single entry point for all configuration
+-- Logging/                  # OPTIONAL (ID: 77720-77729)
|   +-- Logging Manager       # SingleInstance codeunit, cached settings
|   +-- Log Events            # Event subscribers for audit trail
|   +-- Log Setup             # Configuration page (extends Core setup page)
+-- Implementation/           # OPTIONAL - one module per business domain
    +-- Sales/                # ID: 77730-77739
    +-- Purchase/             # ID: 77740-77749
    +-- Warehouse/            # ID: 77750-77759
```

### Print Flow

1. A business event fires (e.g., `Sales-Post` completes)
2. The implementation subscriber calls `PrintMgmt.QueuePrintReports(RecRef, ReportSetNo, TriggerNo)`
3. Print Management looks up configured reports in the Automatic Printing table and inserts records into the Print Buffer
4. The `OnAfterInsertEvent` on the buffer schedules a background task via `TaskScheduler.CreateTask()` with a 5-second delay
5. The Scheduled Task Runner (in a separate session):
   - Locks and claims the buffer record (concurrency guard)
   - Renders the report to PDF via `Report.SaveAs()`
   - Creates a ForNAV DirPrt Queue entry for the configured printer
6. Buffer record status updates to Completed or Failed

### Why This Design?

- **TaskScheduler isolation**: Print rendering runs in a separate session — posting tables are never locked by print operations
- **Buffer pattern**: The posting transaction only does fast inserts into custom tables, adding negligible overhead
- **5-second delay**: Ensures the posting transaction has committed before the print task tries to read the source record (batched insert safety)
- **TryFunction wrapping**: Task scheduling failures never abort the calling posting transaction
- **Concurrency guard**: `LockTable()` + status check prevents duplicate processing
- **Isolated integration events**: Subscribers (logging, etc.) cannot hold locks in the caller's transaction

---

## Developer Guide: Custom Provider

To add automatic printing for your own business events, create three objects in your own extension:

### 1. Enum Extension

Register your provider on the extensible enum:

```al
enumextension 50100 "My Provider" extends "BJF Direct Print Provider"
{
    value(50100; "Custom")
    {
        Caption = 'My Custom Provider';
        Implementation = "I-BJF Direct Print Interface" = "My Custom Implementation";
    }
}
```

### 2. Interface Implementation

Implement `I-BJF Direct Print Interface` to declare your report sets and triggers:

```al
codeunit 50100 "My Custom Implementation" implements "I-BJF Direct Print Interface"
{
    procedure GetProviderInfo(var Provider: Enum "BJF Direct Print Provider"; var Description: Text[100]; var DefaultActive: Boolean)
    begin
        Provider := Enum::"BJF Direct Print Provider"::Custom;
        Description := 'My Custom Provider';
        DefaultActive := true;
    end;

    procedure RegisterReportSets(var Helper: Codeunit "BJF Interface Utils")
    begin
        // Register WHAT to print: a report set name, description, and the source table
        Helper.RegisterReportSet('MY_LABELS', 'My Labels', Database::"My Table");
    end;

    procedure RegisterTriggers(var Helper: Codeunit "BJF Interface Utils")
    begin
        // Register WHEN to print: add compatible tables, then register the trigger
        Helper.AddTable(Database::"My Table");
        Helper.RegisterTriggerWithTables('MY_EVENT', 'After my custom event');
    end;
}
```

### 3. Event Subscriber

Subscribe to the business event and call `QueuePrintReports`:

```al
codeunit 50101 "My Custom Print Events"
{
    var
        PrintMgmt: Codeunit "BJF Print Management";

    [EventSubscriber(ObjectType::Table, Database::"My Table", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertMyTable(var Rec: Record "My Table"; RunTrigger: Boolean)
    var
        RecRef: RecordRef;
    begin
        if not RunTrigger then
            exit;
        RecRef.GetTable(Rec);
        RecRef.SetRecFilter();
        PrintMgmt.QueuePrintReports(RecRef, 'MY_LABELS', 'MY_EVENT');
    end;
}
```

The report set and trigger codes you pass to `QueuePrintReports` must match what you registered in the interface implementation. After deploying, go to Direct Print Setup, click Register Providers, and your new provider will appear in the tree view.

### Tips for Report Developers

- Check the **Source Table** column in the Direct Print Setup tree view — this is the table your ForNAV report's main data item should use
- Report Sets and Triggers that share a common source table are automatically linked in the trigger lookup filter
- The system passes a single record (via `RecordId`) to the report — your report's data item should filter to that record

---

## Object ID Ranges

| Module | Range |
|--------|-------|
| Core | 77700-77719 |
| Logging | 77720-77729 |
| Sales | 77730-77739 |
| Purchase | 77740-77749 |
| Warehouse | 77750-77759 |
| Core Tests | 77800-77819 |
| Performance Tests | 77820-77839 |
| Implementation Tests | 77840-77859 |

## Technical Stack

- **Language**: AL for Microsoft Business Central
- **Target Platform**: Business Central 27.0.0.0
- **Runtime**: AL Runtime 16.0
- **Dependencies**: ForNAV Core 7.4.0.1, Customizable Report Pack 7.2.0.0

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
