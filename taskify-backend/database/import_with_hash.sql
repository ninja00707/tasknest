-- Auto-generated import for 246 employees
BEGIN;

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Naveed Akhtar', 'muhammadnaveedakhtar@um.com.pk', '10000317', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 50, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadnaveedakhtar@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Rashid Ali', 'rashidaliflow@um.com.pk', '10000318', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 50, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'rashidaliflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Ghulam Abbas', 'ghulamabbas@um.com.pk', '10000319', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 50, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'ghulamabbas@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Imran', 'imran@um.com.pk', '10000320', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 50, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'imran@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Amir Abbas', 'amirabbas@um.com.pk', '10000321', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 50, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'amirabbas@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Majid Hussain', 'majidhussainflow@um.com.pk', '10000324', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 50, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'majidhussainflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Nasir Khan', 'nasirflow.@um.com.pk', '10000322', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 50, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'nasirflow.@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Shafqat Hussain', 'shafqathussain@um.com.pk', '10000323', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 50, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'shafqathussain@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Adeel Shahzad Gill', 'adeelshahzadgillflow@um.com.pk', '10000327', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 50, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'adeelshahzadgillflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Asghar', 'asgharflow.@um.com.pk', '10000869', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 50, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'asgharflow.@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Farooq Masih', 'farooqmasihflow@um.com.pk', '10000329', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 50, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'farooqmasihflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Lal Victor', 'lalvictorflow@um.com.pk', '10000328', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 50, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'lalvictorflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Rafaqat Salamat', 'rafaqatsalamatflow@um.com.pk', '10000330', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 50, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'rafaqatsalamatflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Yousuf Masih', 'yousufmasihflow@um.com.pk', '10000326', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 50, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'yousufmasihflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Farhat Perveen', 'farhat.perveen@um.com.pk', '10000870', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 51, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'farhat.perveen@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Yusra', 'yusra.jabbar@um.com.pk', '10000001', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 51, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'yusra.jabbar@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Humais Khan', 'crm.dx@um.com.pk', '10000871', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 54, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'crm.dx@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Hassan Adil', 'hassan.adil@um.com.pk', '10000010', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 52, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'hassan.adil@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Abdul Wasay Malik', 'wasaymalik@um.com.pk', '10000011', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 52, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'wasaymalik@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Sultan', 'sultan@um.com.pk', '10000012', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 52, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'sultan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Umair', 'scm.ops@um.com.pk', '10000779', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 53, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'scm.ops@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Faisal Khan', 'mfaisal@um.com.pk', '10000648', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 53, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'mfaisal@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Talha Sabeel', 'talhasabeelflow@um.com.pk', '10000848', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 53, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'talhasabeelflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Sheikh Shahbaz Akhtar', 'shahbaz.akhtar@um.com.pk', '10000018', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 55, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'shahbaz.akhtar@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Syed Muhammed Khaliq Uzzaman', 'khaliq@um.com.pk', '10000016', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 55, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'khaliq@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Haider Ali', 'haider.ali@um.com.pk', '10000019', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 55, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'haider.ali@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Zeeshan Khan', 'm.zeeshan.@um.com.pk', '10000739', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 56, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'm.zeeshan.@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Faizan', 'doc@um.com.pk', '10000022', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 57, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'doc@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Zehrish', 'doc2@um.com.pk', '10000023', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 57, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'doc2@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Khawaja Aleem Shah', 'cr@um.com.pk', '10000021', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 57, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'cr@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Kosain Hanif', 'coordinator.fa@um.com.pk', '10000050', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 58, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'coordinator.fa@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Saad', 'procurement.fa@um.com.pk', '10000610', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 59, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'procurement.fa@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Uzair', 'uzair.saeed@um.com.pk', '10000048', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 60, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'uzair.saeed@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Qamar Khan', 'oaf@um.com.pk', '10000632', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 60, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'oaf@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Ammar Waseem', 'ammar.waseem@um.com.pk', '10000047', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 60, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'ammar.waseem@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Sarfaraz Hussain', 'sarfaraz.hussain@um.com.pk', '10000046', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 60, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'sarfaraz.hussain@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Kabeer Alam', 'kabeer.alam@um.com.pk', '10000045', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 60, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'kabeer.alam@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Sajid Mustafa', 'scm@um.com.pk', '10000051', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 61, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'scm@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Adeel Ahmed', 'adeel.ahmed@um.com.pk', '10000056', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 62, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'adeel.ahmed@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Abdul Aziz', 'abdulaziz@um.com.pk', '10000062', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 62, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'abdulaziz@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Dost Muhammad', 'dost.muhammad@um.com.pk', '10000055', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 62, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'dost.muhammad@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Arshad', 'muhammadarshad@um.com.pk', '10000058', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 62, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadarshad@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Tanveer Ahmed Khan', 'tanveerahmedkhanflow@um.com.pk', '10000059', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 62, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'tanveerahmedkhanflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Abdul Salam', 'abdulsalamflow@um.com.pk', '10000897', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 62, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'abdulsalamflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Imran', 'Imranflow@um.com.pk', '10000597', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 62, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'Imranflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Ali Akbar', 'aliakbar@um.com.pk', '10000061', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 62, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'aliakbar@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Malik Muhammad Nasir Asad', 'nasirflow@um.com.pk', '10000547', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 62, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'nasirflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Malik Mushtaq Ahmed', 'mushtaq.flow@um.com.pk', '10000918', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 62, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'mushtaq.flow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Mastan Khan', 'mastankhan@um.com.pk', '10000057', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 62, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'mastankhan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Ali', 'muhammadali@um.com.pk', '10000065', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 62, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadali@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Muneer', 'muneerflow@um.com.pk', '10000875', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 62, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muneerflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Nasir', 'm.nasirflow@um.com.pk', '10000860', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 62, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'm.nasirflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Sameen', 'muhammadsameenflow@um.com.pk', '10000060', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 62, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadsameenflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Naveed', 'naveed@um.com.pk', '10000054', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 62, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'naveed@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Sadiq Ali', 'sadiqali@um.com.pk', '10000066', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 62, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'sadiqali@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Wazeer Muhammad', 'wazeermuhammad@um.com.pk', '10000052', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 62, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'wazeermuhammad@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Zohaib Soomro', 'mzohaib@um.com.pk', '10000068', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 63, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'mzohaib@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Ahmed Sohaib', 'ahmed.sohaib@um.com.pk', '10000069', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 63, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'ahmed.sohaib@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Hasan Ali', 'hasanflow@um.com.pk', '10000904', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 64, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'hasanflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Syed Anzal Ali', 'syedanzalaliflow@um.com.pk', '10000722', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 64, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'syedanzalaliflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Mohsin Akhlas', 'mohsin.akhlas@um.com.pk', '10000114', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 65, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'mohsin.akhlas@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Safi Ullah Wasim', 'safiullah@flow.com', '10000812', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 65, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'safiullah@flow.com');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Emran Farook', 'emranfarook@gmail.com', '10000565', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 65, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'emranfarook@gmail.com');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Akber Mughal', 'stats.fm@um.com.pk', '10000168', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 66, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'stats.fm@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Owais Najam', 'owais.najam@um.com.pk', '10000115', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 67, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'owais.najam@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Tamanna Qasim', 'cod.msdz1@um.com.pk', '10000170', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 67, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'cod.msdz1@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Masood Ahmed', 'masood.ahmed@um.com.pk', '10000113', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 67, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'masood.ahmed@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Hafeez Ur Rehman', 'hafeezurrehmanflow@um.com.pk', '10000111', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 67, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'hafeezurrehmanflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Umair', 'umair.flow@um.com.pk', '10000892', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 67, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'umair.flow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Syed Mohsin Hasan', 'Mohsin.hassan@um.com.pk', '10000112', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 67, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'Mohsin.hassan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Abdul Jabbar Khan', 'abdul.jabbar@um.com.pk', '10000121', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 68, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'abdul.jabbar@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Laiq Zada', 'Laiqflow@um.com.pk', '10000905', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 68, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'Laiqflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Qamar', 'muhammadqamar@um.com.pk', '10000119', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 68, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadqamar@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Syed Farooq Azam', 'syedfarooqazamflow@um.com.pk', '10000122', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 68, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'syedfarooqazamflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Farhan Jamal', 'farhan.jamal@um.com.pk', '10000116', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 68, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'farhan.jamal@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Aliyaan', 'aliyaan@um.com.pk', '10000125', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 68, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'aliyaan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Amjad Ansari', 'amjadansariflow@um.com.pk', '10000120', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 68, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'amjadansariflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Arsalan', 'arsalan@um.com.pk', '10000118', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 68, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'arsalan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Hafiz Farhan', 'hafizfarhan@um.com.pk', '10000123', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 68, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'hafizfarhan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Khan Sher', 'khansher@um.com.pk', '10000126', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 68, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'khansher@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Farhan', 'muhammadfarhanflow@um.com.pk', '10000124', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 68, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadfarhanflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Sohail', 'muhammad.sohail@um.com.pk', '10000064', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 68, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammad.sohail@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Waseem Aslam', 'muhammadwaseemaslamflow@um.com.pk', '10000387', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 68, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadwaseemaslamflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Rehan Uddin Siddiqui', 'rehanuddinsiddiquiflow@um.com.pk', '10000117', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 68, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'rehanuddinsiddiquiflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Khalid Gulab', 'khalid@um.com.pk', '10000128', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 69, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'khalid@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Sarfaraz Owais Siddiqui', 'sarfraz.owais@um.com.pk', '10000129', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 69, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'sarfraz.owais@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Arsalan Irshad', 'arsalan.irshad.msd@um.com.pk', '10000171', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 70, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'arsalan.irshad.msd@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Noshad Gull', 'noshad.flow@um.com.pk', '10000913', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 70, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'noshad.flow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Syed Kashif Nayyar Ahmed Jilani', 'vaccination.services@um.com.pk', '10000169', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 71, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'vaccination.services@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Fahad', 'm.fahadflow@gmail.com.pk', '10000723', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 71, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'm.fahadflow@gmail.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Nauman Haider Siddiqui', 'nauman.siddiqui@um.com.pk', '10000551', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 72, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'nauman.siddiqui@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Hafiz Humayun Khan', 'humayun.khan@um.com.pk', '10000067', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 72, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'humayun.khan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Hunain', 'm.hunainflow@um.com.pk', '10000903', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 73, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'm.hunainflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Hussain', 'hussainflow@um.com.pk', '10000886', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 73, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'hussainflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Ali Inayat', 'ali.inayat@um.com.pk', '10000277', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 74, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'ali.inayat@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Siraj', 'muhammad.siraj@um.com.pk', '10000269', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 74, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammad.siraj@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Zaki Uddin Farooqui', 'zaki@um.com.pk', '10000261', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 74, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'zaki@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Tariq Ali Khan', 'tariq.khan@um.com.pk', '10000265', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 74, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'tariq.khan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Naveed', 'naveed.jabbar@um.com.pk', '10000278', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 74, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'naveed.jabbar@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Shah Fahad Khan', 'shahfahad@um.com.pk', '10000266', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 74, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'shahfahad@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Ziyad Ashrafi', 'ziyad.ashrafi@um.com.pk', '10000279', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 74, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'ziyad.ashrafi@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Syed Adeel Mashkoor', 'adeel.mashkoor@um.com.pk', '10000273', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 74, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'adeel.mashkoor@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Arsalan', 'muhammad.arsalan@um.com.pk', '10000276', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 74, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammad.arsalan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Umer Farooq', 'umer.farooq@um.com.pk', '10000275', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 74, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'umer.farooq@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Syed Muhammad Ramiz', 'syedm.ramizflow@um.com.pk', '10000919', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 74, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'syedm.ramizflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Wajahat Ullah Khan', 'wajahatullah@um.com.pk', '10000274', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 74, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'wajahatullah@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Shabbir', 'shabbir.hussain@um.com.pk', '10000270', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 74, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'shabbir.hussain@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Sheraz Ahmad', 'sheraz.ahmad@um.com.pk', '10000262', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 74, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'sheraz.ahmad@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Hamid', 'hamidflow.@um.com.pk', '10000889', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'hamidflow.@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Kumail Arif', 'kumail.arif@um.com.pk', '10000287', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'kumail.arif@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Yaqoob Chohan', 'yaqoobchohanflow@um.com.pk', '10000301', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'yaqoobchohanflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Owais Raza', 'owais.raza@um.com.pk', '10000284', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'owais.raza@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Chanzeb', 'chanzebflow@um.com.pk', '10000348', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'chanzebflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Aslam', 'muhammadaslamflow@um.com.pk', '10000303', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadaslamflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Abdul Rehman', 'abdurrehman@um.com.pk', '10000314', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'abdurrehman@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Riaz Hussain', 'muhammadriazhussain@um.com.pk', '10000282', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadriazhussain@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Haider Ali', 'haiderali@um.com.pk', '10000280', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'haiderali@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Adnan', 'muhammadadnan@um.com.pk', '10000315', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadadnan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Gulzaar Ahmed', 'gulzar.flowahmed@um.com.pk', '10000800', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'gulzar.flowahmed@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Noor Ud Din', 'nooruddin@um.com.pk', '10000298', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'nooruddin@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Syed Wasi Hassan', 'syedwasihassan@um.com.pk', '10000292', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'syedwasihassan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Huraira Khan', 'huraira.khan@um.com.pk', '10000306', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'huraira.khan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Ali Ramzan', 'aliramzanflow@um.com.pk', '10000343', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'aliramzanflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Amna Siddiq', 'amnasiddiqui@um.com.pk', '10000294', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'amnasiddiqui@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Humera Atiq', 'humeraatiq@um.com.pk', '10000285', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'humeraatiq@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Owais Ahmed Khan', 'owaisahmedkhanflow@um.com.pk', '10000297', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'owaisahmedkhanflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Athar Khan', 'muhammadatharkhanflow@um.com.pk', '10000296', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadatharkhanflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Khurram Ali', 'muhammadkhurramali@um.com.pk', '10000289', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadkhurramali@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Umair Maqbool', 'umairmaqbool@um.com.pk', '10000281', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'umairmaqbool@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Dost Muhammad', 'dostmuhammad@um.com.pk', '10000341', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'dostmuhammad@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Ghulam Rasool', 'ghulamrasoolflow@um.com.pk', '10000344', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'ghulamrasoolflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Hafiz Muhammad', 'hafizmuhammad@um.com.pk', '10000333', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'hafizmuhammad@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Ibrahim Shah', 'ibrahimshahflow@um.com.pk', '10000346', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'ibrahimshahflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Safdar Ali', 'safdaraliflow@um.com.pk', '10000316', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'safdaraliflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Zar Malik Shah', 'zarmalikshahflow@um.com.pk', '10000312', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'zarmalikshahflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Syed Rameez Hussain', 'rameez.hussain@um.com.pk', '10000371', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'rameez.hussain@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Kamran', 'kamran.flow@um.com.pk', '10000726', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'kamran.flow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Anwar', 'anwar.manzoor@um.com.pk', '10000763', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'anwar.manzoor@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Ashfaq Gill', 'Ashfaqgillflow@um.com.pk', '10000628', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'Ashfaqgillflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Imran Ayoub', 'imranayoub@um.com.pk', '10000304', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'imranayoub@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Imran Pervez', 'imranpervezflow@um.com.pk', '10000313', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'imranpervezflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Johnson', 'johnsonjozafflow@um.com.pk', '10000291', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'johnsonjozafflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Johnson', 'johnson@um.com.pk', '10000353', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'johnson@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Kalsey Dona', 'kalseydona@um.com.pk', '10000340', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'kalseydona@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Kashif', 'Kashiflow@um.com.pk', '10000550', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'Kashiflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Munir Bashir', 'munirbashirflow@um.com.pk', '10000293', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'munirbashirflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Naveed Masih', 'naveedmasihflow@um.com.pk', '10000336', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'naveedmasihflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Sehoon Joseph', 'sehoon.joseph@um.com.pk', '10000764', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'sehoon.joseph@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Viki', 'viki@um.com.pk', '10000302', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'viki@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Saqib', 'muhammadsaqib@um.com.pk', '10000300', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 75, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadsaqib@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Shahid Siddiqui', 'ss@um.com.pk', '10000357', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 76, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'ss@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Farhan Saghir', 'farhan.saghir@um.com.pk', '10000822', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 77, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'farhan.saghir@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Rasheed', 'rasheed.hr@um.com.pk', '10000359', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 77, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'rasheed.hr@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Adnan Najeeb', 'adnan.hr@um.com.pk', '10000358', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 77, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'adnan.hr@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Azhan Ahmed Qureshi', 'azhan.hr@um.com.pk', '10000734', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 77, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'azhan.hr@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Sufiyan', 'sufiyan.hr@um.com.pk', '10000813', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 77, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'sufiyan.hr@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Zia ul Hassan', 'zia@um.com.pk', '10000364', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 78, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'zia@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Amna Khan', 'amna.khan@um.com.pk', '10000363', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 78, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'amna.khan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Talha Bashir', 'talhabashir@um.com.pk', '10000362', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 78, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'talhabashir@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Asad Sheikh', 'import.doc@um.com.pk', '10000528', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 78, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'import.doc@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Faraz', 'faraz.hanif@um.com.pk', '10000366', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 79, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'faraz.hanif@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Qasim Mehmood', 'Qasim.flow@um.com.pk', '10000920', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 79, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'Qasim.flow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Bilal Ahmed', 'bilal.ahmed@um.com.pk', '10000369', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 79, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'bilal.ahmed@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Fashi Ullah Khan', 'it.support@um.com.pk', '10000368', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 79, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'it.support@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Hamza Khan', 'mhamzakhan@um.com.pk', '10000641', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 79, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'mhamzakhan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Yahya Ajmal', 'yahyaajmalflow@um.com.pk', '10000657', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 79, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'yahyaajmalflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Dilawar Farrukh Rauf', 'farrukh.rauf@um.com.pk', '10000365', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 79, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'farrukh.rauf@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Shahzad Riaz', 'shahzadriaz@um.com.pk', '10000013', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 80, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'shahzadriaz@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Mohsin Ahmed Chohan', 'mohsin.chohan@um.com.pk', '10000373', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 81, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'mohsin.chohan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Naveed Ahmed', 'naveedahmed@um.com.pk', '10000372', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 81, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'naveedahmed@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Mohammad Farhan', 'mohammad.farhan@um.com.pk', '10000375', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 81, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'mohammad.farhan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Qamar Uddin', 'Qamar.flow@um.com.pk', '10000915', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 82, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'Qamar.flow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Riaz Hussain', 'riazhussainflow@um.com.pk', '10000681', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 82, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'riazhussainflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Yaqoob', 'muhammadyaqoobflow@um.com.pk', '10000376', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 82, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadyaqoobflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Afzal', 'muhammadafzalflow@um.com.pk', '10000378', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 82, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadafzalflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Ghalib', 'muhammadghalib@um.com.pk', '10000384', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 82, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadghalib@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Salman Siddiqui', 'muhammadsalmansiddiquiflow@um.com.pk', '10000379', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 82, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadsalmansiddiquiflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Suleman', 'm.sulemanflow@um.com.pk', '10000392', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 82, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'm.sulemanflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Ubaid Siraj', 'muhammadubaidsirajflow@um.com.pk', '10000382', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 82, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadubaidsirajflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Rizwan Ahmed', 'rizwanahmedflow@um.com.pk', '10000383', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 82, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'rizwanahmedflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Salman Malik', 'salmanmalik@um.com.pk', '10000380', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 82, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'salmanmalik@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Shahriyar', 'shahriyar@um.com.pk', '10000385', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 82, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'shahriyar@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Shakir Ullah', 'shakirullah@um.com.pk', '10000381', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 82, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'shakirullah@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Mehr Un Nisa', 'mehr.khan@um.com.pk', '10000399', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 83, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'mehr.khan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Abdul Hafeez', 'abdul.hafeez@um.com.pk', '10000396', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 83, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'abdul.hafeez@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Masood', 'muhammad.masood@um.com.pk', '10000397', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 83, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammad.masood@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Noman', 'mnoman@um.com.pk', '10000627', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 83, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'mnoman@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Shiraz', 'shiraz.silas@um.com.pk', '10000826', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 83, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'shiraz.silas@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Raheel Abbasi', 'muhammad.raheel@um.com.pk', '10000398', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 83, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammad.raheel@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Abdul Qayoom', 'abdulqayoomflow@um.com.pk', '10000718', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 84, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'abdulqayoomflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Mehtab Ali', 'mehtabaliflow@um.com.pk', '10000288', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 84, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'mehtabaliflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Hunain Ali', 'hunain.ali@um.com.pk', '10000025', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 84, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'hunain.ali@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Sami Khan', 'sami.khan@um.com.pk', '10000131', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 84, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'sami.khan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Miraal Javed', 'miraalflow@um.com.pk', '10000693', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 84, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'miraalflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Naima Mukhtar', 'Naimaflow@um.com.pk', '10000698', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 84, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'Naimaflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Khizer Ur Rehman Khan Ghori', 'khizerflow@um.com.pk', '10000796', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 84, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'khizerflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Sohail', 'pa.im@um.com.pk', '10000401', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 85, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'pa.im@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Shamim Azim', 'azim@um.com.pk', '10000400', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 85, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'azim@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Sarfaraz Ahmed Khan', 'sarfaraz.ahmed@um.com.pk', '10000409', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 86, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'sarfaraz.ahmed@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Fazal ur Rehman Khan', 'pkg.store@um.com.pk', '10000408', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 86, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'pkg.store@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Adnan Rehmat', 'adnanrehmatflow@um.com.pk', '10000407', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 86, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'adnanrehmatflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Kashmir', 'kashmirflow@um.com.pk', '10000404', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 86, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'kashmirflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Kaleem', 'muhammadkaleem@um.com.pk', '10000405', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 86, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadkaleem@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Sikandar', 'sikandar@um.com.pk', '10000406', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 86, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'sikandar@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Ubaid Ur Rehman', 'ubaidurrehmanflow.@um.com.pk', '10000127', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 86, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'ubaidurrehmanflow.@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Waseem Akram', 'waseemakram@um.com.pk', '10000388', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 86, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'waseemakram@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Shams Ullah Rafeeq', 'Shams.flow@um.com.pk', '10000825', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 87, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'Shams.flow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Aslam Muhammad', 'aslam.flow@um.com.pk', '10000310', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 87, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'aslam.flow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Yousaf Khan', 'yousuf.flow@um.com.pk', '10000736', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 87, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'yousuf.flow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Khalil Akram', 'Khalil.flow@um.com.pk', '10000622', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 88, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'Khalil.flow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Ali Hamza', 'Ali.flow@um.com.pk', '10000766', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 88, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'Ali.flow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Israfeel Khan', 'Israfeel.flow@um.com.pk', '10000705', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 88, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'Israfeel.flow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Kashif', 'kashif.flow@um.com.pk', '10000828', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 88, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'kashif.flow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Nauman Malik', 'Nauman.flow@um.com.pk', '10000618', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 88, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'Nauman.flow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Naveed Ahmed', 'Naveed.flow@um.com.pk', '10000704', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 88, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'Naveed.flow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Noor Alam', 'noorflow@um.com.pk', '10000746', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 88, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'noorflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Shafi Muhammad', 'shafi.flow@um.com.pk', '10000700', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 88, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'shafi.flow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Shaman', 'shaman.flow@um.com.pk', '10000702', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 88, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'shaman.flow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Waqas', 'waqas.flow@um.com.pk', '10000063', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 88, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'waqas.flow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Waseem Ahmed', 'waseem.flow@um.com.pk', '10000623', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 88, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'waseem.flow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Saqib Khan', 'saqibkhanflow@um.com.pk', '10000851', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 89, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'saqibkhanflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Hamza Ali Khan', 'hamza.khan@um.com.pk', '10000492', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 90, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'hamza.khan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Ammar Malik', 'boviteam@gmail.com', '10000490', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 90, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'boviteam@gmail.com');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Aziz Ur Rehman', 'cod.la@um.com.pk', '10000493', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 90, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'cod.la@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Waqas Saleem', 'waqas.saleem@um.com.pk', '10000491', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 90, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'waqas.saleem@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Sufyan Malik', 'cod.la2@um.com.pk', '10000494', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 90, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'cod.la2@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Syed Muzammil Ali', 'muzammilflow@um.com.pk', '10000852', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 91, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muzammilflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Abdul Muqeet', 'abdulflow.@um.com.pk', '10000742', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 91, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'abdulflow.@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Abdul Wahab', 'abdul.wahabflow@um.com.pk', '10000854', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 91, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'abdul.wahabflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Adnan Hafeez', 'adnanhafeezflow@um.com.pk', '10000858', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 91, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'adnanhafeezflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Ali', 'muhammad.aliflow@um.com.pk', '10000855', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 91, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammad.aliflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Sufyan', 'm.sufyanflow@um.com.pk', '10000857', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 91, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'm.sufyanflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Waqar', 'm.waqarflow.@um.com.pk', '10000861', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 91, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'm.waqarflow.@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muheet', 'muheetflow.@um.com.pk', '10000890', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 91, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muheetflow.@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Sameer', 'sameerflow@um.com.pk', '10000853', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 91, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'sameerflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Tahir Imam Bukhsh', 'tahirflow@um.com.pk', '10000620', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 91, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'tahirflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Zubair Ahmed', 'zubairflow@um.com.pk', '10000856', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 91, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'zubairflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Ghalib Akhter Saleemi', 'ghalib.akhter@um.com.pk', '10000495', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 92, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'ghalib.akhter@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Faisal Shahab', 'faisal.shahab@um.com.pk', '10000513', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 93, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'faisal.shahab@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Saqib Shamim', 'saqib.shamim@um.com.pk', '10000516', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 93, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'saqib.shamim@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Hammad Ali', 'hammadali@um.com.pk', '10000902', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 93, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'hammadali@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Irfan Baloch', 'irfan.baloch@um.com.pk', '10000053', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 94, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'irfan.baloch@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Muhammad Ramiz Hussain', 'muhammadramizhussainflow@um.com.pk', '10000519', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 94, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'muhammadramizhussainflow@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Sabir Khan', 'sabirkhan@um.com.pk', '10000517', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 94, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'sabirkhan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Sherin Khan', 'sherinkhan@um.com.pk', '10000518', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 2, 94, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'sherinkhan@um.com.pk');

INSERT INTO users (name, email, code, password_hash, role_id, department_id, company_id, is_active, must_reset_password)
SELECT 'Fareed Ahmed Soomro', 'cod.la3@um.com.pk', '10000797', '$2b$10$BkrgctImkc2NJevgmzngR.BMg6BtaSnqjQBB0RPJXCyVXdvYOe9Eq', 1, 95, 0, TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'cod.la3@um.com.pk');

COMMIT;

-- Inserted: 246 | Skipped (no dept match): 0
