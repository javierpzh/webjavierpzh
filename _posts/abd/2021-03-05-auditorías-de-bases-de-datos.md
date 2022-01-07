---
layout: post
---

## Oracle

#### Vamos a activar las auditorías en nuestro servidor.

Por defecto, *Oracle* incorpora las auditorías activadas, pero aún así, si queremos comprobar dicho funcionamiento por nosotros mismos, podríamos ejecutar la siguiente sentencia:

<pre>
SQL> SELECT name, value
  2  FROM v$parameter
  3  WHERE name like 'audit_trail';

NAME
--------------------------------------------------------------------------------
VALUE
--------------------------------------------------------------------------------
audit_trail
DB
</pre>

Podemos ver que efectivamente están activadas, ya que el parámetro `audit_trail`, posee el valor `db`, lo cual quiere decir que las auditorías se encuentran activadas y que los registros se almacenan en la base de datos.

En caso de que estuviesen desactivadas, es decir, que el parámetro `audit_trail`, posea el valor `NONE`, podríamos activarlas ejecutando la siguiente sentencia:

<pre>
ALTER SYSTEM SET audit_trail=db scope=spfile;
</pre>

Listo.

#### Vamos a activar la auditoría de los intentos de acceso fallidos al sistema.

En este apartado vamos a activar la auditoría que se encarga de detectar los intentos de acceso fallidos:

<pre>
SQL> AUDIT CREATE SESSION WHENEVER NOT SUCCESSFUL;

Auditoria terminada correctamente.
</pre>

Una vez habilitada, para comprobar su funcionamiento, realizaremos un inicio de sesión erróneo y posteriormente, visualizaremos como se ha registrado dicho intento de acceso:

<pre>
SQL> connect usuarioerror/error
ERROR:
ORA-01017: nombre de usuario/contrase?a no validos; conexion denegada

SQL> connect sysdba
Introduzca la contrase?a:
...

SQL> SELECT os_username, username, extended_timestamp, action_name, returncode
  2  FROM DBA_AUDIT_SESSION;

OS_USERNAME
--------------------------------------------------------------------------------
USERNAME
--------------------------------------------------------------------------------
EXTENDED_TIMESTAMP
---------------------------------------------------------------------------
ACTION_NAME		     RETURNCODE
---------------------------- ----------
oracle
USUARIOERROR
04/03/21 15:38:26,163150 +01:00
LOGON				   1017
</pre>

Podemos ver como efectivamente nos muestra el intento de acceso fallido, además del nombre de usuario utilizado, la fecha exacta, ...


#### Vamos a activar la auditoría de las operaciones DML realizadas por SCOTT.

En este apartado vamos a activar la auditoría de las operaciones DML realizadas por SCOTT, para ello ejecutamos la siguiente sentencia SQL:

<pre>
SQL> AUDIT INSERT TABLE, UPDATE TABLE, DELETE TABLE BY SCOTT;

Auditoria terminada correctamente.
</pre>

Una vez habilitada, para comprobar su funcionamiento, realizaremos un *INSERT*, un *UPDATE* y un *DELETE* y posteriormente, visualizaremos como se han registrado en dicha auditoría:

<pre>
SQL> INSERT INTO DEPT (DEPTNO, DNAME, LOC) VALUES (50,'Pruebas','Sevilla');

1 fila creada.

SQL> UPDATE DEPT SET LOC='Dos Hermanas' WHERE DEPTNO=50;

1 fila actualizada.

SQL> DELETE FROM DEPT WHERE DEPTNO=50;

1 fila suprimida.

SQL> SELECT username, obj_name, action_name, extended_timestamp
  2  FROM DBA_AUDIT_OBJECT;

USERNAME
------------------------------
OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME
----------------------------
EXTENDED_TIMESTAMP
---------------------------------------------------------------------------
SCOTT
DEPT
INSERT
04/03/21 16:21:19,163150 +01:00


USERNAME
------------------------------
OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME
----------------------------
EXTENDED_TIMESTAMP
---------------------------------------------------------------------------
SCOTT
DEPT
UPDATE
04/03/21 16:21:28,264893 +01:00


USERNAME
------------------------------
OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME
----------------------------
EXTENDED_TIMESTAMP
---------------------------------------------------------------------------
SCOTT
DEPT
DELETE
04/03/21 16:21:43,371902 +01:00
</pre>

Podemos ver como efectivamente nos muestra el usuario que ha realizado la acción, qué acción ha realizado, la fecha exacta, ...


#### Auditoría de grano fino

Las auditorías de grano fino son auditorías que almacenan más datos sobre las sentencias que ejecutamos, como la estructura completa de la sentencias.

Es decir, gracias a ellas, podríamos saber qué consulta ha sido ejecutada sobre una tabla o qué datos
han sido insertados, modificados o borrados.


#### Vamos a realizar una auditoría de grano fino para almacenar información sobre la inserción de empleados del departamento 10 de la tabla EMP de SCOTT.

Ahora que ya sabemos lo que son las auditorías de grano fino (FGA), vamos a crear una que almacenen información sobre la inserción de empleados del departamento 10 de la tabla *EMP* de *SCOTT*.

Vamos a crear la siguiente auditoría de grano fino para ello:

<pre>
SQL> BEGIN
  2  DBMS_FGA.ADD_POLICY (
  3  OBJECT_SCHEMA      => 'SCOTT',
  4  OBJECT_NAME        => 'EMP',
  5  POLICY_NAME        => 'audit_fino_javier',
  6  AUDIT_CONDITION    => 'DEPTNO = 10',
  7  STATEMENT_TYPES    => 'INSERT'
  8  );
  9  end;
 10  /

Procedimiento PL/SQL terminado correctamente.
</pre>

Una vez creadas, vamos a realizar una serie de inserciones en el departamento 10, y posteriormente comprobaremos la información almacenada:

<pre>
SQL> INSERT INTO EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) VALUES (9000, 'Javier', 'Administr', 8500, '19-11-2001', 2000, NULL, 10);

1 fila creada.

SQL> INSERT INTO EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) VALUES (9001, 'Pablo', 'Administr', 8600, '22-01-1997', 2100, NULL, 10);

1 fila creada.

SQL> SELECT DB_USER, OBJECT_NAME, SQL_TEXT, EXTENDED_TIMESTAMP
  2  FROM DBA_FGA_AUDIT_TRAIL
  3  WHERE POLICY_NAME='AUDIT_FINO_JAVIER';

DB_USER
------------------------------
OBJECT_NAME
--------------------------------------------------------------------------------
SQL_TEXT
--------------------------------------------------------------------------------
EXTENDED_TIMESTAMP
---------------------------------------------------------------------------
SCOTT
EMP
INSERT INTO EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) VALUES (90
00, 'Javier', 'Administr', 8500, '19-11-2001', 2000, NULL, 10)
04/03/21 17:30:24,253000 +01:00

DB_USER
------------------------------
OBJECT_NAME
--------------------------------------------------------------------------------
SQL_TEXT
--------------------------------------------------------------------------------
EXTENDED_TIMESTAMP
---------------------------------------------------------------------------
SCOTT
EMP
INSERT INTO EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) VALUES (90
01, 'Pablo', 'Administr', 8600, '22-01-1997', 2100, NULL, 10)
04/03/21 17:31:23,488000 +01:00
</pre>

Podemos ver como efectivamente nos muestra la información relativa a las acciones realizadas.


#### Diferencias entre auditar una operación 'BY ACCESS' o 'BY SESSION'.

La principal diferencia entre ambas operaciones es la siguiente:

- **BY ACCESS:** almacena un registro por cada acción realizada independientemente de si es repetida o no.
- **BY SESSION:** almacena un solo registro de una misma acción que hagamos, evitando repetirlas.

Para terminar, hay que saber, que al activar una auditoría, podemos indicar el tipo que deseamos, si **BY ACCESS** o **BY SESSION**. Por ejemplo:

<pre>
AUDIT INSERT TABLE, UPDATE TABLE, DELETE TABLE BY SCOTT BY {ACCESS/SESSION};
</pre>

Listo.


#### Diferencias entre los valores 'DB' y 'DB, EXTENDED' del parámetro audit_trail.

Ambos valores activan la auditoría y almacenan los datos en la tabla **SYS.AUD$** de *Oracle*, pero, la principal diferencia que existe entre ellos es que, el valor **DB, EXTENDED**, además almacena los datos correspondientes en las columnas **SQLBIND** y **SQLTEXT** de dicha tabla, *SYS.AUD$*, mientras que el valor **DB** no lo hace.

Ahora, vamos a ver como podríamos cambiar de un valor a otro.

En primer lugar, para ver cuál de los dos estamos utilizando, ejecutaremos la siguiente sentencia:

<pre>
SQL> SHOW PARAMETER AUDIT_TRAIL

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
audit_trail                          string      DB
</pre>

Vemos como actualmente, en mi caso, poseo el valor **DB**. Ahora voy a cambiar al valor **DB, EXTENDED**:

<pre>
SQL> ALTER SYSTEM SET audit_trail = "DB_EXTENDED" SCOPE=SPFILE;

Sistema modificado.
</pre>

Parece que ya se ha cambiado, pero no, para que se aplique este cambio, es necesario que reiniciemos la base de datos, por lo que vamos a ello:

<pre>
SQL> shutdown
Base de datos cerrada.
Base de datos desmontada.
Instancia ORACLE cerrada.

SQL> startup
Instancia ORACLE iniciada.

Total System Global Area 1720328192 bytes
Fixed Size                  2176448 bytes
Variable Size            1073744448 bytes
Database Buffers          637534208 bytes
Redo Buffers                6873088 bytes
Base de datos montada.
Base de datos abierta.
</pre>

Comprobamos de nuevo que valor estamos utilizando:

<pre>
SQL> SHOW PARAMETER AUDIT_TRAIL

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
audit_trail                          string      DB_EXTENDED
</pre>

Vemos como efectivamente ahora sí, hemos cambiado al nuevo valor.


## PostgreSQL

#### Vamos a activar las auditorías en nuestro servidor.

*PostgreSQL* por defecto no incorpora una herramienta de auditorías, por lo que, si queremos conseguir realizar auditorías, tendremos que descargarnos una herramienta que ha desarrollado la comunidad, llamada **Audit trigger 91plus**.

Esta herramienta consiste en una serie de *scripts* y *triggers* que realizan las acciones necesarias para simular las auditorías.

Para descargarnos la herramienta debemos utilizar el siguiente comando:

<pre>
wget https://raw.githubusercontent.com/2ndQuadrant/audit-trigger/master/audit.sql
</pre>

Una vez descargada, nos conectaremos a nuestro servidor y ejecutaremos el siguiente comando:

<pre>
scott=# \i audit.sql
CREATE EXTENSION
CREATE SCHEMA
REVOKE
COMMENT
CREATE TABLE
REVOKE
COMMENT
COMMENT
COMMENT
COMMENT
COMMENT
COMMENT
COMMENT
COMMENT
COMMENT
COMMENT
COMMENT
COMMENT
COMMENT
COMMENT
COMMENT
COMMENT
COMMENT
COMMENT
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE FUNCTION
COMMENT
CREATE FUNCTION
COMMENT
CREATE FUNCTION
CREATE FUNCTION
COMMENT
CREATE VIEW
COMMENT
</pre>

Por último, tan sólo nos faltaría activar la recogida de datos en dichas auditorías, para ello ejecutamos la siguiente sentencia:

<pre>
select audit.audit_table({nombretabla});
</pre>

Listo.


#### Vamos a activar la auditoría de los intentos de acceso fallidos al sistema.

No es posible activar este tipo de auditoría en *PostgreSQL*.


#### Vamos a activar la auditoría de las operaciones DML.

En este apartado vamos a activar la auditoría de las operaciones DML en la tabla *DEPT*, para ello ejecutamos la siguiente sentencia SQL:

<pre>
scott=# select audit.audit_table('dept');
NOTICE:  trigger "audit_trigger_row" for relation "dept" does not exist, skipping
NOTICE:  trigger "audit_trigger_stm" for relation "dept" does not exist, skipping
NOTICE:  CREATE TRIGGER audit_trigger_row AFTER INSERT OR UPDATE OR DELETE ON dept FOR EACH ROW EXECUTE PROCEDURE audit.if_modified_func('true');
NOTICE:  CREATE TRIGGER audit_trigger_stm AFTER TRUNCATE ON dept FOR EACH STATEMENT EXECUTE PROCEDURE audit.if_modified_func('true');
 audit_table
-------------

(1 row)
</pre>

Una vez habilitada, para comprobar su funcionamiento, realizaremos un *INSERT*, un *UPDATE* y un *DELETE* y posteriormente, visualizaremos como se han registrado en dicha auditoría:

<pre>
scott=# INSERT INTO DEPT (DEPTNO, DNAME, LOC) VALUES (50,'Pruebas','Sevilla');
INSERT 0 1

scott=# UPDATE DEPT SET LOC='Dos Hermanas' WHERE DEPTNO=50;
UPDATE 1

scott=# DELETE FROM DEPT WHERE DEPTNO=50;
DELETE 1

scott=# select session_user_name, action, table_name, action_tstamp_clk, client_query
from audit.logged_actions;
 session_user_name | action | table_name |       action_tstamp_clk       |                              client_query                              
-------------------+--------+------------+-------------------------------+------------------------------------------------------------------------
 postgres          | I      | dept       | 2021-03-05 11:58:31.904308+00 | INSERT INTO DEPT (DEPTNO, DNAME, LOC) VALUES (50,'Pruebas','Sevilla');
 postgres          | U      | dept       | 2021-03-05 11:58:31.905631+00 | UPDATE DEPT SET LOC='Dos Hermanas' WHERE DEPTNO=50;
 postgres          | D      | dept       | 2021-03-05 11:58:32.84674+00  | DELETE FROM DEPT WHERE DEPTNO=50;
(3 rows)
</pre>

Podemos ver como efectivamente nos muestra el usuario que ha realizado la acción, qué acción ha realizado, la fecha exacta, ... Pero además podemos apreciar como directamente, nos muestra las sentencias introducidas, por lo que esta auditoría sería de **grano fino**.


## MySQL

#### Vamos a activar las auditorías en nuestro servidor.

Para activar las auditorías en *MySQL*, debemos ejecutar la siguiente sentencia:

<pre>
SET SESSION profiling = 1;
</pre>

Listo.


#### Vamos a activar la auditoría de los intentos de acceso fallidos al sistema.

No es posible activar este tipo de auditoría en *MySQL*.


#### Vamos a activar la auditoría de las operaciones DML.

En este apartado vamos a ver como se auditan las operaciones DML.

Para comprobar su funcionamiento, realizaremos un *INSERT*, un *UPDATE* y un *DELETE* y posteriormente, visualizaremos como se han registrado dichas operaciones:

<pre>
MariaDB [scott]> INSERT INTO DEPT (DEPTNO, DNAME, LOC) VALUES (50,'Pruebas','Sevilla');
Query OK, 1 row affected (0.004 sec)

MariaDB [scott]> UPDATE DEPT SET LOC='Dos Hermanas' WHERE DEPTNO=50;
Query OK, 1 row affected (0.001 sec)
Rows matched: 1  Changed: 1  Warnings: 0

MariaDB [scott]> DELETE FROM DEPT WHERE DEPTNO=50;
Query OK, 1 row affected (0.004 sec)

MariaDB [scott]> SHOW PROFILES;
+----------+------------+-----------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                 |
+----------+------------+-----------------------------------------------------------------------+
|        1 | 0.00027403 | SELECT DATABASE()                                                     |
|        2 | 0.00060149 | show databases                                                        |
|        3 | 0.00044156 | show tables                                                           |
|        4 | 0.00363078 | INSERT INTO DEPT (DEPTNO, DNAME, LOC) VALUES (50,'Pruebas','Sevilla') |
|        5 | 0.00136099 | UPDATE DEPT SET LOC='Dos Hermanas' WHERE DEPTNO=50                    |
|        6 | 0.00401232 | DELETE FROM DEPT WHERE DEPTNO=50                                      |
+----------+------------+-----------------------------------------------------------------------+
6 rows in set (0.000 sec)
</pre>

Podemos ver como nos muestra las sentencias introducidas, por lo que esta auditoría sería de **grano fino**.
