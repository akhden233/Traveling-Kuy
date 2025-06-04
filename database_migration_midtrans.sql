-- Migration script to support Midtrans integration

-- Ensure 'status' column exists in orders table to track payment status
ALTER TABLE orders
ADD COLUMN IF NOT EXISTS status VARCHAR(50) NOT NULL DEFAULT 'pending';

-- Optional: Add column to store Midtrans transaction ID in orders table
ALTER TABLE orders
ADD COLUMN IF NOT EXISTS midtrans_transaction_id VARCHAR(100);

-- Optional: Create payments table if not exists to store payment details
CREATE TABLE IF NOT EXISTS payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  user_id INT NOT NULL,
  midtrans_transaction_id VARCHAR(100),
  payment_type VARCHAR(50),
  payment_status VARCHAR(50),
  payment_proof_url VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Optional: Remove legacy payment screenshot columns or tables if fully switching to Midtrans
-- DROP COLUMN IF EXISTS payment_screenshot_url ON payments;
