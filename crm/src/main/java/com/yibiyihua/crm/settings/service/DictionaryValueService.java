package com.yibiyihua.crm.settings.service;

import com.yibiyihua.crm.settings.bean.DictionaryValue;

import java.util.List;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/12 16:57
 * @description：字典值业务逻辑层接口
 * @modified By：
 * @version: 1.0
 */
public interface DictionaryValueService {
    /**
     * 根据字典类型查询字典值
     * @param typeCode
     * @return
     */
    List<DictionaryValue> queryDictionaryValueByTypeCode(String typeCode);

    /**
     * 根据id查询字典值
     * @param id
     * @return
     */
    String queryDictionaryValueById(String id);

    /**
     * 根据value和typeCode查询字典记录
     * @param value
     * @param typeCode
     * @return
     */
    DictionaryValue queryDictionaryByValueAndTypeCode(String value, String typeCode);
}
