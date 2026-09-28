const express = require('express');
const { Pool } = require('pg');

const app = express();
app.use(express.json());

const pool = new Pool({
  host: process.env.DB_HOST || 'db',
  port: process.env.DB_PORT || 5432,
  user: process.env.POSTGRES_USER || 'appuser',
  password: process.env.POSTGRES_PASSWORD || 'secretpassword',
  database: process.env.POSTGRES_DB || 'trackerdb',
});

// Readiness / Health probe
app.get('/api/health', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW() AS db_time');
    res.status(200).json({ status: 'UP', db_time: result.rows[0].db_time });
  } catch (err) {
    res.status(500).json({ status: 'DOWN', error: err.message });
  }
});

// Fetch all tasks
app.get('/api/tasks', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM tasks ORDER BY id DESC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create a new task
app.post('/api/tasks', async (req, res) => {
  const { title } = req.body;
  if (!title) return res.status(400).json({ error: 'Title is required' });
  try {
    const { rows } = await pool.query(
      'INSERT INTO tasks (title) VALUES ($1) RETURNING *',
      [title]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`API server listening on port ${PORT}`);
});
