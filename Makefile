# MAKEFILE FOR LOCAL DEVELOPMENT
SHELL := /bin/bash
SLEEP=$(shell which sleep)
CURL=$(shell which curl)
DOCKER=$(shell which docker)
MINIKUBE=$(shell which minikube)
KUBECTL=$(shell which kubectl)
# KUBECONFIG ?= $(HOME)/.kube/config

###### TEST FOR TEKTON PIPELINE #######
expanded = "$(simple)"
simple := "foo"

clean:
	rm bar
	rm foo

foo: bar
	touch foo

bar:
	touch bar

all: foo

test:
  @echo lolnah

.PHONY: all clean test

.DEFAULT_GOAL: all
#######################################

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

## LOCAL DOCKER REGISTRY
docker-registry-up: ## Spin up a local docker registry
	@$(DOCKER) run -d -p 5000:5000 --restart=always --name registry registry:2
	@$(SLEEP) 2
	@$(CURL) -X GET http://localhost:5000/v2/_catalog

docker-registry-down: ## Delete the local docker registry
	@$(DOCKER) container stop registry
	@$(DOCKER) container rm -v registry

## MINIKUBE
mini-up: ## Spin up a dev cluster with Minikube
	@$(MINIKUBE) start --profile dev-cluster
	@$(KUBECTL) get ns

mini-dashboard: ## Enable minikube web dashboard
	@$(MINIKUBE) dashboard --url

mini-down: ## Delete the Minikube dev cluster
	@$(MINIKUBE) stop --profile dev-cluster
	@$(MINIKUBE) delete --profile dev-cluster

docker-pull-and-run-from-local: ## Pull the image from local registry and runs it
	@$(DOCKER) pull localhost:5000/app:v1
	@$(DOCKER) run -it --rm -p 8887:8887 localhost:5000/app:v1
