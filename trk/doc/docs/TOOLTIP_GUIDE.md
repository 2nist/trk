# Dataset Browser Tooltip & UI Guide

## 🎯 **Enhanced User Interface Overview**

The Dataset Browser now includes comprehensive tooltips and workflow guidance to help users navigate the complex process of converting music research datasets to JCRD format.

## 📝 **Interactive Tooltip System**

### **Tooltip Components**
- **Help Markers (?)**: Hover over these gray question marks for detailed explanations
- **Button Tooltips**: Hover over buttons to see what they do
- **Status Indicators**: Color-coded feedback (green=ready, red=error, orange=warning)

### **Available Tooltips**

#### **🔍 Search Field**
*"Filter songs or artists during processing. Leave empty to process all files in the dataset. Use partial names like 'beatles' or 'love' to match multiple entries."*

#### **📂 Dataset Dropdown** 
*"Choose the type of music dataset you want to convert to JCRD format. Green checkmark (✅) means ready to use, warning (⚠️) means coming soon."*

#### **📁 Dataset Path**
*"Path to your dataset folder. Use the Browse button for easy selection, or type/paste the full path. The path should point to the folder containing your dataset files."*

#### **🌐 Browse Button**
*"Open a folder picker to easily navigate to your dataset location. The picker will start in an intelligent location based on common dataset storage folders."*

#### **🔄 Reset Button**
*"Reset the path to the default suggested location for this dataset type. Useful if you want to start over with path selection."*

#### **⚡ Quick Paths**
*"Click these buttons to quickly navigate to common dataset storage locations. Only shows folders that actually exist on your system."*

#### **✅ Validate Option**
*"Recommended! Checks that converted JCRD files are properly formatted and contain valid chord/timing data. Helps catch conversion errors early."*

#### **🔑 Key Estimation**
*"Uses harmonic analysis to detect the musical key of each song. Enhances the chord progression data with tonal center information."*

#### **🎵 MIDI Export**
*"Creates standard MIDI files from the JCRD data. These files can be imported into any DAW or music software for further analysis or playback."*

#### **⚡ Process Button**
*"Execute the conversion workflow. Will run the selected dataset conversion script followed by any optional processing steps you've enabled."*

## 🎯 **Workflow Overview Section**

### **Quick Reference (Collapsible)**
The UI now includes a collapsible "❓ Workflow Overview" section that provides:

```
📋 Quick Workflow Reference:
• 1. Select Dataset Type - Choose from available formats
• 2. Set Dataset Path - Browse or type folder location  
• 3. Verify Path Status - Green = ready, Red = issues
• 4. Configure Options - Validation, key estimation, MIDI export
• 5. Process Dataset - Converts files to JCRD format

💡 Tips:
• Always enable validation for production work
• Use Browse button for easier path selection
• Check console output for detailed progress info
• Hover over (?) icons for detailed help
```

## 📊 **Status Indicators & Feedback**

### **Visual Status System**
- **✅ Green Text**: Path is valid, dataset ready
- **❌ Red Text**: Path issues, missing files
- **⚠️ Orange Text**: Warnings, dataset not ready
- **🔘 Gray Buttons**: Disabled when cannot process
- **🔵 Blue Buttons**: Ready to execute

### **Workflow Status Display**
New collapsible section shows:
- Current dataset selection
- Path status
- Processing readiness
- Enabled options summary

## 🔧 **Error Prevention & User Guidance**

### **Smart Path Management**
- **Intelligent defaults**: Documents/datasets/[dataset_name]/
- **Existence checking**: Only show paths that exist
- **Context-aware browsing**: Starts in appropriate directories

### **Processing Prerequisites**
The "Process Dataset" button is only enabled when:
- ✅ Dataset integration is ready
- ✅ Path is specified and valid
- ✅ Required files are detected

### **Helpful Error Messages**
- Clear explanations of what went wrong
- Suggestions for fixing issues
- Links to download sources for datasets

## 🎨 **Enhanced Visual Design**

### **Icon System**
- 📁 Folder operations
- 🔍 Search and filtering
- ✅ Validation and verification
- 🔑 Key estimation and analysis
- 🎵 MIDI export and audio
- ⚡ Processing and execution
- ⚠️ Warnings and alerts
- ℹ️ Information and tips

### **Theme Integration**
- Consistent with REAPER's theme system
- Proper color contrast for accessibility
- Professional appearance

## 🚀 **Usage Workflow with Tooltips**

### **Step-by-Step with Tooltip Guidance**

1. **Launch UI**: Run from `launch_dataset_browser.lua`
2. **Read Overview**: Expand "❓ Workflow Overview" 
3. **Select Dataset**: Use dropdown, read tooltip for format info
4. **Set Path**: Use Browse button (tooltip explains folder picker)
5. **Verify Status**: Check green/red validation feedback
6. **Configure Options**: Enable checkboxes, read tooltips for each
7. **Review Status**: Check "📊 Workflow Status" section
8. **Process**: Click process button when ready

### **Tooltip Discovery**
- Look for gray `(?)` markers throughout the UI
- Hover over buttons to see their specific functions
- Read status messages for validation feedback
- Check collapsible sections for detailed information

## 📈 **Advanced Features**

### **Context-Sensitive Help**
- Tooltips adapt based on current selection
- Status messages reflect current state
- Error messages provide specific guidance

### **Progressive Disclosure**
- Basic workflow visible by default
- Advanced options in collapsible sections
- Detailed help available on hover

### **Accessibility Features**
- High contrast status indicators
- Clear visual hierarchy
- Comprehensive keyboard navigation support

---

**💡 Pro Tip**: Start by expanding the "Workflow Overview" section to understand the complete process, then use tooltips to get specific help on each UI element as you work through your dataset conversion.
