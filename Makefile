UTILS_PATH := build_utils
TEMPLATES_PATH := .

SERVICE_NAME := swag-anapi-v2
BUILD_IMAGE_TAG := 917afcdd0c0a07bf4155d597bbba72e962e1a34a

CALL_ANYWHERE := all install validate build java.compile java.deploy
CALL_W_CONTAINER := $(CALL_ANYWHERE)

all: validate

-include $(UTILS_PATH)/make_lib/utils_container.mk

.PHONY: $(CALL_W_CONTAINER)

install:
	npm install

validate:
	npm run validate

build:
	npm run build

# Java

ifdef SETTINGS_XML
DOCKER_RUN_OPTS = -v $(SETTINGS_XML):$(SETTINGS_XML)
DOCKER_RUN_OPTS += -e SETTINGS_XML=$(SETTINGS_XML)
endif

ifdef LOCAL_BUILD
DOCKER_RUN_OPTS += -v $$HOME/.m2:/home/$(UNAME)/.m2:rw
endif

COMMIT_HASH := $(shell git --no-pager log -1 --pretty=format:"%h")
NUMBER_COMMITS := $(shell git rev-list --count HEAD)

JAVA_PKG_VERSION := 1.$(NUMBER_COMMITS)-$(COMMIT_HASH)

ifdef BRANCH_NAME
ifeq "$(findstring epic,$(BRANCH_NAME))" "epic"
JAVA_PKG_VERSION := $(JAVA_PKG_VERSION)-epic
endif
endif

REPO_PROFILE := private

ifdef REPO_PUBLIC
ifeq REPO_PUBLIC "true"
REPO_PROFILE := public
endif
endif

MVN = mvn -s $(SETTINGS_XML) -Dcommit.number="$(NUMBER_COMMITS)"

java.openapi.compile_client: java.settings
	$(MVN) clean && \
	$(MVN) compile -P="client"

java.openapi.deploy_client: java.settings
	$(MVN) clean && \
	$(MVN) versions:set versions:commit -DnewVersion="$(JAVA_PKG_VERSION)-client" && \
	$(MVN) deploy -P="client,$(REPO_PROFILE)"

java.openapi.install_client: java.settings
	$(MVN) clean && \
    $(MVN) versions:set versions:commit -DnewVersion="$(JAVA_PKG_VERSION)-client" && \
    $(MVN) install -P="client"

java.openapi.compile_server: java.settings
	$(MVN) clean && \
	$(MVN) compile -P="server"

java.openapi.deploy_server: java.settings
	$(MVN) clean && \
	$(MVN) versions:set versions:commit -DnewVersion="$(JAVA_PKG_VERSION)-server" && \
	$(MVN) deploy -P="server,$(REPO_PROFILE)"

java.openapi.install_server: java.settings
	$(MVN) clean && \
    $(MVN) versions:set versions:commit -DnewVersion="$(JAVA_PKG_VERSION)-server" && \
    $(MVN) install -P="server"

java.compile: java.settings
	$(MVN) compile

java.deploy: java.settings
	$(MVN) versions:set versions:commit -DnewVersion="$(JAVA_PKG_VERSION)" && \
	$(MVN) deploy

java.install: java.settings
	$(MVN) clean && \
	$(MVN) versions:set versions:commit -DnewVersion="$(JAVA_PKG_VERSION)" && \
	$(MVN) install

java.settings:
	$(if $(SETTINGS_XML),, echo "SETTINGS_XML not defined"; exit 1)
