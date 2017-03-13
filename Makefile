## Template to build a hierarchy of dependent docker images.
## Based on https://github.com/jupyter/docker-stacks/blob/master/Makefile
## Builds are tracked via build-stamps in $BUILD_DIR.
## Dependencies for each image are created automatically for all files tracked by git.
##
## Usage (see examples below):
## * Store each image to build in a separate directory containing a `Dockerfile` and append the direcotry name to ALL_IMAGES.
## * Set OUTPUT_IMAGES.
## * Configure dependencies of images.
 
BUILD_DIR := build
 
## Registry settings
OWNER := bigorn0
 
DOCKER_LOG := $(BUILD_DIR)/docker.log
 
versions := latest
GIT_VERSION := $(shell git rev-parse --short --verify HEAD)
ALL_IMAGES := $(shell find * -maxdepth 0 -type d  | egrep -v $(BUILD_DIR) | sort | xargs)

## Images that should be published in the registry.
OUTPUT_IMAGES:= $(shell find * -maxdepth 0 -type d | egrep -v $(BUILD_DIR) | sort | xargs)

# http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## show this help
	@echo "====================="
	@echo "Replace % with a directory name (e.g., make build/nginx)"
	@echo
	@grep -E '^[a-zA-Z0-9_%/-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo "output images: $(OUTPUT_IMAGES)"
	@echo "output of failed docker runs can be found in $(DOCKER_LOG).IMAGE_NAME"

build/%: DARGS?=--build-arg BUILD_DATE="$(shell date +%Y%m%d)" --build-arg GIT_HASH=$(GIT_VERSION) ## builds the latest image after all prerequisite images

build-all: $(patsubst %, $(BUILD_DIR)/%, $(ALL_IMAGES)) ## build all images

all: build-all push-all ## build and pushes all images

clean: ## remove all build stamps
	rm -rf $(BUILD_DIR)

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

## Build rule for all docker stacks
$(BUILD_DIR)/%: | $(BUILD_DIR)
	@printf "Building image: $(notdir $@)... "
	@echo "docker build $(DARGS) --rm --squash --force-rm -t $(OWNER)/$(notdir $@):latest -t $(OWNER)/$(notdir $@):$(GIT_VERSION) ./$(notdir $@) "> $(DOCKER_LOG).$(notdir $@)
	@docker build $(DARGS) --rm --squash --force-rm -t $(OWNER)/$(notdir $@):latest -t $(OWNER)/$(notdir $@):alpine-3.5 ./$(notdir $@) >> $(DOCKER_LOG).$(notdir $@) 2>&1
	@touch $(BUILD_DIR)/$(notdir $@)
	@rm $(DOCKER_LOG).$(notdir $@)
	@echo "Done."

## Dynamically create dependency tree
define generateDependencyTree
$(BUILD_DIR)/$(1): $(shell find $(1) -name Dockerfile -exec dirname {} \; -exec egrep "FROM $(OWNER)" {} \; | sed -e 's/\.\/\(.*\)/$(BUILD_DIR)\/\1:/;s/FROM .*\/\(.*\):.*/$(BUILD_DIR)\/\1/' | sed '$!N;s/\n/ /')
endef

$(foreach folder,$(ALL_IMAGES),$(eval $(call generateDependencyTree,$(folder))))

## Create dependencies for each container: Depend on all files tracked by git.
define generateDependencies
$(BUILD_DIR)/$(1): $(shell git ls-files $(1))
endef

$(foreach container,$(ALL_IMAGES),$(eval $(call generateDependencies,$(container))))

push-all: $(patsubst %, push/%, $(ALL_IMAGES)) ## push all images

push/%: ## push the latest image to registry
	@echo "Pushing $(OWNER)/$(notdir $@):$(GIT_VERSION)"
	@docker push $(OWNER)/$(notdir $@):$(GIT_VERSION) > $(DOCKER_LOG).$(notdir $@) 2>&1
	@echo "Pushing $(OWNER)/$(notdir $@):$(REGISTRY_VERSION)"
	@docker push $(OWNER)/$(notdir $@):$(REGISTRY_VERSION) >> $(DOCKER_LOG).$(notdir $@) 2>&1
	@rm $(OWNER).$(notdir $@)
	@echo "Push done."
      
.PHONY: all build-all help clean push-all
