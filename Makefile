build:
	KO_DOCKER_REPO=ghcr.io/chainguard-customers ko build --image-refs=ko.images .

pipeline:
	kubectl apply -f config/common
