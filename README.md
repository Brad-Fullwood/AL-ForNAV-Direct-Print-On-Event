# ForNAV Direct Print On Event

An AL extension for Microsoft Business Central that provides **automatic direct printing of ForNAV labels triggered by business events**. This solution eliminates manual intervention by automatically printing labels when specific business events occur, such as sales order creation, inventory movements, or warehouse operations.

## 🎯 Project Overview

This extension enables seamless integration between Business Central business events and ForNAV label printing, providing:

- **Event-Driven Architecture**: Automatic label printing triggered by business events
- **Modular Design**: Separate modules for different business domains (Sales, Purchase, Warehouse)
- **Comprehensive Logging**: Full audit trail and debugging capabilities
- **Buffer Management**: Efficient queuing and batch processing of print jobs
- **Provider Interface**: Extensible architecture for custom implementations

## 🏗️ Architecture

The project follows a clean, modular architecture with clear separation of concerns:

```
ForNAV Direct Print On Event/
├── Core/                    # Core functionality (ID: 77700-77719)
│   ├── Print Management     # Main print orchestration
│   ├── Print Buffer        # Job queuing and processing
│   ├── Event System        # Business event integration
│   ├── Provider Interface  # Extensibility framework
│   └── Task Scheduling     # Background processing
├── Logging/                # Logging module (ID: 77720-77729)
│   ├── Log Manager         # Centralized logging
│   ├── Event Tracking      # Business event audit
│   └── Error Handling      # Comprehensive error logging
└── Implementation/         # Domain-specific providers
    ├── Sales/              # Sales events (ID: 77730-77739)
    ├── Purchase/           # Purchase events (ID: 77740-77749)
    └── Warehouse/          # Warehouse events (ID: 77750-77759)
```

## 🔧 Technical Stack

- **Language**: AL (Application Language) for Microsoft Business Central
- **Platform**: Business Central 26.0.0.0
- **Runtime**: AL Runtime 15.2
- **Dependencies**: 
  - ForNAV Core 7.4.0.1
  - Customizable Report Pack 7.2.0.0

## ✨ Key Features

### Core Functionality
- **Automatic Print Triggering**: Labels print automatically on business events
- **Print Buffer System**: Efficient queuing prevents system overload
- **Multi-Provider Architecture**: Support for Sales, Purchase, and Warehouse domains
- **Event Configuration**: Flexible event-to-label mapping
- **Background Processing**: Non-blocking print job execution

### Advanced Features
- **Retention Policies**: Automatic cleanup of processed print buffers
- **Error Recovery**: Robust error handling with retry mechanisms
- **Audit Trail**: Comprehensive logging of all print activities
- **Performance Optimization**: Designed for high-volume environments
- **Extensibility**: Clean provider interface for custom implementations

## 🚀 Getting Started

### Prerequisites
- Microsoft Business Central (version 26.0+)
- ForNAV Core extension installed
- ForNAV Customizable Report Pack installed
- Visual Studio Code with AL Language extension

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/bradfullwood97/AL-ForNAV-Direct-Print-On-Event.git
   ```

2. **Open in VS Code**:
   ```bash
   code AL-ForNAV-Direct-Print-On-Event.code-workspace
   ```

3. **Download symbols**:
   - Open Command Palette (Ctrl+Shift+P)
   - Run "AL: Download Symbols"

4. **Compile the project**:
   - Run "AL: Compile" from Command Palette

5. **Deploy to Business Central**:
   - Run "AL: Publish" from Command Palette

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

### Sales Order Automatic Printing
When a sales order is posted, the system automatically:
1. Detects the "After Post Sales Order" event
2. Identifies configured label groups for sales
3. Queues appropriate labels in the print buffer
4. Processes labels in background task
5. Prints labels to configured printer

### Custom Provider Implementation
To add custom printing logic:

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
# Run performance benchmarks
AL: Run Tests > Core.PerformanceTest
```

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
- **Print Buffer**: Monitor queued jobs and processing status
- **Retention Policy**: Automatic cleanup of processed entries
- **Error Recovery**: Failed jobs marked for retry

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
