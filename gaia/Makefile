.PHONY: build publish

IMAGE=confio/gaia-ci
TAG=7.0.1

build:
	docker build -t $(IMAGE):$(TAG) .
	docker tag $(IMAGE):$(TAG) $(IMAGE):latest

publish: build
	docker push $(IMAGE):$(TAG)