# PictuRAS

<p align="center">
  <img src="https://github.com/user-attachments/assets/454b3e6d-e245-4e8c-801d-4d64a1e4582e" />
</p>

PictuRAS is a web app developed as part of the "Requisitos e Arquiteturas de Software" course for the academic year 2024/2025, as a part of the Software Engineering Master's Degree. Its main goal is to provide a powerful and easy to use image editing platform, with support for bulk editing, advanced AI-powered features and user accounts with different subscription levels.

The project used a microservices architecture, with services dedicated to project management, user/session management, tools and a gateway, with whom the frontend communicates.

## 📒 Features

### Dashboard

Where you can manage your projects and create new ones.

![Captura de Ecrã (12)](https://github.com/user-attachments/assets/8686c8e1-ba20-4da7-9e33-9bf1df81d8de)


### Edit Project View

![411017315-6cf475d2-5222-457e-b02d-51558fa1ddf5](https://github.com/user-attachments/assets/96971982-4b97-4bf1-a8ab-c05625be7a22)

### Share project

![share](https://github.com/user-attachments/assets/9edfc5d5-ec4f-4980-935a-60bb6df7b394)


### Authentication
![Untitled](https://github.com/user-attachments/assets/6a021909-8a16-4101-a374-7c8f225b59f5)

### Mobile View
![mobile](https://github.com/user-attachments/assets/9a602d6e-215b-4774-ba24-a8ff86ba7aaf)


## 🔨 Development

### Backend

The set up of all microservices can be set by doing the following:

1. Create a symbolic link to your docker compose (replace `OS` with your operating system):
   ```
   ln -s deployment/OS/docker-compose.yml docker-compose.yml
   ```
   Run: 
   ```
   docker-compose up -d
   ```

2. Allow direnv inside users and projects:

   ```
   direnv allow .
   ```

3. Copy the environment sample file inside both directories:

   ```
   cp .env.sample .env
   ```

4. Reset the database in Phoenix:

   ```
   mix ecto.reset
   ```

5. Start the Phoenix server:

   ```
   mix phx.server
   ```

6. If dependencies are missing, run:
   ```
   mix deps.get
   ```

### Frontend

To test locally run:

```
bun install
```

Then:

```
bun dev
```

## 🚀 Powered By

### Frontend

- [**Vue.js**](https://vuejs.org/)
- [**tailwindcss**](https://tailwindcss.com/)
- [**shadcn/ui**](https://ui.shadcn.com/)

### Backend

- [**Phoenix**](https://www.phoenixframework.org/)
- [**Elixir**](https://expressjs.com/)
- [**RabbitMQ**](https://www.rabbitmq.com/)

### API Client

- [**Bruno**](https://www.usebruno.com/)

### Deployment

- [**Docker**](https://www.docker.com/)

## 👥 Team

- José Correia (Frontend)
- Marta Rodrigues (Frontend)
- Ricardo Silva (Backend)
- Rui Lopes (Backend)
