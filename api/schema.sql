-- PostgreSQL schema for Vilara website onboarding
-- Run this in the appdb database

-- Create signups table
CREATE TABLE IF NOT EXISTS signups (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    company_size VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    migration_type VARCHAR(20) NOT NULL DEFAULT 'fresh',
    token_hash VARCHAR(64) NOT NULL UNIQUE,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_signups_email ON signups(email);
CREATE INDEX IF NOT EXISTS idx_signups_token_hash ON signups(token_hash);
CREATE INDEX IF NOT EXISTS idx_signups_expires_at ON signups(expires_at);
CREATE INDEX IF NOT EXISTS idx_signups_used_at ON signups(used_at);

-- Create rate_limits table
CREATE TABLE IF NOT EXISTS rate_limits (
    id SERIAL PRIMARY KEY,
    ip_address VARCHAR(45) NOT NULL,
    endpoint VARCHAR(100) NOT NULL,
    request_count INT DEFAULT 1,
    window_start TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(ip_address, endpoint)
);

-- Create index for rate limit cleanup
CREATE INDEX IF NOT EXISTS idx_rate_limits_window_start ON rate_limits(window_start);

-- Grant permissions to appuser
GRANT ALL PRIVILEGES ON TABLE signups TO appuser;
GRANT ALL PRIVILEGES ON TABLE rate_limits TO appuser;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO appuser;