/*
 * Copyright 2009 Denys Pavlov, Igor Azarnyi
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

package org.yes.cart.service.dto.impl;

import org.junit.Before;
import org.junit.Test;
import org.yes.cart.BaseCoreDBTestCase;
import org.yes.cart.constants.DtoServiceSpringKeys;
import org.yes.cart.domain.dto.PriceListDTO;
import org.yes.cart.domain.dto.ShopDTO;
import org.yes.cart.domain.dto.factory.DtoFactory;
import org.yes.cart.domain.dto.impl.PriceListDTOImpl;
import org.yes.cart.service.dto.DtoPriceListsService;

import java.math.BigDecimal;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import static org.junit.Assert.*;

/**
 * User: denispavlov
 * Date: 29/05/2015
 * Time: 16:59
 */
public class DtoPriceListsServiceImplTezt extends BaseCoreDBTestCase {

    private DtoPriceListsService dtoService;
    private DtoFactory dtoFactory;


    @Before
    public void setUp() {
        dtoFactory = (DtoFactory) ctx().getBean(DtoServiceSpringKeys.DTO_FACTORY);
        dtoService = (DtoPriceListsService) ctx().getBean("dtoPriceListService");
        super.setUp();
    }


    @Test
    public void testGetShops() throws Exception {

        final List<ShopDTO> shops = dtoService.getShops();

        assertFalse(shops.isEmpty());

        final Set<String> codes = new HashSet<String>();
        for (final ShopDTO shop : shops) {
            codes.add(shop.getCode());
        }

        assertTrue(codes.contains("SHOIP1"));
        assertTrue(codes.contains("SHOIP2"));

    }

    @Test
    public void testGetShopCurrencies() throws Exception {

        ShopDTO shop = null;
        for (final ShopDTO shopDTO : dtoService.getShops()) {
            if ("SHOIP1".equals(shopDTO.getCode())) {
                shop = shopDTO;
            }
        }

        assertNotNull(shop);

        final List<String> currencies = dtoService.getShopCurrencies(shop);
        assertEquals(4, currencies.size());
        assertTrue(currencies.contains("EUR"));
        assertTrue(currencies.contains("UAH"));
        assertTrue(currencies.contains("RUB"));
        assertTrue(currencies.contains("USD"));

    }

    @Test
    public void testGetPriceList() throws Exception {

        ShopDTO shop = null;
        for (final ShopDTO shopDTO : dtoService.getShops()) {
            if ("SHOIP1".equals(shopDTO.getCode())) {
                shop = shopDTO;
            }
        }

        assertNotNull(shop);

        // No price list without shop
        List<PriceListDTO> pl = dtoService.findBy(0L, null, null, 0, 10);
        assertTrue(pl.isEmpty());


        // Price list available for shop and currency
        pl = dtoService.findBy(shop.getShopId(), "EUR", null, 0, 10);
        assertFalse(pl.isEmpty());

        // Test partial SKU match
        pl = dtoService.findBy(shop.getShopId(), "EUR", "CC_TEST", 0, 10);
        assertFalse(pl.isEmpty());

        Set<String> sku = new HashSet<String>();
        for (final PriceListDTO price : pl) {
            sku.add(price.getSkuCode());
        }

        assertTrue(sku.contains("CC_TEST1"));
        assertTrue(sku.contains("CC_TEST2"));
        assertTrue(sku.contains("CC_TEST3"));


        // Test name SKU match
        pl = dtoService.findBy(shop.getShopId(), "EUR", "cc test 11", 0, 10);
        assertFalse(pl.isEmpty());

        for (final PriceListDTO price : pl) {
            assertTrue("CC_TEST11".equals(price.getSkuCode()));
        }

        // Test exact SKU match
        pl = dtoService.findBy(shop.getShopId(), "EUR", "!CC_TEST1", 0, 10);
        assertFalse(pl.isEmpty());

        for (final PriceListDTO price : pl) {
            assertTrue("CC_TEST1".equals(price.getSkuCode()));
        }

        // Test SKU no match
        pl = dtoService.findBy(shop.getShopId(), "EUR", "!something really weird not matching", 0, 10);
        assertTrue(pl.isEmpty());

        // Pricing policy
        pl = dtoService.findBy(shop.getShopId(), "EUR", "#P1", 0, 10);
        assertFalse(pl.isEmpty());

        // Shipping prices
        pl = dtoService.findBy(shop.getShopId(), "EUR", "#shipping", 0, 10);
        assertFalse(pl.isEmpty());



    }

    @Test
    public void testCreatePrice() throws Exception {

        ShopDTO shop = null;
        for (final ShopDTO shopDTO : dtoService.getShops()) {
            if ("SHOIP1".equals(shopDTO.getCode())) {
                shop = shopDTO;
            }
        }

        assertNotNull(shop);

        assertTrue(dtoService.findBy(shop.getShopId(), "EUR", "!133456-a", 0, 10).isEmpty());

        PriceListDTO skuPriceDTO = new PriceListDTOImpl();
        skuPriceDTO.setRegularPrice(new BigDecimal("1.23"));
        skuPriceDTO.setSalePrice(new BigDecimal("1.22"));
        skuPriceDTO.setMinimalPrice(new BigDecimal("1.21"));
        skuPriceDTO.setSkuCode("133456-a");
        skuPriceDTO.setShopCode("SHOIP1");
        skuPriceDTO.setCurrency("EUR");
        skuPriceDTO.setQuantity(BigDecimal.ONE);
        dtoService.createPrice(skuPriceDTO);

        final List<PriceListDTO> saved = dtoService.findBy(shop.getShopId(), "EUR", "!133456-A", 0, 10);
        assertFalse(saved.isEmpty());

        final PriceListDTO pl = saved.get(0);

        assertEquals("EUR", pl.getCurrency());
        assertEquals("133456-a", pl.getSkuCode());
        assertTrue((new BigDecimal("1.23")).equals(pl.getRegularPrice()));
        assertTrue((new BigDecimal("1.22")).equals(pl.getSalePrice()));
        assertTrue((new BigDecimal("1.21")).equals(pl.getMinimalPrice()));

    }

    @Test
    public void testCreatePriceZeroSales() throws Exception {

        ShopDTO shop = null;
        for (final ShopDTO shopDTO : dtoService.getShops()) {
            if ("SHOIP1".equals(shopDTO.getCode())) {
                shop = shopDTO;
            }
        }

        assertNotNull(shop);

        assertTrue(dtoService.findBy(shop.getShopId(), "EUR", "!133456-a0", 0, 10).isEmpty());

        PriceListDTO skuPriceDTO = new PriceListDTOImpl();
        skuPriceDTO.setRegularPrice(new BigDecimal("0.00"));
        skuPriceDTO.setSalePrice(new BigDecimal("0.00"));
        skuPriceDTO.setMinimalPrice(new BigDecimal("0.00"));
        skuPriceDTO.setSkuCode("133456-a0");
        skuPriceDTO.setShopCode("SHOIP1");
        skuPriceDTO.setCurrency("EUR");
        skuPriceDTO.setQuantity(BigDecimal.ONE);
        dtoService.createPrice(skuPriceDTO);

        final List<PriceListDTO> saved = dtoService.findBy(shop.getShopId(), "EUR", "!133456-a0", 0, 10);
        assertFalse(saved.isEmpty());

        final PriceListDTO pl = saved.get(0);

        assertEquals("EUR", pl.getCurrency());
        assertEquals("133456-a0", pl.getSkuCode());
        // Zero prices must be null, otherwise flex when flex puts in zero it breaks minimal price calculation
        assertTrue((new BigDecimal("0.00")).equals(pl.getRegularPrice()));
        assertNull(pl.getSalePrice());
        assertNull(pl.getMinimalPrice());

    }

    @Test
    public void testUpdatePrice() throws Exception {

        ShopDTO shop = null;
        for (final ShopDTO shopDTO : dtoService.getShops()) {
            if ("SHOIP1".equals(shopDTO.getCode())) {
                shop = shopDTO;
            }
        }

        assertNotNull(shop);

        assertTrue(dtoService.findBy(shop.getShopId(), "EUR", "!133456-b", 0, 10).isEmpty());

        PriceListDTO skuPriceDTO = new PriceListDTOImpl();
        skuPriceDTO.setRegularPrice(new BigDecimal("1.23"));
        skuPriceDTO.setSalePrice(new BigDecimal("1.22"));
        skuPriceDTO.setMinimalPrice(new BigDecimal("1.21"));
        skuPriceDTO.setSkuCode("133456-b");
        skuPriceDTO.setShopCode("SHOIP1");
        skuPriceDTO.setCurrency("EUR");
        skuPriceDTO.setQuantity(BigDecimal.ONE);
        dtoService.createPrice(skuPriceDTO);

        List<PriceListDTO> saved = dtoService.findBy(shop.getShopId(), "EUR", "!133456-b", 0, 10);
        assertFalse(saved.isEmpty());

        PriceListDTO pl = saved.get(0);

        assertEquals("EUR", pl.getCurrency());
        assertEquals("133456-b", pl.getSkuCode());
        assertTrue((new BigDecimal("1.23")).equals(pl.getRegularPrice()));
        assertTrue((new BigDecimal("1.22")).equals(pl.getSalePrice()));
        assertTrue((new BigDecimal("1.21")).equals(pl.getMinimalPrice()));

        pl.setRegularPrice(new BigDecimal("2.23"));
        pl.setSalePrice(new BigDecimal("2.22"));
        pl.setMinimalPrice(new BigDecimal("2.21"));
        pl.setQuantity(BigDecimal.TEN);

        dtoService.updatePrice(pl);

        saved = dtoService.findBy(shop.getShopId(), "EUR", "!133456-b", 0, 10);
        assertFalse(saved.isEmpty());

        pl = saved.get(0);

        assertEquals("EUR", pl.getCurrency());
        assertEquals("133456-b", pl.getSkuCode());
        assertTrue((new BigDecimal("2.23")).equals(pl.getRegularPrice()));
        assertTrue((new BigDecimal("2.22")).equals(pl.getSalePrice()));
        assertTrue((new BigDecimal("2.21")).equals(pl.getMinimalPrice()));

    }

    @Test
    public void testUpdatePriceZeroSales() throws Exception {

        ShopDTO shop = null;
        for (final ShopDTO shopDTO : dtoService.getShops()) {
            if ("SHOIP1".equals(shopDTO.getCode())) {
                shop = shopDTO;
            }
        }

        assertNotNull(shop);

        assertTrue(dtoService.findBy(shop.getShopId(), "EUR", "133456-b0", 0, 10).isEmpty());

        PriceListDTO skuPriceDTO = new PriceListDTOImpl();
        skuPriceDTO.setRegularPrice(new BigDecimal("1.23"));
        skuPriceDTO.setSalePrice(new BigDecimal("1.22"));
        skuPriceDTO.setMinimalPrice(new BigDecimal("1.21"));
        skuPriceDTO.setSkuCode("133456-b0");
        skuPriceDTO.setShopCode("SHOIP1");
        skuPriceDTO.setCurrency("EUR");
        skuPriceDTO.setQuantity(BigDecimal.ONE);
        dtoService.createPrice(skuPriceDTO);

        List<PriceListDTO> saved = dtoService.findBy(shop.getShopId(), "EUR", "133456-B0", 0, 10);
        assertFalse(saved.isEmpty());

        PriceListDTO pl = saved.get(0);

        assertEquals("EUR", pl.getCurrency());
        assertEquals("133456-b0", pl.getSkuCode());
        assertTrue((new BigDecimal("1.23")).equals(pl.getRegularPrice()));
        assertTrue((new BigDecimal("1.22")).equals(pl.getSalePrice()));
        assertTrue((new BigDecimal("1.21")).equals(pl.getMinimalPrice()));

        pl.setRegularPrice(new BigDecimal("1.25"));
        pl.setSalePrice(new BigDecimal("0.00"));
        pl.setMinimalPrice(new BigDecimal("0.00"));
        pl.setQuantity(BigDecimal.TEN);

        dtoService.updatePrice(pl);

        saved = dtoService.findBy(shop.getShopId(), "EUR", "133456-b0", 0, 10);
        assertFalse(saved.isEmpty());

        pl = saved.get(0);

        assertEquals("EUR", pl.getCurrency());
        assertEquals("133456-b0", pl.getSkuCode());
        assertTrue((new BigDecimal("1.25")).equals(pl.getRegularPrice()));
        assertNull(pl.getSalePrice());
        assertNull(pl.getMinimalPrice());

    }

    @Test
    public void testRemovePrice() throws Exception {

        ShopDTO shop = null;
        for (final ShopDTO shopDTO : dtoService.getShops()) {
            if ("SHOIP1".equals(shopDTO.getCode())) {
                shop = shopDTO;
            }
        }

        assertNotNull(shop);

        assertTrue(dtoService.findBy(shop.getShopId(), "EUR", "133456-c", 0, 10).isEmpty());

        PriceListDTO skuPriceDTO = new PriceListDTOImpl();
        skuPriceDTO.setRegularPrice(new BigDecimal("1.23"));
        skuPriceDTO.setSkuCode("133456-c");
        skuPriceDTO.setShopCode("SHOIP1");
        skuPriceDTO.setCurrency("EUR");
        skuPriceDTO.setQuantity(BigDecimal.ONE);
        dtoService.createPrice(skuPriceDTO);

        List<PriceListDTO> saved = dtoService.findBy(shop.getShopId(), "EUR", "133456-c", 0, 10);
        assertFalse(saved.isEmpty());

        PriceListDTO pl = saved.get(0);

        assertEquals("EUR", pl.getCurrency());
        assertEquals("133456-c", pl.getSkuCode());
        assertTrue((new BigDecimal("1.23")).equals(pl.getRegularPrice()));

        dtoService.removePrice(pl.getSkuPriceId());

        saved = dtoService.findBy(shop.getShopId(), "EUR", "133456-c", 0, 10);
        assertTrue(saved.isEmpty());

    }
}
