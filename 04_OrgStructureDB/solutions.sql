--ЗАДАЧА 1
-- Найти всех сотрудников, подчиняющихся Ивану Иванову (с EmployeeID = 1),
-- включая их подчиненных и подчиненных подчиненных, а также самого Ивана Иванова.
-- Для каждого сотрудника вывести следующую информацию:
--  EmployeeID: идентификатор сотрудника.
--  Имя сотрудника.
--  ManagerID: Идентификатор менеджера.
--  Название отдела, к которому он принадлежит.
--  Название роли, которую он занимает.
--  Название проектов, к которым он относится (если есть, конкатенированные в одном столбце через запятую).
--  Название задач, назначенных этому сотруднику (если есть, конкатенированные в одном столбце через запятую).
--  Если у сотрудника нет назначенных проектов или задач, отобразить NULL.

-- Требования:
--  Рекурсивно извлечь всех подчиненных сотрудников Ивана Иванова и их подчиненных.
--  Для каждого сотрудника отобразить информацию из всех таблиц.
--  Результаты должны быть отсортированы по имени сотрудника.
--  Решение задачи должно представлять из себя один sql-запрос и задействовать ключевое слово RECURSIVE.

--РЕШЕНИЕ 1
WITH RECURSIVE employee_hierarchy AS (
    SELECT e.EmployeeID,
           e.Name,
           e.ManagerID,
           e.DepartmentID,
           e.RoleID
    FROM Employees e
    WHERE e.EmployeeID = 1

    UNION ALL

    SELECT e.EmployeeID,
           e.Name,
           e.ManagerID,
           e.DepartmentID,
           e.RoleID
    FROM Employees e
             JOIN employee_hierarchy eh ON e.ManagerID = eh.EmployeeID
),

               project_agg AS (
                   SELECT eh.EmployeeID,
                          STRING_AGG(DISTINCT p.ProjectName, ', ' ORDER BY p.ProjectName) AS ProjectNames
                   FROM employee_hierarchy eh
                            LEFT JOIN Projects p ON p.DepartmentID = eh.DepartmentID
                   GROUP BY eh.EmployeeID
               ),

               task_agg AS (
                   SELECT eh.EmployeeID,
                          STRING_AGG(t.TaskName, ', ' ORDER BY t.TaskName) AS TaskNames
                   FROM employee_hierarchy eh
                            LEFT JOIN Tasks t ON t.AssignedTo = eh.EmployeeID
                   GROUP BY eh.EmployeeID
               )
SELECT eh.EmployeeID,
       eh.Name AS EmployeeName,
       eh.ManagerID,
       d.DepartmentName,
       r.RoleName,
       pa.ProjectNames,
       ta.TaskNames
FROM employee_hierarchy eh
         JOIN Departments d ON d.DepartmentID = eh.DepartmentID
         JOIN Roles r ON r.RoleID = eh.RoleID
         LEFT JOIN project_agg pa ON pa.EmployeeID = eh.EmployeeID
         LEFT JOIN task_agg ta ON ta.EmployeeID = eh.EmployeeID
ORDER BY eh.Name;

--ЗАДАЧА 2
-- Найти всех сотрудников, подчиняющихся Ивану Иванову с EmployeeID = 1,
-- включая их подчиненных и подчиненных подчиненных, а также самого Ивана Иванова.
-- Для каждого сотрудника вывести следующую информацию:
--  EmployeeID: идентификатор сотрудника.
--  Имя сотрудника.
--  Идентификатор менеджера.
--  Название отдела, к которому он принадлежит.
--  Название роли, которую он занимает.
--  Название проектов, к которым он относится (если есть, конкатенированные в одном столбце).
--  Название задач, назначенных этому сотруднику (если есть, конкатенированные в одном столбце).
--  Общее количество задач, назначенных этому сотруднику.
--  Общее количество подчиненных у каждого сотрудника (не включая подчиненных их подчиненных).
--  Если у сотрудника нет назначенных проектов или задач, отобразить NULL.

--РЕШЕНИЕ 2
WITH RECURSIVE employee_hierarchy AS (
    SELECT e.EmployeeID,
           e.Name,
           e.ManagerID,
           e.DepartmentID,
           e.RoleID
    FROM Employees e
    WHERE e.EmployeeID = 1

    UNION ALL

    SELECT e.EmployeeID,
           e.Name,
           e.ManagerID,
           e.DepartmentID,
           e.RoleID
    FROM Employees e
             JOIN employee_hierarchy eh ON e.ManagerID = eh.EmployeeID
),
               project_agg AS (
                   SELECT eh.EmployeeID,
                          STRING_AGG(DISTINCT p.ProjectName, ', ' ORDER BY p.ProjectName) AS ProjectNames
                   FROM employee_hierarchy eh
                            LEFT JOIN Projects p ON p.DepartmentID = eh.DepartmentID
                   GROUP BY eh.EmployeeID
               ),
               task_agg AS (
                   SELECT eh.EmployeeID,
                          STRING_AGG(t.TaskName, ', ' ORDER BY t.TaskName) AS TaskNames,
                          COUNT(t.TaskID) AS TotalTasks
                   FROM employee_hierarchy eh
                            LEFT JOIN Tasks t ON t.AssignedTo = eh.EmployeeID
                   GROUP BY eh.EmployeeID
               ),
               subordinate_agg AS (
                   SELECT eh.EmployeeID,
                          COUNT(child.EmployeeID) AS TotalSubordinates
                   FROM employee_hierarchy eh
                            LEFT JOIN employee_hierarchy child ON child.ManagerID = eh.EmployeeID
                   GROUP BY eh.EmployeeID
               )
SELECT eh.EmployeeID,
       eh.Name AS EmployeeName,
       eh.ManagerID,
       d.DepartmentName,
       r.RoleName,
       pa.ProjectNames,
       ta.TaskNames,
       ta.TotalTasks,
       sa.TotalSubordinates
FROM employee_hierarchy eh
         JOIN Departments d ON d.DepartmentID = eh.DepartmentID
         JOIN Roles r ON r.RoleID = eh.RoleID
         LEFT JOIN project_agg pa ON pa.EmployeeID = eh.EmployeeID
         LEFT JOIN task_agg ta ON ta.EmployeeID = eh.EmployeeID
         LEFT JOIN subordinate_agg sa ON sa.EmployeeID = eh.EmployeeID
ORDER BY eh.Name;


--ЗАДАЧА 3
-- Найти всех сотрудников, которые занимают роль менеджера и имеют подчиненных (то есть число подчиненных больше 0).
-- Для каждого такого сотрудника вывести следующую информацию:
--  EmployeeID: идентификатор сотрудника.
--  Имя сотрудника.
--  Идентификатор менеджера.
--  Название отдела, к которому он принадлежит.
--  Название роли, которую он занимает.
--  Название проектов, к которым он относится (если есть, конкатенированные в одном столбце).
--  Название задач, назначенных этому сотруднику (если есть, конкатенированные в одном столбце).
--  Общее количество подчиненных у каждого сотрудника (включая их подчиненных).
--  Если у сотрудника нет назначенных проектов или задач, отобразить NULL.
--  Find managers who have subordinates at any level

--РЕШЕНИЕ 3
WITH RECURSIVE subordinate_tree AS (
    SELECT e.EmployeeID AS manager_id,
           s.EmployeeID AS subordinate_id
    FROM Employees e
             -- Join Employees with Roles by role ID
             JOIN Roles r ON r.RoleID = e.RoleID
        -- Join Employees with Employees by manager ID
             JOIN Employees s ON s.ManagerID = e.EmployeeID
    WHERE r.RoleName = 'Менеджер'

    UNION ALL

    SELECT st.manager_id,
           e.EmployeeID AS subordinate_id
    FROM subordinate_tree st
             -- Join Employees with the recursive tree by manager ID
             JOIN Employees e ON e.ManagerID = st.subordinate_id
),
               subordinate_agg AS (
                   SELECT manager_id AS EmployeeID,
                          COUNT(DISTINCT subordinate_id) AS TotalSubordinates
                   FROM subordinate_tree
                   GROUP BY manager_id
               ),
               project_agg AS (
                   SELECT e.EmployeeID,
                          STRING_AGG(DISTINCT p.ProjectName, ', ' ORDER BY p.ProjectName) AS ProjectNames
                   FROM Employees e
                            -- Join Employees with Projects by department ID
                            LEFT JOIN Projects p ON p.DepartmentID = e.DepartmentID
                   GROUP BY e.EmployeeID
               ),
               task_agg AS (
                   SELECT e.EmployeeID,
                          STRING_AGG(t.TaskName, ', ' ORDER BY t.TaskName) AS TaskNames
                   FROM Employees e
                            -- Join Employees with Tasks by employee ID
                            LEFT JOIN Tasks t ON t.AssignedTo = e.EmployeeID
                   GROUP BY e.EmployeeID
               )
SELECT e.EmployeeID,
       e.Name AS EmployeeName,
       e.ManagerID,
       d.DepartmentName,
       r.RoleName,
       pa.ProjectNames,
       ta.TaskNames,
       sa.TotalSubordinates
FROM Employees e
         JOIN Roles r ON r.RoleID = e.RoleID
         JOIN Departments d ON d.DepartmentID = e.DepartmentID
         JOIN subordinate_agg sa ON sa.EmployeeID = e.EmployeeID
         LEFT JOIN project_agg pa ON pa.EmployeeID = e.EmployeeID
         LEFT JOIN task_agg ta ON ta.EmployeeID = e.EmployeeID
WHERE r.RoleName = 'Менеджер'
  AND sa.TotalSubordinates > 0
ORDER BY e.Name;
