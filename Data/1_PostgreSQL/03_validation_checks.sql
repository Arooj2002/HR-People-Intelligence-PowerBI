-- Run after load: every check should return 0 rows / 0 count
-- 1) payroll months outside employment window
SELECT COUNT(*) AS payroll_outside_employment FROM payroll.payroll_monthly p JOIN hr.employee e USING (employee_key)
WHERE p.pay_month_end < date_trunc('month', e.hire_date) OR (e.exit_date IS NOT NULL AND date_trunc('month', p.pay_month_end) > e.exit_date);
-- 2) attendance outside employment window
SELECT COUNT(*) AS attendance_outside_employment FROM attendance.daily_attendance a JOIN hr.employee e USING (employee_key)
WHERE a.attendance_date < e.hire_date OR (e.exit_date IS NOT NULL AND a.attendance_date > e.exit_date);
-- 3) attendance on weekends
SELECT COUNT(*) AS weekend_rows FROM attendance.daily_attendance WHERE EXTRACT(ISODOW FROM attendance_date) IN (6,7);
-- 4) separation dates match employee master
SELECT COUNT(*) AS sep_mismatch FROM hr.separation s JOIN hr.employee e USING (employee_key)
WHERE s.exit_date <> e.exit_date OR s.hire_date <> e.hire_date;
-- 5) every exited employee has exactly one separation row
SELECT COUNT(*) AS exited_without_separation FROM hr.employee e LEFT JOIN hr.separation s USING (employee_key)
WHERE e.employment_status = 'Exited' AND s.employee_key IS NULL;
-- 6) every employee has a Hire event on hire_date
SELECT COUNT(*) AS missing_hire_event FROM hr.employee e
WHERE NOT EXISTS (SELECT 1 FROM hr.job_history j WHERE j.employee_key = e.employee_key AND j.event_type = 'Hire' AND j.event_date = e.hire_date);
-- 7) job events after exit
SELECT COUNT(*) AS events_after_exit FROM hr.job_history j JOIN hr.employee e USING (employee_key)
WHERE e.exit_date IS NOT NULL AND j.event_date > e.exit_date;

-- ---------------------------------------------------------------- quick story KPIs
-- Headcount at month end (last 6 months)
SELECT pay_month_end, COUNT(*) FILTER (WHERE is_active_month_end) AS headcount
FROM payroll.payroll_monthly GROUP BY 1 ORDER BY 1 DESC LIMIT 6;
-- Exits by department & location
SELECT d.department_name, l.city, COUNT(*) AS exits
FROM hr.separation s JOIN hr.department d USING (department_key) JOIN hr.location l USING (location_key)
GROUP BY 1,2 ORDER BY 3 DESC LIMIT 10;
-- Bradford Factor top 10 (S^2 x D) on unplanned absences
SELECT employee_key, COUNT(DISTINCT absence_spell_id) AS spells, COUNT(*) AS days,
       POWER(COUNT(DISTINCT absence_spell_id), 2) * COUNT(*) AS bradford
FROM attendance.daily_attendance WHERE is_unplanned GROUP BY 1 ORDER BY bradford DESC LIMIT 10;
