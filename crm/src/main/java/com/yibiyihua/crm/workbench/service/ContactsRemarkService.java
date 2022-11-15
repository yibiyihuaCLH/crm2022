package com.yibiyihua.crm.workbench.service;

import com.yibiyihua.crm.workbench.bean.ContactsRemark;

import java.util.List;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/20 18:03
 * @description：联系人备注业务逻辑层接口
 * @modified By：
 * @version: 1.0
 */
public interface ContactsRemarkService {

    /**
     * 根据联系人id查询联系人备注
     * @param contactsId
     * @return
     */
    List<ContactsRemark> queryContactsRemarkByContactsId(String contactsId);

    /**
     * 保存创建的联系人备注
     * @param contactsRemark
     * @return
     */
    int saveCreateContactsRemark(ContactsRemark contactsRemark);

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
    int saveEditContactsRemarkNoteContentById(ContactsRemark contactsRemark);
}
