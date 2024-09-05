-- Create the database
CREATE DATABASE InstagramAnalysis;
USE InstagramAnalysis;

-- Create Users table
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    join_date DATE NOT NULL,
    membership_type VARCHAR(20) DEFAULT 'Free'
);

-- Create Posts table
CREATE TABLE Posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    post_date DATE NOT NULL,
    caption TEXT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Create Likes table
CREATE TABLE Likes (
    like_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT,
    user_id INT,
    like_date DATE NOT NULL,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Create Comments table
CREATE TABLE Comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT,
    user_id INT,
    comment_text TEXT,
    comment_date DATE NOT NULL,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Create Followers table
CREATE TABLE Followers (
    follower_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    follower_user_id INT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (follower_user_id) REFERENCES Users(user_id)
);

-- Create Memberships table
CREATE TABLE Memberships (
    membership_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    membership_type VARCHAR(20),
    start_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Insert sample data into Users table
INSERT INTO Users (username, join_date, membership_type) VALUES
('alice', '2024-08-01', 'Free'),
('bob', '2024-06-15', 'Premium'),
('carol', '2024-07-23', 'Free'),
('dave', '2024-05-30', 'Premium');

-- Insert sample data into Posts table
INSERT INTO Posts (user_id, post_date, caption) VALUES
(1, '2024-08-10', 'Enjoying a sunny day!'),
(2, '2024-08-15', 'Just got a new camera.'),
(3, '2024-08-20', 'Check out my latest artwork.'),
(4, '2024-08-25', 'Had a great meal tonight!');

-- Insert sample data into Likes table
INSERT INTO Likes (post_id, user_id, like_date) VALUES
(1, 2, '2024-08-11'),
(1, 3, '2024-08-12'),
(2, 1, '2024-08-16'),
(3, 4, '2024-08-21');

-- Insert sample data into Comments table
INSERT INTO Comments (post_id, user_id, comment_text, comment_date) VALUES
(1, 2, 'Looks awesome!', '2024-08-11'),
(2, 3, 'Can\'t wait to see the photos!', '2024-08-16'),
(3, 1, 'Amazing work!', '2024-08-22');

-- Insert sample data into Followers table
INSERT INTO Followers (user_id, follower_user_id) VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 1);

-- Insert sample data into Memberships table
INSERT INTO Memberships (user_id, membership_type, start_date) VALUES
(2, 'Premium', '2024-06-15'),
(4, 'Premium', '2024-05-30');

-- 1. Find all users who joined in the last 30 days
SELECT user_id, username, join_date
FROM Users
WHERE join_date >= CURDATE() - INTERVAL 30 DAY;

-- 2. Get the number of posts made by each user
SELECT u.user_id, u.username, COUNT(p.post_id) AS post_count
FROM Users u
LEFT JOIN Posts p ON u.user_id = p.user_id
GROUP BY u.user_id, u.username;

-- 3. List the most liked posts (top 5) along with the number of likes
SELECT p.post_id, p.caption, COUNT(l.like_id) AS like_count
FROM Posts p
LEFT JOIN Likes l ON p.post_id = l.post_id
GROUP BY p.post_id, p.caption
ORDER BY like_count DESC
LIMIT 5;

-- 4. Find users who have not posted in the last 60 days
SELECT u.user_id, u.username
FROM Users u
LEFT JOIN Posts p ON u.user_id = p.user_id
WHERE p.post_date IS NULL OR p.post_date < CURDATE() - INTERVAL 60 DAY
GROUP BY u.user_id, u.username;

-- 5. Calculate the average number of likes per post for each user
SELECT u.user_id, u.username, AVG(like_count) AS avg_likes_per_post
FROM Users u
LEFT JOIN (
    SELECT p.user_id, p.post_id, COUNT(l.like_id) AS like_count
    FROM Posts p
    LEFT JOIN Likes l ON p.post_id = l.post_id
    GROUP BY p.user_id, p.post_id
) AS post_likes ON u.user_id = post_likes.user_id
GROUP BY u.user_id, u.username;

-- 6. Find the top 10 users with the most followers
SELECT u.user_id, u.username, COUNT(f.follower_user_id) AS follower_count
FROM Users u
LEFT JOIN Followers f ON u.user_id = f.user_id
GROUP BY u.user_id, u.username
ORDER BY follower_count DESC
LIMIT 10;

-- 7. Determine the total number of comments on posts for each user
SELECT u.user_id, u.username, COUNT(c.comment_id) AS comment_count
FROM Users u
LEFT JOIN Posts p ON u.user_id = p.user_id
LEFT JOIN Comments c ON p.post_id = c.post_id
GROUP BY u.user_id, u.username;

-- 8. Get the list of users who are premium members and have made at least 5 posts
SELECT u.user_id, u.username
FROM Users u
JOIN Memberships m ON u.user_id = m.user_id
JOIN Posts p ON u.user_id = p.user_id
WHERE m.membership_type = 'Premium'
GROUP BY u.user_id, u.username
HAVING COUNT(p.post_id) >= 5;

-- 9. Calculate the total amount of likes earned by each user in the past month
SELECT u.user_id, u.username, SUM(like_count) AS total_likes
FROM Users u
LEFT JOIN (
    SELECT p.user_id, COUNT(l.like_id) AS like_count
    FROM Posts p
    LEFT JOIN Likes l ON p.post_id = l.post_id
    WHERE l.like_date >= CURDATE() - INTERVAL 30 DAY
    GROUP BY p.user_id
) AS recent_likes ON u.user_id = recent_likes.user_id
GROUP BY u.user_id, u.username;

-- 10. List the top 5 most commented posts and the number of comments
SELECT p.post_id, p.caption, COUNT(c.comment_id) AS comment_count
FROM Posts p
LEFT JOIN Comments c ON p.post_id = c.post_id
GROUP BY p.post_id, p.caption
ORDER BY comment_count DESC
LIMIT 5;