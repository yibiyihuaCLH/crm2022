package com.yibiyihua.crm.workbench.service;

import com.yibiyihua.crm.workbench.bean.ContactsActivityRelation;

import java.util.List;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/21 10:49
 * @description：联系人、市场活动关联关系业务逻辑层接口
 * @modified By：
 * @version: 1.0
 */
public interface ContactsActivityRelationService {

    /**
     * 根据联系人id、市场活动id查询关联记录条数
     * @param contactsActivityRelation
     * @return
     */
    int queryRelationshipCountByContactsActivityId(ContactsActivityRelation contactsActivityRelation);

    /**
     * 添加联系人、市场活动关联记录
     * @param contactsActivityRelationList
     * @return
     */
    int addCreateContactsActivityRelation(List<ContactsActivityRelation> contactsActivityRelationList);

    /**
     * 根据联系人id、市场活动id解雇关联
     * @param contactsActivityRelation
     * @return
     */
    int deleteRelationshipByContactsActivityId(ContactsActivityRelation contactsActivityRelation);
}
