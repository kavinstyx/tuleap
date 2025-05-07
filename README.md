# Tuleap with Git, Wiki, and Docman on CentOS 8

This repository contains a Docker setup for running Tuleap with Git, Wiki, and Docman plugins on CentOS 8.

## Prerequisites

- Docker installed on your system
- At least 4GB of RAM (8GB recommended)
- At least 10GB of free disk space

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/tuleap-docker.git
   cd tuleap-docker
   ```

2. Make the build script executable:
   ```bash
   chmod +x build.sh
   ```

3. Build and run the container:
   ```bash
   ./build.sh
   ```

4. Wait for the container to start (it may take a few minutes for all services to initialize).

5. Access Tuleap at: http://tuleap.local

## Getting Admin Credentials

After the container starts, you can retrieve the admin password with:

```bash
docker exec tuleap cat /root/.tuleap_passwd
```

## Accessing Tuleap

- **Web Interface**: http://tuleap.local
- **SSH Access**: Port 22 is exposed for Git operations
- **HTTPS**: https://tuleap.local (self-signed certificate by default)

## Data Persistence

All Tuleap data is stored in the `tuleap_data` directory in the project root. This includes:
- Database
- Git repositories
- Documents
- Configuration files

## Custom Configuration

You can customize the following environment variables in the `build.sh` script:

- `CONTAINER_NAME`: Name of the Docker container (default: tuleap)
- `TULEAP_IMAGE`: Name of the Docker image (default: tuleap:latest)
- `DATA_DIR`: Directory for persistent data (default: ./tuleap_data)
- `HOSTNAME`: Hostname for the Tuleap instance (default: tuleap.local)
- `DEFAULT_DOMAIN`: Default domain (default: localhost)
- `ORG_NAME`: Organization name (default: Tuleap)

## Stopping and Removing the Container

To stop the container:
```bash
docker stop tuleap
```

To remove the container (data will be preserved in the data directory):
```bash
docker rm tuleap
```

To completely remove the container and its data:
```bash
docker stop tuleap
docker rm tuleap
rm -rf tuleap_data/
```

## Troubleshooting

### View Logs

```bash
docker logs -f tuleap
```

### Access Container Shell

```bash
docker exec -it tuleap /bin/bash
```

### Common Issues

1. **Port Conflicts**: Ensure ports 80, 443, and 22 are not in use by other services.
2. **Insufficient Resources**: Tuleap requires at least 4GB of RAM to run smoothly.
3. **Slow Initialization**: First-time setup may take several minutes as it configures all services.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
# tuleap
