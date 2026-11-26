-- Smart Campus Marketplace Database Schema
-- Database Name: campus_marketplace

CREATE DATABASE IF NOT EXISTS campus_marketplace;
USE campus_marketplace;

-- Disable foreign key checks for clean recreation
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS exchange_requests;
DROP TABLE IF EXISTS negotiation_messages;
DROP TABLE IF EXISTS negotiations;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS wishlist;
DROP TABLE IF EXISTS cart_items;
DROP TABLE IF EXISTS product_images;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

-- 1. USERS TABLE
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    college_name VARCHAR(150) NOT NULL,
    campus_location VARCHAR(100) NOT NULL,
    phone_number VARCHAR(30) NULL,
    avatar_url VARCHAR(500) NULL,
    bio TEXT NULL,
    role ENUM('student', 'admin') DEFAULT 'student',
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_email (email),
    INDEX idx_user_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. CATEGORIES TABLE
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL UNIQUE,
    slug VARCHAR(80) NOT NULL UNIQUE,
    icon VARCHAR(50) NULL,
    description VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. PRODUCTS TABLE
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT NOT NULL,
    category_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    original_price DECIMAL(10,2) NULL,
    condition_state ENUM('New', 'Like New', 'Good', 'Fair') NOT NULL DEFAULT 'Good',
    status ENUM('available', 'sold', 'reserved', 'inactive') NOT NULL DEFAULT 'available',
    exchange_available TINYINT(1) DEFAULT 0,
    preferred_exchange VARCHAR(255) NULL,
    campus_location VARCHAR(100) NOT NULL,
    contact_info VARCHAR(100) NULL,
    views_count INT DEFAULT 0,
    primary_image VARCHAR(500) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
    INDEX idx_product_status (status),
    INDEX idx_product_category (category_id),
    INDEX idx_product_seller (seller_id),
    INDEX idx_product_exchange (exchange_available)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. PRODUCT IMAGES TABLE
CREATE TABLE product_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    is_primary TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_image_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. CART ITEMS TABLE
CREATE TABLE cart_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_product (user_id, product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. WISHLIST TABLE
CREATE TABLE wishlist (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY uk_wishlist_user_product (user_id, product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. ORDERS TABLE
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_code VARCHAR(50) NOT NULL UNIQUE,
    buyer_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    pickup_location VARCHAR(150) NOT NULL,
    contact_phone VARCHAR(30) NOT NULL,
    delivery_type ENUM('Campus Pickup', 'Hostel Delivery', 'Library Meetup') DEFAULT 'Campus Pickup',
    payment_method ENUM('Cash on Pickup', 'UPI Simulation', 'Demo Payment') DEFAULT 'Cash on Pickup',
    payment_status ENUM('Pending', 'Paid', 'Completed') DEFAULT 'Pending',
    order_status ENUM('Placed', 'Confirmed', 'Ready for Pickup', 'Completed', 'Cancelled') DEFAULT 'Placed',
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE RESTRICT,
    INDEX idx_orders_buyer (buyer_id),
    INDEX idx_orders_status (order_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. ORDER ITEMS TABLE
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    seller_id INT NOT NULL,
    price_at_purchase DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE RESTRICT,
    INDEX idx_order_items_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. NEGOTIATIONS (PRICE OFFERS) TABLE
CREATE TABLE negotiations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    buyer_id INT NOT NULL,
    seller_id INT NOT NULL,
    original_price DECIMAL(10,2) NOT NULL,
    current_offered_price DECIMAL(10,2) NOT NULL,
    status ENUM('Pending', 'Accepted', 'Rejected', 'Countered', 'Expired') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_nego_buyer (buyer_id),
    INDEX idx_nego_seller (seller_id),
    INDEX idx_nego_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. NEGOTIATION MESSAGES / COUNTER OFFERS TABLE
CREATE TABLE negotiation_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    negotiation_id INT NOT NULL,
    sender_id INT NOT NULL,
    sender_type ENUM('buyer', 'seller') NOT NULL,
    offered_price DECIMAL(10,2) NOT NULL,
    message VARCHAR(500) NULL,
    action_type ENUM('offer', 'counter', 'accept', 'reject') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (negotiation_id) REFERENCES negotiations(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. PRODUCT EXCHANGE REQUESTS TABLE
CREATE TABLE exchange_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    requester_id INT NOT NULL,
    target_seller_id INT NOT NULL,
    requested_product_id INT NOT NULL,
    offered_product_id INT NOT NULL,
    message TEXT NULL,
    status ENUM('Pending', 'Accepted', 'Rejected', 'Cancelled', 'Completed') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (requester_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (target_seller_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (requested_product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (offered_product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_exch_requester (requester_id),
    INDEX idx_exch_target (target_seller_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. NOTIFICATIONS TABLE
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    message VARCHAR(500) NOT NULL,
    link VARCHAR(255) NULL,
    is_read TINYINT(1) DEFAULT 0,
    type ENUM('offer', 'exchange', 'order', 'system') DEFAULT 'system',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_notif_user (user_id, is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 13. REVIEWS TABLE
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    reviewer_id INT NOT NULL,
    seller_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Categories
INSERT INTO categories (id, name, slug, icon, description) VALUES
(1, 'Books', 'books', 'BookOpen', 'Engineering textbooks, novels, notes and reference guides'),
(2, 'Electronics', 'electronics', 'Monitor', 'Laptops, monitors, headphones, keyboards and tech gear'),
(3, 'Lab Equipment', 'lab-equipment', 'FlaskConical', 'Lab coats, Vernier calipers, dissection sets, and electrical breadboards'),
(4, 'Stationery', 'stationery', 'PenTool', 'Geometry boxes, drawing sheets, drafting pens, and premium notebooks'),
(5, 'Calculators', 'calculators', 'Calculator', 'Scientific and financial calculators (Casio fx-991EX, Texas Instruments)'),
(6, 'Accessories', 'accessories', 'Backpack', 'Backpacks, ergonomic laptop stands, desk organizers and LED study lamps'),
(7, 'Sports Equipment', 'sports-equipment', 'Trophy', 'Badminton rackets, basketballs, footballs, and gym equipment'),
(8, 'Other', 'other', 'Layers', 'Campus bicycles, electric kettles, dorm fans, and musical instruments');

-- Users
INSERT INTO users (id, full_name, email, password_hash, college_name, campus_location, phone_number, avatar_url, bio, role) VALUES
(1, 'Campus Admin', 'admin@campuscart.edu', '$2a$10$Q7y0r7v8fC8NfG.9T/t6f.dZgEKnwzZqCgPjJpZJqI3iH2cQ5.8aG', 'National Institute of Technology', 'Admin Block, North Campus', '+91 9876543210', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80', 'CampusCart Marketplace Administrator', 'admin'),
(2, 'Aarav Sharma', 'aarav.sharma@campus.edu', '$2a$10$Q7y0r7v8fC8NfG.9T/t6f.dZgEKnwzZqCgPjJpZJqI3iH2cQ5.8aG', 'Engineering College of Technology', 'Hostel Block 4, South Campus', '+91 9876501234', 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=200&q=80', 'Final year CS undergrad. Selling textbooks and electronics.', 'student'),
(3, 'Priya Patel', 'priya.patel@campus.edu', '$2a$10$Q7y0r7v8fC8NfG.9T/t6f.dZgEKnwzZqCgPjJpZJqI3iH2cQ5.8aG', 'University School of Medicine & Tech', 'East Wing Dorms, Medical Campus', '+91 9876505678', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80', 'Bio-engineering junior. Open to textbook and calculator exchanges.', 'student'),
(4, 'Rohit Verma', 'rohit.verma@campus.edu', '$2a$10$Q7y0r7v8fC8NfG.9T/t6f.dZgEKnwzZqCgPjJpZJqI3iH2cQ5.8aG', 'Institute of Design & Technology', 'West Campus, Studio Block', '+91 9876509988', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80', 'Mechanical Engg 3rd year. Looking to negotiate reasonably.', 'student'),
(5, 'Ananya Singh', 'ananya.singh@campus.edu', '$2a$10$Q7y0r7v8fC8NfG.9T/t6f.dZgEKnwzZqCgPjJpZJqI3iH2cQ5.8aG', 'School of Physical Sciences', 'Central Campus, Girls Hostel B', '+91 9876504321', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80', 'Physics major. Always willing to exchange lab gear.', 'student');

-- Products
INSERT INTO products (id, seller_id, category_id, title, description, price, original_price, condition_state, status, exchange_available, preferred_exchange, campus_location, contact_info, views_count, primary_image) VALUES
(1, 2, 1, 'Engineering Mathematics by B.S. Grewal (44th Ed.)', 'Higher Engineering Mathematics 44th Edition in pristine condition. No highlighted pages, clean binding. Essential for Sem 1 to Sem 4 across all engineering disciplines.', 450.00, 850.00, 'Like New', 'available', 1, 'Data Structures or Algorithm Textbook', 'North Campus, Library Lawn', 'aarav.sharma@campus.edu', 142, 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=800&q=80'),
(2, 3, 5, 'Casio fx-991EX ClassWiz Scientific Calculator', 'High-resolution LCD scientific calculator with spreadsheet, matrix and equation solver functions. Allowed in university examinations. Comes with original protective slide-on hard case.', 850.00, 1495.00, 'Like New', 'available', 1, 'Scientific graphing calculator or Arduino Kit', 'Medical Campus, East Wing', '+91 9876505678', 215, 'https://images.unsplash.com/photo-1587145820266-a5951ee6f620?auto=format&fit=crop&w=800&q=80'),
(3, 4, 2, 'Arduino Uno R3 Ultimate Starter Kit with Sensors', 'Complete Arduino Uno Starter kit including breadboard, jumper wires, ultrasonic sensor, RFID module, 1602 LCD, servo motor, and step motors. Perfect for IoT & robotics projects.', 1200.00, 2400.00, 'Good', 'available', 1, 'Raspberry Pi 3/4 or mechanical keyboard', 'West Campus, Mech Lab', 'rohit.verma@campus.edu', 189, 'https://images.unsplash.com/photo-1553406830-ef2513450d76?auto=format&fit=crop&w=800&q=80'),
(4, 2, 2, 'Boat Rockerz 450 Wireless Bluetooth Headphones', '40mm dynamic drivers, up to 15 hours playback, plush padded ear cushions. Working perfectly, minor scuff on left headband. Comes with micro-USB charging cable.', 650.00, 1499.00, 'Good', 'available', 0, NULL, 'Hostel 4, South Campus', '+91 9876501234', 98, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80'),
(5, 5, 3, 'Pure Cotton White Lab Coat (Size 38 / M)', 'Full-sleeve unisex laboratory coat with two deep front pockets and chest pocket. 100% thick pre-shrunk cotton. Washed and sanitized, no chemical stains.', 280.00, 600.00, 'Like New', 'available', 0, NULL, 'Girls Hostel B, Central Campus', 'ananya.singh@campus.edu', 74, 'https://images.unsplash.com/photo-1584017911766-d451b3d0e843?auto=format&fit=crop&w=800&q=80'),
(6, 4, 4, 'Staedtler Mars Professional Engineering Mini Drafter & Set', 'Heavy duty engineering mini drafter with steel clamp and dual protractor scales. Includes drawing tube, 0.5mm mechanical pencils and clutch pencil.', 550.00, 1100.00, 'Good', 'available', 1, 'Calculus textbook or drawing board', 'West Campus, Studio Block', 'rohit.verma@campus.edu', 130, 'https://images.unsplash.com/photo-1585776245991-cf89dd7fc73a?auto=format&fit=crop&w=800&q=80'),
(7, 3, 6, 'Adjustable Aluminium Ergonomic Laptop Stand', 'Foldable 6-level height adjustable laptop riser. Sturdy aluminum alloy with silicone anti-slip pads. Fits laptops from 10 to 15.6 inches. Great for dorm desk posture.', 420.00, 899.00, 'New', 'available', 0, NULL, 'Medical Campus, Room 204', 'priya.patel@campus.edu', 165, 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?auto=format&fit=crop&w=800&q=80'),
(8, 2, 2, 'Redragon K552 RGB Mechanical Gaming Keyboard', 'Compact 87-key tenkeyless mechanical keyboard with dust-proof Outemu Red linear switches. Molded keycaps, solid metal base, adjustable backlighting.', 1400.00, 2899.00, 'Like New', 'available', 1, 'Wireless mouse or ergonomic desk chair', 'North Campus, Library Steps', 'aarav.sharma@campus.edu', 240, 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=800&q=80'),
(9, 5, 1, 'Introduction to Algorithms (CLRS 3rd Edition)', 'The MIT Press classic algorithms bible by Cormen, Leiserson, Rivest, Stein. Softcover international edition. Clean, crisp pages with no ink markings.', 800.00, 1600.00, 'Good', 'available', 1, 'Operating Systems Concepts (Galvin)', 'Central Campus, Physics Dept', 'ananya.singh@campus.edu', 310, 'https://images.unsplash.com/photo-1532012164546-f432f2e3777a?auto=format&fit=crop&w=800&q=80'),
(10, 3, 1, 'Data Structures and Algorithms Made Easy - N. Karumanchi', 'Fifth edition of the popular coding interview prep book. Comprehensive explanations of recursion, trees, graphs, and dynamic programming.', 400.00, 750.00, 'Like New', 'available', 0, NULL, 'East Wing, Medical Campus', 'priya.patel@campus.edu', 210, 'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=800&q=80'),
(11, 4, 3, 'Mitutoyo Style Digital Vernier Caliper (0-150mm)', 'Stainless steel electronic digital caliper with high precision LCD display. Measures internal, external, depth, and step dimensions in mm and inches. Battery included.', 650.00, 1300.00, 'Like New', 'available', 1, 'Analog multimeter or micrometer screw gauge', 'West Campus, Mech Workshop', 'rohit.verma@campus.edu', 88, 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=800&q=80'),
(12, 2, 7, 'Yonex Nanoray 7000I Badminton Racket + Cover', 'Graphite shaft badminton racket with factory string tension at 24 lbs. Lightweight, fast swing speed. Includes full cover bag and 3 plastic shuttlecocks.', 750.00, 1600.00, 'Good', 'available', 0, NULL, 'South Campus Sports Complex', 'aarav.sharma@campus.edu', 115, 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=800&q=80'),
(13, 5, 7, 'Spalding NBA Street Outdoor Basketball (Size 7)', 'Durable performance rubber cover basketball designed for outdoor concrete and asphalt courts. Deep channel design for superior finger grip and control.', 550.00, 1200.00, 'Good', 'available', 1, 'Football or gym dumbbells', 'Central Campus Playground', 'ananya.singh@campus.edu', 92, 'https://images.unsplash.com/photo-1519861531473-9200262188bf?auto=format&fit=crop&w=800&q=80'),
(14, 3, 8, 'Hero Hawk 21-Speed Hybrid Campus Bicycle', 'Rigid steel frame, front and rear disc brakes, Shimano 21-speed thumb shifters. Ideal for daily commuting across large campuses. Serviced recently, tires in great shape.', 3200.00, 7500.00, 'Good', 'available', 0, NULL, 'Medical Campus Parking Bay 2', '+91 9876505678', 410, 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?auto=format&fit=crop&w=800&q=80'),
(15, 4, 8, 'Havells 1.2L Stainless Steel Electric Kettle', 'Cordless 360-degree rotational base electric kettle with auto cut-off protection and concealed heating element. Essential for late-night hostel tea and noodles.', 600.00, 1250.00, 'Like New', 'available', 0, NULL, 'Hostel 3, West Campus', 'rohit.verma@campus.edu', 178, 'https://images.unsplash.com/photo-1594213114663-ddf4f240f08d?auto=format&fit=crop&w=800&q=80'),
(16, 2, 6, 'American Tourister 32L Water-Resistant Laptop Backpack', 'Spacious 3-compartment college backpack with padded 15.6 inch laptop sleeve, bottle holders, and rain cover. Clean condition with sturdy zippers.', 850.00, 1990.00, 'Good', 'available', 1, 'Gym duffle bag or messenger bag', 'North Campus, Student Canteen', 'aarav.sharma@campu
