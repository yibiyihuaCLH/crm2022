package com.yibiyihua.crm.workbench.mapper;

import com.yibiyihua.crm.workbench.bean.Customer;

import java.util.List;
import java.util.Map;

public interface CustomerMapper {
    /**
     * 添加客户
     * @param customer
     * @return
     */
    int insertCustomer(Customer customer);

    /**
     * 根据条件分页查询客户详细信息
     * @param map
     * @return
     */
    List<Customer> selectCustomerByConditionForPage (Map<String,Object> map);

    /**
     * 根据条件查询客户记录总条数
     * @param customer
     * @return
     */
    int selectCustomerCountByCondition(Customer customer);

    /**
     * 根据id查询客户详细信息
     * @param id
     * @return
     */
    Customer selectCustomerForDetailById(String id);

    /**
     * 根据id更新客户记录
     * @param customer
     * @return
     */
    int updateCustomerById(Customer customer);

    /**
     * 根据ids批量删除客户记录
     * @param ids
     * @return
     */
    int deleteCustomerByIds(String[] ids);

    /**
     * 根据id查询客户的信息
     * @param id
     * @return
     */
    Customer selectCustomerById(String id);

    /**
     * 模糊查询客户名称
     * @param name
     * @return
     */
    String[] selectCustomerNameByLike(String name);

    /**
     * 根据客户名称查询客户id
     * @param name
     * @return
     */
    String selectCustomerIdByName(String name);
}