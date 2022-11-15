package com.yibiyihua.crm.workbench.service.Impl;

import com.yibiyihua.crm.workbench.bean.ContactsRemark;
import com.yibiyihua.crm.workbench.mapper.ContactsRemarkMapper;
import com.yibiyihua.crm.workbench.service.ContactsRemarkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/20 18:03
 * @description：联系人业务逻辑层实现类
 * @modified By：
 * @version: 1.0
 */
@Service
public class ContactsRemarkServiceImpl implements ContactsRemarkService {
    @Autowired
    private ContactsRemarkMapper contactsRemarkMapper;

    /**
     * 根据联系人id查询联系人备注
     * @param contactsId
     * @return
     */
    @Override
    public List<ContactsRemark> queryContactsRemarkByContactsId(String contactsId) {
        return contactsRemarkMapper.selectContactsRemarkByContactsId(contactsId);
    }

    /**
     * 保存创建的联系人备注
     * @param contactsRemark
     * @return
     */
    @Override
    public int saveCreateContactsRemark(ContactsRemark contactsRemark) {
        return contactsRemarkMapper.insertContactsRemark(contactsRemark);
    }

    /**
     * 根据id删除联系人备注
     * @param id
     * @return
     */
    @Override
    public int deleteContactsRemarkById(String id) {
        return contactsRemarkMapper.deleteContactsRemarkById(id);
    }

    /**
     * 根据id保存编辑的联系人备注
     * @param contactsRemark
     * @return
     */
    @Override
    public int saveEditContactsRemarkNoteContentById(ContactsRemark contactsRemark) {
        return contactsRemarkMapper.updateContactsRemarkById(contactsRemark);
    }
}
