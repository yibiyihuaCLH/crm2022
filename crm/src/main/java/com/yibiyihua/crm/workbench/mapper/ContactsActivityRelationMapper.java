package com.yibiyihua.crm.workbench.mapper;

import com.yibiyihua.crm.workbench.bean.ContactsActivityRelation;

import java.util.List;

public interface ContactsActivityRelationMapper {
    /**
     * 批量添加联系人、市场活动关联关系
     * @param contactsActivityRelationList
     * @return
     */
    int insertRelationByList(List<ContactsActivityRelation> contactsActivityRelationList);

    /**
     * 根据市场活动ids解除联系人、市场活动关联关系
     * @param activityIds
     * @return
     */
    int deleteRelationshipByActivityIds(String[] activityIds);

    /**
     * 根据联系人id、市场活动id查询关联记录条数
     * @param contactsActivityRelation
     * @return
     */
    int selectRelationshipCountByContactsActivityId(ContactsActivityRelation contactsActivityRelation);

    /**
     * 增加线索、市场活动关联记录
     * @param contactsActivityRelationList
     * @return
     */
    int insertCreateContactsActivityRelation(List<ContactsActivityRelation> contactsActivityRelationList);

    /**
     * 根据联系人id、市场活动id解雇关联
     * @param contactsActivityRelation
     * @return
     */
    int deleteRelationshipByContactsActivityId(ContactsActivityRelation contactsActivityRelation);
}