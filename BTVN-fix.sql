CREATE DATABASE IF NOT EXISTS StudentManagement;
USE StudentManagement;

DROP TABLE IF EXISTS grade_log;
DROP TABLE IF EXISTS grades;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    student_id VARCHAR(5) PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    total_debt DECIMAL(10,2) DEFAULT 0.00
);

CREATE TABLE subjects (
    subject_id VARCHAR(5) PRIMARY KEY,
    subject_name VARCHAR(50) NOT NULL,
    credits INT,
    CONSTRAINT chk_credits CHECK (credits > 0)
);

CREATE TABLE grades (
    student_id VARCHAR(5),
    subject_id VARCHAR(5),
    score DECIMAL(4,2),
    PRIMARY KEY (student_id, subject_id), -- Khóa chính phức hợp
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
    CONSTRAINT chk_score CHECK (score BETWEEN 0 AND 10)
);

CREATE TABLE grade_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id VARCHAR(5),
    old_score DECIMAL(4,2),
    new_score DECIMAL(4,2),
    change_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);

INSERT INTO students (student_id, full_name, total_debt) VALUES 
('SV01', 'Le Hoang Nam', 3500000.00), -- Phục vụ cho câu 4 (Đóng học phí)
('SV03', 'Tran Quoc Anh', 0.00),       -- Sinh viên sạch nợ
('SV04', 'Vu Phuong Thao', 1500000.00);

INSERT INTO subjects (subject_id, subject_name, credits) VALUES 
('SUB01', 'Database Systems', 3),
('SUB02', 'Java Programming', 4),
('SUB03', 'Web Development', 3);

INSERT INTO grades (student_id, subject_id, score) VALUES 
('SV01', 'SUB01', 3.50),  -- Điểm < 4.0: Phục vụ test Câu 5 (Cho phép sửa điểm vì tạch môn)
('SV01', 'SUB02', 7.50),  -- Điểm >= 4.0: Phục vụ test Câu 5 (Chặn sửa điểm vì đã qua môn)
('SV04', 'SUB01', 5.00);

SELECT 'students' AS Table_Name, COUNT(*) AS Total_Rows FROM students
UNION ALL
SELECT 'subjects', COUNT(*) FROM subjects
UNION ALL
SELECT 'grades', COUNT(*) FROM grades
UNION ALL
SELECT 'grade_log', COUNT(*) FROM grade_log;

-- Câu01
DROP TRIGGER IF EXISTS ck_scores;
DELIMITER // 
CREATE TRIGGER ck_scores 
BEFORE INSERT ON grades 
FOR EACH ROW 
BEGIN 
    IF NEW.score < 0 THEN 
        SET NEW.score = 0; 
    ELSEIF NEW.score > 10 THEN 
        SET NEW.score = 10; 
    END IF; 
END // 
DELIMITER ;

-- Câu02
START TRANSACTION;
INSERT INTO students (student_id, full_name)
VALUES ('SV02', 'Ha Bich Ngoc');
UPDATE students
SET total_debt = 5000000
WHERE student_id = 'SV02';
COMMIT;

-- Câu03
DROP TRIGGER IF EXISTS  tg_log_grade_update;
DELIMITER // 
CREATE TRIGGER  tg_log_grade_update  
AFTER UPDATE ON grades 
FOR EACH ROW 
BEGIN 
    IF NEW.score != OLD.score THEN 
		INSERT INTO grade_log(student_id,old_score)
        VALUES (NEW.student_id,OLD.score);
    END IF; 
END // 
DELIMITER ;

UPDATE grades SET score = 10 WHERE subject_id = 'SUB02';

-- Câu04
DROP PROCEDURE IF EXISTS sp_pay_tuition;
DELIMITER //
CREATE PROCEDURE sp_pay_tuition()
BEGIN 
	DECLARE current_debt DECIMAL(10,2);
    START TRANSACTION;
	
    UPDATE students SET total_debt = total_debt - 2000000 WHERE student_id = 'SV01';
    
    SELECT total_debt INTO current_debt FROM students WHERE student_id = 'SV01';
    
    IF current_debt < 0 THEN	
		ROLLBACK;
	ELSE
		COMMIT;
    END IF;
END //
DELIMITER ;

CALL sp_pay_tuition();
SELECT * FROM students WHERE student_id = 'SV01';

-- Câu 05
DROP TRIGGER IF EXISTS tg_prevent_pass_update;
DELIMITER //
CREATE TRIGGER tg_prevent_pass_update
BEFORE UPDATE ON grades
FOR EACH ROW
BEGIN 
    IF OLD.score >= 4.0 THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không thể cập nhật điểm';
	END IF;
END //
DELIMITER ;	

