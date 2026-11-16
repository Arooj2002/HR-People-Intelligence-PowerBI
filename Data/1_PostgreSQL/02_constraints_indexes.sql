
-- ---------------------------------------------------------------- foreign keys (added after load)
ALTER TABLE hr.department ADD CONSTRAINT fk_dept_head FOREIGN KEY (head_employee_key) REFERENCES hr.employee(employee_key);
ALTER TABLE hr.employee   ADD CONSTRAINT fk_emp_mgr  FOREIGN KEY (manager_key) REFERENCES hr.employee(employee_key);
ALTER TABLE hr.employee   ADD CONSTRAINT fk_emp_dept FOREIGN KEY (current_department_key) REFERENCES hr.department(department_key);
ALTER TABLE hr.employee   ADD CONSTRAINT fk_emp_loc  FOREIGN KEY (current_location_key) REFERENCES hr.location(location_key);
ALTER TABLE hr.job_history ADD CONSTRAINT fk_jh_emp  FOREIGN KEY (employee_key) REFERENCES hr.employee(employee_key);
ALTER TABLE hr.job_history ADD CONSTRAINT fk_jh_dept FOREIGN KEY (department_key) REFERENCES hr.department(department_key);
ALTER TABLE hr.job_history ADD CONSTRAINT fk_jh_loc  FOREIGN KEY (location_key) REFERENCES hr.location(location_key);
ALTER TABLE hr.separation ADD CONSTRAINT fk_sep_emp  FOREIGN KEY (employee_key) REFERENCES hr.employee(employee_key);
ALTER TABLE hr.separation ADD CONSTRAINT fk_sep_dept FOREIGN KEY (department_key) REFERENCES hr.department(department_key);
ALTER TABLE hr.separation ADD CONSTRAINT fk_sep_loc  FOREIGN KEY (location_key) REFERENCES hr.location(location_key);
ALTER TABLE hr.separation ADD CONSTRAINT fk_sep_mgr  FOREIGN KEY (manager_key) REFERENCES hr.employee(employee_key);
ALTER TABLE payroll.payroll_monthly ADD CONSTRAINT fk_pay_emp  FOREIGN KEY (employee_key) REFERENCES hr.employee(employee_key);
ALTER TABLE payroll.payroll_monthly ADD CONSTRAINT fk_pay_dept FOREIGN KEY (department_key) REFERENCES hr.department(department_key);
ALTER TABLE payroll.payroll_monthly ADD CONSTRAINT fk_pay_loc  FOREIGN KEY (location_key) REFERENCES hr.location(location_key);
ALTER TABLE payroll.payroll_monthly ADD CONSTRAINT fk_pay_mgr  FOREIGN KEY (manager_key) REFERENCES hr.employee(employee_key);
ALTER TABLE attendance.daily_attendance ADD CONSTRAINT fk_att_emp  FOREIGN KEY (employee_key) REFERENCES hr.employee(employee_key);
ALTER TABLE attendance.daily_attendance ADD CONSTRAINT fk_att_dept FOREIGN KEY (department_key) REFERENCES hr.department(department_key);
ALTER TABLE attendance.daily_attendance ADD CONSTRAINT fk_att_loc  FOREIGN KEY (location_key) REFERENCES hr.location(location_key);
ALTER TABLE attendance.daily_attendance ADD CONSTRAINT fk_att_mgr  FOREIGN KEY (manager_key) REFERENCES hr.employee(employee_key);

-- ---------------------------------------------------------------- indexes (query folding / DirectQuery speed)
CREATE INDEX ix_emp_mgr        ON hr.employee (manager_key);
CREATE INDEX ix_jh_emp_date    ON hr.job_history (employee_key, event_date);
CREATE INDEX ix_jh_type_date   ON hr.job_history (event_type, event_date);
CREATE INDEX ix_sep_exit       ON hr.separation (exit_date);
CREATE INDEX ix_pay_month      ON payroll.payroll_monthly (pay_month_end);          -- incremental refresh filter
CREATE INDEX ix_pay_dept_month ON payroll.payroll_monthly (department_key, pay_month_end);
CREATE INDEX ix_att_date       ON attendance.daily_attendance (attendance_date);     -- DirectQuery date filter
CREATE INDEX ix_att_emp_date   ON attendance.daily_attendance (employee_key, attendance_date);
CREATE INDEX ix_att_status     ON attendance.daily_attendance (status) INCLUDE (hours_worked);

ANALYZE;
