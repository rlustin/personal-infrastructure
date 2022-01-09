.PHONY: clean help terraform-plan-% terraform-apply-% playbook-% playbook-%-bootstrap terraform-init terraform-plan terraform-apply
.DEFAULT_GOAL := help

PLAYBOOKS := playbooks
ANSIBLE_COMMON_ROLES := roles/common
ANSIBLE_OPTS := -v
ANSIBLE_PLAYBOOK_CMD=poetry run ansible-playbook

playbook-%-bootstrap:  ## Bootstrap an instance. Replace '%' by the instance playbook you want to run
	@cd $(PLAYBOOKS) && ANSIBLE_ROLES_PATH=$(ANSIBLE_COMMON_ROLES):roles/$* ANSIBLE_CONFIG=./ansible-bootstrap.cfg $(ANSIBLE_PLAYBOOK_CMD) --ask-pass $*-bootstrap.yml $(ANSIBLE_OPTS)

playbook-%:  ## Configure an instance. Replace '%' by the instance playbook you want to run
	@cd $(PLAYBOOKS) && ANSIBLE_ROLES_PATH=$(ANSIBLE_COMMON_ROLES):roles/$* $(ANSIBLE_PLAYBOOK_CMD) $*.yml $(ANSIBLE_OPTS) $(target)

playbook-lint:  ## Lint role directories and playbook files
	@cd $(PLAYBOOKS) && \
	echo $$( $(FIND) roles/ -mindepth 2 -maxdepth 2 -type d && $(FIND) . -maxdepth 1 -name "*.yml") | xargs ansible-lint

terraform-%-plan:  ## Plan all terraform changes under the target directory %
	@cd terraform && cd $* && terraform plan

terraform-%-apply:  ## Apply all terraform changes under the target directory %
	@cd terraform && cd $* && terraform apply

terraform-init:  ## Initialize all terraform workspaces
	@cd terraform && \
	for dir in $$(find . -mindepth 1 -maxdepth 1 -type d | grep -v global_vars); do \
		cd $$dir && \
		echo "[+] Initializing $$dir" && \
		terraform init && \
		cd .. && \
		echo "\n"; \
	done

terraform-plan:  ## Plan all terraform workspaces
	@cd terraform && \
	for dir in $$(find . -mindepth 1 -maxdepth 1 -type d | grep -v global_vars); do \
		cd $$dir && \
		echo "[+] Planning $$dir" && \
		terraform plan && \
		cd .. && \
		echo "\n"; \
	done

terraform-apply:  ## Apply all terraform workspaces
	@cd terraform && \
	for dir in $$(find . -mindepth 1 -maxdepth 1 -type d | grep -v global_vars); do \
		cd $$dir && \
		echo "[+] Applying $$dir" && \
		terraform apply ; \
		cd .. && \
		echo "\n"; \
	done

clean:  ## Remove useless files
	@find . -name "*.retry" -or -name "*.tfstate.backup" | xargs rm
