.PHONY: help clean-% build-% test-%

# Require the DEV_REGISTRY environment variable to be set
ifndef DEV_REGISTRY
$(error DEV_REGISTRY is not set)
endif

help:
	@echo "make clean"
	@echo "    Remove the image"
	@echo "make build"
	@echo "    Build the image"

clean:
	@podman rmi -f ${DEV_REGISTRY}/toolbx:latest || true

build:
	@podman build -t ${DEV_REGISTRY}/toolbx:latest --format=docker .	
	@podman push ${DEV_REGISTRY}/toolbx:latest
 