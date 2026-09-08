.DEFAULT_GOAL := help

.PHONY: help setup up create-aliases create-bucket config-replication replication-info replication-status down destroy

setup: up create-aliases create-bucket config-replication

help:
	@echo "Available commands:"
	@echo "  make setup                Setup MinIO and replication"
	@echo "  make up                   Start MinIO"
	@echo "  make create-aliases       Create MinIO aliases"
	@echo "  make create-bucket        Create test bucket"
	@echo "  make config-replication   Configure replication"
	@echo "  make replication-info     Show replication info"
	@echo "  make replication-status   Show replication status"
	@echo "  make buckets              List buckets"
	@echo "  make shell                Open shell in mc container"
	@echo "  make down                 Stop MinIO"
	@echo "  make destroy              Stop MinIO and remove volumes"

up:
	docker compose up -d
	sleep 10

create-aliases:
	docker exec mc mc alias set minio01 http://minio01:9000 admin minioadmin
	docker exec mc mc alias set minio02 http://minio02:9000 admin minioadmin

create-bucket:
	docker exec mc mc mb minio01/test
	docker exec mc sh -c 'echo "test" > /tmp/test.txt'
	docker exec mc mc cp /tmp/test.txt minio01/test/

config-replication:
	docker exec mc mc admin replicate add minio01 minio02

replication-info:
	docker exec mc mc admin replicate info minio01
	docker exec mc mc admin replicate info minio02

replication-status:
	docker exec mc mc admin replicate status minio01
	docker exec mc mc admin replicate status minio02

buckets:
	docker exec mc mc ls minio01/test
	docker exec mc mc ls minio02/test

shell:
	docker exec -it mc /bin/sh

down:
	docker compose down

destroy:
	docker compose down -v
