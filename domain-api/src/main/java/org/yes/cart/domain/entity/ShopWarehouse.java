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

package org.yes.cart.domain.entity;

/**
 * Relation between shop and warehouse.
 * <p/>
 * User: Igor Azarny iazarny@yahoo.com
 * Date: 07-May-2011
 * Time: 11:12:54
 */
public interface ShopWarehouse extends Auditable {

    /**
     * @return primary key
     */
    long getShopWarehouseId();

    /**
     * Set primary key.
     *
     * @param shopWarehouseId primary key value.
     */
    void setShopWarehouseId(long shopWarehouseId);

    /**
     * @return {@link Shop}
     */
    Shop getShop();

    /**
     * @param shop {@link Shop} to set.
     */
    void setShop(Shop shop);

    /**
     * @return {@link Warehouse}
     */
    Warehouse getWarehouse();

    /**
     * Set {@link Warehouse}.
     *
     * @param warehouse {@link Warehouse} to use.
     */
    void setWarehouse(Warehouse warehouse);

    /**
     * Get the rank of warehouse usage in shop.
     * @return    rank of warehouse usage
     */
    Integer getRank();


    /**
     * Set the rank of warehouse usage.
     * @param rank of warehouse usage.
     */
    void setRank(Integer rank);

    /**
     * Disable this warehouse in shop.
     *
     * @return true if this is disabled
     */
    boolean isDisabled();

    /**
     * Disable this warehouse in shop.
     *
     * @param disabled true if this is disabled
     */
    void setDisabled(boolean disabled);


}
