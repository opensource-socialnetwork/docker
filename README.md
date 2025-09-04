
# Open Source Social Network (OSSN) Docker Deployment

This repository contains a Docker setup to deploy [Open Source Social Network (OSSN)](https://www.opensource-socialnetwork.org/) with MySQL for the database and persistent storage for user data.

## Features
- **Dockerized OSSN**: Easily deploy the OSSN platform with a pre-configured Docker image.
- **MySQL Integration**: A dedicated MySQL container is included for managing the database.
- **Persistent Volumes**: User data and database storage are retained using Docker volumes.
- **Caddy Integration**: Recommended for handling HTTPS/TLS and as a reverse proxy for OSSN.

---

## Prerequisites
- Docker and Docker Compose installed on your system.
- A domain name (optional, if you want to configure HTTPS with Caddy).

---

## Usage

1. **Clone this repository**:
   ```bash
   git clone https://gitlab.com/nicolas.fournier/ossn-docker.git
   cd ossn-docker
   ```

2. **Update environment variables**:
   Review and update the database credentials and environment variables in `docker-compose.yml` as needed.

3. **Run the containers**:
   ```bash
   docker-compose up -d
   ```

4. **Access the application**:
   - Open your browser and go to `http://localhost:8080`.

---

## Using Caddy as a Reverse Proxy

Caddy is recommended to handle HTTPS and reverse proxy traffic to your OSSN container.

### Install Caddy
Follow the [official installation guide](https://caddyserver.com/docs/install) for your platform.

### Using Caddy Docker Proxy
For advanced Caddy integration in Docker, consider using the [Caddy Docker Proxy plugin](https://github.com/lucaslorentz/caddy-docker-proxy). This plugin automatically updates Caddy configurations based on your Docker services.

#### Installation
1. Pull the Caddy Docker Proxy image:
   ```bash
   docker pull lucaslorentz/caddy-docker-proxy:latest
   ```

2. Update your `docker-compose.yml` to include the Caddy service:
   ```yaml
   caddy:
     image: lucaslorentz/caddy-docker-proxy:latest
     container_name: caddy
     ports:
       - "80:80"
       - "443:443"
     volumes:
       - /var/run/docker.sock:/var/run/docker.sock
     restart: always
   ```

3. Add labels to your OSSN web service for automatic Caddy configuration:
   ```yaml
   web:
     image: registry.gitlab.com/nicolas.fournier/ossn-docker:latest
     labels:
       caddy: example.com
       caddy.reverse_proxy: "{{upstreams 80}}"
   ```

4. Restart your services:
   ```bash
   docker-compose up -d
   ```

---

## Customization

- **Persistent Volumes**: Data is stored in Docker volumes (`ossn_data` and `db_data`) to retain user and database information across restarts.
- **Environment Variables**: Adjust the environment variables in `docker-compose.yml` for database credentials or OSSN-specific paths.

---

## Troubleshooting

- **Web container fails to start**:
  Ensure the MySQL service is healthy and ready. Check logs with:
  ```bash
  docker-compose logs db
  ```

- **Caddy TLS setup**:
  If using a custom domain, ensure your DNS records point to your server's IP address.

---

## License

This project is licensed under the MIT License. OSSN is subject to its [own license](https://www.opensource-socialnetwork.org/license).

---

## References

- [OSSN Official Website](https://www.opensource-socialnetwork.org/)
- [Docker Documentation](https://docs.docker.com/)
- [Caddy Documentation](https://caddyserver.com/docs/)
- [Caddy Docker Proxy Plugin](https://github.com/lucaslorentz/caddy-docker-proxy)
