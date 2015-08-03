NAME = aepifanov/pacemaker
VERSION = 0.0.1

SSH_PUB_KEY=~/.ssh/id_rsa.pub

.PHONY: all build test tag_latest release ssh dnsmasq dnsmasq_install

all: build tag_latest

build:
	docker build -t $(NAME):$(VERSION) --rm image

test:
	env NAME=$(NAME) VERSION=$(VERSION) ./test/runner.sh

tag_latest:
	docker tag -f $(NAME):$(VERSION) $(NAME):latest

release: test tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! head -n 1 Changelog.md | grep -q 'release date'; then echo 'Please note the release date in Changelog.md.' && false; fi
	docker push $(NAME)
	@echo "*** Don't forget to create a tag. git tag rel-$(VERSION) && git push origin rel-$(VERSION)"

ssh:
	if [ -e $(SSH_PUB_KEY) ]; then cp -f $(SSH_PUB_KEY) image/ssh/; fi

dnsmasq:
	cd dnsmasq_utils/ && sudo ./update && cd -

dnsmasq_install:
	cd dnsmasq_utils/ && sudo ./install && cd -
