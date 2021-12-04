CREATE USER test IDENTIFIED WITH mysql_native_password BY 'test-pass'
WITH MAX_QUERIES_PER_HOUR 100
PASSWORD EXPIRE INTERVAL 180 DAY FAILED_LOGIN_ATTEMPTS 3
ATTRIBUTE '{"lname": "Pretty", "fname": "James"}';

SHOW CREATE USER test;
SELECT plugin, authentication_string, password_lifetime, max_questions, User_attributes FROM mysql.user WHERE User = 'test'\G

GRANT SELECT ON test_db.* TO test;

SHOW GRANTS FOR test;

SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user = 'test'\G