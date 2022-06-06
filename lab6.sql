/* 1. Добавить внешние ключи */
ALTER TABLE [order]
ADD CONSTRAINT fk_order_production_id_production
FOREIGN KEY(id_production) REFERENCES production(id_production)

ALTER TABLE [order]
ADD CONSTRAINT fk_order_dealer_id_dealer
FOREIGN KEY(id_dealer) REFERENCES dealer(id_dealer)

ALTER TABLE [order]
ADD CONSTRAINT fk_order_pharmacy_id_pharmacy
FOREIGN KEY(id_pharmacy) REFERENCES pharmacy(id_pharmacy)

ALTER TABLE production
ADD CONSTRAINT fk_production_medicine_id_medicine
FOREIGN KEY(id_medicine) REFERENCES medicine(id_medicine)

ALTER TABLE production
ADD CONSTRAINT fk_production_company_id_company
FOREIGN KEY(id_company) REFERENCES company(id_company)

ALTER TABLE dealer
ADD CONSTRAINT fk_dealer_company_id_company
FOREIGN KEY(id_company) REFERENCES company(id_company)

/* 2. Выдать информацию по всем заказам лекарства “Кордерон” компании “Аргус” с указанием названий аптек, дат, объема заказов */
SELECT pharmacy.name, [order].quantity, [order].date
FROM [order]
  JOIN production ON [order].id_production = production.id_production
  JOIN medicine ON production.id_medicine = medicine.id_medicine
  JOIN company ON production.id_company = company.id_company
  JOIN pharmacy ON [order].id_pharmacy = pharmacy.id_pharmacy
WHERE company.name = 'Аргус' and medicine.name = 'Кордерон'

/* 3. Дать список лекарств компании “Фарма”, на которые не были сделаны заказы до 25 января*/
SELECT [medicine].name
FROM [order]
JOIN production ON [order].id_production = production.id_production 
JOIN company ON production.id_company = company.id_company and company.name = 'Фарма'
RIGHT JOIN medicine on production.id_medicine = medicine.id_medicine
WHERE [order].date >= '2019-01-25'

/* 4. Дать минимальный и максимальный баллы лекарств каждой фирмы, которая оформила не менее 120 заказов*/
SELECT company.name, MIN(production.rating) minRate, MAX(production.rating) maxRate, COUNT([order].id_order) countOrder
FROM production
JOIN [order] ON production.id_production = [order].id_production
JOIN company ON production.id_company = company.id_company
GROUP BY company.name
HAVING NOT COUNT([order].id_order) < 120;
	

/* 5. Дать списки сделавших заказы аптек по всем дилерам компании “AstraZeneca”. Если у дилера нет заказов, в названии аптеки проставить NULL */

SELECT dealer.name, pharmacy.name, [order].date
FROM dealer
left join [order] on dealer.id_dealer = [order].id_dealer
left join pharmacy on [order].id_pharmacy = pharmacy.id_pharmacy
join company on dealer.id_company = company.id_company and company.name = 'AstraZeneca'

/* 6. Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а длительность лечения не более 7 дней */
update
   production 
set production.price = production.price * 0.8
from production
join medicine on production.id_medicine = medicine.id_medicine
where production.price > 3000 and medicine.cure_duration <= 7

/* 7. Добавить необходимые индексы */
CREATE INDEX dealer_name_idx
ON dealer(name);

CREATE INDEX company_name_idx
ON company(name);

CREATE INDEX medicine_name_idx
ON medicine(name);

CREATE INDEX order_date_idx
ON [order](date);

CREATE INDEX pharmacy_name_idx
ON pharmacy(name);
