# ForNAV Direct Print On Event

> **⚠️ UNTESTED — This project is currently untested and under active development. It has not been validated in a production or sandbox environment. Use at your own risk.**

An AL extension for Microsoft Business Central that provides **automatic direct printing of ForNAV labels triggered by business events**. This solution eliminates manual intervention by automatically printing labels when specific business events occur, such as sales order creation, inventory movements, or warehouse operations.

## 🧩 **Modular Architecture - Install Only What You Need**

**Key Design Principle**: This extension follows a **highly modular architecture** where you can install only the components required for your business needs. The Core module provides the essential functionality, while all other modules (including Logging) are completely optional and can be installed independently.

- **Core Module** (Required): Essential print management and event system
- **Logging Module** (Optional): Comprehensive audit trail and debugging - can be omitted entirely
- **Implementation Modules** (Optional): Domain-specific providers (Sales, Purchase, Warehouse) - install only what you use

## 🎯 Project Overview

This extension enables seamless integration between Business Central business events and ForNAV label printing, providing:

- **Event-Driven Architecture**: Automatic label printing triggered by business events
- **Modular Design**: **Highly modular architecture** - install only the modules you need for your specific business requirements
- **Selective Installation**: Core module required, everything else optional (including logging)
- **Comprehensive Logging**: Full audit trail and debugging capabilities (optional module)
- **Buffer Management**: Efficient queuing and batch processing of print jobs
- **Provider Interface**: Extensible architecture for custom implementations

## 🏗️ Architecture

The project follows a **highly modular architecture** with clear separation of concerns. You can install only the modules you need:

```
ForNAV Direct Print On Event/
├── Core/                    # 🔴 REQUIRED - Core functionality (ID: 77700-77719)
│   ├── Print Management     # Main print orchestration and queuing
│   ├── Print Buffer         # Job queuing with retry mechanisms
│   ├── Task Scheduling      # Background processing via BC Task Scheduler
│   ├── Provider Interface   # Extensible provider framework
│   ├── Dataset Mapping      # Table-to-provider intelligent mapping
│   ├── Retention Policy     # Automatic cleanup integration
│   ├── Event System         # Business event integration
│   └── Setup & Configuration # User interface for management
├── Logging/                # 🟡 OPTIONAL - Logging module (ID: 77720-77729)
│   ├── Log Manager          # Centralized logging system
│   ├── Event Tracking       # Business event audit trail
│   └── Error Handling       # Comprehensive error logging
└── Implementation/         # 🟡 OPTIONAL - Domain-specific providers
    ├── Sales/              # Sales events: Order→Invoice→Shipment (ID: 77730-77739)
    ├── Purchase/           # Purchase events: Order→Invoice→Receipt (ID: 77740-77749)
    └── Warehouse/          # Warehouse events: Shipment→Receipt (ID: 77750-77759)
```

**Installation Flexibility**:
- **Core Module**: Always required for basic functionality
- **Logging Module**: Optional - omit entirely if you don't need audit trails
- **Implementation Modules**: Mix and match based on your business domains

## 🔧 Technical Stack

- **Language**: AL (Application Language) for Microsoft Business Central
- **Platform**: Business Central 26.0.0.0 (Spring 2024)
- **Runtime**: AL Runtime 15.2
- **Task Scheduling**: Integrated with BC's built-in Task Scheduler with automatic retry (up to 99 times)
- **Retention Policies**: Native integration with BC's retention policy framework
- **Dependencies**:
  - ForNAV Core 7.4.0.1 (Label printing engine)
  - Customizable Report Pack 7.2.0.0 (Report layouts and customization)
- **Testing Framework**: Microsoft Performance Toolkit integration for performance testing

## ✨ Key Features

### Core Functionality
- **Modular Installation**: Install only the modules you need - no unnecessary components
- **Automatic Print Triggering**: Labels print automatically on business events
- **Print Buffer System**: Efficient queuing with automatic retry mechanisms (up to 99 retries)
- **Task Scheduling**: Background task processing with BC's built-in Task Scheduler
- **Multi-Provider Architecture**: Support for Sales, Purchase, and Warehouse domains
- **Dataset Mapping**: Intelligent mapping between business tables and print providers
- **Event Configuration**: Flexible event-to-label mapping with table-based filtering
- **Background Processing**: Non-blocking print job execution with comprehensive error handling
- **Retention Policies**: Automatic cleanup using BC's built-in retention policy framework

### Advanced Features
- **Retention Policies**: Automatic cleanup integrated with BC's retention policy framework (minimum 3 days)
- **Error Recovery**: Robust error handling with automatic retry mechanisms (up to 99 retries via Task Scheduler)
- **Task Scheduling**: Advanced background processing with failure recovery and status tracking
- **Audit Trail**: Comprehensive logging of all print activities (when logging module installed)
- **Performance Optimization**: Designed for high-volume environments with efficient buffering
- **Provider Interface**: Clean, extensible architecture for custom business domain implementations

## 🚀 Getting Started

### Prerequisites
- Microsoft Business Central (version 26.0+)
- ForNAV Core extension installed
- ForNAV Customizable Report Pack installed
- Visual Studio Code with AL Language extension

### Installation

#### **Step 1: Choose Your Modules**
Before installation, decide which modules you need:
- **Core** (Always Required): Print management and event system
- **Logging** (Optional): Audit trail and debugging capabilities
- **Implementation Modules** (Optional): Choose from Sales, Purchase, or Warehouse based on your business needs

#### **Step 2: Install Process**

1. **Clone the repository**:
   ```bash
   git clone https://github.com/bradfullwood97/AL-ForNAV-Direct-Print-On-Event.git
   ```

2. **Open in VS Code**:
   ```bash
   code AL-ForNAV-Direct-Print-On-Event.code-workspace
   ```

3. **Select modules to compile** (Modular Installation):
   - Open workspace settings and enable/disable specific modules
   - Or manually exclude folders you don't need from compilation

4. **Download symbols**:
   - Open Command Palette (Ctrl+Shift+P)
   - Run "AL: Download Symbols"

5. **Compile selected modules**:
   - Run "AL: Compile" from Command Palette

6. **Deploy to Business Central**:
   - Run "AL: Publish" from Command Palette for each selected module

### Selective Module Installation Examples

**Minimal Installation** (Core Only):
- Install only Core module for basic print management
- No logging, no domain-specific providers
- Best for: Simple deployments, testing, or when you want minimal footprint

**Standard Installation** (Core + Logging):
- Core module + Logging module
- Full audit trail but no domain-specific automation
- Best for: When you need debugging capabilities but handle events manually

**Business-Specific Installation** (Core + Selected Domains):
- Core + Sales module (if you only handle sales events)
- Core + Purchase + Warehouse (if you handle procurement and inventory)
- Add Logging module if audit trails are required
- Best for: Targeted deployments matching your business processes

### Configuration

1. **Setup Direct Printing**:
   - Navigate to "Direct Printing Setup" page
   - Configure default settings and providers

2. **Configure Label Groups**:
   - Use "Label Groups" page to define label sets
   - Map label groups to business events

3. **Event Configuration**:
   - Configure events on "Label Event" page
   - Link events to appropriate label groups

## 📋 Usage Examples

### Sales Order Processing Workflow
When a sales order is posted, the system automatically:
1. Detects the "After Post Sales Order" event
2. Identifies configured label groups for sales documents
3. Queues appropriate labels in the print buffer with retry capability
4. Schedules background task processing via BC Task Scheduler
5. Prints labels to configured ForNAV printer with error recovery

### Complete Business Process Coverage

**Sales Cycle:**
- Sales Order → Posted Sales Invoice: Automatic invoice labeling
- Sales Order → Posted Sales Shipment: Automatic shipment labeling
- End-to-end sales document lifecycle coverage

**Purchase Cycle:**
- Purchase Order → Posted Purchase Invoice: Automatic invoice labeling
- Purchase Order → Posted Purchase Receipt: Automatic receipt labeling
- Complete procurement document tracking

**Warehouse Operations:**
- Warehouse Shipment → Posted Warehouse Shipment: Automatic shipment labeling
- Warehouse Receipt → Posted Warehouse Receipt: Automatic receipt labeling
- Inventory movement documentation

### Provider Interface System

The system uses a clean provider interface pattern for extensibility. Each provider implements the `I-BJF Direct Print Interface` with three key methods:

1. **GetProviderInfo**: Defines provider identity and default activation status
2. **RegisterLabelGroups**: Declares available label sets and their associated tables
3. **RegisterEvents**: Specifies business events that trigger printing for each label group

### Supported Business Events

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

### Custom Provider Implementation

To add custom printing logic for your business domain:

```al
namespace BradFullwood.ForNAV.Implementation.Custom;

using BradFullwood.ForNAV.Core;

codeunit 50100 "BJF Custom Provider" implements "I-BJF Direct Print Interface"
{
    Access = Internal;
    InherentPermissions = x;

    procedure GetProviderInfo(var Provider: Enum "BJF Direct Print Provider"; var Description: Text[100]; var DefaultActive: Boolean)
    begin
        Provider := Enum::"BJF Direct Print Provider"::Custom;
        Description := 'Custom Provider';
        DefaultActive := true;
    end;

    procedure RegisterLabelGroups(var Helper: Codeunit "BJF Interface Utils")
    begin
        Helper.RegisterLabelGroup('CUSTOM', 'Custom Labels', Database::"My Table");
    end;

    procedure RegisterEvents(var Helper: Codeunit "BJF Interface Utils")
    begin
        Helper.AddTable(Database::"My Table");
        Helper.RegisterEventWithTables('MY_EVENT', 'My Custom Event');
    end;
}
```

## 🧪 Testing

The project includes comprehensive testing:

### Unit Tests
```bash
# Run core functionality tests
AL: Run Tests > Core.Test
```

### Performance Tests
```bash
# Run performance benchmarks using Microsoft Performance Toolkit
AL: Run Tests > Core.PerformanceTest
```
Performance tests simulate real business processes to detect regressions and measure throughput under load.

### Implementation Tests
```bash
# Test domain-specific providers
AL: Run Tests > Implementation.Test
```

## 🔍 Monitoring and Debugging

### Logging System
- **Log Entries**: View all print activities in "Log Entries" page
- **Error Tracking**: Monitor failed print jobs and system errors
- **Performance Metrics**: Track processing times and throughput

### Buffer Management
- **Print Buffer**: Monitor queued jobs with detailed status tracking (Pending, Processing, Completed, Failed)
- **Task Scheduling**: Background processing with BC Task Scheduler integration and automatic retries
- **Retention Policy**: Automatic cleanup using BC's retention policy framework (configurable retention periods)
- **Error Recovery**: Failed jobs automatically retried up to 99 times with comprehensive error logging

## 🎨 Code Quality

This project follows strict AL coding standards:

- **NoImplicitWith**: Explicit coding for better maintainability
- **Consistent 'this.' Usage**: Clear object member access
- **XML Documentation**: Comprehensive procedure documentation
- **Single Responsibility**: Focused, maintainable procedures
- **Early Exit Pattern**: Reduced complexity and nesting

## 🤝 Contributing

1. **Fork the repository**
2. **Create feature branch**: `git checkout -b feature/amazing-feature`
3. **Follow coding standards**: Use consistent naming and documentation
4. **Add tests**: Ensure new functionality is tested
5. **Commit changes**: `git commit -m 'Add amazing feature'`
6. **Push branch**: `git push origin feature/amazing-feature`
7. **Open Pull Request**

### Development Guidelines
- Follow BJF naming conventions
- Add XML documentation to all public procedures
- Include unit tests for new functionality
- Maintain backward compatibility
- Use provided ID ranges for new objects

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

- **Issues**: Report bugs on [GitHub Issues](https://github.com/bradfullwood97/AL-ForNAV-Direct-Print-On-Event/issues)
- **Documentation**: Comprehensive XML documentation in source code
- **Examples**: Sample implementations in Implementation modules

## 📈 Roadmap

- [ ] Enhanced error recovery mechanisms
- [ ] Additional provider implementations
