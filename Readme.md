# Doc for the 3 tier app using docker compose
# 1. Create Database init script :
A database initialization script (init.sql or init-db.sh) is required because a freshly installed or newly spun-up PostgreSQL server is completely blank—it has no tables, no columns, no extensions, and no starter data.

# 2. Build Node.js appl tier :
Create package.json file with express and pg(node-postgres)
Create server.json with a DB health check endpoint and CRUD tasks
Create Dockerfile

# 3.Configure Nginx presentation and Reverse Proxy tier
Serves the UI on '/' and proxies /api/* to the backend node.js container
Create lightweight UI in nginx/index.html that communicates exclusively with /api/tasks and /api/health

# 4.Orchestrate with Docker Compose and Health checks
Create the docker-compose.yml in the docker (base directory)

Specify each service in seperate block under services block

Specify networks in network block -> A bridge network in Docker Compose is the default network driver that creates an isolated, internal virtual network on a single host, allowing containers to communicate with each other while remaining isolated from the host's external network.  When using Docker Compose, a custom user-defined bridge network is automatically created for the project (named <project>_default), enabling containers to resolve each other by service name via automatic DNS resolution, which eliminates the need for legacy --link flags or hardcoded IP addresses.

Specify volumes in volume block -> The Host filesystem connects to containers in two distinct ways—either through a Docker-managed volume box and directly to specific Host filesystem folders like /etc , /usr, /docker-entrypoint-initdb.d via Bind Mounts. 
  This means there are 2 types of volume mounts for containers : Volume Mounts , Bind Mounts
  * Named Volume Mounts : This will store the data from emphemeral container's volume to a persistence volume in thte host system.
  * Bind Mounts : This is a specific file system in host machine where 


# 5.Launch and Verify tier Isolation
Test reverse proxy routing, data persistence, and network segmentation using below commands
```bash
# 1. Build and start all three tiers in detached mode
docker compose up -d --build

# 2. Test the health endpoint through Nginx (Port 8080 -> Nginx -> Node.js -> Postgres)
curl -i http://localhost:8080/api/health

# 3. Create a task via the Nginx reverse proxy
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Test network isolation between tiers"}'

# 4. Verify Nginx CANNOT reach PostgreSQL directly (should fail to resolve host 'db')
docker exec tier3_nginx ping -c 1 db```


