#!/bin/bash

# Application Center - Final Verification Script
# Checks that all components are properly configured

echo "🔍 Application Center - System Verification"
echo "============================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASS=0
FAIL=0
WARN=0

# Helper functions
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASS++))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAIL++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARN++))
}

echo "📁 Checking Directory Structure..."
echo "-----------------------------------"

# Check directories
dirs=("public_html" "data" "src" "roblox" "tests" "data/apps" "data/submissions" "data/creators")
for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
        check_pass "Directory exists: $dir"
    else
        check_fail "Directory missing: $dir"
    fi
done

echo ""
echo "📄 Checking Core Files..."
echo "-------------------------"

# Check core files
files=(
    ".env.example"
    ".gitignore"
    "README.md"
    "SETUP.md"
    "CONTRIBUTING.md"
    "LICENSE"
    "public_html/index.php"
    "public_html/builder.html"
    "public_html/assets/css/style.css"
    "public_html/assets/js/builder.js"
    "src/Env.php"
    "src/Helpers.php"
    "src/AstParser.php"
    "src/AstSerializer.php"
    "src/AppController.php"
    "src/SubmissionController.php"
    "src/FeatherlessGrader.php"
    "src/PromotionService.php"
    "roblox/AppCenterClient.lua"
    "roblox/ExampleSetup.lua"
    "data/apps/example.astappcnt"
    "tests/run_tests.php"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        check_pass "File exists: $file"
    else
        check_fail "File missing: $file"
    fi
done

echo ""
echo "🔧 Checking PHP Syntax..."
echo "-------------------------"

# Check PHP syntax
php_files=$(find . -name "*.php" -type f)
php_errors=0

for file in $php_files; do
    if php -l "$file" > /dev/null 2>&1; then
        check_pass "PHP syntax valid: $file"
    else
        check_fail "PHP syntax error: $file"
        ((php_errors++))
    fi
done

echo ""
echo "🧪 Running Tests..."
echo "------------------"

# Run tests
if php tests/run_tests.php > /tmp/test_output.txt 2>&1; then
    check_pass "All tests passed"
    grep "Passed:" /tmp/test_output.txt
else
    check_fail "Some tests failed"
    cat /tmp/test_output.txt
fi

echo ""
echo "⚙️  Checking Configuration..."
echo "-----------------------------"

# Check .env file
if [ -f ".env" ]; then
    check_pass ".env file exists"
    
    # Check for required variables
    required_vars=("ROBLOX_API_KEY" "FEATHERLESS_API_KEY" "FEATHERLESS_MODEL")
    for var in "${required_vars[@]}"; do
        if grep -q "^$var=" .env 2>/dev/null; then
            value=$(grep "^$var=" .env | cut -d'=' -f2-)
            if [[ "$value" == *"your_"* ]] || [[ "$value" == *"_here"* ]]; then
                check_warn "$var is set but appears to be a placeholder"
            else
                check_pass "$var is configured"
            fi
        else
            check_warn "$var not found in .env"
        fi
    done
else
    check_warn ".env file not found (using .env.example for reference)"
fi

echo ""
echo "📊 Checking File Permissions..."
echo "--------------------------------"

# Check data directory permissions
if [ -w "data" ]; then
    check_pass "data/ directory is writable"
else
    check_fail "data/ directory is not writable"
fi

if [ -w "data/apps" ]; then
    check_pass "data/apps/ directory is writable"
else
    check_fail "data/apps/ directory is not writable"
fi

if [ -w "data/submissions" ]; then
    check_pass "data/submissions/ directory is writable"
else
    check_fail "data/submissions/ directory is not writable"
fi

echo ""
echo "============================================"
echo "📊 VERIFICATION SUMMARY"
echo "============================================"
echo -e "${GREEN}✓ Passed:${NC} $PASS"
echo -e "${YELLOW}⚠ Warnings:${NC} $WARN"
echo -e "${RED}✗ Failed:${NC} $FAIL"
echo "============================================"

if [ $FAIL -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 All checks passed! System is ready.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Copy .env.example to .env and configure API keys"
    echo "2. Upload to your web server"
    echo "3. Configure web server to point to public_html"
    echo "4. Access the builder in your browser"
    echo "5. Follow SETUP.md for detailed instructions"
    echo ""
    exit 0
else
    echo ""
    echo -e "${RED}⚠️  Some checks failed. Please review and fix.${NC}"
    echo ""
    exit 1
fi
