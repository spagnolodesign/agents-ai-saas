# Chat Widget - Vue 3 + Vite

A simple, clean chat widget to test the Rails API.

## Setup

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

## Development

Using npm:
```bash
npm run dev
```

Or using yarn:
```bash
yarn dev
```

The app will run on `http://localhost:5173` and proxy API requests to `http://localhost:3000`.

## Build

Using npm:
```bash
npm run build
```

Or using yarn:
```bash
yarn build
```

## Configuration

Update the API URL in `src/App.vue` if your Rails server runs on a different port:

```javascript
apiUrl: 'http://localhost:3000/api/v1/chat'
```

## Features

- Clean, modern UI
- Real-time chat interface
- Conversation persistence (conversation_id)
- Loading states
- Error handling
- Responsive design

