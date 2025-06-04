-- SQL to add ticket_url column to orders table
ALTER TABLE orders
ADD COLUMN ticket_url VARCHAR(255) NULL;

-- Alternatively, create a separate tickets table
-- CREATE TABLE tickets (
--   id INT AUTO_INCREMENT PRIMARY KEY,
--   order_id INT NOT NULL,
--   user_id INT NOT NULL,
--   ticket_url VARCHAR(255) NOT NULL,
--   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--   updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--   FOREIGN KEY (order_id) REFERENCES orders(id),
--   FOREIGN KEY (user_id) REFERENCES users(uid)
-- );
