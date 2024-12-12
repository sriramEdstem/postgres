CREATE TABLE "User" (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    emailVerified TIMESTAMP
);


CREATE TABLE "Bookmark" (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    url TEXT NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    userId INTEGER REFERENCES "User"(id),
    collectionId INTEGER
);


CREATE TABLE "Collection" (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    userId INTEGER REFERENCES "User"(id) NOT NULL
);



CREATE TABLE "CollectionShare" (
    id SERIAL PRIMARY KEY,
    collectionId INT REFERENCES "Collection"(id) NOT NULL,
    userId  INTEGER REFERENCES "User"(id) NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "Tags" (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL UNIQUE
);


CREATE TABLE "BookmarkTags" (
	id SERIAL PRIMARY KEY,
	bookmarkId INTEGER REFERENCES "Bookmark"(id) NOT NULL,
	tagId INT references "Tags"(id) NOT NULL
);



INSERT INTO "User" (name, email, emailVerified)
VALUES
    ('Cristiano Ronaldo', 'ronaldo@gmail.com', '2002-01-01 02:00:01'),
    ('Messi', 'messi@gmail.com', '2013-01-01 03:00:00'),
    ('Pele', 'pele@gmail.com', '2012-01-01 13:00:00'),
    ('Rooney', 'rooney@gmail.com', '2000-01-01 12:01:22');
	
	INSERT INTO "Bookmark" (title, url , userId, collectionId)
VALUES
    ('Google', 'https://www.google.com', 1, 1),
    ('Stack Overflow', 'https://stackoverflow.com', 1, 1),
    ('GitHub', 'https://github.com',  2, 2),
    ('Amazon', 'https://www.amazon.com',  3, 3),
    ('Facebook', 'https://www.facebook.com',  4, 4);
	
	INSERT INTO "Collection" (name, description, userId)
VALUES
    ('Development Resources', 'A collection of bookmarks related to development', 1),
    ('Productivity Tools', 'A collection of bookmarks related to productivity', 2),
    ('Shopping', 'A collection of bookmarks related to shopping', 3),
    ('Social Media', 'A collection of bookmarks related to social media', 4);
	
	INSERT INTO "CollectionShare" (collectionId, userId)
VALUES
    (1, 2),
    (1, 3),
    (2, 1),
    (2, 4),
    (3, 1),
    (3, 2),
    (4, 1),
    (4, 3);
	
	INSERT INTO "Tags" (name)
VALUES
    ('search'),
    ('engine'),
    ('programming'),
    ('version'),
    ('control'),
    ('shopping');
	
	
	INSERT INTO "BookmarkTags" (bookmarkId, tagId)
VALUES
    (1, 1),
    (1, 2),
    (2, 3),
    (2, 4),
    (3, 5),
    (3, 6),
    (4, 1),
    (4, 2),
    (5, 3),
    (5, 4);


--Question 1. Find all bookmarks in a collection:
SELECT b.title, b.url, c.name, t.name
FROM "Bookmark" b
JOIN "Collection" c ON b.collectionId = c.id
JOIN "BookmarkTags" bt ON b.id = bt.bookmarkId
JOIN "Tags" t ON bt.tagId = t.id
WHERE c.name = 'Development Resources';

--question 2. Most used tags: 
SELECT t.name, COUNT(bt.id) AS usage_count
FROM "Tags" t
JOIN "BookmarkTags" bt ON t.id = bt.tagId
GROUP BY t.name
ORDER BY usage_count DESC
LIMIT 10;

--question 3. Collection sharing analysis
SELECT 
  c.name AS collectionName ,
  u.name AS userName, 
  u.email, 
  COUNT(b.id) AS num_bookmarks, 
  COUNT(cs.id) AS num_shared_users
FROM "Collection" c
JOIN "User" u ON c.userId = u.id
LEFT JOIN "Bookmark" b ON c.id = b.collectionId
LEFT JOIN "CollectionShare" cs ON c.id = cs.collectionId
GROUP BY c.name, u.name, u.email
HAVING COUNT(cs.id) > 0;


--question 4. User engagement 
SELECT 
  u.name, 
  u.email, 
  COUNT(b.id) AS num_bookmarks_created, 
  COUNT(cs.id) AS num_collections_shared
FROM "User" u
JOIN "Bookmark" b ON u.id = b.userId
JOIN "CollectionShare" cs ON u.id = cs.userId
WHERE b.createdAt > NOW() - INTERVAL '30 days'
AND cs.createdAt > NOW() - INTERVAL '30 days'
GROUP BY u.name, u.email
ORDER BY num_collections_shared DESC;


