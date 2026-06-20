-- Reset all passwords to UM@2024 + force reset on next login (excludes ADMIN001)
UPDATE users SET
  password_hash = '$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe',
  must_reset_password = TRUE
WHERE code <> 'ADMIN001';
