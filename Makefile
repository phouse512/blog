development:
	docker run --rm -p 4000:4000 --volume="${PWD}:/srv/jekyll" -it jekyll/jekyll:3 ./scripts/development.sh

build:
	docker run --volume="${PWD}:/srv/jekyll" -it jekyll/jekyll:3 ./scripts/build.sh

deploy: build
	docker run --rm --volume="${PWD}:/build" -it \
	-e AWS_ACCESS_KEY_ID=${PERSONAL_BLOG_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${PERSONAL_BLOG_ACCESS_KEY} \
	-e AWS_DEFAULT_REGION="us-east-2" \
	library/python:3.6 ./build/scripts/deploy.sh

spellcheck:
	./node_modules/.bin/spellchecker --files _posts/2020** --dictionaries dictionary.txt

