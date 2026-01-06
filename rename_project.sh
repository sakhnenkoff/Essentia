#!/bin/bash
set -e

# AppTemplateLite Project Rename Script
# Usage: ./rename_project.sh NewProjectName
#
# This script renames the entire project from "AppTemplateLite" to your chosen name.
# It updates all file names, directory names, and file contents.

OLD_NAME="AppTemplateLite"
NEW_NAME="$1"

# Validate input
if [ -z "$NEW_NAME" ]; then
    echo "❌ Error: Please provide a new project name"
    echo ""
    echo "Usage: ./rename_project.sh NewProjectName"
    echo ""
    echo "Example: ./rename_project.sh MyAwesomeApp"
    exit 1
fi

# Check for valid identifier (alphanumeric and underscore only)
if [[ ! "$NEW_NAME" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
    echo "❌ Error: Project name must start with a letter and contain only letters, numbers, and underscores"
    exit 1
fi

# Check if we're in the right directory
if [ ! -d "${OLD_NAME}.xcodeproj" ]; then
    echo "❌ Error: This script must be run from the AppTemplateLite root directory"
    echo "   Current directory: $(pwd)"
    echo "   Expected to find: ${OLD_NAME}.xcodeproj"
    exit 1
fi

echo "🔄 Renaming project from '${OLD_NAME}' to '${NEW_NAME}'..."
echo ""

# Step 1: Update file contents first (before renaming directories)
echo "📝 Step 1/4: Updating file contents..."

find . -type f \( \
    -name "*.swift" \
    -o -name "*.pbxproj" \
    -o -name "*.xcscheme" \
    -o -name "*.xcconfig" \
    -o -name "*.plist" \
    -o -name "*.md" \
    -o -name "*.entitlements" \
    -o -name "*.storyboard" \
    -o -name "*.xib" \
    -o -name "*.strings" \
    -o -name "Contents.json" \
\) ! -path "./.git/*" ! -path "./rename_project.sh" -print0 | while IFS= read -r -d '' file; do
    if grep -q "${OLD_NAME}" "$file" 2>/dev/null; then
        sed -i '' "s/${OLD_NAME}/${NEW_NAME}/g" "$file"
        echo "   ✓ Updated: $file"
    fi
done

# Step 2: Rename scheme files
echo ""
echo "📋 Step 2/4: Renaming scheme files..."

SCHEMES_DIR="${OLD_NAME}.xcodeproj/xcshareddata/xcschemes"
if [ -d "$SCHEMES_DIR" ]; then
    for scheme in "$SCHEMES_DIR"/*"${OLD_NAME}"*; do
        if [ -f "$scheme" ]; then
            new_scheme=$(echo "$scheme" | sed "s/${OLD_NAME}/${NEW_NAME}/g")
            mv "$scheme" "$new_scheme"
            echo "   ✓ Renamed: $(basename "$scheme") → $(basename "$new_scheme")"
        fi
    done
fi

# Step 3: Rename main directories
echo ""
echo "📁 Step 3/4: Renaming directories..."

# Rename UI Tests directory
if [ -d "${OLD_NAME}UITests" ]; then
    mv "${OLD_NAME}UITests" "${NEW_NAME}UITests"
    echo "   ✓ Renamed: ${OLD_NAME}UITests → ${NEW_NAME}UITests"
fi

# Rename Unit Tests directory
if [ -d "${OLD_NAME}UnitTests" ]; then
    mv "${OLD_NAME}UnitTests" "${NEW_NAME}UnitTests"
    echo "   ✓ Renamed: ${OLD_NAME}UnitTests → ${NEW_NAME}UnitTests"
fi

# Rename main source directory
if [ -d "${OLD_NAME}" ]; then
    mv "${OLD_NAME}" "${NEW_NAME}"
    echo "   ✓ Renamed: ${OLD_NAME} → ${NEW_NAME}"
fi

# Step 4: Rename Xcode project
echo ""
echo "📦 Step 4/4: Renaming Xcode project..."

if [ -d "${OLD_NAME}.xcodeproj" ]; then
    mv "${OLD_NAME}.xcodeproj" "${NEW_NAME}.xcodeproj"
    echo "   ✓ Renamed: ${OLD_NAME}.xcodeproj → ${NEW_NAME}.xcodeproj"
fi

# Rename workspace if it exists
if [ -d "${OLD_NAME}.xcworkspace" ]; then
    mv "${OLD_NAME}.xcworkspace" "${NEW_NAME}.xcworkspace"
    echo "   ✓ Renamed: ${OLD_NAME}.xcworkspace → ${NEW_NAME}.xcworkspace"
fi

# Done!
echo ""
echo "✅ Project successfully renamed to '${NEW_NAME}'!"
echo ""
echo "Next steps:"
echo "   1. Open ${NEW_NAME}.xcodeproj in Xcode"
echo "   2. Clean build folder (Cmd+Shift+K)"
echo "   3. Build the project (Cmd+B)"
echo "   4. Update your bundle identifier in Signing & Capabilities"
echo "   5. Configure your secrets in Configurations/Secrets.xcconfig.local"
echo ""
echo "📖 See README.md for full setup instructions"
