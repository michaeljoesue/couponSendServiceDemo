# Money Transfer App

## Overview

The Money Transfer App is a web-based application designed to enable users to transfer points between accounts. This application consists of a frontend using React and a backend using Ruby on Rails, with SQLite database for data storage. Users can send points to other users.

## Required Versions

- **Ruby**: 3.2.2
- **Rails**: 7.1.2
- **Node.js**: 24
- **React**: 19

## Getting Started

Follow these steps to start this application using Docker Compose.

### Prerequisites

Make sure the following software is installed on your system:

- Docker
- Docker Compose

### Starting the Application

1. **Clone the repository**:

   ```bash
   git clone https://github.com/<your-username>/take-home-<id>.git
   cd take-home-<id>
   ```

2. **Build and start containers**:

   Run the following command to build and start Docker containers for both frontend and backend services.

   ```bash
   docker compose up --build
   ```

   This command will build and start the services defined in the `docker-compose.yml` file.

3. **Access the application**:

   Once the containers are running, the frontend serves on port 3000 and the backend API on port 8080 (`/api/accounts`, `/api/balances`).

When you start the application, the following features are enabled:

- Hot reloading is enabled. When you change the code, it will be automatically rebuilt and restarted.
- Database setup is performed automatically when the application starts.

### Stopping the Application

To stop the running containers, use the following command:

```bash
docker compose down
```
