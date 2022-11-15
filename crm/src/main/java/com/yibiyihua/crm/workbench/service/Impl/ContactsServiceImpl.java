package com.yibiyihua.crm.workbench.service.Impl;

import com.yibiyihua.crm.commons.utils.DateUtil;
import com.yibiyihua.crm.commons.utils.UUIDUtil;
import com.yibiyihua.crm.workbench.bean.Contacts;
import com.yibiyihua.crm.workbench.bean.Customer;
import com.yibiyihua.crm.workbench.mapper.ContactsMapper;
import com.yibiyihua.crm.workbench.mapper.CustomerMapper;
import com.yibiyihua.crm.workbench.service.ContactsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/19 16:57
 * @description：联系人业务逻辑层实体类
 * @modified By：
 * @version: 1.0
 */
@Service
public class ContactsServiceImpl implements ContactsService {
    @Autowired
    private ContactsMapper contactsMapper;
    @Autowired
    private CustomerMapper customerMapper;

    /**
     * 根据客户id查询联系人
     * @param customerId
     * @return
     */
    @Override
    public List<Contacts> queryContactsByCustomerId(String customerId) {
        return contactsMapper.selectContactsByCustomerId(customerId);
    }

    /**
     * 根据id删除联系人
     * @param id
     * @return
     */
    @Override
    public int deleteContactsById(String id) {
        return contactsMapper.deleteContactsById(id);
    }

    /**
     * 根据查询条件分页查询联系人
     * @param map
     * @return
     */
    @Override
    public List<Contacts> queryContactsByConditionForPage(Map<String, Object> map) {
        return contactsMapper.selectContactsByConditionForPage(map);
    }

    /**
     * 根据条件查询联系人总记录条数
     * @param map
     * @return
     */
    @Override
    public int queryCountByCondition(Map<String, Object> map) {
        return contactsMapper.selectCountByCondition(map);
    }

    /**
     * 根据ids删除联系人记录
     * @param ids
     * @return
     */
    @Override
    public int deleteContactsByIds(String[] ids) {
        return contactsMapper.deleteContactsByIds(ids);
    }

    /**
     * 保存创建的联系人
     * @param contacts
     * @return
     */
    @Override
    public int saveCreateContacts(Contacts contacts,String sessionUserId) {
        setCustomerId(contacts, sessionUserId);
        //添加联系人记录
        return contactsMapper.insertContacts(contacts);
    }

    /**
     * 根据id查询联系人信息
     * @param id
     * @return
     */
    @Override
    public Contacts queryContactsById(String id) {
        return contactsMapper.selectContactsById(id);
    }

    /**
     * 保存编辑的联系人信息
     * @param contacts
     * @param sessionUserId
     * @return
     */
    @Override
    public int saveEditContacts(Contacts contacts, String sessionUserId) {
        setCustomerId(contacts, sessionUserId);
        return contactsMapper.updateContactsById(contacts);
    }

    /**
     * 根据id查询联系人详细信息
     * @param id
     * @return
     */
    @Override
    public Contacts queryContactsForDetailByContactsId(String id) {
        return contactsMapper.selectContactsForDetailByContactsId(id);
    }

    /**
     * 根据名称模糊查询联系人
     * @param map
     * @return
     */
    @Override
    public List<Contacts> queryContactsByNameLike(Map<String,Object> map) {
        return contactsMapper.selectContactsByNameLike(map);
    }

    /**
     * 设置联系人客户id
     * @param contacts
     * @param sessionUserId
     */
    private void setCustomerId(Contacts contacts, String sessionUserId) {
        if (contacts.getCustomerId() != null && contacts.getCustomerId() != "") {
            String customerId = customerMapper.selectCustomerIdByName(contacts.getCustomerId());
            if (customerId == null || "".equals(customerId)) {//输入的客户是否存在
                //输入的客户不存在，创建新客户
                Customer customer = new Customer();
                customer.setId(UUIDUtil.uuidToStr());
                customer.setOwner(sessionUserId);
                customer.setName(contacts.getCustomerId());
                customer.setCreateBy(sessionUserId);
                customer.setCreateTime(DateUtil.parseDateToStr(new Date()));
                customerMapper.insertCustomer(customer);
                //将新创建的客户id保存至联系人信息中心
                contacts.setCustomerId(customer.getId());
            }else {
                //将查询到的客户id保存至联系人信息中
                contacts.setCustomerId(customerId);
            }
        }
    }
}
