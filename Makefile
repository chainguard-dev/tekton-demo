build:
	KO_DOCKER_REPO=ghcr.io/chainguard-dev ko build --image-refs=ko.images .

setup:
	./setup.sh

pipeline:
	kubectl apply -f config/common
	kubectl apply -f config/kind
	kubectl apply -f config/go

github_token:
	kubectl delete secret github-token || true
	@kubectl create secret generic github-token --from-literal=GITHUB_TOKEN="${GITHUB_TOKEN}" --namespace default

docker_secret:
	./docker-secret.sh
#	kubectl delete secret ghcr-secret || true
#	#@kubectl create secret docker-registry ghcr-secret --docker-server=ghcr.io --docker-username=strongjz --docker-password="${GITHUB_TOKEN}" --docker-email="strong.james.e@gmail.com"
#	kubectl annotate secret ghcr-secret tekton.dev/docker-0=ghcr.io
#	kubectl patch serviceaccount default -p "{\"imagePullSecrets\": [{\"name\": \"ghcr-secret\"}]}" -n default
run:
	 tkn pipeline start go-build-pipeline --use-pipelinerun go-build-pipeline-run

clean:
