/***************************/
/*     MySQL Join Basics   */
/***************************/

-- Q. Query all employees ename, deptno, dname, sorted by deptno in ascending order
select e.ename, e.deptno, d.dname
from emp e join dept d on e.deptno = d.deptno
order by e.deptno;

-- Q. Query employees ename, job, sal, dname that works in New York
select e.ename, e.sal, d.dname, d.loc
from emp e join dept d on e.deptno = d.deptno
where d.loc = 'New York';

-- Q. Query all employees ename, dname, location that get commission
select e.ename, d.dname, d.loc
from emp e join dept d on e.deptno=d.deptno
where e.comm>0;

-- Q. Query employees ename, job, dname and location that has 'L' in their name
select e.ename, e.job, d.dname, d.loc
from emp e join dept d on e.deptno=d.deptno
where ename like '%L%';

-- Q. Query all employees with their empno, mgr name and mgrno
select e.ename Employee, e.empno, m.ename Manager, e.mgr mgrno
from emp e left join emp m on e.mgr=m.empno;
