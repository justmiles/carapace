IMAGE_NAME := justmiles/carapace
TAG := latest
CONTAINER_ENGINE := docker

.PHONY: help build push run shell publish

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build the container image
	$(CONTAINER_ENGINE) build -t $(IMAGE_NAME):$(TAG) .

push: ## Push the container image to the registry
	$(CONTAINER_ENGINE) push $(IMAGE_NAME):$(TAG)

run: ## Run the container locally
	$(CONTAINER_ENGINE) run -d \
		-p 7756:7756 \
		-p 8080:8080 \
		-p 18789:18789 \
		--name carapace-instance \
		$(IMAGE_NAME):$(TAG)

shell: ## Run a shell inside the container
	$(CONTAINER_ENGINE) run -it --rm $(IMAGE_NAME):$(TAG) /bin/bash

publish: push ## Push the container image and update README
	@echo "Updating README.md with tag $(TAG)..."
	sed 's/{{TAG}}/$(TAG)/g' README.md.tpl > README.md
	@echo "README.md updated."
