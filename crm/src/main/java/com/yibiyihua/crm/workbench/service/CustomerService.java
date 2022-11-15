package com.yibiyihua.crm.workbench.service;

import com.yibiyihua.crm.workbench.bean.Customer;

import java.util.List;
import java.util.Map;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/18 13:04
 * @description：客户业务逻辑层接口
 * @modified By：
 * @version: 1.0
 */
public interface CustomerService {

    /**
     * 根据查询条件分页查询客户记录
     * @param map
     * @return
     */
    List<Customer> queryCustomerByConditionForPage(Map<String,Object> map);

    /**
     * 根据条件查询客户记录总条数
     * @param customer
     * @return
     */
    int queryCustomerCountByCondition(Customer customer);

    /**
     * 保存创建的客户记录
     * @param customer
     * @return
     */
    int saveCreateCustomer(Customer customer);

    /**
     * 根据id查询客户详细信息
     * @param id
     * @return
     */
    Customer queryCustomerForDetailById(String id);

    /**
     * 根据id保存编辑的客户记录
     * @param customer
     * @return
     */
    int saveEditCustomerById(Customer customer);

    /**
     * 根据ids批量删除客户记录
     * @param ids
     * @return
     */
    int deleteCustomerByIds(String[] ids) throws Exception;

    /**
     * 根据id查询客户的信息
     * @param id
     * @return
     */
    Customer queryCustomerById(String id);

    /**
     * 模糊查询客户名称
     * @param name
     * @return
     */
    String[] queryCustomerNameByLike(String name);
}
