NAME = aepifanov/pacemaker
VERSION = 0.0.1

SSH_PUB_KEY=~/.ssh/id_rsa.pub

.PHONY: help
help:
	@egrep "^# target:" [Mm]akefile | sort

# target: all             - Build image and tagged as latest
.PHONY: all
all: build tag_latest

# target: build           - Build image
.PHONY: build
build: ssh
	sudo docker build -t $(NAME):$(VERSION) --rm image

ssh:
	if [ -e $(SSH_PUB_KEY) ]; then cp -f $(SSH_PUB_KEY) image/ssh/; fi

.PHONY: test
test:
	env NAME=$(NAME) VERSION=$(VERSION) ./test/runner.sh

.PHONY: tag_latest
tag_latest:
	sudo docker tag -f $(NAME):$(VERSION) $(NAME):latest

release: test tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! head -n 1 Changelog.md | grep -q 'release date'; then echo 'Please note the release date in Changelog.md.' && false; fi
	sudo docker push $(NAME)
	@echo "*** Don't forget to create a tag. git tag rel-$(VERSION) && git push origin rel-$(VERSION)"

# target: dnsmasq_update  - Update dnsmasq
.PHONY: dnsmasq_update
dnsmasq_update:
	cd utils/ && sudo ./dnsmasq_update

# target: dnsmasq_install - Install dnsmasq
.PHONY: dnsmasq_install
dnsmasq_install:
	cd utils/ && sudo ./dnsmasq_install


# target: env             - Create env
.PHONY: env
env:
	cd utils/ && sudo ./env_create

# target: env_rm          - Remove env
.PHONY: env_rm
env_rm:
	cd utils/ && sudo ./env_remove
