# DET-on-docker

**DET-on-docker** is a Dockerized version of the **DET (Data Exfiltration Toolkit)**. This project simplifies running DET by avoiding compatibility issues, ensuring an easy and reliable setup within an isolated, containerized environment.

With this Docker setup, all dependencies are automatically installed, allowing for seamless execution of DET for penetration testing and security assessments.

## Prerequisites

To build and run this Docker image, ensure you have **Docker** installed on your system.

- **Docker**: Follow the installation instructions on the [official Docker website](https://docs.docker.com/get-docker/).

## How to Build and Run

### 1. Clone the repository

```bash
git clone https://github.com/your-username/DET-on-docker.git
cd DET-on-docker
```

### 2. Build the Docker image

Run the following command to build the Docker image. This will create a Docker image named `det-docker` based on the provided `Dockerfile`.

```bash
sudo docker build -t det-docker .
```

### 3. Run DET with the provided script `det.sh`

Once the image is built, you can use the `det.sh` script to run DET inside the Docker container. The script automates the container execution and allows you to pass necessary arguments to DET.

For example, to launch DET with a listener:

```bash
sudo ./det.sh -t listener -p 8080
```

### 4. Customization

Feel free to modify the `det.sh` script to include any additional arguments or configurations you need. Alternatively, you can run the container manually with Docker commands, giving you full flexibility for using DET.

## DET Project Reference

This project is based on the original [DET project](https://github.com/sensepost/DET) by [SensePost](https://github.com/sensepost). For more details, visit the original repository.

