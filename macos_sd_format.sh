#!/bin/bash

#############################################
# macOS SD Card Formatter
#
# This script formats SD cards on macOS with
# options for quick or secure formatting.
#
# Usage: sudo bash macos_sd_format.sh
#############################################

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables
DISK_MAP=()
NUM_DISKS=0
SELECTED_DISK=""
FORMAT_METHOD=""

# Function to print colored messages
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to print header
print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     macOS SD Card Formatter Script        ║${NC}"
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo ""
}

# Check if running on macOS
check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script is designed for macOS only."
        print_error "Current system: $(uname)"
        exit 1
    fi
    print_success "Running on macOS"
}

# Check if running with sudo
check_sudo() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run with sudo privileges."
        echo ""
        echo "Usage: sudo bash $0"
        exit 1
    fi
    print_success "Running with proper privileges"
}

# List all external disks
list_external_disks() {
    # Send all output to stderr except the final return value
    print_info "Scanning for external disks..." >&2
    echo "" >&2

    # Get list of all disks
    local disk_list=$(diskutil list | grep "^/dev/disk" | grep -v "internal" | awk '{print $1}')

    if [[ -z "$disk_list" ]]; then
        print_error "No external disks found." >&2
        print_info "Please connect an SD card and try again." >&2
        exit 1
    fi

    # Store disks in array (0-based indexing)
    local index=0

    # Send display output to stderr so it doesn't interfere with return value
    echo -e "${BLUE}Available External Disks:${NC}" >&2
    echo "─────────────────────────────────────────────────────" >&2

    for disk in $disk_list; do
        local disk_info=$(diskutil info "$disk" | grep -E "Device Identifier:|Disk Size:|Volume Name:|Media Name:")
        local size=$(diskutil info "$disk" | grep "Disk Size:" | awk -F: '{print $2}' | xargs)
        local name=$(diskutil info "$disk" | grep "Media Name:" | awk -F: '{print $2}' | xargs)

        if [[ -z "$name" ]]; then
            name="Unknown Device"
        fi

        # Display with 1-based numbering for user
        local display_num=$((index + 1))
        echo -e "${GREEN}[$display_num]${NC} $disk" >&2
        echo "    Name: $name" >&2
        echo "    Size: $size" >&2
        echo "" >&2

        # Store in 0-based array
        DISK_MAP[$index]="$disk"
        ((index++))
    done

    echo "─────────────────────────────────────────────────────" >&2

    # Set the global NUM_DISKS variable
    NUM_DISKS=$index
}

# Select disk to format
select_disk() {
    local num_disks=$1
    local selected_num

    while true; do
        echo ""
        read -p "Enter the number of the disk to format [1-$num_disks] (or 'q' to quit): " selected_num

        if [[ "$selected_num" == "q" ]] || [[ "$selected_num" == "Q" ]]; then
            print_info "Operation cancelled by user."
            exit 0
        fi

        if [[ "$selected_num" =~ ^[0-9]+$ ]] && [[ "$selected_num" -ge 1 ]] && [[ "$selected_num" -le "$num_disks" ]]; then
            # Convert 1-based user input to 0-based array index
            local array_index=$((selected_num - 1))
            SELECTED_DISK="${DISK_MAP[$array_index]}"
            break
        else
            print_error "Invalid selection. Please enter a number between 1 and $num_disks."
        fi
    done

    echo ""
    print_info "Selected disk: $SELECTED_DISK"
}

# Show detailed disk information and confirm
confirm_disk() {
    local disk=$1

    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}                  ⚠️  WARNING  ⚠️                        ${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
    print_warning "You are about to FORMAT the following disk:"
    echo ""

    diskutil info "$disk" | grep -E "Device Identifier:|Device Node:|Disk Size:|Volume Name:|Media Name:|Removable Media:|Protocol:"

    echo ""
    print_warning "ALL DATA ON THIS DISK WILL BE PERMANENTLY ERASED!"
    echo ""

    # Additional safety check - prevent formatting of internal disks
    local internal_check=$(diskutil info "$disk" | grep "Internal:" | grep -i "yes")
    if [[ -n "$internal_check" ]]; then
        print_error "SAFETY CHECK FAILED: This appears to be an internal disk!"
        print_error "Formatting internal disks is not allowed by this script."
        exit 1
    fi

    # Confirmation prompt
    read -p "Type 'YES' (in capital letters) to confirm: " confirmation

    if [[ "$confirmation" != "YES" ]]; then
        print_info "Operation cancelled. Disk not formatted."
        exit 0
    fi

    print_success "Confirmation received."
}

# Select format method
select_format_method() {
    echo ""
    echo -e "${BLUE}Select Format Method:${NC}"
    echo "─────────────────────────────────────────────────────"
    echo -e "${GREEN}[1]${NC} Quick Format (Fast - recommended for most users)"
    echo "    Creates a new FAT32 file system quickly"
    echo ""
    echo -e "${GREEN}[2]${NC} Secure Erase (Slow - for security/privacy)"
    echo "    Overwrites entire disk with zeros, then formats"
    echo "    This can take 30+ minutes depending on card size"
    echo "─────────────────────────────────────────────────────"

    while true; do
        echo ""
        read -p "Enter your choice [1-2]: " method_choice

        if [[ "$method_choice" == "1" ]]; then
            FORMAT_METHOD="quick"
            print_info "Selected: Quick Format"
            break
        elif [[ "$method_choice" == "2" ]]; then
            FORMAT_METHOD="secure"
            print_warning "Selected: Secure Erase (this will take a while)"
            echo ""
            read -p "Are you sure you want to proceed with secure erase? [y/N]: " confirm_secure
            if [[ "$confirm_secure" =~ ^[Yy]$ ]]; then
                break
            else
                print_info "Switching to Quick Format"
                FORMAT_METHOD="quick"
                break
            fi
        else
            print_error "Invalid selection. Please enter 1 or 2."
        fi
    done
}

# Unmount disk
unmount_disk() {
    local disk=$1

    print_info "Unmounting disk..."

    if diskutil unmountDisk "$disk" > /dev/null 2>&1; then
        print_success "Disk unmounted successfully."
    else
        print_warning "Could not unmount disk (it may not be mounted)."
    fi
}

# Format disk
format_disk() {
    local disk=$1
    local method=$2

    # Extract disk number (e.g., disk2 from /dev/disk2)
    local disk_num=$(echo "$disk" | sed 's/\/dev\/disk//')

    echo ""
    print_info "Starting format process..."
    echo ""

    if [[ "$method" == "secure" ]]; then
        print_warning "Performing secure erase (writing zeros to entire disk)..."
        print_info "This may take 30+ minutes. Please be patient..."
        echo ""

        # Secure erase: write zeros to entire disk
        if diskutil secureErase 0 "$disk"; then
            print_success "Secure erase completed."
        else
            print_error "Secure erase failed!"
            exit 1
        fi
        echo ""
    fi

    print_info "Formatting as FAT32..."
    echo ""

    # Format as FAT32 (MS-DOS FAT32)
    # Using MBR partition scheme for maximum compatibility
    if diskutil eraseDisk FAT32 SDCARD MBRFormat "$disk"; then
        echo ""
        print_success "Format completed successfully!"
    else
        echo ""
        print_error "Format failed!"
        print_info "Please check if the disk is write-protected or damaged."
        exit 1
    fi
}

# Eject disk
eject_disk() {
    local disk=$1

    echo ""
    print_info "Ejecting disk..."

    if diskutil eject "$disk" > /dev/null 2>&1; then
        print_success "Disk ejected safely."
        print_success "You can now safely remove the SD card."
    else
        print_warning "Could not eject disk automatically."
        print_info "Please eject the disk manually from Finder."
    fi
}

# Main script execution
main() {
    print_header

    # Perform checks
    check_macos
    check_sudo

    echo ""

    # List disks and get count (sets global NUM_DISKS)
    list_external_disks

    # Select disk
    select_disk "$NUM_DISKS"

    # Confirm selection
    confirm_disk "$SELECTED_DISK"

    # Select format method
    select_format_method

    # Final confirmation
    echo ""
    print_warning "Last chance to cancel!"
    read -p "Press Enter to continue or Ctrl+C to abort..."

    # Unmount
    unmount_disk "$SELECTED_DISK"

    # Format
    format_disk "$SELECTED_DISK" "$FORMAT_METHOD"

    # Eject
    eject_disk "$SELECTED_DISK"

    # Success message
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║          Operation Completed! ✓            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
    echo ""
}

# Run main function
main
