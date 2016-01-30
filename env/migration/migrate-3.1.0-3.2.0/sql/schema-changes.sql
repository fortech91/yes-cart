--
--  Copyright 2009 Denys Pavlov, Igor Azarnyi
--
--     Licensed under the Apache License, Version 2.0 (the "License");
--     you may not use this file except in compliance with the License.
--     You may obtain a copy of the License at
--
--         http://www.apache.org/licenses/LICENSE-2.0
--
--     Unless required by applicable law or agreed to in writing, software
--     distributed under the License is distributed on an "AS IS" BASIS,
--     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--     See the License for the specific language governing permissions and
--     limitations under the License.
--

--
-- This script is for MySQL only with some Derby hints inline with comments
-- We highly recommend you seek YC's support help when upgrading your system
-- for detailed analysis of your code.
--
-- Upgrades organised in blocks representing JIRA tasks for which they are
-- necessary - potentially you may hand pick the upgrades you required but
-- to keep upgrade process as easy as possible for future we recommend full
-- upgrades
--

--
-- YC-652 Introduce a separate field for customer and customer address to hold 'title'
--

alter table TMANAGER  add column SALUTATION varchar(24);
alter table TCUSTOMER add column SALUTATION varchar(24);
alter table TADDRESS  add column SALUTATION varchar(24);

update TATTRIBUTE set DESCRIPTION = 'Placeholders:
{{salutation}} {{firstname}} {{middlename}} {{lastname}}
{{addrline1}} {{addrline2}} {{postcode}} {{city}} {{countrycode}} {{statecode}}
{{phone1}} {{phone2}} {{mobile1}} {{mobile2}}
{{email1}} {{email2}}
{{custom1}} {{custom2}} {{custom3}} {{custom4}}', ETYPE_ID = 1011
where CODE = 'SHOP_ADDRESS_FORMATTER';

update TATTRIBUTE set DESCRIPTION = 'Placeholders: {{salutation}} {{firstname}} {{middlename}} {{lastname}}', ETYPE_ID = 1011 where CODE = 'SHOP_CUSTOMER_FORMATTER';

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, CHOICES, ETYPE_ID, ATTRIBUTEGROUP_ID)
  VALUES (  11052,  'salutation', 'salutation',  0,  NULL,  'Salutation',  'Salutation CSV options
e.g. "en|Mr-Mr,Mrs-Mrs,Dr-Dr"', 'en#~#Mrs-Mrs,Miss-Miss,Mr-Mr#~#uk#~#Пані-Пані,Пан-Пан#~#ru#~#-#~#de#~#Frau-Frau,Herr-Herr', 1004,  1006);
INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID)
  VALUES (  11053,  'firstname', 'firstname',  1,  NULL,  'First name',  'First name', 1000,  1006);
INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID)
  VALUES (  11054,  'lastname', 'lastname',  1,  NULL,  'Last name',  'Last name', 1000,  1006);
INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID)
  VALUES (  11055,  'middlename', 'middlename',  0,  NULL,  'Middle name',  'Middle name', 1000,  1006);

INSERT INTO TSHOPATTRVALUE(ATTRVALUE_ID,VAL,CODE,SHOP_ID, GUID)  VALUES (23, 'firstname,middlename,lastname,CUSTOMER_PHONE,MARKETING_OPT_IN','SHOP_CUSTOMER_REGISTRATION_ATTRIBUTES', 10, 'SHOP_CUSTOMER_REGISTRATION_10');
INSERT INTO TSHOPATTRVALUE(ATTRVALUE_ID,VAL,CODE,SHOP_ID, GUID)  VALUES (24, 'firstname,middlename,lastname,CUSTOMER_PHONE,MARKETING_OPT_IN','SHOP_CUSTOMER_PROFILE_ATTRIBUTES_VISIBLE', 10, 'SHOP_CUSTOMER_PROFILE_10');

--
-- YC-653 Allow configurable address form
--

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, GUID)
  VALUES (  11039,  'SHOP_CUSTOMER_ADDRESS_PREFIX',  0,  NULL,  'Customer: address form prefix attribute',
'Address form prefix attribute used to define various address forms.
Prefix will be used to select ADDRESS attributes
E.g. if this attribute is ADDR_FORM and Customer attribute value for it is "default"
then fields would be resolved as "default_firstname", "default_lastname" etc.',  1000, 1001, 'SHOP_CUSTOMER_ADDR_PREF');

INSERT INTO TATTRIBUTEGROUP (ATTRIBUTEGROUP_ID, GUID, CODE, NAME, DESCRIPTION) VALUES (1007, 'ADDRESS', 'ADDRESS', 'Customer address settings.', '');


INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID)
  VALUES (  11200,  'default_addressform', 'default_addressform',  0,  NULL,  'Customer: "default_" address form (CSV)',
    'List of address form attributes separated by comma.
Available fields:
salutation, firstname, middlename, lastname
addrline1, addrline2, postcode, city, countrycode, statecode
phone1, phone2, mobile1, mobile2
email1, email2
custom1, custom2, custom3, custom4',  1004, 1007);
INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, CHOICES, ETYPE_ID, ATTRIBUTEGROUP_ID)
  VALUES (  11201,  'default_salutation', 'default_salutation',  0,  'salutation',  'Salutation',  'Salutation CSV options
e.g. "en|Mr-Mr,Mrs-Mrs,Dr-Dr"', 'en#~#Mrs-Mrs,Miss-Miss,Mr-Mr#~#uk#~#Пані-Пані,Пан-Пан#~#ru#~#-#~#de#~#Frau-Frau,Herr-Herr', 1004,  1007);
INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID)
  VALUES (  11202,  'default_firstname', 'default_firstname',  1,  'firstname',  'First name',  'First name', 1000,  1007);
INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID)
  VALUES (  11203,  'default_lastname', 'default_lastname',  1,  'lastname',  'Last name',  'Last name', 1000,  1007);
INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID)
  VALUES (  11204,  'default_middlename', 'default_middlename',  0,  'middlename',  'Middle name',  'Middle name', 1000,  1007);


--
-- YC-654 Allow choosing primary shop url
--

alter table TSHOPURL add column PRIMARY_URL bit not null default 0;
-- alter table TSHOPURL add column PRIMARY_URL smallint not null DEFAULT 0;

--
-- YC-662 Add PG attribute for external locale code mapping
--

INSERT INTO TPAYMENTGATEWAYPARAMETER (PAYMENTGATEWAYPARAMETER_ID, PG_LABEL, P_LABEL, P_VALUE, P_NAME, P_DESCRIPTION)
VALUES (14560, 'payPalButtonPaymentGateway', 'LANGUAGE_MAP', 'en=GB,de=DE,ru=RU,uk=RU', 'Language Mapping',
  'Language mapping can be used to map internal locale to PG supported locale
  See "HTML Variables for PayPal Payments Standard" lc parameter for more details');

INSERT INTO TPAYMENTGATEWAYPARAMETER (PAYMENTGATEWAYPARAMETER_ID, PG_LABEL, P_LABEL, P_VALUE, P_NAME, P_DESCRIPTION)
VALUES (15178, 'postFinancePaymentGateway', 'LANGUAGE_MAP', 'en=en_US,de=de_DE,ru=ru_RU,uk=ru_RU', 'Language Mapping',
  'Language mapping can be used to map internal locale to PG supported locale
  See "PostFinance > Support > Parameter CookBook" LANGUAGE parameter for more details');

INSERT INTO TPAYMENTGATEWAYPARAMETER (PAYMENTGATEWAYPARAMETER_ID, PG_LABEL, P_LABEL, P_VALUE, P_NAME, P_DESCRIPTION)
VALUES (15278, 'postFinanceManualPaymentGateway', 'LANGUAGE_MAP', 'en=en_US,de=de_DE,ru=ru_RU,uk=ru_RU', 'Language Mapping',
  'Language mapping can be used to map internal locale to PG supported locale
  See "PostFinance > Support > Parameter CookBook" LANGUAGE parameter for more details');

--
-- YC-639 Improve payment messaging via dynamic content
--

INSERT INTO TCATEGORY(CATEGORY_ID, PARENT_ID, RANK, NAME, DESCRIPTION, UITEMPLATE, GUID) VALUES (10500, 10100, 0, 'Payment Result Page', 'Payment Result Page','include', 'SHOP10-10500');

INSERT INTO TCATEGORY(CATEGORY_ID, PARENT_ID, RANK, NAME, DESCRIPTION, UITEMPLATE, GUID, URI) VALUES (10510, 10500, 0, 'Internal payment gateway', 'Internal payment gateway','dynocontent', 'SHOP10-10510', 'SHOP10_paymentpage_message');
INSERT INTO TCATEGORYATTRVALUE(ATTRVALUE_ID, CODE,VAL, CATEGORY_ID, GUID) VALUES (12510,'CONTENT_BODY_en_1','
<h2>Order Payment</h2>

<% if (result) { %>
   <p>
      Your order has been successfully created. You will receive confirmation by e-mail.
   </p>
   <a href="/yes-shop" class="btn btn-primary2" rel="bookmark">Continue shopping</a>
   <a href="/yes-shop/orders" class="btn btn-primary" rel="nofollow">Check order status</a>
<% } else {
   if (missingStock !=null) { %>
      <p>
         Item ${product} with code ${sku} has just gone out of stock. Please try to buy similar product
      </p>
      <a href="/yes-shop" class="btn btn-primary2" rel="bookmark">Back to Home page</a>
   <% } else if (exception !=null) { %>
      <p>
         An error occurred while trying to create your order. Please try again.
      </p>
      <a href="/yes-shop" class="btn btn-primary2" rel="bookmark">Back to Home page</a>
   <% } %>
<% } %>

',10510,'12510_CAV');
INSERT INTO TCATEGORYATTRVALUE(ATTRVALUE_ID, CODE,VAL, CATEGORY_ID, GUID) VALUES (12511,'CONTENT_BODY_ru_1','
<h2>Оплата заказа</h2>

<% if (result) { %>
   <p>
      Ваш заказ был успешно оформлен. Вы получите уведомление на электронный адрес.
   </p>
   <a href="/yes-shop" class="btn btn-primary2" rel="bookmark">За новыми покупками</a>
   <a href="/yes-shop/orders" class="btn btn-primary" rel="nofollow">Проверить статус заказа</a>
<% } else {
   if (missingStock !=null) { %>
      <p>
         Недостаточное количество ${product} (код ${sku}) на складе. Попробуйте купить похожий продукт. Приносим свои извинения
      </p>
      <a href="/yes-shop" class="btn btn-primary2" rel="bookmark">Перейти на главную</a>
   <% } else if (exception !=null) { %>
      <p>
         Произошла ошибка при создании Вашего заказа. Попробуйте еще раз.
      </p>
      <a href="/yes-shop" class="btn btn-primary2" rel="bookmark">Перейти на главную</a>
   <% } %>
<% } %>

',10510,'12511_CAV');
INSERT INTO TCATEGORYATTRVALUE(ATTRVALUE_ID, CODE,VAL, CATEGORY_ID, GUID) VALUES (12513,'CONTENT_BODY_uk_1','
<h2>Оплата замовлення</h2>

<% if (result) { %>
   <p>
      Ваше замовлення було успішно оформлено. Ви отримаєте повідомлення на електронну адресу.
   </p>
   <a href="/yes-shop" class="btn btn-primary2" rel="bookmark">За новими покупками</a>
   <a href="/yes-shop/orders" class="btn btn-primary" rel="nofollow">Перевірити статус замовлення</a>
<% } else {
   if (missingStock !=null) { %>
      <p>
         Недостатня кількість ${product} (код ${sku}) на складі. Спробуйте купити схожий товар. Приносимо вибачення
      </p>
      <a href="/yes-shop" class="btn btn-primary2" rel="bookmark">Повернутися на головну</a>
   <% } else if (exception !=null) { %>
      <p>
         Сталася помилка при створені Вашого замовлення. Спробуйте ще раз.
      </p>
      <a href="/yes-shop" class="btn btn-primary2" rel="bookmark">Повернутися на головну</a>
   <% } %>
<% } %>

',10510,'12513_CAV');
INSERT INTO TCATEGORYATTRVALUE(ATTRVALUE_ID, CODE,VAL, CATEGORY_ID, GUID) VALUES (12514,'CONTENT_BODY_de_1','
<h2>Order Payment</h2>

<% if (result) { %>
   <p>
      Ihre Bestellung wurde erfolgreich erstellt. Sie erhalten eine Bestätigung per E-Mail.
   </p>
   <a href="/yes-shop" class="btn btn-primary2" rel="bookmark">Weiter mit Einkaufen</a>
   <a href="/yes-shop/orders" class="btn btn-primary" rel="nofollow">Status der Bestellung überprüfen</a>
<% } else {
   if (missingStock !=null) { %>
      <p>
         Leider ist der Artikel in der gewünschten Anzahl ${product} mit Artikel Nummer ${sku} nicht an Lager. Versuchen Sie ein vergleichbares Produkt zu kaufen.
      </p>
      <a href="/yes-shop" class="btn btn-primary2" rel="bookmark">Zurück zur Startseite</a>
   <% } else if (exception !=null) { %>
      <p>
         Beim Erstellen Ihrer Bestellung ist ein Fehler aufgetreten. Bitte versuchen Sie es nochmals.
      </p>
      <a href="/yes-shop" class="btn btn-primary2" rel="bookmark">Zurück zur Startseite</a>
   <% } %>
<% } %>

',10510,'12514_CAV');

INSERT INTO TCATEGORY(CATEGORY_ID, PARENT_ID, RANK, NAME, DESCRIPTION, UITEMPLATE, GUID, URI) VALUES (10520, 10500, 0, 'External payment gateway', 'External payment gateway','dynocontent', 'SHOP10-10520', 'SHOP10_resultpage_message');
INSERT INTO TCATEGORYATTRVALUE(ATTRVALUE_ID, CODE,VAL, CATEGORY_ID, GUID) VALUES (12520,'CONTENT_BODY_en_1','
<h2>Payment result</h2>
<%
def _status = binding.hasVariable(''status'') ? status : (binding.hasVariable(''hint'') ? hint : "");
if (_status.equals("ok")) { %>
	<p>Order successfully placed</p>
	<a href="/yes-shop" class="btn btn-primary2" rel="bookmark">Continue shopping</a>
	<a href="/yes-shop/orders" class="btn btn-primary" rel="nofollow">Check order status</a>
<% } else if (_status.equals("cancel")) { %>
	<p>Order was cancelled. This maybe due to payment failure or insufficient stock</p>
	<a href="/yes-shop" class="btn btn-primary2" rel="bookmark">Continue shopping</a>
<% } else { %>
	<p>Errors in payment</p>
	<a href="/yes-shop" class="btn btn-primary2" rel="bookmark">Back to Homepage</a>
<% } %>

',10520,'12520_CAV');
INSERT INTO TCATEGORYATTRVALUE(ATTRVALUE_ID, CODE,VAL, CATEGORY_ID, GUID) VALUES (12521,'CONTENT_BODY_ru_1','
<h2>Результат оплаты</h2>
<%
def _status = binding.hasVariable(''status'') ? status : (binding.hasVariable(''hint'') ? hint : "");
if (_status.equals("ok")) { %>
	<p>Заказ успешно оформлен</p>
	<a href="/yes-shop" class="btn btn-primary2" rel="bookmark">За новыми покупками</a>
	<a href="/yes-shop/orders" class="btn btn-primary" rel="nofollow">Проверить статус заказа</a>
<% } else if (_status.equals("cancel")) { %>
	<p>Заказ отменен. Возможная причина - это ошибка при оплате, либо недостаточное кол-во товара на складе</p>
	<a href="/yes-shop" class="btn btn-primary2" rel="bookmark">За новыми покупками</a>
<% } else { %>
	<p>Ошибки при оплате</p>
	<a href="/yes-shop" class="btn btn-primary2" rel="bookmark">Перейти на главную</a>
<% } %>

',10520,'12521_CAV');
INSERT INTO TCATEGORYATTRVALUE(ATTRVALUE_ID, CODE,VAL, CATEGORY_ID, GUID) VALUES (12522,'CONTENT_BODY_uk_1','
<h2>Результат оплати</h2>
<%
def _status = binding.hasVariable(''status'') ? status : (binding.hasVariable(''hint'') ? hint : "");
if (_status.equals("ok")) { %>
	<p>Замовлення успішно оформлене</p>
	<a href="/yes-shop" class="btn btn-primary2" rel="bookmark">За новими покупками</a>
	<a href="/yes-shop/orders" class="btn btn-primary" rel="nofollow">Перевірити статус замовлення</a>
<% } else if (_status.equals("cancel")) { %>
	<p>Замовлення скасовано. Можлива причина - це помилка при оплаті, або недостатня кількість товару на складі</p>
	<a href="/yes-shop" class="btn btn-primary2" rel="bookmark">За новими покупками</a>
<% } else { %>
	<p>Помилка при оплаті</p>
	<a href="/yes-shop" class="btn btn-primary2" rel="bookmark">Повернутися на головну</a>
<% } %>

',10520,'12522_CAV');
INSERT INTO TCATEGORYATTRVALUE(ATTRVALUE_ID, CODE,VAL, CATEGORY_ID, GUID) VALUES (12523,'CONTENT_BODY_de_1','
<h2>Resultat des Zahlungsvorgangs</h2>
<%
def _status = binding.hasVariable(''status'') ? status : (binding.hasVariable(''hint'') ? hint : "");
if (_status.equals("ok")) { %>
	<p>Bestellung erfolgreich getätigt</p>
	<a href="/yes-shop" class="btn btn-primary2" rel="bookmark">Weiter Einkaufen / Zur Startseite</a>
	<a href="/yes-shop/orders" class="btn btn-primary" rel="nofollow">Status der Bestellung verfolgen</a>
<% } else if (_status.equals("cancel")) { %>
	<p>Die Bestellung wurde annuliert oder die Artikel ist nicht mehr an Lager. Das kann der Grund für den Abbruch der Zahlung sein</p>
	<a href="/yes-shop" class="btn btn-primary2" rel="bookmark">Weiter Einkaufen / Zur Startseite</a>
<% } else { %>
	<p>Fehler bei der Zahlung</p>
	<a href="/yes-shop" class="btn btn-primary2" rel="bookmark">Zurück zur Startseite</a>
<% } %>

',10520,'12523_CAV');


--
-- YC-670 Allow image service resolutions to be configurable in system attributes
--

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID)
  VALUES (  10099,  'SYSTEM_ALLOWED_IMAGE_SIZES', 'SYSTEM_ALLOWED_IMAGE_SIZES',  1,  NULL,
  'SF\Image service: allowed image sizes', 'Image resolutions allowed to be processed by shop
  E.g. 40x40,50x50,60x60,80x80,200x200,160x160,360x360,120x120,280x280,240x240 ', 1004,  1000);

INSERT INTO TSYSTEMATTRVALUE ( ATTRVALUE_ID,  VAL,  CODE, SYSTEM_ID, GUID)
  VALUES (1023,'40x40,50x50,60x60,80x80,200x200,160x160,360x360,120x120,280x280,240x240','SYSTEM_ALLOWED_IMAGE_SIZES',100, 'YC_SYSTEM_ALLOWED_IMAGE_SIZES');

