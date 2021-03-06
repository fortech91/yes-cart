/*
 * Copyright 2009- 2016 Denys Pavlov, Igor Azarnyi
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
package org.yes.cart.service.endpoint.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.yes.cart.domain.misc.MutablePair;
import org.yes.cart.domain.vo.VoAttrValueSystem;
import org.yes.cart.service.endpoint.SystemPreferencesEndpointController;
import org.yes.cart.service.vo.VoSystemPreferencesService;

import java.util.List;

/**
 * User: denispavlov
 * Date: 12/08/2016
 * Time: 17:55
 */
@Component
public class SystemPreferencesEndpointControllerImpl implements SystemPreferencesEndpointController {


    private final VoSystemPreferencesService voSystemPreferencesService;

    @Autowired
    public SystemPreferencesEndpointControllerImpl(final VoSystemPreferencesService voSystemPreferencesService) {
        this.voSystemPreferencesService = voSystemPreferencesService;
    }

    @Override
    public @ResponseBody
    List<VoAttrValueSystem> getSystemPreferences() throws Exception {
        return voSystemPreferencesService.getSystemPreferences(false);
    }

    @Override
    public @ResponseBody
    List<VoAttrValueSystem> getSystemPreferencesSecure() throws Exception {
        return voSystemPreferencesService.getSystemPreferences(true);
    }

    @Override
    public @ResponseBody
    List<VoAttrValueSystem> update(@RequestBody final List<MutablePair<VoAttrValueSystem, Boolean>> vo) throws Exception {
        return voSystemPreferencesService.update(vo, false);
    }

    @Override
    public @ResponseBody
    List<VoAttrValueSystem> updateSecure(@RequestBody final List<MutablePair<VoAttrValueSystem, Boolean>> vo) throws Exception {
        return voSystemPreferencesService.update(vo, true);
    }
}
