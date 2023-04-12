use master
go


if db_id ('TAXI_SEGURO') is not null
Drop DataBase TAXI_SEGURO
go

Create Database TAXI_SEGURO
on
--MDF--ES LA BD PRINCIPAL_almacena datos
(name = Archivo_Datos, filename='C:\Data\Archivo_BDatosTaxi.mdf',
size = 12MB, maxsize= 800MB, filegrowth= 10MB),
--NDF--Ahi estan los datos que no caben en la BD principal--no es necesario
(name = Archivo_Secundario, filename ='C:\Data\Archivo_secundarioTaxi.ndf',
size= 8MB, maxsize= 400MB, filegrowth= 10%)
log on 
--ldf--Registro que se utiliza para recuperar la BD--al menos una
(name =  Archivo_Transacciones, filename= 'C:\Data\Archivo_TransaccionesTaxi.ldf', 
size= 8MB, maxsize= 100MB, filegrowth=10MB)
go

use TAXI_SEGURO
go

----------------------------------------------------------
Create table TIPO_DOCUMENTO
(
ID_TIPODOCUMENTO  int	not null primary key,
DESC_TIPODOCUMENTO  varchar(30) not null
)
go

-------------------------------------------------------
Create table CLIENTE
(
ID_CLIENTE int not null primary key,
NOMBRECLIENTE     varchar(30) not null,
APELLIDOCLIENTE	varchar(30) not null,
NUMERO_DOCUMENTO	int  not null,
DIRECCIONCLIENTE       varchar(200) not null,
CORREOCLIENTE		varchar(200) not null,
ID_TIPODOCUMENTO  int not null  foreign key references TIPO_DOCUMENTO (ID_TIPODOCUMENTO)
)
go

----------------------------------------------------------
Create table CONDUCTOR
(
IDCONDUCTOR int not null primary key,
NOMBRECONDUCTOR	 varchar(30) not null,
APELLIDOSCONDUCTOR	varchar(30) not null,
NRODOCUMENTO		 varchar(10) not null,
ID_TIPODOCUMENTO int foreign key references TIPO_DOCUMENTO(ID_TIPODOCUMENTO )
)
go

----------------------------------------------------------
Create table VEHICULO
(
PLACAVEHICULO	char(7)	not null primary key,
MARCAVEHICULO   char(20) not null,
COLORVEHICULO	char(20) not null,
AÑOFABRICACIONVEHICULO  char(4) not null,
ASIENTOSDISPONIBLES_VEHICULO  smallint	not null,
MODELOVEHICULO varchar(30) not null,
PAISFABRICACIONVEHICULO	 char(20) not null
)
go

----------------------------------------------------------
Create table LICENCIA
(
NUMERO_LICENCIA int not null primary key,
CATEGORIALICENCIA char(20) not null,
EMISIONLICENCIA date not null,
CADUCIDADLICENCIA date not null,
IDCONDUCTOR int not null foreign key references CONDUCTOR (IDCONDUCTOR)
)
go

----------------------------------------------------------

Create table EQUIPO
(
IDCONDUCTOR int not null foreign key  references CONDUCTOR(IDCONDUCTOR),
PLACAVEHICULO char(7) not null foreign key references VEHICULO (PLACAVEHICULO),
primary key (IDCONDUCTOR,PLACAVEHICULO)
)
go

----------------------------------------------------------

Create table FICHA_RESERVA
(
	NUMERO_RESERVA	int		not null	primary key,
	FECHAREGISTRORESERVA  date not null,
	HORAREGISTRORESERVA   time not null,
	FECHARESERVA		date not null, 
	HORARESERVA  time  not null, 
	DIRECCIONORIGEN varchar(200) not null, 
	DIRECCIONDESTINO varchar (200)not null,
	CANTIDADPERSONAS smallint not null, 
	CANTIDADMALETAS smallint not null,
	TOTALAPAGAR money not null,
	ESTADO varchar(20) not null,
	IDCONDUCTOR  int	not null foreign Key references CONDUCTOR (IDCONDUCTOR ),
	PLACAVEHICULO  char(7)	not null foreign Key references VEHICULO (PLACAVEHICULO ),
	ID_CLIENTE  int	not null foreign Key references CLIENTE(ID_CLIENTE  ),
)
go

----------------------------------------------------------
Create table BOLETAPAGO
(
NROBOLETA int not null primary key, 
FECHAREGISTRO date not null, 
HORAREGISTRO time not null, 
PRECIOTOTAL money not null,
ESTADO varchar (30)not null,
IDCONDUCTOR  int not null references CONDUCTOR(IDCONDUCTOR), 
ID_CLIENTE  int not null references CLIENTE (ID_CLIENTE),
NUMERO_RESERVA  int not null references FICHA_RESERVA (NUMERO_RESERVA )
)
go
----------------------------------------------------------

--PARA VER LAS PROPIEDADES DE LA ESTRUCTURA DE LA BASE DE DATOS 
--DataFile es la que guarda los datos
--LogFile registra los cambios
--En un DataFile se almacenan los objetos de una base de datos
--Puede haber uno o varios DataFile
--LogFile es un registro de transacciones, almacena cada transacción


--sp_helpdb:PROCEDIMIENTO ALMACENADO DE RESERVA
sp_helpdb TAXI_SEGURO
go


----RESTRICCIONES
---TIPO_DOCUMENTO
---TIPO DE DOCUMENTO PUEDE SER O DNI O PASAPORTE 
--CHECK:Si define una restricción CHECK en una sola columna, solo se permiten ciertos valores para esta columna.
--SIN EJECUTAR
Alter Table TIPO_DOCUMENTO
Add check (DESC_TIPODOCUMENTO In ('DNI', 'PASAPORTE','CARNET'))
go

Alter Table LICENCIA
add unique (NUMERO_LICENCIA) 
go




--VEHÍCULO
--PLACA DE VEHÍCULO
--LA PLACA DEL VEHÍCULO EMPIEZA POR A1A Y LOS TRES NÚMEROS RESTANTES VAN DEL 0 AL 9
--EJECUTADO
Alter Table VEHICULO
Add check (PLACAVEHICULO like 'A1A-[0-9][0-9][0-9]') 
go


Alter Table VEHICULO
ADD unique (PLACAVEHICULO)
go

Alter Table VEHICULO
Add check (MARCAVEHICULO In ('TOYOTA', 'AURI', 'KIA', 'CHEBROKE', 'HYUNDAI'))
go



Alter Table VEHICULO
ADD CHECK (ASIENTOSDISPONIBLES_VEHICULO In (4, 7, 10))
go


--EJECUTADO
--Alter--Modificar la tabla--Add check: Agregar una restricción
Alter Table VEHICULO
ADD CHECK (MODELOVEHICULO In ('StationWagon', 'Sedan','Hatchback','Monovolumen','KiaPicanto'))
go


--FICHA_RESERVA
Alter Table FICHA_RESERVA 
ADD CHECK (CANTIDADPERSONAS between 1 and 10)
go


ALter table FICHA_RESERVA
ADD CHECK (CANTIDADMALETAS between 1 and 16)
go


-----------------------------------------
----------------------------------
-----------------
INSERT TIPO_DOCUMENTO
(
ID_TIPODOCUMENTO, DESC_TIPODOCUMENTO)
values (1, 'CARNET'),
(2, 'DNI'),
(3, 'PASAPORTE')
go



----------------------------------------CONDUCTOR------------
Insert CONDUCTOR
(IDCONDUCTOR, NOMBRECONDUCTOR, APELLIDOSCONDUCTOR, NRODOCUMENTO, ID_TIPODOCUMENTO)
values 
(1, 'JUAN DIEGO', 'DÁVILA HUERTAS', '824915',1),
(2, 'PIERO ALONSO', 'MEDRANO SOTELO', '7521698', 1),
(3, 'HANS VICTOR', 'CHAPA VILLACORTA', '782146',1),
(4, 'JUAN PABLO', 'MEJIA ZAVALETA', '52641879', 2),
(5, 'FRANKLIN ALEJANDRO', 'VELIZ SECLÉN', '1429',3),
(6, 'EDGAR RAUL', 'PAREDES CERRÓN', '74851264', 2),
(7, 'RENATO EMILIO', 'RAMOS APONTE', '1425', 3),
(8, 'JAIR CARLOS', 'JIMENEZ GAMARRA', '1748', 3),
(9, 'ALESSANDRO SEBASTIAN', 'BURGOS PONCE', '84157264', 2),
(10, 'DANIEL DAVID', 'SUAREZ PEZO', '76840035',2)

go


----------------------------------------------------------
---------------------------------------------------VEHÍCULO----------------------------------------------------------
Insert VEHICULO
(PLACAVEHICULO, MARCAVEHICULO, COLORVEHICULO, AÑOFABRICACIONVEHICULO, ASIENTOSDISPONIBLES_VEHICULO,
 MODELOVEHICULO,PAISFABRICACIONVEHICULO)
values
('A1A-301', 'TOYOTA', 'NEGRO', '2016', '4', 'SEDAN', 'ESTADOS UNIDOS'),
('A1A-405', 'HYUNDAI', 'ROJO', '2010', '4', 'STATIONWAGON', 'ESTADOS UNIDOS'),
('A1A-485', 'TOYOTA', 'BLANCO', '2019', '10', 'HATCHBACK', 'BRASIL'),
('A1A-416', 'AURI', 'NEGRO', '2020', '7', 'MONOVOLUMEN', 'COREA DEL NORTE'),
('A1A-481', 'CHEBROKE', 'NEGRO', '2015', '7', 'KIAPICANTO', 'ITALIA'),
('A1A-741', 'AURI', 'BLANCO', '2018', '4', 'KIAPICANTO', 'BRASIL'),
('A1A-852', 'CHEBROKE', 'NEGRO', '2021', '4', 'SEDAN', 'ESTADOS UNIDOS'),
('A1A-942', 'HYUNDAI', 'NEGRO', '2014', '7', 'SEDAN', 'ESTADOS UNIDOS'),
('A1A-718', 'TOYOTA', 'AMARILLO', '2013', '10', 'STATIONWAGON', 'BRASIL'),
('A1A-451', 'CHEBROKE', 'NEGRO', '2019', '7', 'KIAPICANTO', 'ESPAÑA')
go






------------------------INSERCCION DE DATOS TABLA LICENCIA------------

INSERT LICENCIA
VALUES
('98472841','A1','2013/06/07','2016/07/12',1),
('98472842','A2A','2017/10/12','2021/11/18', 2),
('98472843','B2C','2011/08/02','2016/10/01', 3),
('98472844','B2B','2002/02/27','2007/03/02', 4),
('98472845','A3C','2004/09/10','2007/06/12', 5),
('98472846','A3B','2001/01/30','2004/02/02', 6),
('98472847','B2A','2015/08/15','2020/08/15', 7),
('98472848','A1','2006/12/28','2009/01/28', 8),
('98472849','A','2016/11/04','2020/10/04',9),
('98472851','A','2019/03/27','2023/04/28',10)
GO


------------------------INSERCCION DE DATOS TABLA EQUIPO--------------
INSERT EQUIPO
VALUES
(1 , 'A1A-301'),
(2 , 'A1A-405'),
(3 , 'A1A-485'),
(4 , 'A1A-416'),
(5 , 'A1A-481'),
(6 , 'A1A-741'),
(7 , 'A1A-852'),
(8 , 'A1A-942'),
(9 , 'A1A-718'),
(10, 'A1A-451')
go




----------------------INSRTANDO DATOS TABLA CLIENTES--------------------
insert CLIENTE
Values
('1004','Gladys','Hernandez','14528145','Av Jose Granda Mz G lote 15 SMP','balcazarhernandezgl@gmail.com',2),
('4001','Noemi','Vargas','84157261','Jorge Basadre 498, Lima 27','vj.Noemi@gmail.com',2),
('6409','Brigitte','Ormeño','2305','Calle Los Pinos 490 San Isidro','bri_ormoeño@gmail.com',3),
('1003','Dolly','Sotelo','2815','Jiron Pinar del rio #120 Cercado de lima ','dollyy.sote120@gmail.com',3),
('4002','Sebastian','Ocharan','38441256','Avenida Produccion Nacional#201 Chorrillos','sebitasAbi@hotmail.com',2),
('3940','Diego','Tarazona','6931','Avenida Angamos #1685 Miraflores','jeanyin.17@hotmail.com',3),
('2014','Marcelo','Prado','812459','Avenida Guillermo Dansey #1799','Arath.Marce@hotmail.com',1),
('1120','Nicoly','Suyon','152469','Avenida Larco #743 Miraflores','Nicoly.30@gmail.com',1),
('2024','Jesus','Sanchez','3570','Avenida Tomas Marsano #507 Surquillo','jesussanchez123@gmail.com',3),
('1823','Oscar','Palomino','9358','Calle Alameda #303 Mmiraflores','osquitar_palo@gmail.com',3)
go




----------------------INSRTANDO DATOS TABLA FICHA_RESERVA--------------------
INSERT FICHA_RESERVA
Values
(101,'2021/11/10','9:10:00', '2021/11/11', '10:00:00','Comas Urb.Rosa 1001',          'Av. Elmer Faucett s/n, Callao 07031(Aeropuerto internacional Jorge Chávez)', 1 ,2, 20.00,'CULMINADO', 1,'A1A-301','1004'),
(102,'2021/11/10','9:15:00', '2021/11/12', '10:00:00','Los Olivos Urb.Villa Sol 174', 'Av. Elmer Faucett s/n, Callao 07031(Aeropuerto internacional Jorge Chávez)', 2, 4, 40.00,'RESERVADO', 2,'A1A-405','4001'),
(103,'2021/11/11','9:10:00', '2021/11/13', '10:00:00','Los Olivos Urb.Rosales 1002',  'Av. Elmer Faucett s/n, Callao 07031(Aeropuerto internacional Jorge Chávez)', 3, 3, 50.00,'RESERVADO',3 ,'A1A-485','6409'),
(104,'2021/11/12','9:10:00', '2021/11/14', '10:00:00','Independencia 1003',           'Av. Elmer Faucett s/n, Callao 07031(Aeropuerto internacional Jorge Chávez)', 4, 4, 60.00,'RESERVADO', 4,'A1A-416','1003'),
(105,'2021/11/13','9:10:00', '2021/11/15', '10:00:00','Independencia 1004',           'Av. Elmer Faucett s/n, Callao 07031(Aeropuerto internacional Jorge Chávez)', 5, 6, 70.00,'RESERVADO', 5,'A1A-481','4002'),
(106,'2021/11/14','10:20:00','2021/11/16', '12:00:00','Av. Elmer Faucett s/n, Callao 07031(Aeropuerto internacional Jorge Chávez)',   'Los Olivos Urb.Rosales 1007', 6,6, 60.00,'RESERVADO', 6,'A1A-741','3940'),
(107,'2021/11/15','11:30:00','2021/11/17', '1:00:00','Av. Elmer Faucett s/n, Callao 07031(Aeropuerto internacional Jorge Chávez)',   'Los Olivos Urb.Rosales 2000', 7, 7, 70.00,'RESERVADO', 7,'A1A-852','2014'),
(108,'2021/11/16','9:20:00', '2021/11/18','2:00:00','Breña-Chacra colorada 1005',    'Av. Elmer Faucett s/n, Callao 07031(Aeropuerto internacional Jorge Chávez)', 8, 8,  75.00,'CANCELADO', 8,'A1A-942','1120'),
(109,'2021/11/17','9:50:00','2021/11/19', '3:00:00','Av. Elmer Faucett s/n, Callao 07031(Aeropuerto internacional Jorge Chávez)',   'Independencia 1009',          4, 5,  50.00,'CANCELADO', 9,'A1A-718','2024'),
(110,'2021/11/18','10:50:00', '2021/11/20', '4:00:00','Av. Elmer Faucett s/n, Callao 07031(Aeropuerto internacional Jorge Chávez)',  'Independencia 1008',         5,  6, 60.00,'RESERVADO', 10,'A1A-451','1823')
go


----------------------INSRTANDO DATOS BOLETAPAGO--------------------

INSERT BOLETAPAGO
VALUES
(2000,'2021/11/10','9:20:00' ,  20.00, 'CULMINADO',1,  '1004',101),
(2001,'2021/11/10','9:30:00' ,  40.00, 'RESERVADO',2,  '4001',102),
(2002,'2021/11/11','9:30:00' ,  50.00, 'RESERVADO',3,  '6409',103),
(2003,'2021/11/12','9:40:00' ,  60.00, 'RESERVADO',4,  '1003',104),
(2004,'2021/11/13','9:50:00' , 70.00, 'RESERVADO',5,  '4002',105),
(2005,'2021/11/14','10:40:00' , 60.00, 'RESERVADO',6,  '3940',106),
(2006,'2021/11/15','11:50:00' , 70.00, 'RESERVADO',7,  '2014',107),
(2007,'2021/11/16','9:50:00' ,  75.00, 'CANCELADO',8,  '1120',108),
(2008,'2021/11/17','9:55:00' , 50.00, 'CANCELADO',9,  '2024',109),
(2009,'2021/11/18','10:55:00' , 60.00, 'RESERVADO',10, '1823',110)
GO


--CREACIÓN DE 5 VISTAS ENLAZANDO AL MENOS 3 TABLAS
--CLIENTE, BOLETA DE PAGO, TIPO_DOCUMENTO
Select t.DESC_TIPODOCUMENTO as [DESCRIPCIÓN DE DOCUMENTO],
c.NOMBRECLIENTE as [NOMBRE DEL CLIENTE],
c.APELLIDOCLIENTE as [APELLIDO DEL CLIENTE],
c.NUMERO_DOCUMENTO as [DOCUMENTO DEL CLIENTE],
b.FECHAREGISTRO as [FECHA REGISTRO DEL CLIENTE]
from CLIENTE c join TIPO_DOCUMENTO t on c.ID_TIPODOCUMENTO=t.ID_TIPODOCUMENTO
join BOLETAPAGO b  on b.ID_CLIENTE=c.ID_CLIENTE
go


--CONDUCTOR LICENCIA EQUIPO
Select c.NOMBRECONDUCTOR as [NOMBRE DEL CONDUCTOR],
c.APELLIDOSCONDUCTOR as [APELLIDO DEL CONDUCTOR],
c.NRODOCUMENTO as [NÚMERO DEL DOCUMENTO DE CONDUCTOR],
l.NUMERO_LICENCIA as [NÚMERO DE LICENCIA DEL CONDUCTOR],
l.CATEGORIALICENCIA as [CATEGORÍA DE LINCENCIA],
l.CADUCIDADLICENCIA as [CADUCIDADLICENCIA],
e.IDCONDUCTOR, 
e.PLACAVEHICULO as [PLACA DEL VEHÍCULO]
from CONDUCTOR c join LICENCIA l on c.IDCONDUCTOR=l.IDCONDUCTOR
join EQUIPO e on e.IDCONDUCTOR=c.IDCONDUCTOR
go


--VEHICULO FICHARESERVA CLIENTE
Select v.PLACAVEHICULO as [PLACA DEL VEHÍCULO],
v.ASIENTOSDISPONIBLES_VEHICULO as [ASIENTOS DISPONIBLES DE VEHÍCULO],
f.FECHAREGISTRORESERVA as [FECHA DE RESERVA],
f.CANTIDADPERSONAS as [CANTIDAD DE PERSONAS],
f.CANTIDADMALETAS as [CANTIDAD DE MALETAS],
f.TOTALAPAGAR as [TOTAL],
c.NOMBRECLIENTE as [NOMBRE DEL CLIENTE],
c.APELLIDOCLIENTE as [APELLIDO DEL CLIENTE]
from FICHA_RESERVA f join VEHICULO v on f.PLACAVEHICULO=v.PLACAVEHICULO
join CLIENTE c on f.ID_CLIENTE=c.ID_CLIENTE
go

--cliente fichareserva conductor
Create or Alter Procedure p1
@NOMBRECONDUCTOR varchar(30),
@DIRECCIONCLIENTE varchar(200)
as
Begin
Select c.APELLIDOCLIENTE as [APELLIDO CLIENTE],
c.DIRECCIONCLIENTE as [DIRECCIÓN CLIENTE], 
c.CORREOCLIENTE as [CORREO CLIENTE],
f.TOTALAPAGAR as [TOTAL],
o.NOMBRECONDUCTOR as [NOMBRE CONDUCTOR],
o.APELLIDOSCONDUCTOR as [APELLIDO CONDUCTOR]
from Cliente c join FICHA_RESERVA f on c.ID_CLIENTE=f.ID_CLIENTE
join CONDUCTOR o on o.IDCONDUCTOR=f.IDCONDUCTOR
where o.NOMBRECONDUCTOR=@NOMBRECONDUCTOR and
c.DIRECCIONCLIENTE=@DIRECCIONCLIENTE
end
go
execute p1 'JUAN DIEGO', 'Av Jose Granda Mz G lote 15 SMP'
go



--TIPO_DOCUMENTO CLIENTE BOLETADEAPAGO
Create or Alter Procedure p2
@PRECIOTOTAL varchar(30),
@ESTADO varchar(30)
as
Begin
Select c.NOMBRECLIENTE as [NOMBRE CLIENTE],
c.APELLIDOCLIENTE as [APELLIDO CLIENTE],
c.NUMERO_DOCUMENTO as [NÚMERO DOCUMENTO CLIENTE],
t.DESC_TIPODOCUMENTO as [DESCRIPCIÓN DOCUMENTO],
b.PRECIOTOTAL as [PRECIO TOTAL],
b.ESTADO
from  TIPO_DOCUMENTO t join CLIENTE c on t.ID_TIPODOCUMENTO=c.ID_TIPODOCUMENTO
join BOLETAPAGO b on b.ID_CLIENTE=c.ID_CLIENTE
where b.PRECIOTOTAL>@PRECIOTOTAL and
b.ESTADO=@ESTADO
end
go
execute p2 '50', 'RESERVADO'
go

--FICHARESERVA CONDUCTOR VEHICULO
Create or Alter Procedure p3
@ID_TIPODOCUMENTO int,
@ASIENTOSDISPONIBLES_VEHICULO smallint,
@AÑOFABRICACIONVEHICULO char(4)
as
Begin 
Select f.CANTIDADPERSONAS as [CANTIDAD PERSONAS],
f.CANTIDADMALETAS as [CANTIDAD MALETAS],
c.APELLIDOSCONDUCTOR as [APELLIDO CONDUCTOR],
c.NOMBRECONDUCTOR as [NOMBRE CONDUCTOR],
v.AÑOFABRICACIONVEHICULO as [AÑO DE FABRICACIÓN VEHÍCULO],
v.COLORVEHICULO as [COLOR VEHÍCULO]
from FICHA_RESERVA f join CONDUCTOR c on f.IDCONDUCTOR=c.IDCONDUCTOR
join VEHICULO v on v.PLACAVEHICULO=f.PLACAVEHICULO
where c.ID_TIPODOCUMENTO=@ID_TIPODOCUMENTO and v.ASIENTOSDISPONIBLES_VEHICULO=@ASIENTOSDISPONIBLES_VEHICULO
and v.AÑOFABRICACIONVEHICULO=@AÑOFABRICACIONVEHICULO
end
go
execute p3 1, '4', '2016'
go



---ELIMINACIÓN
Create or Alter Procedure eliminar1
@AÑOFABRICACION char(4)
as
Begin 
if exists (Select * from VEHICULO where AÑOFABRICACIONVEHICULO=@AÑOFABRICACION)
delete from VEHICULO
where AÑOFABRICACIONVEHICULO=@AÑOFABRICACION
else
raiserror ('NINGÚN AUTO REGISTRADO DE ESTE AÑO',10,1)
End 
go


---REGISTRAR
Create or Alter Procedure registrar1
@ID_CLIENTE int,
@NOMBRECLIENTE varchar(30),
@APELLIDOCLIENTE varchar(30),
@NUMERO_DOCUMENTO int,
@DIRECCIONCLIENTE varchar(200),
@CORREOCLIENTE varchar(200),
@ID_TIPODOCUMENTO int
as
Begin
if not exists (Select * from CLIENTE where ID_CLIENTE=@ID_CLIENTE)
Insert into CLIENTE (ID_CLIENTE, NOMBRECLIENTE, APELLIDOCLIENTE, NUMERO_DOCUMENTO, DIRECCIONCLIENTE, CORREOCLIENTE, ID_TIPODOCUMENTO)
values (@ID_CLIENTE,@NOMBRECLIENTE,@APELLIDOCLIENTE,@NUMERO_DOCUMENTO,@DIRECCIONCLIENTE, @CORREOCLIENTE, @ID_TIPODOCUMENTO)
else
raiserror ('ESTE ID YA EXISTE',10,1)
End 
go
execute registrar1 1788,'Edwin','Guerra',9845,'Palmeras con MArañon #2112', 'edwuin667@hotmail.com',3
go



Create or Alter Procedure actualizar1
@IDCONDUCTOR int,
@NOMBRECONDUCTOR varchar(30)
as 
BEGIN
if exists (Select * from CONDUCTOR where IDCONDUCTOR=@IDCONDUCTOR)
update CONDUCTOR
set NOMBRECONDUCTOR=@NOMBRECONDUCTOR
where IDCONDUCTOR=@IDCONDUCTOR
ELSE
RAISERROR ('ERROR ID NO EXISTE',10,1)
end 
go
execute actualizar1 2,'Brando'
go


---
Create or Alter Procedure prob
@DESC_TIPODOCUMENTO varchar(30)
as
begin
select 
t.DESC_TIPODOCUMENTO as [DESCRIPCIÓN DE DOCUMENTO],
count(T.DESC_TIPODOCUMENTO) as [CANTIDAD DE CLIENTES CON ESTE DOCUMENTO]
from CLIENTE c join TIPO_DOCUMENTO t on c.ID_TIPODOCUMENTO=t.ID_TIPODOCUMENTO
where T.DESC_TIPODOCUMENTO=@DESC_TIPODOCUMENTO
group by t.DESC_TIPODOCUMENTO
end
go
EXECUTE prob 'PASAPORTE'
go













































































