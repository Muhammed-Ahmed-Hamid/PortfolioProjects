/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [location]
      ,[continent]
      ,[date]
      ,[population]
      ,[new_vaccinations]
      ,[rolling_people_vaccinated]
  FROM [MSBA23].[dbo].[PercentPopulationVaccinated]

select
 *
from
 [PercentPopulationVaccinated]