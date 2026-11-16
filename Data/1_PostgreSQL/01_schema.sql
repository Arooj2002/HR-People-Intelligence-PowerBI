-- =====================================================================
-- HR People Intelligence | PostgreSQL schema (HRMS + Payroll + Biometric)
-- Database: hr_analytics
-- =====================================================================
CREATE SCHEMA IF NOT EXISTS hr;
CREATE SCHEMA IF NOT EXISTS payroll;
CREATE SCHEMA IF NOT EXISTS attendance;

DROP TABLE IF EXISTS attendance.daily_attendance, payroll.payroll_monthly, hr.separation,
                     hr.job_history, hr.employee, hr.location, hr.department CASCADE;

CREATE TABLE hr.department (
    department_key     SMALLINT     PRIMARY KEY,
    department_name    VARCHAR(40)  NOT NULL,
    dept_code          CHAR(3)      NOT NULL UNIQUE,
    function_group     VARCHAR(20)  NOT NULL,
    cost_center        VARCHAR(10)  NOT NULL,
    head_employee_key  INT                                   -- FK added after load
);

CREATE TABLE hr.location (
    location_key  SMALLINT    PRIMARY KEY,
    city          VARCHAR(30) NOT NULL,
    country       VARCHAR(40) NOT NULL,
    region        VARCHAR(10) NOT NULL,                     -- Pakistan / GCC
    office_type   VARCHAR(10) NOT NULL,                     -- HQ / Hub / Regional
    timezone      VARCHAR(20) NOT NULL,
    work_week     VARCHAR(10) NOT NULL
);

CREATE TABLE hr.employee (
    employee_key             INT          PRIMARY KEY,
    emp_id                   VARCHAR(10)  NOT NULL UNIQUE,  -- EMP-10001
    full_name                VARCHAR(80)  NOT NULL,
    email                    VARCHAR(120) NOT NULL UNIQUE,
    gender                   VARCHAR(10)  NOT NULL,
    date_of_birth            DATE         NOT NULL,
    nationality              VARCHAR(30)  NOT NULL,
    home_city                VARCHAR(40)  NOT NULL,
    education_level          VARCHAR(20)  NOT NULL,
    hire_date                DATE         NOT NULL,
    exit_date                DATE,
    employment_status        VARCHAR(10)  NOT NULL,         -- Active / Exited
    employment_type          VARCHAR(12)  NOT NULL,         -- Permanent / Contract
    manager_key              INT,                           -- current line manager (self FK)
    is_people_manager        BOOLEAN      NOT NULL,         -- has ever managed a team
    current_department_key   SMALLINT     NOT NULL,
    current_location_key     SMALLINT     NOT NULL,
    current_designation_key  SMALLINT     NOT NULL,         -- designation lives in Excel (no FK)
    CONSTRAINT chk_exit_after_hire CHECK (exit_date IS NULL OR exit_date >= hire_date)
);

CREATE TABLE hr.job_history (
    event_id               INT          PRIMARY KEY,
    employee_key           INT          NOT NULL,
    event_date             DATE         NOT NULL,
    event_type             VARCHAR(25)  NOT NULL,           -- Hire / Promotion / Location Transfer / Department Transfer
    from_designation_key   SMALLINT,
    designation_key        SMALLINT     NOT NULL,           -- designation AFTER the event
    from_department_key    SMALLINT,
    department_key         SMALLINT     NOT NULL,
    from_location_key      SMALLINT,
    location_key           SMALLINT     NOT NULL,
    salary_change_pct      NUMERIC(5,1),
    is_internal_move       BOOLEAN      NOT NULL
);

CREATE TABLE hr.separation (
    separation_id          INT          PRIMARY KEY,
    employee_key           INT          NOT NULL UNIQUE,
    exit_date              DATE         NOT NULL,
    hire_date              DATE         NOT NULL,           -- inactive relationship in Power BI
    department_key         SMALLINT     NOT NULL,
    location_key           SMALLINT     NOT NULL,
    designation_key        SMALLINT     NOT NULL,
    manager_key            INT,
    separation_type        VARCHAR(15)  NOT NULL,           -- Voluntary / Involuntary / Retirement / Contract End
    exit_reason            VARCHAR(40)  NOT NULL,
    is_regretted           BOOLEAN      NOT NULL,
    last_rating            SMALLINT     NOT NULL,
    last_base_salary_usd   NUMERIC(10,2) NOT NULL,
    tenure_months          INT          NOT NULL,
    notice_days            SMALLINT     NOT NULL,
    rehire_eligible        BOOLEAN      NOT NULL,
    CONSTRAINT chk_sep_dates CHECK (exit_date >= hire_date)
);

CREATE TABLE payroll.payroll_monthly (
    payroll_id            INT           PRIMARY KEY,
    employee_key          INT           NOT NULL,
    pay_month_end         DATE          NOT NULL,           -- grain: 1 employee x 1 month
    department_key        SMALLINT      NOT NULL,           -- as-of month
    location_key          SMALLINT      NOT NULL,
    designation_key       SMALLINT      NOT NULL,
    manager_key           INT,
    base_salary_usd       NUMERIC(10,2) NOT NULL,           -- contractual monthly base (not pro-rated)
    allowances_usd        NUMERIC(10,2) NOT NULL,
    overtime_usd          NUMERIC(10,2) NOT NULL,
    bonus_usd             NUMERIC(10,2) NOT NULL,
    deductions_usd        NUMERIC(10,2) NOT NULL,
    gross_pay_usd         NUMERIC(10,2) NOT NULL,
    net_pay_usd           NUMERIC(10,2) NOT NULL,
    employer_cost_usd     NUMERIC(10,2) NOT NULL,
    days_paid             SMALLINT      NOT NULL,
    is_active_month_end   BOOLEAN       NOT NULL,
    CONSTRAINT uq_payroll UNIQUE (employee_key, pay_month_end)
);

CREATE TABLE attendance.daily_attendance (
    attendance_id     INT          PRIMARY KEY,
    employee_key      INT          NOT NULL,
    attendance_date   DATE         NOT NULL,                -- grain: 1 employee x 1 working day
    department_key    SMALLINT     NOT NULL,
    location_key      SMALLINT     NOT NULL,
    manager_key       INT,
    status            VARCHAR(15)  NOT NULL,                -- Present / WFH / Late / Half Day / Sick Leave / Casual Leave / Annual Leave / Unpaid Absence
    is_unplanned      BOOLEAN      NOT NULL,
    check_in          TIME,
    check_out         TIME,
    hours_worked      NUMERIC(4,2) NOT NULL,
    absence_spell_id  VARCHAR(20),                          -- consecutive unplanned-absence days share one ID (Bradford Factor)
    CONSTRAINT uq_attendance UNIQUE (employee_key, attendance_date)
);
