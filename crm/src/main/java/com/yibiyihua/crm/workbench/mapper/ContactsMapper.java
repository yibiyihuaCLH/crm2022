package com.yibiyihua.crm.workbench.mapper;

import com.yibiyihua.crm.workbench.bean.Contacts;

import java.util.List;
import java.util.Map;

public interface ContactsMapper {
    /**
     * 添加联系人
     * @param contacts
     * @return
     */
    int insertContacts(Contacts contacts);

    /**
     * 根据客户ids删除客户联系人
     * @param customerIds
     * @return
     */
    int deleteContactsByCustomerIds(String[] customerIds);

    /**
     * 根据客户id查询联系人
     * @param customerId
     * @return
     */
    List<Contacts> selectContactsByCustomerId(String customerId);

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
    List<Contacts> selectContactsByConditionForPage(Map<String, Object> map);

    /**
     * 根据条件查询联系人总记录条数
     * @param map
     * @return
     */
    int selectCountByCondition(Map<String, Object> map);

    /**
     * 根据ids删除联系人记录
     * @param ids
     * @return
     */
    int deleteContactsByIds(String[] ids);

    /**
     * 根据id查询联系人信息
     * @param id
     * @return
     */
    Contacts selectContactsById(String id);

    /**
     * 根据id更新联系人
     * @param contacts
     * @return
     */
    int updateContactsById(Contacts contacts);

    /**
     * 根据id查询联系人详细信息
     * @param id
     * @return
     */
    Contacts selectContactsForDetailByContactsId(String id);

    /**
     * 根据名称模糊查询联系人
     * @param map
     * @return
     */
    List<Contacts> selectContactsByNameLike(Map<String,Object> map);
}