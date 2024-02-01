run:
	flutter run -d web-server

clean:
	flutter clean

build:
	flutter build web

docker-build:
	docker build . -t upsygma/jarvis

docker-run:
	docker run -p 8080:80 upsygma/jarvis

docker-push:
	docker push upsygma/jarvis:latest
