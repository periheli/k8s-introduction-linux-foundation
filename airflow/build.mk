# Variables
DOCKER_IMAGE_NAME ?= my-airflow
DOCKER_TAG ?= 0.0.1
DOCKERFILE ?= Dockerfile
BUILD_CONTEXT ?= .
DOCKER_REGISTRY ?= 
# Full image name with optional registry
FULL_IMAGE_NAME := $(if $(DOCKER_REGISTRY),$(DOCKER_REGISTRY)/$(DOCKER_IMAGE_NAME),$(DOCKER_IMAGE_NAME))

# Build arguments (can be overridden)
BUILD_ARGS ?= 

# Docker build options
DOCKER_BUILD_OPTS ?= --pull --no-cache

.PHONY: build_image clean_build_cache show_build_info

build_image: show_build_info
	@echo "🏗️  Building Docker image for Airflow..."
	@echo "📦 Image: ${FULL_IMAGE_NAME}:$(DOCKER_TAG)"
	@echo "📄 Dockerfile: $(DOCKERFILE)"
	@echo "📂 Build context: $(BUILD_CONTEXT)"
	@if [ -n "$(BUILD_ARGS)" ]; then \
		echo "🔧 Build args: $(BUILD_ARGS)"; \
	fi
	@echo "────────────────────────────────────────"
	@docker build \
		-f $(DOCKERFILE) \
		$(DOCKER_BUILD_OPTS) \
		$(if $(BUILD_ARGS),$(addprefix --build-arg ,$(BUILD_ARGS))) \
		-t ${FULL_IMAGE_NAME}:$(DOCKER_TAG) \
		$(BUILD_CONTEXT)
	@echo "✅ Successfully built ${FULL_IMAGE_NAME}:$(DOCKER_TAG)"
	@echo "📊 Image size: $$(docker images --format 'table {{.Size}}' ${FULL_IMAGE_NAME}:$(DOCKER_TAG) | tail -n 1)"

# Fast build without cache or pull
build_image_fast:
	@echo "🚀 Fast building Docker image (no cache, no pull)..."
	@docker build \
		-f $(DOCKERFILE) \
		-t ${FULL_IMAGE_NAME}:$(DOCKER_TAG) \
		$(BUILD_CONTEXT)

# Build with specific tag
build_image_tag:
	@if [ -z "$(TAG)" ]; then \
		echo "❌ Error: TAG variable is required. Usage: make build_image_tag TAG=v1.0.0"; \
		exit 1; \
	fi
	@$(MAKE) build_image DOCKER_TAG=$(TAG)

# Show build information
show_build_info:
	@echo "🔍 Docker Build Information:"
	@echo "   Docker version: $$(docker --version)"
	@echo "   Available space: $$(df -h . | tail -n 1 | awk '{print $$4}')"
	@echo "   Build timestamp: $$(date)"
	@echo ""

# Clean build cache
clean_build_cache:
	@echo "🧹 Cleaning Docker build cache..."
	@docker builder prune -f
	@echo "✅ Build cache cleaned"

# Remove the built image
clean_image:
	@echo "🗑️  Removing Docker image ${FULL_IMAGE_NAME}:$(DOCKER_TAG)..."
	@docker rmi ${FULL_IMAGE_NAME}:$(DOCKER_TAG) 2>/dev/null || echo "Image not found"

# Build and run container for testing
build_and_test: build_image
	@echo "🧪 Testing the built image..."
	@docker run --rm ${FULL_IMAGE_NAME}:$(DOCKER_TAG) --version || echo "⚠️  Version check failed"

# Show help
help:
	@echo "🐳 Docker Build Targets:"
	@echo "  build_image       - Build the Docker image (default)"
	@echo "  build_image_fast  - Build without cache or pull"
	@echo "  build_image_tag   - Build with specific tag (requires TAG=)"
	@echo "  clean_build_cache - Clean Docker build cache"
	@echo "  clean_image       - Remove the built image"
	@echo "  build_and_test    - Build image and run basic test"
	@echo "  show_build_info   - Show Docker build information"
	@echo ""
	@echo "🔧 Variables (can be overridden):"
	@echo "  DOCKER_IMAGE_NAME - Image name (default: my-airflow)"
	@echo "  DOCKER_TAG        - Image tag (default: latest)"
	@echo "  DOCKERFILE        - Dockerfile path (default: Dockerfile)"
	@echo "  BUILD_CONTEXT     - Build context (default: .)"
	@echo "  DOCKER_REGISTRY   - Registry prefix (default: empty)"
	@echo "  BUILD_ARGS        - Build arguments (default: empty)"
	@echo ""
	@echo "📝 Examples:"
	@echo "  make build_image"
	@echo "  make build_image DOCKER_TAG=v1.2.3"
	@echo "  make build_image_tag TAG=production"
	@echo "  make build_image BUILD_ARGS='PYTHON_VERSION=3.9 ENV=prod'"
	@echo "  make build_image DOCKER_REGISTRY=myregistry.com/"


# Extract version components for multi-tagging
VERSION_PARTS := $(subst ., ,$(DOCKER_TAG))
MAJOR := $(word 1,$(VERSION_PARTS))
MINOR := $(word 2,$(VERSION_PARTS))
PATCH := $(word 3,$(VERSION_PARTS))
MAJOR_MINOR := $(MAJOR).$(MINOR)
DOCKER_HUB_USER_NAME = wiuy3120

# Full image name with optional registry
FULL_IMAGE_NAME := $(if $(DOCKER_REGISTRY),$(DOCKER_REGISTRY)/$(DOCKER_IMAGE_NAME),$(DOCKER_IMAGE_NAME))

.PHONY: release validate_version show_release_info clean_release_tags

# Main release rule
release: validate_version show_release_info build_image
	@echo "🚀 Starting release process for $(DOCKER_TAG)..."
	@echo "📦 Creating multi-version tags..."
	
	# Tag the image with all versions
	@docker tag $(FULL_IMAGE_NAME):$(DOCKER_TAG) $(FULL_IMAGE_NAME):$(MAJOR_MINOR)
	@echo "✅ Tagged: $(FULL_IMAGE_NAME):$(MAJOR_MINOR)"
	
	@docker tag $(FULL_IMAGE_NAME):$(DOCKER_TAG) $(FULL_IMAGE_NAME):$(MAJOR)
	@echo "✅ Tagged: $(FULL_IMAGE_NAME):$(MAJOR)"
	
	@docker tag $(FULL_IMAGE_NAME):$(DOCKER_TAG) $(FULL_IMAGE_NAME):latest
	@echo "✅ Tagged: $(FULL_IMAGE_NAME):latest"
	
	@echo "📤 Pushing all tags to registry..."
# # 	@docker push $(FULL_IMAGE_NAME):$(DOCKER_TAG)
# 	@minikube image load $(FULL_IMAGE_NAME):$(DOCKER_TAG)
# 	@echo "✅ Pushed: $(FULL_IMAGE_NAME):$(DOCKER_TAG)"
	
# # 	@docker push $(FULL_IMAGE_NAME):$(MAJOR_MINOR)
# 	@minikube image load $(FULL_IMAGE_NAME):$(MAJOR_MINOR)
# 	@echo "✅ Pushed: $(FULL_IMAGE_NAME):$(MAJOR_MINOR)"
	
# # 	@docker push $(FULL_IMAGE_NAME):$(MAJOR)
# 	@minikube image load $(FULL_IMAGE_NAME):$(MAJOR)
# 	@echo "✅ Pushed: $(FULL_IMAGE_NAME):$(MAJOR)"
	
	@docker tag ${FULL_IMAGE_NAME}:latest ${DOCKER_HUB_USER_NAME}/$(FULL_IMAGE_NAME):latest
	@docker push ${DOCKER_HUB_USER_NAME}/$(FULL_IMAGE_NAME):latest
# 	@minikube image load $(FULL_IMAGE_NAME):latest
	@echo "✅ Pushed: $(FULL_IMAGE_NAME):latest"
	
	@echo "🎉 Release $(DOCKER_TAG) completed successfully!"
	@echo ""
	@echo "📋 Available tags:"
	@echo "  • $(FULL_IMAGE_NAME):$(DOCKER_TAG) (immutable)"
	@echo "  • $(FULL_IMAGE_NAME):$(MAJOR_MINOR) (rolling patch)"
	@echo "  • $(FULL_IMAGE_NAME):$(MAJOR) (rolling minor)"
	@echo "  • $(FULL_IMAGE_NAME):latest (rolling major)"
	@echo ""
	@echo "💡 Usage examples:"
	@echo "  Production:   docker pull $(FULL_IMAGE_NAME):$(DOCKER_TAG)"
	@echo "  Development:  docker pull $(FULL_IMAGE_NAME):$(MAJOR_MINOR)"
	@echo "  Latest:       docker pull $(FULL_IMAGE_NAME):latest"

# Quick release with custom version
release_version:
	@if [ -z "$(VERSION)" ]; then \
		echo "❌ Error: VERSION is required. Usage: make release_version VERSION=1.2.3"; \
		exit 1; \
	fi
	@$(MAKE) release DOCKER_TAG=$(VERSION)

# Release without latest tag (for pre-releases)
release_no_latest: validate_version show_release_info build_image
	@echo "🚀 Starting release process for $(DOCKER_TAG) (no latest tag)..."
	
	@docker tag $(FULL_IMAGE_NAME):$(DOCKER_TAG) $(FULL_IMAGE_NAME):$(MAJOR_MINOR)
	@docker tag $(FULL_IMAGE_NAME):$(DOCKER_TAG) $(FULL_IMAGE_NAME):$(MAJOR)
	
	@docker push $(FULL_IMAGE_NAME):$(DOCKER_TAG)
	@docker push $(FULL_IMAGE_NAME):$(MAJOR_MINOR)
	@docker push $(FULL_IMAGE_NAME):$(MAJOR)
	
	@echo "✅ Released $(DOCKER_TAG) without latest tag"

# Pre-release (alpha, beta, rc)
release_pre: validate_version show_release_info build_image
	@echo "🚀 Starting pre-release for $(DOCKER_TAG)..."
	@docker push $(FULL_IMAGE_NAME):$(DOCKER_TAG)
	@echo "✅ Pre-release $(DOCKER_TAG) pushed (specific tag only)"

# Validate semver format
validate_version:
	@if [ -z "$(DOCKER_TAG)" ]; then \
		echo "❌ Error: DOCKER_TAG is required"; \
		exit 1; \
	fi
	@if ! echo "$(DOCKER_TAG)" | grep -E "^[0-9]+\.[0-9]+\.[0-9]+"; then \
		echo "❌ Error: DOCKER_TAG must be in semver format (e.g., 1.2.3)"; \
		echo "Current value: $(DOCKER_TAG)"; \
		exit 1; \
	fi
	@echo "✅ Version $(DOCKER_TAG) is valid semver format"

# Show release information
show_release_info:
	@echo "📋 Release Information:"
	@echo "   Image: $(FULL_IMAGE_NAME)"
	@echo "   Version: $(DOCKER_TAG)"
	@echo "   Major: $(MAJOR)"
	@echo "   Minor: $(MINOR)"
	@echo "   Patch: $(PATCH)"
	@echo "   Registry: $(if $(DOCKER_REGISTRY),$(DOCKER_REGISTRY),Docker Hub)"
	@echo "   Date: $$(date)"
	@echo ""

# Clean up local release tags (keeps the main version)
clean_release_tags:
	@echo "🧹 Cleaning up local release tags..."
	@docker rmi $(FULL_IMAGE_NAME):$(MAJOR_MINOR) 2>/dev/null || true
	@docker rmi $(FULL_IMAGE_NAME):$(MAJOR) 2>/dev/null || true
	@docker rmi $(FULL_IMAGE_NAME):latest 2>/dev/null || true
	@echo "✅ Cleaned up local tags (kept $(FULL_IMAGE_NAME):$(DOCKER_TAG))"

# Show current tags for the image
show_tags:
	@echo "🏷️  Current tags for $(DOCKER_IMAGE_NAME):"
	@docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" | grep $(DOCKER_IMAGE_NAME) || echo "No images found"

# Rollback to previous version (requires PREV_VERSION)
rollback:
	@if [ -z "$(PREV_VERSION)" ]; then \
		echo "❌ Error: PREV_VERSION is required. Usage: make rollback PREV_VERSION=1.2.2"; \
		exit 1; \
	fi
	@echo "🔄 Rolling back to $(PREV_VERSION)..."
	@docker pull $(FULL_IMAGE_NAME):$(PREV_VERSION)
	@docker tag $(FULL_IMAGE_NAME):$(PREV_VERSION) $(FULL_IMAGE_NAME):latest
	@docker push $(FULL_IMAGE_NAME):latest
	@echo "✅ Rolled back to $(PREV_VERSION)"

# Help for release commands
help_release:
	@echo "🚀 Release Commands:"
	@echo "  release              - Full release with multi-tagging"
	@echo "  release_version      - Release with custom version (requires VERSION=x.y.z)"
	@echo "  release_no_latest    - Release without updating latest tag"
	@echo "  release_pre          - Pre-release (only specific tag)"
	@echo "  rollback             - Rollback latest to previous version (requires PREV_VERSION=x.y.z)"
	@echo "  clean_release_tags   - Clean up local release tags"
	@echo "  show_tags           - Show current image tags"
	@echo "  validate_version    - Validate DOCKER_TAG format"
	@echo ""
	@echo "📝 Examples:"
	@echo "  make release                              # Release current DOCKER_TAG"
	@echo "  make release_version VERSION=1.2.3       # Release specific version"
	@echo "  make release DOCKER_TAG=1.2.3            # Release with override"
	@echo "  make release_pre DOCKER_TAG=1.2.3-alpha  # Pre-release"
	@echo "  make rollback PREV_VERSION=1.2.2         # Rollback"
	@echo "  make release DOCKER_REGISTRY=myregistry.com"