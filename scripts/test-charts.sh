#!/bin/bash

# Local development helper script for Helm charts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if required tools are installed
check_dependencies() {
    log_info "Checking dependencies..."
    
    if ! command -v helm &> /dev/null; then
        log_error "Helm is not installed. Please install Helm first."
        exit 1
    fi
    
    if ! command -v ct &> /dev/null; then
        log_warning "chart-testing (ct) is not installed. Some features will be limited."
    fi
    
    log_success "Dependencies check completed"
}

# Function to lint all charts
lint_charts() {
    log_info "Linting all charts..."
    
    for chart_dir in */Chart.yaml; do
        chart=$(dirname "$chart_dir")
        log_info "Linting chart: $chart"
        
        if helm lint "$chart"; then
            log_success "Chart $chart passed linting"
        else
            log_error "Chart $chart failed linting"
            exit 1
        fi
    done
}

# Function to test chart templates
test_templates() {
    log_info "Testing chart templates..."
    
    for chart_dir in */Chart.yaml; do
        chart=$(dirname "$chart_dir")
        log_info "Testing templates for chart: $chart"
        
        # Test with default values
        if helm template "test-$chart" "$chart" > /dev/null; then
            log_success "Chart $chart templates rendered successfully"
        else
            log_error "Chart $chart template rendering failed"
            exit 1
        fi
        
        # Test with example values if they exist
        if [ -d "$chart/examples" ]; then
            for example in "$chart/examples"/*.yaml; do
                if [ -f "$example" ]; then
                    example_name=$(basename "$example" .yaml)
                    log_info "Testing $chart with example: $example_name"
                    
                    if helm template "test-$chart-$example_name" "$chart" -f "$example" > /dev/null; then
                        log_success "Chart $chart with $example_name rendered successfully"
                    else
                        log_error "Chart $chart with $example_name failed to render"
                        exit 1
                    fi
                fi
            done
        fi
    done
}

# Function to package charts
package_charts() {
    log_info "Packaging charts..."
    
    mkdir -p packages
    
    for chart_dir in */Chart.yaml; do
        chart=$(dirname "$chart_dir")
        log_info "Packaging chart: $chart"
        
        if helm package "$chart" --destination packages/; then
            log_success "Chart $chart packaged successfully"
        else
            log_error "Chart $chart packaging failed"
            exit 1
        fi
    done
}

# Function to run chart-testing if available
run_ct() {
    if command -v ct &> /dev/null; then
        log_info "Running chart-testing..."
        
        # Lint with ct
        if ct lint --config .github/ct.yaml; then
            log_success "Chart-testing lint passed"
        else
            log_error "Chart-testing lint failed"
            exit 1
        fi
    else
        log_warning "chart-testing not available, skipping ct tests"
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  check       Check dependencies"
    echo "  lint        Lint all charts"
    echo "  test        Test chart templates"
    echo "  package     Package all charts"
    echo "  ct          Run chart-testing (if available)"
    echo "  all         Run all checks (default)"
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0           # Run all checks"
    echo "  $0 lint      # Only lint charts"
    echo "  $0 test      # Only test templates"
}

# Main script logic
case "${1:-all}" in
    check)
        check_dependencies
        ;;
    lint)
        check_dependencies
        lint_charts
        ;;
    test)
        check_dependencies
        test_templates
        ;;
    package)
        check_dependencies
        package_charts
        ;;
    ct)
        check_dependencies
        run_ct
        ;;
    all)
        check_dependencies
        lint_charts
        test_templates
        run_ct
        log_success "All checks completed successfully!"
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        log_error "Unknown command: $1"
        show_usage
        exit 1
        ;;
esac
