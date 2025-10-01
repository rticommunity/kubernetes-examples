# Makefile for RTI Connext DDS Kubernetes Examples
.PHONY: help install-dev-tools lint test test-basic test-advanced clean validate-yaml security-scan

# Default target
.DEFAULT_GOAL := help

# Variables
KUBECTL := kubectl
NAMESPACE := rti-test-$(shell date +%s)
LINT_CONFIG := .yamllint.yml
TEST_TIMEOUT := 600

help: ## Show this help message
	@echo "RTI Connext DDS Kubernetes Examples"
	@echo "====================================="
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

install-dev-tools: ## Install development tools
	@echo "Installing development tools..."
	# Install yamllint
	pip3 install --user yamllint
	# Install kubectl if not present
	@which kubectl > /dev/null || (echo "Please install kubectl: https://kubernetes.io/docs/tasks/tools/" && exit 1)
	# Install kind for local testing
	@which kind > /dev/null || (echo "Installing kind..." && GO111MODULE="on" go install sigs.k8s.io/kind@latest)
	@echo "Development tools installed!"

validate-yaml: ## Validate all YAML files
	@echo "Validating YAML files..."
	@find . -name "*.yaml" -o -name "*.yml" | grep -v ".git" | grep -v ".yamllint.yml" | grep -v "kind-config.yaml" | while read file; do \
		echo "Validating $$file"; \
		$(KUBECTL) --dry-run=client apply -f "$$file" > /dev/null || exit 1; \
	done
	@echo "All YAML files are valid!"

lint: ## Run YAML linting
	@echo "Running YAML lint..."
	@if [ -f $(LINT_CONFIG) ]; then \
		find . -name "*.yaml" -o -name "*.yml" | grep -v ".git" | xargs yamllint -c $(LINT_CONFIG); \
	else \
		find . -name "*.yaml" -o -name "*.yml" | grep -v ".git" | xargs yamllint; \
	fi
	@echo "Linting complete!"

##@ Testing

test: test-basic test-advanced ## Run all tests

test-basic: ## Run basic tests (multicast, unicast, shared memory)
	@echo "Running basic integration tests..."
	@chmod +x tests/run_integration_tests.sh
	@./tests/run_integration_tests.sh basic

test-advanced: ## Run advanced tests (external gateways, load balancing)
	@echo "Running advanced integration tests..."
	@chmod +x tests/run_integration_tests.sh
	@./tests/run_integration_tests.sh advanced

test-loadbalancer: ## Run load balancer tests
	@echo "Running load balancer tests..."
	@chmod +x tests/run_integration_tests.sh
	@./tests/run_integration_tests.sh loadbalancer

test-single: ## Run single test case (usage: make test-single CASE=pod_to_pod_unicast_disc)
	@if [ -z "$(CASE)" ]; then echo "Error: CASE not specified. Usage: make test-single CASE=pod_to_pod_unicast_disc"; exit 1; fi
	@echo "Testing single use case: $(CASE)"
	@chmod +x tests/run_integration_tests.sh
	@./tests/run_integration_tests.sh $(CASE)

##@ Security

security-scan: ## Run security scanning with Trivy
	@echo "Running security scan..."
	@which trivy > /dev/null || (echo "Installing trivy..." && \
		curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin)
	trivy fs --security-checks vuln,config .
	@echo "Security scan complete!"

##@ Local Development

kind-create: ## Create local kind cluster for testing
	@echo "Creating kind cluster..."
	@kind create cluster --name rti-test --config tests/kind-config.yaml || true
	@kubectl cluster-info --context kind-rti-test

kind-delete: ## Delete local kind cluster
	@echo "Deleting kind cluster..."
	@kind delete cluster --name rti-test

kind-test: kind-create ## Run tests on local kind cluster
	@echo "Running tests on kind cluster..."
	@$(MAKE) test-basic
	@$(MAKE) kind-delete

##@ Deployment

deploy-example: ## Deploy specific example (usage: make deploy-example EXAMPLE=pod_to_pod_unicast_disc NAMESPACE=default)
	@if [ -z "$(EXAMPLE)" ]; then echo "Error: EXAMPLE not specified"; exit 1; fi
	@NS=${NAMESPACE:-default}; \
	echo "Deploying example $(EXAMPLE) to namespace $$NS..."; \
	cd $(EXAMPLE) && \
	find . -name "*.yaml" -o -name "*.yml" | head -10 | xargs -I {} kubectl apply -f {} -n $$NS

cleanup-example: ## Cleanup specific example (usage: make cleanup-example EXAMPLE=pod_to_pod_unicast_disc NAMESPACE=default)
	@if [ -z "$(EXAMPLE)" ]; then echo "Error: EXAMPLE not specified"; exit 1; fi
	@NS=${NAMESPACE:-default}; \
	echo "Cleaning up example $(EXAMPLE) from namespace $$NS..."; \
	cd $(EXAMPLE) && \
	find . -name "*.yaml" -o -name "*.yml" | head -10 | xargs -I {} kubectl delete -f {} -n $$NS --ignore-not-found=true

##@ Maintenance

clean: ## Clean up test artifacts and temporary files
	@echo "Cleaning up..."
	@rm -rf tests/results/
	@rm -f trivy-results.sarif
	@$(KUBECTL) delete namespace --selector=test-runner=rti-examples --ignore-not-found=true
	@echo "Cleanup complete!"

format: ## Format YAML files
	@echo "Formatting YAML files..."
	@find . -name "*.yaml" -o -name "*.yml" | grep -v ".git" | while read file; do \
		echo "Formatting $$file"; \
		# You can add YAML formatting tool here, like yq or prettier \
	done

update-images: ## Check for updated RTI Docker images
	@echo "Checking for updated RTI Docker images..."
	@grep -r "rticom/" . --include="*.yaml" --include="*.yml" | grep "image:" | sed 's/.*image: *//' | sort -u | while read image; do \
		echo "Checking $$image"; \
		docker pull "$$image" 2>/dev/null || echo "Failed to pull $$image"; \
	done

##@ Documentation

docs-serve: ## Serve documentation locally
	@echo "Starting documentation server..."
	@which python3 > /dev/null && python3 -m http.server 8000 || python -m SimpleHTTPServer 8000

docs-validate: ## Validate documentation links
	@echo "Validating documentation..."
	@find . -name "README.md" | while read file; do \
		echo "Checking links in $$file"; \
		# Add link checker here if available \
	done

version: ## Show version information
	@echo "RTI Connext DDS Kubernetes Examples"
	@echo "Kubernetes version: $$(kubectl version --short 2>/dev/null | head -1 || echo 'Not available')"
	@echo "Docker version: $$(docker --version 2>/dev/null || echo 'Not available')"
	@echo "Git commit: $$(git rev-parse --short HEAD 2>/dev/null || echo 'Not available')"