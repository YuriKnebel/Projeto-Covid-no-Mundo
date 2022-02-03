# Projeto Covid

Neste projeto foram utilizados dados obtidos no site https://ourworldindata.org/covid-deaths. Este banco de dados traz atualização diária dos mais diversos impactos da Covid-19 na sociedade e como estamos lidando com esta pandemia.
O objetivo deste projeto é fazer uma análise comparativa da evolução dos casos, mortes e vacinações por país.

## ETL no SQL Server

Para o processo de ETL (Extract, Transform & Load) foram desenvolvidas queries no SQL Server, podendo ser acessadas [aqui](https://github.com/YuriKnebel/Projeto-Covid/blob/main/SQL/projeto_covid.sql). <br/>
Os atributos utilizados foram:<br/>
![alt text](https://github.com/YuriKnebel/Projeto-Covid/blob/main/SQL/tabela-atributos.jpg)<br/>
As queries tiveram como objetivo a transformação e a segmentação dos dados. Para isso, foi feito uso de agregações, subqueries, join, conversão de tipos de dados e CTE (Commom Table Expression).

## Power BI

![alt text](https://github.com/YuriKnebel/Projeto-Covid/blob/main/Power-BI/imagem-dashboard.png)

O dashboard criado visa oferecer de forma interativa a análise dos dados de casos, mortes e vacinações completas por país. Além disso, foram inseridos dados globais para que possamos comparar a situação do país em um contexto mais amplo.

Para fazer download do arquivo contendo o dashboard [clique aqui](https://github.com/YuriKnebel/Projeto-Covid/blob/main/Power-BI/projeto_covid.pbix).
