.PHONY: build publish

IMAGE=confio/wasm-ci
TAG=0.27.0

build:
	docker build -t $(IMAGE):$(TAG) .
	docker tag $(IMAGE):$(TAG) $(IMAGE):latest

publish: build
	docker push $(IMAGE):$(TAG)