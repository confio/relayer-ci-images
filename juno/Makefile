.PHONY: build publish

IMAGE=confio/juno-ci
TAG=9.0.0

build:
	docker build -t $(IMAGE):$(TAG) .
	docker tag $(IMAGE):$(TAG) $(IMAGE):latest

publish: build
	docker push $(IMAGE):$(TAG)