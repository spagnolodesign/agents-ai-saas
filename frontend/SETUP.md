# Quick Setup Guide

## 1. Install Dependencies

Using npm:
```bash
cd frontend
npm install
```

Or using yarn:
```bash
cd frontend
yarn install
```

## 2. Start Rails Server

In the project root:

```bash
bundle exec rails server
```

Rails will run on `http://localhost:3000`

## 3. Start Vue Dev Server

In the `frontend` directory:

Using npm:
```bash
npm run dev
```

Or using yarn:
```bash
yarn dev
```

Vue will run on `http://localhost:5173`

## 4. Test the Chat

1. Open `http://localhost:5173` in your browser
2. Start chatting! The widget will call the Rails API

## Notes

- The Vite proxy is configured to forward `/api/*` requests to `http://localhost:3000`
- CORS is enabled for `localhost:5173` in Rails
- Make sure you have a workflow set up in Rails (use the rake task `rake api:chat:test` to see how to set one up)

