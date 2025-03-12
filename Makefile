# Docker build and run commands
.PHONY: build run

# Build the Docker image
build:
	docker build -t edk-examples .

# Run the Docker container with jupyter notebook
run:
	docker run -it --rm -p 8888:8888 edk-examples jupyter notebook --NotebookApp.default_url=/lab/ --ip=0.0.0.0 --port=8888