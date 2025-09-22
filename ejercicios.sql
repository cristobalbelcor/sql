-- Ver empleados (muestra controlada)
SELECT *
FROM employees
LIMIT 100;

-- ¿Cuántos empleados hay (total histórico)?
SELECT COUNT(*) AS total_empleados
FROM employees;

-- ¿Último empleado contratado? (nombre completo y fecha)
SELECT CONCAT(first_name, ' ', last_name) AS nombre, hire_date AS fecha_contratacion
FROM employees
ORDER BY hire_date DESC
LIMIT 1;

/*
   2) SALARIOS (HISTÓRICOS vs ACTUALES)
 */

-- Salario más alto y más bajo registrado (histórico)
SELECT MIN(salary) AS salario_min, MAX(salary) AS salario_max
FROM salaries;

-- Salario promedio (histórico)
SELECT AVG(salary) AS salario_promedio_historico
FROM salaries;

-- Salario actual de cada empleado (solo filas “actuales”)
SELECT 
  e.emp_no,
  e.first_name AS nombre,
  e.last_name  AS apellido,
  s.salary     AS salario_actual
FROM employees e
JOIN salaries  s ON e.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01';

-- Empleados cuyo salario actual > promedio (promedio basado en salarios actuales)
SELECT 
  e.emp_no,
  e.first_name AS nombre,
  e.last_name  AS apellido,
  s.salary     AS salario_actual
FROM employees e
JOIN salaries  s ON e.emp_no = s.emp_no
WHERE s.to_date = '9999-01-01'
  AND s.salary > (
    SELECT AVG(s2.salary)
    FROM salaries s2
    WHERE s2.to_date = '9999-01-01'
  );

-- Empleado(s) con el salario más alto registrado (histórico)
SELECT 
  e.first_name AS nombre, 
  e.last_name  AS apellido, 
  s.salary
FROM employees e
JOIN salaries  s ON e.emp_no = s.emp_no
WHERE s.salary = (SELECT MAX(salary) FROM salaries);

/*
   3) DEMOGRAFÍA
 */

-- Conteo por género (histórico, 1 por empleado)
SELECT gender, COUNT(*) AS total
FROM employees
GROUP BY gender;

-- Antigüedad (años) por empleado
SELECT e.emp_no, TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) AS antiguedad_anios
FROM employees e;

-- Iniciales por empleado (p. ej. 'G.F.')
SELECT CONCAT(LEFT(first_name,1), '.', LEFT(last_name,1), '.') AS iniciales
FROM employees;

/*
   4) CARGOS (TITLES)
  */

-- ¿Cuántos empleados han ostentado cada cargo (histórico)?
-- Ordenado del cargo más común al menos común
SELECT 
  t.title, 
  COUNT(*) AS total_hist
FROM titles t
GROUP BY t.title
ORDER BY total_hist DESC;

-- Cargos ocupados por más de 75,000 personas (histórico)
SELECT 
  t.title, 
  COUNT(*) AS total_hist
FROM titles t
GROUP BY t.title
HAVING COUNT(*) > 75000
ORDER BY total_hist DESC;

-- ¿Cuántos empleados M y F hay por cargo (actual)?
-- Nota: usamos el cargo actual de cada empleado
SELECT 
  t.title,
  e.gender,
  COUNT(*) AS total
FROM titles t
JOIN employees e ON e.emp_no = t.emp_no
WHERE t.to_date = '9999-01-01'
GROUP BY t.title, e.gender
ORDER BY t.title, e.gender;

-- Todos los cargos del empleado 10006 (histórico) con fechas
SELECT 
  t.title      AS cargo,
  t.from_date  AS fecha_inicio,
  t.to_date    AS fecha_fin
FROM titles t
WHERE t.emp_no = 10006
ORDER BY t.from_date;

-- El 'Senior Engineer' mejor pagado (salario actual)
SELECT 
  e.first_name AS nombre,
  e.last_name  AS apellido,
  s.salary     AS salario_actual
FROM employees e
JOIN titles    t ON t.emp_no = e.emp_no AND t.to_date = '9999-01-01'
JOIN salaries  s ON s.emp_no = e.emp_no AND s.to_date = '9999-01-01'
WHERE t.title = 'Senior Engineer'
ORDER BY s.salary DESC
LIMIT 1;

/* 
   5) DEPARTAMENTOS & GERENTES
 */

-- Empleado (emp_no, nombre) + departamento actual
SELECT 
  e.emp_no,
  e.first_name AS nombre,
  e.last_name  AS apellido,
  d.dept_name  AS departamento
FROM employees   e
JOIN dept_emp    de ON de.emp_no = e.emp_no AND de.to_date = '9999-01-01'
JOIN departments d  ON d.dept_no = de.dept_no;

-- Empleados del departamento "Marketing" (actuales)
SELECT 
  e.first_name AS nombre,
  e.last_name  AS apellido
FROM employees   e
JOIN dept_emp    de ON e.emp_no = de.emp_no  AND de.to_date = '9999-01-01'
JOIN departments d  ON de.dept_no = d.dept_no
WHERE d.dept_name = 'Marketing';

-- Gerentes de departamento (actuales): emp_no, nombre completo y depto
SELECT 
  e.emp_no,
  e.first_name AS nombre,
  e.last_name  AS apellido,
  d.dept_name  AS departamento
FROM employees     e
JOIN dept_manager  dm ON e.emp_no = dm.emp_no   AND dm.to_date = '9999-01-01'
JOIN departments   d  ON dm.dept_no = d.dept_no
ORDER BY d.dept_name;

-- Salario promedio actual por departamento
SELECT
  d.dept_name                AS departamento,
  AVG(s.salary)              AS salario_promedio_actual
FROM departments d
JOIN dept_emp   de ON de.dept_no = d.dept_no AND de.to_date = '9999-01-01'
JOIN salaries   s  ON s.emp_no  = de.emp_no  AND s.to_date  = '9999-01-01'
GROUP BY d.dept_name
ORDER BY d.dept_name;

-- Departamento con el mejor salario promedio actual
SELECT
  d.dept_name                AS departamento,
  AVG(s.salary)              AS salario_promedio_actual
FROM departments d
JOIN dept_emp   de ON de.dept_no = d.dept_no AND de.to_date = '9999-01-01'
JOIN salaries   s  ON s.emp_no  = de.emp_no  AND s.to_date  = '9999-01-01'
GROUP BY d.dept_name
ORDER BY salario_promedio_actual DESC
LIMIT 1;

-- ¿Algún departamento sin empleados asignados (histórico)?
-- (Si quieres "sin empleados actuales", agrega AND de.to_date='9999-01-01' en el JOIN y mueve la condición al ON)
SELECT 
  d.dept_name,
  de.emp_no
FROM departments d
LEFT JOIN dept_emp de ON d.dept_no = de.dept_no
WHERE de.emp_no IS NULL;

-- Nombres de los gerentes que han dirigido "Development" (histórico)
SELECT 
  e.first_name AS nombre,
  e.last_name  AS apellido,
  d.dept_name
FROM employees     e
JOIN dept_manager  dm ON dm.emp_no = e.emp_no
JOIN departments   d  ON d.dept_no = dm.dept_no
WHERE d.dept_name = 'Development';

/* 
   6) SUBCONSULTAS ÚTILES
 */

-- Personas que son o han sido gerentes (histórico)
SELECT 
  e.first_name AS nombre,
  e.last_name  AS apellido
FROM employees e
WHERE e.emp_no IN (SELECT dm.emp_no FROM dept_manager dm);

-- Empleados que nunca han sido gerentes
SELECT 
  e.first_name AS nombre,
  e.last_name  AS apellido
FROM employees e
WHERE e.emp_no NOT IN (SELECT dm.emp_no FROM dept_manager dm);

/* 
   7) AGRUPACIONES & FECHAS
*/

-- Contrataciones por mes (independiente del año)
SELECT 
  MONTH(e.hire_date) AS mes,
  COUNT(*)           AS empleados_contratados
FROM employees e
GROUP BY MONTH(e.hire_date)
ORDER BY mes;

/*
   8) UTILIDADES VARIAS
 */

-- Top 100 nombres completos
SELECT CONCAT(e.first_name, ' ', e.last_name) AS nombre_completo
FROM employees e
LIMIT 100;

-- Pares de empleados contratados el mismo día
SELECT 
  e1.first_name AS empleado1_nombre, 
  e1.last_name  AS empleado1_apellido, 
  e2.first_name AS empleado2_nombre, 
  e2.last_name  AS empleado2_apellido, 
  e1.hire_date  AS fecha_contratacion
FROM employees e1
JOIN employees e2 
  ON e1.hire_date = e2.hire_date 
 AND e1.emp_no    < e2.emp_no
ORDER BY e1.hire_date;

-- Diferencia entre primer y salario actual del empleado 10001
SELECT 
  e.first_name AS nombre,
  e.last_name  AS apellido,
  (SELECT salary FROM salaries WHERE emp_no = 10001 ORDER BY from_date ASC  LIMIT 1) AS primer_salario,
  (SELECT salary FROM salaries WHERE emp_no = 10001 AND to_date = '9999-01-01' LIMIT 1) AS salario_actual,
  (SELECT salary FROM salaries WHERE emp_no = 10001 AND to_date = '9999-01-01' LIMIT 1)
  -
  (SELECT salary FROM salaries WHERE emp_no = 10001 ORDER BY from_date ASC  LIMIT 1) AS diferencia_salarial
FROM employees e
WHERE e.emp_no = 10001;
