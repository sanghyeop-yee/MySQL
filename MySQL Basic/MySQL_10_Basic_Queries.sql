/***************************/
/*      MySQL Basics       */
/***************************/

-- Delete table: Employee, Department, Salary_Grade
DROP TABLE IF EXISTS EMP;
DROP TABLE IF EXISTS DEPT;
DROP TABLE IF EXISTS SALGRADE;

-- Create tables and add rows
CREATE TABLE EMP
       (EMPNO INT NOT NULL,
        ENAME VARCHAR(10),
        JOB VARCHAR(9),
        MGR INT,
        HIREDATE DATETIME,
        SAL DECIMAL(7, 2),
        COMM DECIMAL(7, 2),
        DEPTNO INT);

INSERT INTO EMP VALUES(7369, 'SMITH',  'CLERK', 7902, '1980-12-17', 800, NULL, 20);
INSERT INTO EMP VALUES(7499, 'ALLEN',  'SALESMAN',  7698, '1981-02-20', 1600,  300, 30);
INSERT INTO EMP VALUES(7521, 'WARD',   'SALESMAN',  7698, '1981-02-22', 1250,  500, 30);
INSERT INTO EMP VALUES(7566, 'JONES',  'MANAGER',   7839, '1981-04-02',  2975, NULL, 20);
INSERT INTO EMP VALUES(7654, 'MARTIN', 'SALESMAN',  7698,'1981-09-28', 1250, 1400, 30);
INSERT INTO EMP VALUES(7698, 'BLAKE',  'MANAGER',   7839,'1981-05-01', 2850, NULL, 30);
INSERT INTO EMP VALUES(7782, 'CLARK',  'MANAGER',   7839,'1981-06-09', 2450, NULL, 10);
INSERT INTO EMP VALUES(7788, 'SCOTT',  'ANALYST',   7566, '1982-12-09', 3000, NULL, 20);
INSERT INTO EMP VALUES(7839, 'KING',   'PRESIDENT', NULL, '1981-11-17', 5000, NULL, 10);
INSERT INTO EMP VALUES(7844, 'TURNER', 'SALESMAN',  7698, '1981-09-08',  1500,    0, 30);
INSERT INTO EMP VALUES(7876, 'ADAMS',  'CLERK', 7788, '1983-01-12', 1100, NULL, 20);
INSERT INTO EMP VALUES(7900, 'JAMES',  'CLERK',     7698, '1981-12-03',   950, NULL, 30);
INSERT INTO EMP VALUES(7902, 'FORD',   'ANALYST',   7566, '1981-12-03',  3000, NULL, 20);
INSERT INTO EMP VALUES(7934, 'MILLER', 'CLERK',     7782, '1982-01-23', 1300, NULL, 10);

CREATE TABLE DEPT
       (DEPTNO INT,
        DNAME VARCHAR(14),
        LOC VARCHAR(13) );

INSERT INTO DEPT VALUES (10, 'ACCOUNTING', 'NEW YORK');
INSERT INTO DEPT VALUES (20, 'RESEARCH',   'DALLAS');
INSERT INTO DEPT VALUES (30, 'SALES',      'CHICAGO');
INSERT INTO DEPT VALUES (40, 'OPERATIONS', 'BOSTON');

CREATE TABLE SALGRADE
        (GRADE INT,
         LOSAL INT,
         HISAL INT);

INSERT INTO SALGRADE VALUES (1,  700, 1200);
INSERT INTO SALGRADE VALUES (2, 1201, 1400);
INSERT INTO SALGRADE VALUES (3, 1401, 2000);
INSERT INTO SALGRADE VALUES (4, 2001, 3000);
INSERT INTO SALGRADE VALUES (5, 3001, 9999);

/*
1. Query name, hire date and salary of employees whose job is Manager or Salesman.
*/
select ename, hiredate, sal
from emp
where job in ('salesman', 'manager'); 

/*
2. Query all employees that has empno greater than or equal to 7500 and has salary between 2000 and 3000,
sorted by ename.
*/
select *
from emp
where empno >= 7500
and sal between 2000 and 3000
order by ename;

/*
3. Query empno, ename, hiredate, and  sal of employees that has department id equal to 20 or 30.
Sorted by hire date desc
*/
select empno, ename, hiredate, sal
from emp
where deptno in(20,30)
order by hiredate desc;

/*
4. Query all employees that have 'M' or 'O' in their name and receive commissions.
*/
select *
from emp
where (ename like '%M%' or ename like '%O%') and comm>0;

/*
5. Query employees who were hired in December in department 20.
*/
select *
from emp
where month(hiredate) = 12 and deptno = 20;

/*
6. Query employees that were hired in 1982 sorted by name and sal desc.
*/
select *
from emp
where year(hiredate) = 1982
order by ename, sal desc;

/*
7. Query empno, ename, sal, comm(0 if null), and total salary(sal+comm).
*/
select empno, ename, sal, ifnull(comm,0) as comm, sal+ifnull(comm,0) as total_salary
from emp;

/*
8. Query employees who don't receive comm, sorted by ename.
*/
select *
from emp
where comm is null or comm<=0
order by ename;

/*
9. Query all employees that are not manager, sorted by salary desc.
*/
select *
from emp
where job != 'manager'
order by sal desc;

/*
10. Query ename, job, sal, deptno, excluding Salesman.
*/
select ename, job, sal, deptno
from emp
where job != 'salesman';
