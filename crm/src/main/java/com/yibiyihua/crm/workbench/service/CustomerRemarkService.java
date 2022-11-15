package com.yibiyihua.crm.workbench.service;

import com.yibiyihua.crm.workbench.bean.CustomerRemark;

import java.util.List;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/19 9:31
 * @description：客户备注业务逻辑层接口
 * @modified By：
 * @version: 1.0
 */
public interface CustomerRemarkService {

    /**
     * 根据客户id查询客户备注
     * @param customerId
     * @return
     */
    List<CustomerRemark> queryCustomerRemarkByCustomerId(String customerId);

    /**
     * 保存创建的客户备注
     * @param customerRemark
     * @return
     */
    int saveCreateCustomerRemark(CustomerRemark customerRemark);

    /**
     * 根据客户备注id删除客户备注
     * @param id
     * @return
     */
    int deleteCustomerRemarkById(String id);

    /**
     * 保存编辑的客户备注
     * @param customerRemark
     * @return
     */
    int saveEditCustomerRemark(CustomerRemark customerRemark);
}
