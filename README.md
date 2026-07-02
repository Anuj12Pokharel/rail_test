# Angelswing Development Test (Backend, Rails) - Extended

This repository implements the **Angelswing Backend Coding Test** using Ruby on Rails, Dockerized with PostgreSQL, JWT-based authentication, camelCase JSON parameter/response converters, and a full RSpec test suite.

## 🚀 Getting Started

The application is containerized, making it easy to build and run on any machine with Docker installed.

### Prerequisites
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

### 🛠️ Build and Start the Application

1. **Build and start the services (Rails Web & PostgreSQL DB)**:
   ```bash
   docker-compose up --build
   ```

2. **Set up the Database (create tables, run migrations)**:
   Open a separate terminal window and run:
   ```bash
   docker-compose run web bundle exec rails db:create db:migrate
   ```

The API will now be running and accessible at: **`http://localhost:3000/api/v1`**

---

## 🧪 Testing

The application includes unit tests for the `Content` model and integration/request tests for the `ContentsController` using **RSpec**.

### Running the Test Suite
To run the automated tests inside the Docker environment:
```bash
docker-compose run web bundle exec rspec
```

The test coverage covers:
- **Content Model**: Title presence validation, body presence validation, user association.
- **Content Controller / Requests**:
  - `GET /api/v1/content` (List all contents, return camelCase attributes, open to all).
  - `POST /api/v1/contents` (Create content for authenticated user, validate fields).
  - `PUT /api/v1/contents/:id` (Update content, enforce user ownership - returns `403 Forbidden` if unauthorized, update fields).
  - `DELETE /api/v1/contents/:id` (Delete content, enforce user ownership - returns `403 Forbidden` if unauthorized).
  - Proper responses and HTTP status codes for expected and unexpected cases.

---

## 📬 Postman Collection

The duplicated Postman Collection can be accessed and imported using this link:
👉 **[Duplicated Postman Collection Link](https://anujpokharel2engineer-3368495.postman.co/workspace/61104fd8-8fe0-405d-8e2a-07fe1dfacaac/collection/56337915-3c0ed417-9891-4949-984f-938a7dae360f?action=share&source=copy-link&creator=56337915)**

---

## 🛠️ Architecture & Technical Details

### 1. CamelCase/SnakeCase Converter (`CamelCaseHandler`)
To conform to the `camelCase` requirement in the Postman collection while keeping standard `snake_case` patterns in Rails, we implemented a custom controller concern:
- **Request parameters**: Intercepted in a `before_action :underscore_params!` callback where incoming parameter keys are deep-transformed into snake_case.
- **Response rendering**: Serialized hashes/arrays are parsed and their keys recursively camelized to `camelCase` using lower-camelization (`render_camel_json`).

### 2. JWT Authentication (`Authenticatable` & `JsonWebToken`)
- Upon sign-up (`POST /users/signup`) and sign-in (`POST /auth/signin`), a JSON Web Token is signed with the `user_id` payload and returned.
- Protected endpoints (`POST`, `PUT`, `DELETE` on content resources) require the JWT to be passed in the `Authorization: Bearer <token>` header.
- An authentication filter (`authenticate_user!`) decodes the token and retrieves the `current_user`. If missing or invalid, a `401 Unauthorized` response is returned.

### 3. Resource Routing
To align precisely with the Postman specification:
- Listing contents is mapped to the singular `/api/v1/content` path (`GET`).
- Editing, creating, and deleting are mapped to the plural `/api/v1/contents` paths (`POST`, `PUT`, `DELETE`).
- Both formats are gracefully configured in [routes.rb](file:///c:/Users/hp/rail_test/config/routes.rb).
