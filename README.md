# Dockerized Laravel Project - Velzon

This project is a containerized Laravel application designed for easy local development and production-ready deployment. It uses Docker Compose to orchestrate the application and its database.

## 🚀 Getting Started

Follow these steps to get the project up and running on your local machine.

### Prerequisites

Ensure you have the following installed:
- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)

### 🛠️ Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd docker-sample-velzon
   ```

2. **Environment Configuration:**
   Copy the example environment file:
   ```bash
   cp .env.example .env
   ```
   *Note: The `docker-compose.yml` already contains default environment variables for local development, but Laravel still requires a `.env` file.*

3. **Build and Start the Containers:**
   Run the following command to build the image and start the services in the background:
   ```bash
   docker-compose up -d --build
   ```

4. **Install Dependencies (if not already handled by Docker):**
   The Dockerfile handles `composer install` and `npm install`, but if you need to run them manually within the container:
   ```bash
   docker-compose exec app composer install
   docker-compose exec app npm install
   ```

5. **Generate Application Key:**
   ```bash
   docker-compose exec app php artisan key:generate
   ```

6. **Run Database Migrations:**
   ```bash
   docker-compose exec app php artisan migrate
   ```

### 🌐 Accessing the Application

- **Web Application:** [http://localhost:8000](http://localhost:8000)
- **Vite (Hot Module Replacement):** [http://localhost:5173](http://localhost:5173)

### 🗄️ Database Connection

The project uses MySQL 8.0. You can connect to the database using the following credentials:
- **Host:** `localhost` (from your host machine) or `db` (from within the container)
- **Port:** `3306`
- **Database:** `laravel`
- **Username:** `root`
- **Password:** `root`

## 🛠️ Common Commands

- **Stop containers:** `docker-compose stop`
- **Down containers (removes network):** `docker-compose down`
- **View logs:** `docker-compose logs -f`
- **Run Artisan commands:** `docker-compose exec app php artisan <command>`
- **Run NPM commands:** `docker-compose exec app npm <command>`

## 📁 Project Structure

- `Dockerfile`: Defines the PHP 8.2 + Apache environment.
- `docker-compose.yml`: Orchestrates the `app` and `db` services.
- `docker-entrypoint.sh`: Handles cache clearing/caching based on the environment.
- `k8s-simulation.yaml`: Configuration for Kubernetes deployment simulation.

---
Built with ❤️ for scalable Laravel development.
