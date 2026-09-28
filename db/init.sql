CREATE TABLE IF NOT EXISTS tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(120) NOT NULL,
    status VARCHAR(20) DEFAULT 'OPEN',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO tasks (title, status) VALUES
    ('Configure Nginx reverse proxy headers', 'DONE'),
    ('Verify PostgreSQL volume persistence', 'OPEN');
