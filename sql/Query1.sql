----------------------------------------
--POBLAR LA TABLA DimModelo
----------------------------------------

INSERT INTO AdventureWorksDW5TO.dbo.dimModelo (ModeloID, Modelo)
SELECT a.ProductModelID, a.Name
	FROM AdventureWorks2019.Production.ProductModel as a
	ORDER BY a.ProductModelID

----------------------------------------
--POBLAR LA TABLA DimCategoria
----------------------------------------

INSERT INTO AdventureWorksDW5TO.dbo.dimCategoria(CategoriaID, Categoria)
SELECT a.ProductCategoryID, a.Name
	FROM AdventureWorks2019.Production.ProductCategory as a
	ORDER BY a.ProductCategoryID

----------------------------------------
--POBLAR LA TABLA DimSubCategoria
----------------------------------------

INSERT INTO AdventureWorksDW5TO.dbo.dimSubCategoria(SubCategoriaID, CategoriaID, SubCategoria)
SELECT a.ProductSubCategoryID, a.ProductCategoryID,a.Name
	FROM AdventureWorks2019.Production.ProductSubCategory as a
	ORDER BY a.ProductSubCategoryID

----------------------------------------
--POBLAR LA TABLA DimProducto
----------------------------------------

INSERT INTO AdventureWorksDW5TO.dbo.dimProducto(ProductoID, SubCategoriaID, ModeloID, Producto, PrecioLista, CompradoFabricado)
SELECT a.ProductID, a.ProductSubCategoryID, a.ProductModelID, a.Name, a.ListPrice, 'CompradoFabricado' = case
																		 when a.MakeFlag = 0 then 'Comprado'
																		 when a.MakeFlag = 1 then 'Fabricado'
																		 end
FROM AdventureWorks2019.Production.Product as a
where a.ProductSubcategoryID is not null and a.ProductModelID is not null
ORDER BY a.ProductID

----------------------------------------
--POBLAR LA TABLA DimFechas
----------------------------------------

declare @f datetime='01-01-2011'
    declare @idfecha int;
    declare @anio int;
    declare @trimestre varchar(15);
    declare @mes varchar(15);
    declare @nmes int;
    set dateformat dmy;

    while(@f<= '31-12-2014') 
    begin
    set @idfecha=YEAR(@f)*10000+ MONTH(@f)*100+DAY(@f);
    set @anio=YEAR(@f);
    set @trimestre=case when DATEPART(QUARTER, @f)= 1 then '1er Tri'
                when DATEPART(QUARTER, @f)= 2 then '2er Tri'
                when DATEPART(QUARTER, @f)= 3 then '3er Tri'
                else '4to tri'
                end
    set @mes=case when DATEPART(MONTH,@f)=1 then 'Enero'
    when DATEPART(MONTH,@f)=2 then 'Febrero'
    when DATEPART(MONTH,@f)=3 then 'Marzo'
    when DATEPART(MONTH,@f)=4 then 'Abril'
    when DATEPART(MONTH,@f)=5 then 'Mayo'
    when DATEPART(MONTH,@f)=6 then 'Junio'
    when DATEPART(MONTH,@f)=7 then 'Julio'
    when DATEPART(MONTH,@f)=8 then 'Agosto'
    when DATEPART(MONTH,@f)=9 then 'Septiembre'
    when DATEPART(MONTH,@f)=10 then 'Octubre'
    when DATEPART(MONTH,@f)=11 then 'Noviembre'
    else 'Diciembre'
    end

        set @nmes=case when DATEPART(MONTH,@f)=1 then 1
    when DATEPART(MONTH,@f)=2 then 2
    when DATEPART(MONTH,@f)=3 then 3
    when DATEPART(MONTH,@f)=4 then 4
    when DATEPART(MONTH,@f)=5 then 5
    when DATEPART(MONTH,@f)=6 then 6
    when DATEPART(MONTH,@f)=7 then 7
    when DATEPART(MONTH,@f)=8 then 8
    when DATEPART(MONTH,@f)=9 then 9
    when DATEPART(MONTH,@f)=10 then 10
    when DATEPART(MONTH,@f)=11 then 11
    else 12
    end

    insert into AdventureWorksDW5TO.dbo.dimFechas
    values(@idfecha,@anio,@trimestre,@mes, CONVERT(date, @f),@nmes);

    set @f=@f+1;
end;

---Poblar Clientes
INSERT INTO AdventureWorksDW5TO.dbo.dimCLientes (ClienteID, Cliente, TIpo)
SELECT a.CustomerID, (b.LastName + ' ' + b.FirstName) as Cliente, b.PersonType
from AdventureWorks2019.Sales.Customer as a , AdventureWorks2019.Person.Person as b
WHERE a.PersonID = b.BusinessEntityID and a.PersonID > 0 and a.StoreID > 0 
order by a.CustomerID
------------------------------
--POBLAR TABLA dimCiudades
------------------------------
ALTER TABLE AdventureWorksDW5TO.dbo.dimCiudades DROP COLUMN Id_new
Alter Table AdventureWorksDW5TO.dbo.dimCiudades
Add IdCiudad Int Identity(1, 1)
Go

------------------------------
--POBLAR TABLA dimPaises
------------------------------
INSERT INTO AdventureWorksDW5TO.dbo.dimPaises(IdPais, Nombre)
SELECT a.CountryRegionCode, a.Name
FROM AdventureWorks2019.Person.CountryRegion as a
ORDER BY a.CountryRegionCode

------------------------------
--POBLAR TABLA dimEstado
------------------------------
INSERT INTO AdventureWorksDW5TO.dbo.dimEstados(IdEstado, Nombre, IdPais)
SELECT a.StateProvinceID, a.Name, a.CountryRegionCode 
FROM AdventureWorks2019.Person.StateProvince as a
ORDER BY a.StateProvinceID


------------------------------
--POBLAR TABLA dimEmpleados
------------------------------
INSERT INTO AdventureWorksDW5TO.dbo.dimEmpleados(IdEmpleado, Empleado, IdCiudad, idEstado)
SELECT DISTINCT a.SalesPersonID as ID, (c.FirstName+ ' ' + c.LastName) as Empleado,d.City as Cidad, d.StateProvinceID
FROM	AdventureWorks2019.Sales.SalesOrderHeader as a, AdventureWorks2019.Sales.SalesPerson as b, 
		AdventureWorks2019.Person.Person as c ,AdventureWorks2019.Person.Address as d,
		AdventureWorks2019.Person.BusinessEntityAddress as e
WHERE a.SalesPersonID = b.BusinessEntityID and 
		b.BusinessEntityID = e.BusinessEntityID and
		e.BusinessEntityID = c.BusinessEntityID and
		c.PersonType = 'SP' and
		e.AddressID = d.AddressID 
ORDER BY a.SalesPersonID


-----------------------------
--Poblar Estado Orden
-----------------------------
select a.status
from AdventureWorks2019.Sales.SalesOrderHeader as a
INSERT  INTO AdventureWorksDW5TO.dbo.dimEstadoOrden(IdEstado,EstadoOrden)
SELECT distinct a.Status, 'EstadoOrden' = case
when a.status = 1
then 'En Proceso'
when a.status = 2
then 'Aprobado'
when a.status = 3
then 'En Espera'
when a.status = 4
then 'Rechazado'
when a.status = 5
then 'Enviado'
when a.status = 6
then 'Cancelado'
end
from 
AdventureWorks2019.Sales.SalesOrderHeader as a
-------------------------------
--POBLAR TABLA factVentas 
-------------------------------
INSERT INTO AdventureWorksDW5TO.dbo.factVentas(ClienteID, ProductoID, FechaID, Cantidad, PrecioUnitario,Descuento,DescuentoTotal, VentaID,IdEmpleado,IdEstadoOrden, Diferencia)
select b.CustomerID, a.ProductID, (YEAR(b.OrderDate)*10000 + MONTH(b.OrderDate)*100 + DAY(b.OrderDate)) as Fecha,
		a.OrderQty, a.UnitPrice, a.UnitPriceDiscount, (a.OrderQty*a.UnitPrice*a.UnitPriceDiscount), a.SalesOrderID,
		d.IdEmpleado, e.IdEstado, ((f.ListPrice - (a.UnitPrice - a.UnitPriceDiscount))*a.OrderQty) as Diferencia
		from	AdventureWorks2019.Sales.SalesOrderDetail as a,
				AdventureWorks2019.Sales.SalesOrderHeader as b,
				AdventureWorksDW5TO.dbo.dimClientes as c,
				AdventureWorksDW5TO.dbo.dimEmpleados as d,
				AdventureWorksDW5TO.dbo.dimEstadoOrden as e,
				AdventureWorks2019.Production.ProductListPriceHistory f
where a.SalesOrderID = b.SalesOrderID and b.CustomerID = c.ClienteID
	and b.SalesPersonID = d.IdEmpleado
	and a.ProductID = f.ProductID
order by a.SalesOrderID

SELECT * FROM dimProducto

select * from
AdventureWorks2019.Sales.SalesOrderHeader 
where SalesOrderID = 43659



delete factVentas
go
delete dimClientes
go
delete dimFechas
go
delete dimProducto
go
delete dimModelo
go
delete dimSubcategoria
go
delete dimCategoria
go
delete dimEmpleados
go
delete dimEstados
go
delete dimPaises
go
delete dimEstadoOrden
go