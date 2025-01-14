#working directory is the root of the android project
pwd=$(shell pwd)

#default local maven deployment path
maven_repo=$(HOME)/.m2

.PHONY : build tests dockerImage clean deployLocal bash setup all

build: setup
	docker run \
		-v $(pwd):/home/gradle/ \
		-w /home/gradle/ \
		android-build:android-gradle \
		gradle build
	
tests: setup
	docker run \
		-v $(pwd):/home/gradle/ \
		-w /home/gradle/ \
		android-build:android-gradle \
		run_connected_tests.sh

dockerImage:
	docker build \
		-t android-build:android-gradle \
		docker

clean:
	docker run \
		-v $(pwd):/home/gradle/ \
		-w /home/gradle/ \
		android-build:android-gradle \
		gradle clean

deployLocal: setup
	docker run \
		-v $(pwd):/home/gradle/ \
		-v $(maven_repo):/root/.m2/ \
		-w /home/gradle/ \
		android-build:android-gradle \
		gradle publishToMavenLocal

bash: setup
	docker run \
		-it \
		-v $(pwd):/home/gradle/ \
		-v $(maven_repo):/root/.m2/ \
		-w /home/gradle/ android-build:android-gradle \
		bash

setup: dockerImage

all: setup clean build deployLocal

