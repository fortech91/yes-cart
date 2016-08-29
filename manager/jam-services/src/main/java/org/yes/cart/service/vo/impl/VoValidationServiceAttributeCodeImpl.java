/*
 * Copyright 2009 - 2016 Denys Pavlov, Igor Azarnyi
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

package org.yes.cart.service.vo.impl;

import org.yes.cart.domain.entity.Attribute;
import org.yes.cart.service.domain.AttributeService;
import org.yes.cart.service.vo.VoValidationService;

/**
 * User: denispavlov
 * Date: 29/08/2016
 * Time: 15:31
 */
public class VoValidationServiceAttributeCodeImpl extends AbstractVoValidationServiceSubjectCodeFieldImpl implements VoValidationService {

    private final AttributeService categoryService;

    public VoValidationServiceAttributeCodeImpl(final AttributeService categoryService) {
        this.categoryService = categoryService;
    }

    @Override
    protected Long getDuplicateId(final long currentId, final String valueToCheck) {
        final Attribute attr = this.categoryService.findByAttributeCode(valueToCheck);
        return attr != null && attr.getAttributeId() != currentId ? attr.getAttributeId() : null;
    }
}
