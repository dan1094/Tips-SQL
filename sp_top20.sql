/****** Object:  StoredProcedure [dbo].[sp_Top20]    Script Date: 25/08/2015 9:25:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	Correr el sp en master ir a Tools - Options - Keyboard. agregar el sp, o un 'select * from ' cerrar reiniciar management.
-- =============================================
CREATE PROCEDURE [dbo].[sp_Top20] 
	@tableInformation VARCHAR(200) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @consulta VARCHAR(300),
			@table varchar(100),
			@schema varchar(100)
	if CHARINDEX('.',@tableInformation,0) = 0 --No encuentra divisor de schema por lo cual solo viene el nombre de la tabla
	begin
		select	@schema = tableInfo.TABLE_SCHEMA,
				@table = tableInfo.TABLE_NAME,
				@tableInformation = 'Se encontro la tabla en el esquema de ' + tableInfo.TABLE_SCHEMA
		from 
				information_schema.TABLES tableInfo 
		where 
				tableInfo.TABLE_NAME = @tableInformation
	end
	else
	begin
		select	@tableInformation =
					(case when tableInfo.TABLE_SCHEMA <> split.Item1 
						then
						'No se encontro la tabla en el esquema ingresado, pero se encontro en ' + tableInfo.TABLE_SCHEMA + '.' + tableInfo.TABLE_NAME 
						else 
						tableInfo.TABLE_SCHEMA + '.' + tableInfo.TABLE_NAME 
						end),
				@schema = tableInfo.TABLE_SCHEMA,
				@table = tableInfo.TABLE_NAME				
		from 
				dbo.Split_Dimensional_String(@tableInformation,'','.') split
		inner join
				information_schema.TABLES tableInfo
			on
				tableInfo.TABLE_NAME = split.item2
		
	end
	
	select @tableInformation = case when @table is null or @schema is null then 'La tabla especificada no se encontro' else @tableInformation end
	print @tableInformation
	
	select  @consulta = 'SELECT DISTINCT TOP(20) * FROM '+ @schema +'.'+ @table

	EXEC (@consulta)
END
