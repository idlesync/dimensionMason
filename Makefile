install:
	npm install && ./node_modules/.bin/bower install --config.interactive=false

clean:
	rm -rf node_modules
	rm -rf bower_components
	rm -rf public/*

watch:
	./node_modules/.bin/grunt live --force

build:
	./node_modules/.bin/grunt build

deploy:
	./node_modules/.bin/grunt deploy
