build:
	KO_DOCKER_REPO=ghcr.io/chainguard-dev/tekton-dev ko build --image-refs=ko.images .

setup:
	./setup.sh

pipeline:
	HTTPS_PROXY=socks5://localhost:8118 kubectl apply -f config/common
	HTTPS_PROXY=socks5://localhost:8118 kubectl apply -f config/gcp
	HTTPS_PROXY=socks5://localhost:8118 kubectl apply -f config/go

docker_secret:
	./docker-secret.sh

run:
	 HTTPS_PROXY=socks5://localhost:8118 tkn pipeline start go-build-pipeline --use-pipelinerun go-build-pipeline-run

clean:
