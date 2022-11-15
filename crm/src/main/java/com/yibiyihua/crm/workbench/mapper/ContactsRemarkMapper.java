package com.yibiyihua.crm.workbench.mapper;

import com.yibiyihua.crm.workbench.bean.ContactsRemark;

import java.util.List;

public interface ContactsRemarkMapper {
    /**
     * 批量添加联系人备注
     * @param contactsRemarkList
     * @return
     */
    int insertContactsRemarkByList(List<ContactsRemark> contactsRemarkList);

    /**
     * 根据联系人id查询联系人备注
     * @param contactsId
     * @return
     */
    List<ContactsRemark> selectContactsRemarkByContactsId(String contactsId);

    /**
     * 保存创建的联系人备注
     * @param contactsRemark
     * @return
     */
    int insertContactsRemark(ContactsRemark contactsRemark);

    /**
     * 根据id删除联系人备注
     * @param id
     * @return
     */
    int deleteContactsRemarkById(String id);

    /**
     * 根据id保存编辑的联系人备注
     * @param contactsRemark
     * @return
     */
    int updateContactsRemarkById(ContactsRemark contactsRemark);
}