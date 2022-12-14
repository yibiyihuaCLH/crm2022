package com.yibiyihua.crm.settings.mapper;

import com.yibiyihua.crm.settings.bean.DictionaryValue;

import java.util.List;

public interface DictionaryValueMapper {
    /**
     * 根据字典类型查询字典值
     * @param typeCode
     * @return
     */
    List<DictionaryValue> selectDictionaryValueByTypeCode(String typeCode);

    /**
     * 根据id查询字典值
     * @param id
     * @return
     */
    String selectDictionaryValueById(String id);

    /**
     * 根据value和typeCode查询字典记录
     * @param value
     * @param typeCode
     * @return
     */
    DictionaryValue selectDictionaryByValueAndTypeCode(String value, String typeCode);
}