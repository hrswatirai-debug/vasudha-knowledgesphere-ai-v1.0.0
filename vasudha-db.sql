CREATE TABLE n8n_chat_history (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(255) NOT NULL,
    message JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE conversation_history (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) DEFAULT 'anonymous',
    message TEXT,
    role VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';

SELECT * FROM n8n_chat_history;

SELECT id, session_id, user_id, role, created_at
FROM conversation_history
ORDER BY id DESC LIMIT 5;

SELECT setval('conversation_history_id_seq', (SELECT MAX(id) FROM conversation_history));

SELECT MAX(id) FROM conversation_history;

ALTER SEQUENCE conversation_history_id_seq RESTART WITH 100;

-- Clean up bad row
DELETE FROM conversation_history WHERE id = 0;

-- Drop and recreate the id column fresh
ALTER TABLE conversation_history DROP COLUMN id;
ALTER TABLE conversation_history ADD COLUMN id SERIAL PRIMARY KEY;

-- Step 1: Drop the table completely
DROP TABLE conversation_history;

-- Step 2: Recreate it fresh
CREATE TABLE conversation_history (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) DEFAULT 'anonymous',
    message TEXT,
    role VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

DROP TABLE IF EXISTS conversation_history CASCADE;

CREATE TABLE conversation_history (
    id BIGSERIAL PRIMARY KEY,
    session_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) DEFAULT 'anonymous',
    message TEXT,
    role VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

SELECT * FROM conversation_history;

-- Add logging columns to conversation_history
ALTER TABLE conversation_history
  ADD COLUMN IF NOT EXISTS articles_retrieved TEXT,
  ADD COLUMN IF NOT EXISTS top_confidence FLOAT,
  ADD COLUMN IF NOT EXISTS retrieval_count INTEGER,
  ADD COLUMN IF NOT EXISTS request_time TIMESTAMP,
  ADD COLUMN IF NOT EXISTS response_time TIMESTAMP,
  ADD COLUMN IF NOT EXISTS processing_ms INTEGER;

SELECT id, session_id, left(message,50) as message,
       articles_retrieved, top_confidence, 
       retrieval_count, processing_ms,
       response_time
FROM conversation_history 
ORDER BY id DESC 
LIMIT 5;
  
CREATE TABLE IF NOT EXISTS rate_limits (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    request_time TIMESTAMP DEFAULT NOW()
);

-- Index for fast lookups
CREATE INDEX IF NOT EXISTS idx_rate_limits_user_time 
ON rate_limits(user_id, request_time);

SELECT user_id, COUNT(*) as total_requests,
       MIN(request_time) as first_request,
       MAX(request_time) as last_request
FROM rate_limits
GROUP BY user_id
ORDER BY total_requests DESC;

SELECT * FROM conversation_history;
SELECT * FROM n8n_chat_history;
SELECT * FROM rate_limits;


