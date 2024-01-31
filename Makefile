clean:
	flutter clean

build: clean
	flutter build web

docker-build: build
	docker build . -t upsygma/jarvis

docker-run: docker-build
	docker run -p 8080:80 upsygma/jarvis

docker-push: docker-build
	docker push upsygma/jarvis:latest
