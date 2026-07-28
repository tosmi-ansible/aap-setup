.DEFAULT_GOAL := help

GALAXY_TOKEN_FILE := ./.ansible/galaxy_token
VAULT_SECRET_FILE := ./.ansible/vault_password

.PHONY:
prereq:
	mkdir -p ./.ansible

.PHONY:
tokens: prereq ## extract galaxy token
	pass show other/ansible/aws-aap-tokens | awk '/hub_token/ { printf "%s",$$2 }' > $(GALAXY_TOKEN_FILE)

.PHONY:
vaultsecret: prereq ## store vault secret in file for devcontainer
	pass show other/ansible/lab-vault > $(VAULT_SECRET_FILE)

.PHONY:
up: HUB_TOKEN = $(file < $(GALAXY_TOKEN_FILE))
up: tokens vaultsecret ## start the devcontainer

	$(info $(GALAXY_TOKEN_FILE))
	$(info $(HUB_TOKEN))

	-pkill -f 'ssh -i /Users/pinhead/.local/share/containers/podman/machine/machine.*-fN'
	podman machine ssh -- rm -f /tmp/ssh-agent.sock
	podman machine ssh -- -R /tmp/ssh-agent.sock:"$$SSH_AUTH_SOCK" -fN

	export ANSIBLE_GALAXY_SERVER_HUB_VALIDATED_TOKEN=$(HUB_TOKEN) \
	&& export ANSIBLE_GALAXY_SERVER_HUB_CERTIFIED_TOKEN=$(HUB_TOKEN) \
	&& export ANSIBLE_GALAXY_SERVER_HUB_COMMUNITY_TOKEN=$(HUB_TOKEN) \
	&& devcontainer up

.PHONY:
down: clean ## stop and remove the devcontainer
	-pkill -f 'ssh -i /Users/pinhead/.local/share/containers/podman/machine/machine.*-fN'
	podman kill aap-setup-devcontainer
	podman rm aap-setup-devcontainer
	podman machine ssh -- rm -f /tmp/ssh-agent.sock \

.PHONY:
clean: ## remove secrets
	rm -f $(GALAXY_TOKEN_FILE)
	rm -f $(VAULT_SECRET_FILE)

# Help and Documentation
.PHONY: help
help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk '/^[a-zA-Z\-_0-9%]+:/ { \
	        helpMessage = match($$0, /^([^:]+):[^#]*## (.+)/); \
	        if (helpMessage) { \
	                helpCommand = substr($$0, 1, index($$0, ":")-1); \
	                helpMessage = substr($$0, index($$0, "##") + 3); \
	                printf "  %-20s %s\n", helpCommand, helpMessage; \
	        } \
	}' $(MAKEFILE_LIST) | sort
