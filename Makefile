build:
	KO_DOCKER_REPO=ghcr.io/chainguard-dev/tekton-dev ko build --image-refs=ko.images .

setup:
	./setup.sh

pipeline:
	HTTPS_PROXY=socks5://localhost:8118 kubectl apply -f config/common
	HTTPS_PROXY=socks5://localhost:8118 kubectl apply -f config/kind
	HTTPS_PROXY=socks5://localhost:8118 kubectl apply -f config/go

github_token:
	kubectl delete secret github-token || true
	@kubectl create secret generic github-token --from-literal=GITHUB_TOKEN="${GITHUB_TOKEN}" --namespace default

docker_secret:
	./docker-secret.sh

run:
	 HTTPS_PROXY=socks5://localhost:8118 tkn pipeline start go-build-pipeline --use-pipelinerun go-build-pipeline-run

clean:
