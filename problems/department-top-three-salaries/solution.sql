with cte_1 as(
    select id
    from Department
    group by id
),
cte_2 as(
    select
        e.salary, e.departmentId
    from
        Employee as e
        inner join cte_1 on e.departmentId = cte_1.id
    where
        e.salary in (
            select top_salaries.salary
            from Employee as top_salaries join (select Employee.salary as slry from Employee where Employee.departmentId = cte_1.id group by Employee.salary order by Employee.salary desc limit 3) r
            on top_salaries.salary in (r.slry)
            )
)

select
    d.name as Department, e.name as Employee, e.salary as Salary
from
    Department as d
    inner join Employee as e on e.departmentId = d.id
    inner join cte_2 on (cte_2.salary = e.salary and cte_2.departmentId = e.departmentId)
group by e.id


-- refacto
select d.name as Department, e.name as Employee, e.salary as Salary
from
    Employee as e
    inner join Department as d on e.departmentId = d.id
where
    e.salary in (
        select salary
        from Employee join (
            select Employee.salary as slry
            from Employee
            where Employee.departmentId = d.id
            group by Employee.salary
            order by Employee.salary
            desc limit 3) r
        on salary in (r.slry)
    )