development:
	docker run --rm -p 4000:4000 --volume="${PWD}:/srv/jekyll" -it jekyll/jekyll ./scripts/development.sh

build:
	docker run --volume="${PWD}:/srv/jekyll" -it jekyll/jekyll ./scripts/build.sh

deploy: build
	docker run --rm --volume="${PWD}:/srv/jekyll" -it mesosphere/aws-cli \
	-e AWS_ACCESS_KEY_ID="nice" \
	-e AWS_SECRET_ACCESS_KEY="noice" \
	-e AWS_DEFAULT_REGION="us-east-2" ./aws.sh s3 sync /srv/jekyll/_site s3://phizzle.space
