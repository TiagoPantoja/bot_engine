# Bot Engine - Real-Time Messaging & Webhook Dispatcher

## About The Project

Bot Engine is a high-performance, real-time messaging server designed to handle thousands of concurrent WebSocket connections. Built with Elixir and the Phoenix Framework, it acts as the central nervous system for chat rooms and bot integrations. It seamlessly routes real-time messages and dispatches external HTTP webhooks reliably in the background, ensuring zero latency degradation for connected users.

## Tech Stack

* **Language:** Elixir
* **Framework:** Phoenix
* **Database:** PostgreSQL
* **Background Jobs:** Oban
* **HTTP Client:** Req HTTP Client
* **Infrastructure:** Docker & Docker Compose

## Architectural Decisions

This project was built strictly adhering to Software Engineering best practices:

1.  **Domain-Driven Design (DDD):** Business logic is strictly isolated within the `BotEngine.Chat` Context. The WebSocket layer (`RoomChannel`) acts only as a dumb router, delegating persistence and validation to the domain.
2.  **Command Pattern via Pattern Matching:** Instead of complex classes or massive `switch` statements, Elixir's native pattern matching is used within `handle_in/3` callbacks to route incoming WebSocket commands efficiently.
3.  **Asynchronous Webhook Dispatching:** External HTTP requests are **never** executed synchronously within the WebSocket process. Instead, actions are queued via **Oban**. This guarantees that external API outages or latency spikes do not block the real-time chat infrastructure.
4.  **Exponential Backoff & Self-Healing:** Failed webhook deliveries are automatically retried by Oban with an exponential backoff strategy, leveraging the BEAM's "Let it crash" philosophy to maintain system stability.

## How to Run the Project

You can run this project fully containerized using Docker, or locally using the Elixir CLI.

### Option A: Fully Dockerized

The project includes a multi-stage `Dockerfile` that compiles an optimized Elixir Release.

1. Clone the repository and navigate to the project folder.
2. Build and start the containers in the background:
   ```bash
   docker compose up --build -d
   ```
3. The API and WebSocket server will be available at `ws://localhost:4000/socket`.

### Option B: Local Development

1. Start only the PostgreSQL database via Docker:
    ```bash
    docker compose up -d db
    ```
2. Install Elixir dependencies:
    ```bash
    mix deps.get
    ```
3. Create the database and run migrations (including Ecto and Oban setups):
    ```bash
    mix ecto.setup
    ```
4. Start the Phoenix server:
    ```bash
    mix phx.server
    ```

### How to Test the Endpoints

Since this is a Real-Time API, you will need a WebSocket client like Postman (WebSocket feature), Insomnia, or a CLI tool like `wscat`.

1. Connect to the Server

Establish a WebSocket connection to the endpoint:

- URL: `ws://localhost:4000/socket/websocket`

2. Join a Room

Once connected, send the following JSON payload to join a specific room (e.g., `room:lobby`):

    {
        "topic": "room:lobby",
        "event": "phx_join",
        "payload": {},
        "ref": "1"
    }

3. Send a Standard Message

To broadcast a message to everyone in the room:

    {
        "topic": "room:lobby",
        "event": "new_message",
        "payload": {
        "body": "Hello, everyone!"
        },
        "ref": "2"
    }

4. Trigger an External Webhook Action

To simulate a bot command that requires external API interaction (handled asynchronously by Oban):

    {
        "topic": "room:lobby",
        "event": "trigger_action",
        "payload": {
        "action": "send_alert",
        "payload": {"urgency": "high", "message": "Server CPU at 90%"}
        },
        "ref": "3"
    }

Check your terminal logs to see Oban processing the HTTP request in the background!


