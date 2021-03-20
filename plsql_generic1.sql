set serveroutput on;
DECLARE
  --Declare variables
  x_salary  employee.salary%TYPE;
  x_last    employee.lname%TYPE;
BEGIN
  --Retrieve the salary data
  select salary, lname into x_salary, x_last from employee WHERE SSN = '999887777';
  --Display the results
  dbms_output.put_line (x_last || ' salary is $' || x_salary);
END;
-------------------------------------------------------------------------------
DECLARE
	x_salary employee.salary%TYPE;
BEGIN
	select salary
	into x_salary
	from employee
	where ssn=&enter_ssn;
	--Output the result
	DBMS_OUTPUT.PUT_LINE('Salary is ' || x_salary);
EXCEPTION
	--Output when no records are returned
	WHEN no_data_found THEN
		DBMS_OUTPUT.PUT_LINE ('No employee found');
	WHEN others THEN
		DBMS_OUTPUT.PUT_LINE ('Error encountered, but cause unknown');
END;
-------------------------------------------------------------------------------
DECLARE
BEGIN
  FOR I IN 1..1000 LOOP
  	--Insert data into the employee table
  	INSERT INTO employee (ssn, fname, lname, dno, salary)
  	VALUES (900000000 + I, 'John', 'Doe', 1, 30000 + I);
  END LOOP;
  --Commit changes
  commit;
EXCEPTION
  --Output when no records are returned
  WHEN OTHERS THEN
    ROLLBACK;
END;
-------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
	--Declare variables
	1Number	NUMBER(4);
	2Char	CHAR(10);
BEGIN
	--Tell the user that everything is working
	DBMS_OUTPUT.PUT_LINE('Compiled declarations successfully');
END;
-------------------------------------------------------------------------------
set serveroutput on;
DECLARE
  --Declare variables
  rowEmp1  employee%ROWTYPE;
  rowEmp2  employee%ROWTYPE;
BEGIN
  --Fill the fields
  rowEmp1.lname := 'Doe';
  rowEmp1.fname := 'John';
  rowEmp2.lname := 'Doe';
  rowEmp2.fname := 'Jane';
  --Output one of the records
  dbms_output.put_line ('Row 1 is ' || rowEmp1.lname || ', ' || rowEmp1.fname || '.');
END;
-------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
  --Declare the table
  TYPE EmpSSNarray
    IS TABLE OF employee.ssn%TYPE
    INDEX BY SIMPLE_INTEGER;
  --Declare variables using the table
  ManagementList  EmpSSNarray;
  WorkerList      EmpSSNarray;
BEGIN
  --Retrieve the first Supervisor
  SELECT superssn
  INTO ManagementList(1)
  FROM employee
  WHERE superssn IS NOT NULL
  AND ROWNUM <= 1;
  --Retrieve the second Supervisor
  SELECT superssn
  INTO ManagementList(2)
  FROM employee
  WHERE superssn IS NOT NULL
  AND ROWNUM <= 1
  AND superssn <> ManagementList(1);
  --Retrieve the first worker
  SELECT essn
  INTO WorkerList(1)
  FROM works_on
  WHERE hours IS NOT NULL
  AND ROWNUM <= 1
  AND essn NOT IN (ManagementList(1), ManagementList(2));
  --Retrieve the second worker
  SELECT essn
  INTO WorkerList(2)
  FROM works_on
  WHERE hours IS NOT NULL
  AND ROWNUM <= 1
  AND essn NOT IN (ManagementList(1), ManagementList(2), WorkerList(1));
  --Output the results
  dbms_output.put_line ('Managers are: ' || ManagementList(1) || ', ' || ManagementList(2));
  dbms_output.put_line ('Workers are: ' || WorkerList(1) || ', ' || WorkerList(2));
END;
-------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
  --Declare the record
  TYPE EmpRecord
    IS RECORD (ssn            employee.ssn%TYPE,
               LName          employee.lname%TYPE,
               DName          department.DName%TYPE,
               BonusPayment   NUMBER(6)
               );
  --Declare variables
  ActiveEmp     EmpRecord;
  InactiveEmp   EmpRecord;
BEGIN
  --Retrieve the Active employee detail
  SELECT essn, LName, DName, 5000
  INTO ActiveEmp
  FROM employee, department, works_on
  WHERE employee.dno = department.dnumber
  AND employee.ssn = works_on.essn
  AND hours = (SELECT MAX(hours) FROM works_on)
  AND ROWNUM <= 1;
  --Output the results
  dbms_output.put_line('Active employee name: ' || ActiveEmp.LName);
  dbms_output.put_line('Active employee department: ' || ActiveEmp.DName);
  dbms_output.put_line('Active employee bonus: $' || ActiveEmp.BonusPayment);
  --Retrieve the Inactive employee detail
  SELECT essn, LName, DName, 0
  INTO InactiveEmp
  FROM employee, department, works_on
  WHERE employee.dno = department.dnumber
  AND employee.ssn = works_on.essn
  AND hours = (SELECT MIN(hours) FROM works_on)
  AND ROWNUM <= 1;
  --Output the results
  dbms_output.put_line('Inactive employee name: ' || InactiveEmp.LName);
  dbms_output.put_line('Inactive employee department: ' || InactiveEmp.DName);
  dbms_output.put_line('Inactive employee bonus: $' || InactiveEmp.BonusPayment);
END;
-------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
  --Simple type declaration
  TYPE BonusCompensation
    IS RECORD (CashPayment    NUMBER(6),
               CompanyCar     BOOLEAN,
               VacationWeeks  NUMBER(2)
               );
  --Extended type declaration
  TYPE EmpRecord
    IS RECORD (ssn            employee.ssn%TYPE,
               LName          employee.lname%TYPE,
               DName          department.DName%TYPE,
               BonusPayment   BonusCompensation
               );
  --Another extended type declaration along with the instance declaration
  TYPE ManagerRecord
    IS RECORD (ssn            employee.ssn%TYPE,
               BonusPayment   BonusCompensation
               );
  --Instance Declaration
  BestEmp       EmpRecord;
  BestManager   ManagerRecord;
BEGIN
  /*
  Less than meaningful logic to determine the employee who should receive
  a bonus.  The main focus in this example is the ability to store datbase
  values within the record instance.
  */
  SELECT essn, LName, DName
  INTO BestEmp.ssn,
       BestEmp.LName,
       BestEmp.DName
  FROM employee, department, works_on
  WHERE employee.dno = department.dnumber
  AND employee.ssn = works_on.essn
  AND hours = (SELECT MAX(hours) FROM works_on)
  AND ROWNUM <= 1;
  --The next segment of code accesses the values within the record instance
  BestEmp.BonusPayment.CashPayment := 5000;
  BestEmp.BonusPayment.CompanyCar := TRUE;
  BestEmp.BonusPayment.VacationWeeks := 1;
  --Output the results
  dbms_output.put_line('Best employee name: ' || BestEmp.LName);
  dbms_output.put_line('Best employee department: ' || BestEmp.DName);
  dbms_output.put_line('Best employee bonus payment: $' || BestEmp.BonusPayment.CashPayment);
  --Test for company car
  IF BestEmp.BonusPayment.CompanyCar = TRUE THEN
    dbms_output.put_line ('Company car also provided');
  END IF;
  --Test for vacation weeks
  IF BestEmp.BonusPayment.VacationWeeks > 0 THEN
    dbms_output.put_line ('Extra vacation weeks granted: ' || BestEmp.BonusPayment.VacationWeeks);
  END IF;
  /*
  A similar set of instructions uses the other record instance.  This is used to
  perform similar logic for a manager who is selected for bonus compensation.
  */
  SELECT ssn
  INTO BestManager.ssn
  FROM employee, department
  WHERE employee.ssn = department.MgrSSN
  AND ROWNUM <= 1;
  --The next segment of code accesses the values within the record instance
  BestManager.BonusPayment.CashPayment := 10000;
  BestManager.BonusPayment.CompanyCar := TRUE;
  BestManager.BonusPayment.VacationWeeks := 2;
  --Output the results
  dbms_output.put_line('');
  dbms_output.put_line('Best manager SSN: ' || BestManager.ssn);
  dbms_output.put_line('Best manager bonus payment: $' || BestManager.BonusPayment.CashPayment);
  --Test for company car
  IF BestManager.BonusPayment.CompanyCar = TRUE THEN
    dbms_output.put_line ('Company car also provided');
  END IF;
  --Test for vacation weeks
  IF BestManager.BonusPayment.VacationWeeks > 0 THEN
    dbms_output.put_line ('Extra vacation weeks granted: ' || BestManager.BonusPayment.VacationWeeks);
  END IF;
/*
  --Retrieve the Inactive employee detail
  SELECT essn, LName, DName, 0
  INTO InactiveEmp
  FROM employee, department, works_on
  WHERE employee.dno = department.dnumber
  AND employee.ssn = works_on.essn
  AND hours = (SELECT MIN(hours) FROM works_on)
  AND ROWNUM <= 1;
  --Output the results
  dbms_output.put_line('Inactive employee name: ' || InactiveEmp.LName);
  dbms_output.put_line('Inactive employee department: ' || InactiveEmp.DName);
  dbms_output.put_line('Inactive employee bonus: $' || InactiveEmp.BonusPayment);
*/
END;
