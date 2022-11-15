package com.yibiyihua.crm.workbench.mapper;

import com.yibiyihua.crm.workbench.bean.CustomerRemark;

import java.util.List;

public interface CustomerRemarkMapper {
    /**
     * 批量添加客户备注
     * @param customerRemarkList
     * @return
     */
    int insertCustomerRemarkList(List<CustomerRemark> customerRemarkList);

    /**
     * 根据客户ids删除客户备注
     * @param customerIds
     * @return
     */
    int deleteCustomerRemarkByCustomerIds(String[] customerIds);

    /**
     * 根据客户id查询客户备注
     * @param customerId
     * @return
     */
    List<CustomerRemark> selectCustomerRemarkByCustomerId(String customerId);

    /**
     * 添加客户备注
     * @param customerRemark
     * @return
     */
    int insertCustomerRemark(CustomerRemark customerRemark);

    /**
     * 根据客户备注id删除客户备注
     * @param id
     * @return
     */
    int deleteCustomerRemarkById(String id);

    /**
     * 根据id更行客户备注
     * @param customerRemark
     * @return
     */
    int updateCustomerRemarkById(CustomerRemark customerRemark);
}