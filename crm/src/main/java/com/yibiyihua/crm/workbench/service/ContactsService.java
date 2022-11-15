package com.yibiyihua.crm.workbench.service;

import com.yibiyihua.crm.workbench.bean.Contacts;

import java.util.List;
import java.util.Map;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/19 16:57
 * @description：联系人业务逻辑层接口
 * @modified By：
 * @version: 1.0
 */
public interface ContactsService {

    /**
     * 根据客户id查询联系人
     * @param customerId
     * @return
     */
    List<Contacts> queryContactsByCustomerId(String customerId);

    /**
     * 根据id删除联系人
     * @param id
     * @return
     */
    int deleteContactsById(String id);

    /**
     * 根据查询条件分页查询联系人
     * @param map
     * @return
     */
    List<Contacts> queryContactsByConditionForPage(Map<String, Object> map);

    /**
     * 根据条件查询联系人总记录条数
     * @param map
     * @return
     */
    int queryCountByCondition(Map<String, Object> map);

    /**
     * 根据ids删除联系人记录
     * @param ids
     * @return
     */
    int deleteContactsByIds(String[] ids);

    /**
     * 保存创建的联系人
     * @param contacts
     * @return
     */
    int saveCreateContacts(Contacts contacts,String sessionUserId);

    /**
     * 根据id查询联系人信息
     * @param id
     * @return
     */
    Contacts queryContactsById(String id);

    /**
     * 保存编辑的联系人信息
     * @param contacts
     * @param sessionUserId
     * @return
     */
    int saveEditContacts(Contacts contacts, String sessionUserId);

    /**
     * 根据id查询联系人详细信息
     * @param id
     * @return
     */
    Contacts queryContactsForDetailByContactsId(String id);

    /**
     * 根据名称模糊查询联系人
     * @param map
     * @return
     */
    List<Contacts> queryContactsByNameLike(Map<String,Object> map);
}
