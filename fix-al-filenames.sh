#!/bin/bash

# Script to fix AL file naming conventions
# Converts: PurchaseEvents.enum.al -> Purchase Events.Enum.al
# - Adds spaces between CamelCase words
# - Capitalizes the object type suffix

BASE_DIR="/home/bradf/Dev/AL/AL-ForNAV-Direct-Print-On-Event"

# Function to add spaces between CamelCase words
add_spaces() {
    local name="$1"
    # Add space before uppercase letters that follow lowercase letters
    # Also handle sequences like "PrintEvents" -> "Print Events"
    name=$(echo "$name" | sed -E 's/([a-z])([A-Z])/\1 \2/g')
    # Then fix specific known issues like "For NAV" -> "ForNAV"
    echo "$name" | sed 's/For NAV/ForNAV/g'
}

# Function to capitalize object type
capitalize_object_type() {
    local filename="$1"

    # Replace common object type extensions with proper casing
    filename=$(echo "$filename" | sed 's/\.codeunit\.al$/.Codeunit.al/i')
    filename=$(echo "$filename" | sed 's/\.enum\.al$/.Enum.al/i')
    filename=$(echo "$filename" | sed 's/\.enumext\.al$/.EnumExt.al/i')
    filename=$(echo "$filename" | sed 's/\.table\.al$/.Table.al/i')
    filename=$(echo "$filename" | sed 's/\.tableext\.al$/.TableExt.al/i')
    filename=$(echo "$filename" | sed 's/\.page\.al$/.Page.al/i')
    filename=$(echo "$filename" | sed 's/\.pageext\.al$/.PageExt.al/i')
    filename=$(echo "$filename" | sed 's/\.report\.al$/.Report.al/i')
    filename=$(echo "$filename" | sed 's/\.reportext\.al$/.ReportExt.al/i')
    filename=$(echo "$filename" | sed 's/\.xmlport\.al$/.XmlPort.al/i')
    filename=$(echo "$filename" | sed 's/\.query\.al$/.Query.al/i')
    filename=$(echo "$filename" | sed 's/\.interface\.al$/.Interface.al/i')
    filename=$(echo "$filename" | sed 's/\.permissionset\.al$/.PermissionSet.al/i')
    filename=$(echo "$filename" | sed 's/\.permissionsetextension\.al$/.PermissionSetExtension.al/i')
    filename=$(echo "$filename" | sed 's/\.controladdin\.al$/.ControlAddin.al/i')
    filename=$(echo "$filename" | sed 's/\.profile\.al$/.Profile.al/i')

    echo "$filename"
}

# Track if any changes were made
changes_made=0

# Find all .al files
find "$BASE_DIR" -name "*.al" -type f | while read -r filepath; do
    dir=$(dirname "$filepath")
    filename=$(basename "$filepath")

    # Skip if filename already has spaces (likely already correct)
    # But still check for object type casing issues

    # Extract base name (everything before the object type)
    # Pattern: Name.ObjectType.al
    if [[ "$filename" =~ ^(.+)\.([^.]+)\.al$ ]]; then
        basename_part="${BASH_REMATCH[1]}"
        objecttype_part="${BASH_REMATCH[2]}"

        # Add spaces to the base name
        new_basename=$(add_spaces "$basename_part")

        # Reconstruct the filename and fix object type casing
        new_filename="${new_basename}.${objecttype_part}.al"
        new_filename=$(capitalize_object_type "$new_filename")

        # Check if rename is needed
        if [ "$filename" != "$new_filename" ]; then
            old_path="$filepath"
            new_path="$dir/$new_filename"

            echo "Renaming: $filename"
            echo "      To: $new_filename"
            echo ""

            # Use git mv if in a git repo to preserve history
            if git -C "$BASE_DIR" rev-parse --git-dir > /dev/null 2>&1; then
                git -C "$BASE_DIR" mv "$old_path" "$new_path" 2>/dev/null || mv "$old_path" "$new_path"
            else
                mv "$old_path" "$new_path"
            fi

            changes_made=1
        fi
    fi
done

echo "Done!"
