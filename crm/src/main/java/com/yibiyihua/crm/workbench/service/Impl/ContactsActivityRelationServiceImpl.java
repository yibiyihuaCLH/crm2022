package com.yibiyihua.crm.workbench.service.Impl;

import com.yibiyihua.crm.workbench.bean.ContactsActivityRelation;
import com.yibiyihua.crm.workbench.mapper.ContactsActivityRelationMapper;
import com.yibiyihua.crm.workbench.service.ContactsActivityRelationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/21 10:50
 * @description：联系人、市场活动关联关系业务逻辑层实现类
 * @modified By：
 * @version: 1.0
 */
@Service
public class ContactsActivityRelationServiceImpl implements ContactsActivityRelationService {
    @Autowired
    private ContactsActivityRelationMapper contactsActivityRelationMapper;

    /**
     * 根据联系人id、市场活动id查询关联记录条数
     * @param contactsActivityRelation
     * @return
     */
    @Override
    public int queryRelationshipCountByContactsActivityId(ContactsActivityRelation contactsActivityRelation) {
        return contactsActivityRelationMapper.selectRelationshipCountByContactsActivityId(contactsActivityRelation);
    }

    /**
     * 添加联系人、市场活动关联记录
     * @param contactsActivityRelationList
     * @return
     */
    @Override
    public int addCreateContactsActivityRelation(List<ContactsActivityRelation> contactsActivityRelationList) {
        return contactsActivityRelationMapper.insertCreateContactsActivityRelation(contactsActivityRelationList);
    }

    /**
     * 根据联系人id、市场活动id解雇关联
     * @param contactsActivityRelation
     * @return
     */
    @Override
    public int deleteRelationshipByContactsActivityId(ContactsActivityRelation contactsActivityRelation) {
        return contactsActivityRelationMapper.deleteRelationshipByContactsActivityId(contactsActivityRelation);
    }


}
