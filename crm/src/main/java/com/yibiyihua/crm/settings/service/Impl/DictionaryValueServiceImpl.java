package com.yibiyihua.crm.settings.service.Impl;

import com.yibiyihua.crm.settings.bean.DictionaryValue;
import com.yibiyihua.crm.settings.mapper.DictionaryValueMapper;
import com.yibiyihua.crm.settings.service.DictionaryValueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/12 16:59
 * @description：字典值业务逻辑层实现类
 * @modified By：
 * @version: 1.0
 */
@Service
public class DictionaryValueServiceImpl implements DictionaryValueService {
    @Autowired
    private DictionaryValueMapper dictionaryValueMapper;

    /**
     * 根据字典类型查询字典值
     * @param typeCode
     * @return
     */
    @Override
    public List<DictionaryValue> queryDictionaryValueByTypeCode(String typeCode) {
        return dictionaryValueMapper.selectDictionaryValueByTypeCode(typeCode);
    }

    /**
     * 根据id查询字典值
     * @param id
     * @return
     */
    @Override
    public String queryDictionaryValueById(String id) {
        return dictionaryValueMapper.selectDictionaryValueById(id);
    }

    /**
     * 根据value和typeCode查询字典记录
     * @param value
     * @param typeCode
     * @return
     */
    @Override
    public DictionaryValue queryDictionaryByValueAndTypeCode(String value, String typeCode) {
        return dictionaryValueMapper.selectDictionaryByValueAndTypeCode(value,typeCode);
    }
}
